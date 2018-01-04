//
//  AdvanceSettingsViewController.swift
//  KickAss
//
//  Created by CIPL108-MOBILITY on 11/12/17.
//  Copyright © 2017 Self. All rights reserved.
//

import UIKit
import Charts

class AdvanceSettingsViewController: UIViewController {

    @IBOutlet weak var backToHomeScreenView: UIView!{
        didSet {
            let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(pushViewController(gestureRecognizer:)))
            backToHomeScreenView.addGestureRecognizer(tapRecognizer)
        }
    }
    @IBOutlet weak var lineChart: LineChartView!
    @IBOutlet weak var rightBinChart: LineChartView!
    @IBOutlet weak var voltageChart: LineChartView!
    @IBOutlet weak var motorLabel: UILabel!
    @IBOutlet weak var temperatureMetricView: UIView!
    @IBOutlet weak var FarenheatButton: UIButton!
    @IBOutlet weak var celciusButton: UIButton!
    @IBOutlet weak var deviceStatusLabel: UILabel!
    @IBOutlet weak var rightBinHeightConstraint: NSLayoutConstraint!
    
    private var tempArray : [String] = []
    private var leftBinArray : [Float] = []
    private var rightBinArray : [Float] = []
    private var voltageArray : [Float] = []
    private var tempCurveArray : [String] = []
 
    override func viewDidLayoutSubviews() {
        celciusButton.layer.cornerRadius = celciusButton.frame.height/2
        FarenheatButton.layer.cornerRadius = celciusButton.frame.height/2
        if Utility.shared.connectedDevice.fridgeType == FRIDGETYPE.single {
            rightBinHeightConstraint.constant = -(rightBinChart.frame.height)
            rightBinChart.isHidden = true
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        celciusButton.backgroundColor = UIColor.white
        FarenheatButton.backgroundColor = UIColor.white
        celciusButton.isSelected = false
        FarenheatButton.isSelected = false

        if Utility.shared.connectedDevice.tempUnit == TEMP_UNIT.celcius {
            celciusButton.backgroundColor = COLOR.green
            celciusButton.isSelected = true
        }
        else {
            FarenheatButton.backgroundColor = COLOR.green
            FarenheatButton.isSelected = true
        }
        
        setGrapProperties(array: [lineChart,rightBinChart,voltageChart])
        temperatureMetricView.layer.borderWidth = 7.0
        temperatureMetricView.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.5).cgColor
        temperatureMetricView.layer.cornerRadius = 5.0
        motorLabel.backgroundColor = UIColor.lightGray.withAlphaComponent(0.3)
        motorLabel.layer.cornerRadius = 5.0
        motorLabel.clipsToBounds = true
        celciusButton.layer.borderWidth = 5.0
        celciusButton.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.3).cgColor
        FarenheatButton.layer.borderWidth = 5.0
        FarenheatButton.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.3).cgColor

        MBProgressHUD.showAdded(to: self.view, animated: true,withText: "Fetching data, please wait for 30 secs...")
        Utility.shared.readTemperatureCurve(forViewController: self)
        
        NotificationCenter.default.addObserver(self, selector: #selector(HomeViewController.connectionChanged(_:)), name: NSNotification.Name(rawValue: BLEServiceChangedStatusNotification), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.deviceDetected(notification:)), name: NSNotification.Name(rawValue: BLEDeviceDetectedNotification), object: nil)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func connectionChanged(_ notification: Notification) {
        // Connection status changed. Indicate on GUI.
        let userInfo = (notification as NSNotification).userInfo as! [String: Bool]
        
        DispatchQueue.main.async(execute: {
            // Set image based on connection status
            if let isConnected: Bool = userInfo["isConnected"] {
                if isConnected {
                   
                    Utility.shared.readTemperatureCurve(forViewController: self)
                    self.deviceStatusLabel.text = "Device Connected"
                    Utility.shared.connectedDevice.isConnected = true
                } else {
                    self.deviceStatusLabel.text = "Device Disconnected"
                }
            }
        });
    }
    
    @IBAction func tempUnitButtonAction(_ sender: UIButton) {
        
        celciusButton.backgroundColor = UIColor.white
        FarenheatButton.backgroundColor = UIColor.white
        celciusButton.isSelected = false
        FarenheatButton.isSelected = false
        
        sender.backgroundColor = COLOR.green
        sender.isSelected = true
        
        Utility.shared.connectedDevice.tempUnitCode = sender == celciusButton ? "0" : "1"
        Utility.shared.writeValues()
    }
    
    func convertToCelsius(fahrenheit: Int) -> Int {
        return Int(5.0 / 9.0 * (Double(fahrenheit) - 32.0))
    }
    
    @objc func pushViewController(gestureRecognizer: UITapGestureRecognizer) {
       self.navigationController?.popViewController(animated: true)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
}

extension AdvanceSettingsViewController : didUpdateValueDelegate {
    
    func pheriperalValue(hexString: String) {
        
        DispatchQueue.main.async {
            
            print("TEMP CURVE : \(hexString)")
            
            self.tempCurveArray.append(hexString)
            
            if self.tempCurveArray.count == 48 {
                var trimmeredString = self.tempCurveArray[0]
                trimmeredString = trimmeredString.replacingOccurrences(of: "ff", with: "00")
                let hexArray = trimmeredString.formHexArr()
                self.split(hexArray: Array((Array(hexArray.dropLast(2))).dropFirst(10)))
            }
        }
    }
    
    func split(hexArray : [String]) {
        
        seperateTemperature(array: hexArray, onCompletion: {
            status in
            DispatchQueue.main.async {
                if status {
                    self.split(hexArray: Array(hexArray.dropFirst(4)))
                }
                else {
                    if self.tempCurveArray.count == 0 {
                        MBProgressHUD.hide(for: self.view, animated: true)
                        self.lineChart.data = self.formChartData(array: self.leftBinArray.reversed(), title:  Utility.shared.connectedDevice.fridgeType == FRIDGETYPE.single ? "SINGLE BIN" : "LEFT BIN")
                        self.rightBinChart.data = self.formChartData(array: self.rightBinArray.reversed(), title: "RIGHT BIN")
                        self.voltageChart.data = self.formChartData(array: self.voltageArray.reversed(), title: "VOLTAGE")
                    }
                    else {
                        var trimmeredString = self.tempCurveArray[0]
                        trimmeredString = trimmeredString.replacingOccurrences(of: "ff", with: "0")
                        let tempHexArray = trimmeredString.formHexArr()
                        self.split(hexArray: Array((Array(tempHexArray.dropLast(2))).dropFirst(10)))
                        self.tempCurveArray.remove(at: 0)
                    }
                }
            }
        })
    }
    
    func formChartData(array : [Float], title : String) -> LineChartData  {
        let values = (1...24*60).map { (i) -> ChartDataEntry in
            let val = Double(array[i-1])
            return ChartDataEntry(x: Double(i/60), y: val)
        }
        
        let set1 = LineChartDataSet(values: values, label: title)
        set1.drawIconsEnabled = false
        set1.setColor(.red)
        set1.setCircleColor(.black)
        set1.lineWidth = 1
        set1.circleRadius = 0
        set1.drawCircleHoleEnabled = false
        set1.valueFont = .systemFont(ofSize: 0)
        set1.formLineDashLengths = [5, 2.5]
        set1.formLineWidth = 1
        set1.formLineWidth = 15
        
        return LineChartData(dataSet: set1)
    }
    
    func setGrapProperties(array : [LineChartView]) {
        
        for lineChart in array {
            lineChart.chartDescription?.enabled = false
            lineChart.xAxis.avoidFirstLastClippingEnabled = true
            lineChart.leftAxis.spaceBottom = 0.0
            lineChart.xAxis.granularityEnabled = true
            lineChart.xAxis.granularity  = 1.0
            lineChart.xAxis.labelCount = 12
            lineChart.leftAxis.labelCount = 10
            lineChart.scaleYEnabled = false
            lineChart.leftAxis.axisMinimum =  -30
            lineChart.leftAxis.axisMaximum =  30
            lineChart.animate(xAxisDuration: 1.0, yAxisDuration: 1.0)
            lineChart.xAxis.labelPosition = .bottom
            lineChart.rightAxis.enabled=false
            lineChart.layer.borderWidth = 1.0
            lineChart.layer.borderColor = UIColor.gray.cgColor
            lineChart.layer.cornerRadius = 5.0
        }
    }
    
    func seperateTemperature(array : [String], onCompletion : (Bool) -> Void) {
        
        if array.count > 3 {
            
            let leftBinTemp = array[0].getTemperatureInCelcius()
            let rightBinTemp = array[1].getTemperatureInCelcius()

            leftBinArray.append(Float(leftBinTemp))
            rightBinArray.append(Float(rightBinTemp))
            voltageArray.append(Float("\(Int(array[2]) ?? 0).\(Int(array[3]) ?? 0)") ?? 0)
            onCompletion(true)
        }
        else {
            onCompletion(false)
        }
    }
    
}

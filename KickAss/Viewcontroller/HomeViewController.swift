//
//  HomeViewController.swift
//  KickAss
//
//  Created by CIPL108-MOBILITY on 10/11/17.
//  Copyright © 2017 Self. All rights reserved.
//

import UIKit
import CoreBluetooth
import Gifu

protocol didUpdateValueDelegate {
    func pheriperalValue(hexString : String)
}

class HomeViewController: UIViewController,UINavigationControllerDelegate {
    
    @IBOutlet weak var deviceStatusLabel: UILabel!
    @IBOutlet weak var powerButton: UIButton!
    @IBOutlet weak var connectButton: UIButton!
    @IBOutlet weak var fridgeNameTextFiled: UITextField!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var leftBinView: UIView!
    @IBOutlet weak var rightBinView: UIView!
    @IBOutlet weak var leftBinTempView: UIView!{
        didSet {
            let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(pushViewController(gestureRecognizer:)))
            leftBinTempView.addGestureRecognizer(tapRecognizer)
        }
    }
    @IBOutlet weak var rightBinTempView: UIView!{
        didSet {
            let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(pushViewController(gestureRecognizer:)))
            rightBinTempView.addGestureRecognizer(tapRecognizer)
        }
    }
    @IBOutlet weak var leftBinCurrentTemperature: UIView!
    @IBOutlet weak var leftBinCurrentTemperatureLabel: UILabel!
    @IBOutlet weak var rightBinCurrentTemperature: UIView!
    @IBOutlet weak var rightBinCurrentTemperatureLabel: UILabel!
    @IBOutlet weak var batteryProtectionView: UIView!
    @IBOutlet weak var voltageLabel: UILabel!
    @IBOutlet weak var coolingSpeedView: UIView!
    @IBOutlet weak var advancedSettingsView: UIView!
    @IBOutlet weak var singleFridgeView: UIView!
    @IBOutlet weak var fridgeHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var singleFridgeTempView: UIView!{
        didSet {
            let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(pushViewController(gestureRecognizer:)))
            singleFridgeTempView.addGestureRecognizer(tapRecognizer)
        }
    }
    @IBOutlet weak var leftBinUpButton: UIButton!
    @IBOutlet weak var leftBinDownButton: UIButton!
    @IBOutlet weak var rightBinUpButton: UIButton!
    @IBOutlet weak var rightBinDownButton: UIButton!
    @IBOutlet weak var singleFridgeDownButton: UIButton!
    @IBOutlet weak var singleFridgeUpButton: UIButton!
    @IBOutlet weak var singleBinTemplabel: UILabel!
    @IBOutlet weak var rightBinTempLabel: UILabel!
    @IBOutlet weak var leftBinTempLabel: UILabel!
    @IBOutlet weak var singleBinFanButton: UIButton!
    @IBOutlet weak var highLabel: UILabel!
    @IBOutlet weak var mediumLabel: UILabel!
    @IBOutlet weak var lowLabel: UILabel!
    @IBOutlet weak var quicklabel: UILabel!
    @IBOutlet weak var normalLabel: UILabel!
    @IBOutlet weak var econamyLabel: UILabel!
    @IBOutlet weak var binBaseView: UIView!
    @IBOutlet weak var leftBinImageView: GIFImageView!
    @IBOutlet weak var rightBinImageView: GIFImageView!
    @IBOutlet weak var appVersionLabel: UILabel!
    @IBOutlet weak var inputTextView: UITextView!
    
    //var autoRefreshTimer : Timer!
    
    override func viewDidLayoutSubviews() {
        
        clipLable(views: [batteryProtectionView,coolingSpeedView])
        singleFridgeView.frame.size = binBaseView.frame.size
        binBaseView.addSubview(singleFridgeView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if Utility.shared.connectedDevice.isConnected {
            DispatchQueue.main.async {
                //self.autoRefreshTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.update), userInfo: nil, repeats: true)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        appVersionLabel.text = "App version : \(Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") ?? "")"
        
        fridgeNameTextFiled.text = Utility.shared.connectedDevice.name
        
        if Utility.shared.connectedDevice.isSingleFridge {
            singleFridgeView.isHidden = false
            leftBinView.isHidden = true
            rightBinView.isHidden = true
            fridgeHeightConstraint.constant = -60
        }
        else {
            singleFridgeView.isHidden = true
            leftBinView.isHidden = false
            rightBinView.isHidden = false
            fridgeHeightConstraint.constant = 0
        }
        
        addBoder(views: [leftBinView,rightBinView,batteryProtectionView,coolingSpeedView,advancedSettingsView,singleFridgeView])
        
        singleFridgeTempView.layer.cornerRadius = 5
        singleFridgeTempView.backgroundColor = UIColor.lightGray.withAlphaComponent(0.5)
        leftBinTempView.layer.cornerRadius = 5
        leftBinTempView.backgroundColor = UIColor.lightGray.withAlphaComponent(0.5)
        rightBinTempView.layer.cornerRadius = 5
        rightBinTempView.backgroundColor = UIColor.lightGray.withAlphaComponent(0.5)
        voltageLabel.layer.cornerRadius = 5
        voltageLabel.backgroundColor = UIColor.lightGray.withAlphaComponent(0.5)
        voltageLabel.clipsToBounds = true
        leftBinCurrentTemperature.layer.cornerRadius = 5
        leftBinCurrentTemperature.backgroundColor = UIColor.lightGray.withAlphaComponent(0.7)
        leftBinCurrentTemperature.layer.borderWidth = 3
        leftBinCurrentTemperature.layer.borderColor = UIColor.lightGray.cgColor
        rightBinCurrentTemperature.layer.cornerRadius = 5
        rightBinCurrentTemperature.backgroundColor = UIColor.lightGray.withAlphaComponent(0.7)
        rightBinCurrentTemperature.layer.borderWidth = 3
        rightBinCurrentTemperature.layer.borderColor = UIColor.lightGray.cgColor
        
        NotificationCenter.default.addObserver(self, selector: #selector(HomeViewController.connectionChanged(_:)), name: NSNotification.Name(rawValue: BLEServiceChangedStatusNotification), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.deviceDetected(notification:)), name: NSNotification.Name(rawValue: BLEDeviceDetectedNotification), object: nil)
        
        setValues()
        update()
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Notification Observer Methods
    
    @objc func deviceDetected(notification : NSNotification) {
        
        let name: String = (notification.object as! CBPeripheral).name!
        
        if let device = Utility.shared.connectedDevice {
            if name == device.name {
                if let bleService = btDiscoverySharedInstance.cManager {
                    bleService.connect((notification.object as! CBPeripheral), options: nil)
                }
            }
        }
    }
    
    @objc func connectionChanged(_ notification: Notification) {
        
        let userInfo = (notification as NSNotification).userInfo as! [String: Bool]
        
        DispatchQueue.main.async(execute: {
            
            if let isConnected: Bool = userInfo["isConnected"] {
                if isConnected {
                    Utility.shared.connectedDevice.isConnected = true
                    Utility.shared.readValues(forViewController: self)
                    self.deviceStatusLabel.text = "Device Connected"
                  //  self.autoRefreshTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.update), userInfo: nil, repeats: true)
                } else {
                    self.deviceStatusLabel.text = "Device Disconnected"
                   // if self.autoRefreshTimer != nil {
                   //     self.autoRefreshTimer.invalidate()
                   //     self.autoRefreshTimer = nil
                    //}
                }
            }
        });
    }
    
    // MARK: - Custom methods
    
    func setBatteryProtection() {
        
        Utility.shared.connectedDevice.setBatteryProtectionLevel()
        
        let button = UIButton()
        button.tag = 67
        switchBatteryButtonAction(button)
    }
    
    func setCoolingSpeed() {
        
        Utility.shared.connectedDevice.setCoolingSpeedLevel()
        
        let button = UIButton()
        button.tag = 67
        coolingSwitchButtonAction(button)
    }
    
    // MARK: - UI Updates
    
    func addBoder(views : [UIView]) {
        
        for view in views {
            view.layer.borderWidth = 3
            view.layer.borderColor = UIColor.lightGray.cgColor
            view.layer.cornerRadius = 5
        }
    }
    
    func clipLable (views : [UIView]) {
        for view in views {
            for case let label as UILabel in view.subviews {
                if label.tag == 50 {
                    label.layer.cornerRadius = label.frame.height/2
                    label.clipsToBounds = true
                }
            }
        }
    }
    
    func setValues() {
        
        self.rightBinCurrentTemperatureLabel.text = Utility.shared.connectedDevice.getRightBinCurrentTemp()
        self.leftBinCurrentTemperatureLabel.text = Utility.shared.connectedDevice.getLeftBinCurrentTemp()
        self.rightBinTempLabel.text = Utility.shared.connectedDevice.getRightBinTemp()
        self.leftBinTempLabel.text = Utility.shared.connectedDevice.getLeftBinTemp()
        self.voltageLabel.text = Utility.shared.connectedDevice.voltage
        
        if Utility.shared.connectedDevice.onOffCode == "00" {
            powerButton.isSelected = false
            rightBinImageView.image = Fan.red
            leftBinImageView.image = Fan.red
            leftBinImageView.stopAnimatingGIF()
            rightBinImageView.stopAnimatingGIF()
        }
        else {
            self.powerButton.isSelected = true
            
            if !leftBinImageView.isAnimatingGIF {
                leftBinImageView.animate(withGIFNamed: "fan_2")
                rightBinImageView.animate(withGIFNamed: "fan_2")
            }
            
            if Utility.shared.connectedDevice.onOffCode == "10"{
                rightBinImageView.image = Fan.green
                leftBinImageView.image = Fan.green
                leftBinImageView.stopAnimatingGIF()
                rightBinImageView.stopAnimatingGIF()
            }
            else if !self.leftBinImageView.isAnimating {
                leftBinImageView.startAnimatingGIF()
                rightBinImageView.startAnimatingGIF()
            }
        }
        
        setBatteryProtection()
        setCoolingSpeed()
    }
    
    // MARK: - Timer method
    
    @objc func update() {
        Utility.shared.readValues(forViewController: self)
    }
    
    // MARK: - Alert methods
    
    func turnOffBin( onCompletion : @escaping (Bool) -> Void) {
        let actionSheet: UIAlertController = UIAlertController(title: "", message: "Do you want to Turn Off ?", preferredStyle: .actionSheet)
        
        let cancelActionButton: UIAlertAction = UIAlertAction(title: "Cancel", style: .cancel) { action -> Void in
            onCompletion(false)
        }
        
        let disconnectActionButton: UIAlertAction = UIAlertAction(title: "Turn Off", style: .destructive) { action -> Void in
            onCompletion(true)
        }
        
        actionSheet.addAction(cancelActionButton)
        actionSheet.addAction(disconnectActionButton)
        
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    func disconnectDevice( onCompletion : @escaping (Bool) -> Void) {
        let actionSheet: UIAlertController = UIAlertController(title: "", message: "Do you want to Disconnect ?", preferredStyle: .actionSheet)
        
        let cancelActionButton: UIAlertAction = UIAlertAction(title: "Cancel", style: .cancel) { action -> Void in
            onCompletion(false)
        }
        
        let disconnectActionButton: UIAlertAction = UIAlertAction(title: "Disconnect", style: .destructive) { action -> Void in
            onCompletion(true)
        }
        
        actionSheet.addAction(cancelActionButton)
        actionSheet.addAction(disconnectActionButton)
        
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    // MARK : Gesture methods
    
    @objc func pushViewController(gestureRecognizer: UITapGestureRecognizer) {
        
        if gestureRecognizer.view == leftBinTempView {
            
            if leftBinImageView.image == Fan.red {
                self.leftBinImageView.image = Fan.green
                leftBinImageView.startAnimatingGIF()
                leftBinTempLabel.text = Utility.shared.connectedDevice.getLeftBinTemp()
            }
            else {
                turnOffBin(onCompletion: {status in
                    DispatchQueue.main.async {
                        if status {
                            self.leftBinImageView.image = Fan.red
                            self.leftBinImageView.stopAnimatingGIF()
                            self.leftBinTempLabel.text = "OFF"
                        }
                    }
                })
            }
        }
        else if gestureRecognizer.view == rightBinTempView {
            if rightBinImageView.image == Fan.red {
                self.leftBinImageView.image = Fan.green
                rightBinImageView.startAnimatingGIF()
                rightBinTempLabel.text = Utility.shared.connectedDevice.getRightBinTemp()
            }
            else {
                turnOffBin(onCompletion: {status in
                    DispatchQueue.main.async {
                        if status {
                            self.rightBinImageView.image = Fan.red
                            self.rightBinImageView.stopAnimatingGIF()
                            self.rightBinTempLabel.text = "OFF"
                        }
                    }
                })
            }
        }
        else if gestureRecognizer.view == singleFridgeTempView {
            if singleBinFanButton.isSelected {
                singleBinFanButton.isSelected = false
                singleBinTemplabel.text = "\(Utility.shared.connectedDevice.singleBinTemp)C"
            }
            else {
                turnOffBin(onCompletion: {status in
                    DispatchQueue.main.async {
                        if status {
                            self.singleBinFanButton.isSelected = true
                            self.singleBinTemplabel.text = "OFF"
                        }
                    }
                })
            }
        }
    }
    
    // MARK: - IBAction
    
    @IBAction func userManualButtonAction(_ sender: UIButton) {
       Utility.shared.setFridgeType()
    }
    
    @IBAction func powerButton(_ sender: UIButton) {
        
        if sender.isSelected {
            Utility.shared.connectedDevice.onOffCode = "00"
            sender.isSelected = false
        }
        else {
            Utility.shared.connectedDevice.onOffCode = "01"
            sender.isSelected = true
        }
        
        Utility.shared.writeValues()
    }
    
    @IBAction func editButtonAction(_ sender: UIButton) {
        
        if sender.isSelected {
            fridgeNameTextFiled.resignFirstResponder()
            fridgeNameTextFiled.isUserInteractionEnabled = false
            sender.isSelected = false
        }
        else {
            fridgeNameTextFiled.isUserInteractionEnabled = true
            fridgeNameTextFiled.becomeFirstResponder()
            sender.isSelected = true
        }
    }
    
    @IBAction func connectButtonAction(_ sender: Any) {
        disconnectDevice(onCompletion: {
            status in
            DispatchQueue.main.async {
                if status {
                    if let bleService = btDiscoverySharedInstance.cManager {
                    Utility.shared.removePeripheral()
                    Utility.shared.connectedDevice.name = ""
                  //  if self.autoRefreshTimer != nil {
                  //      self.autoRefreshTimer.invalidate()
                 //       self.autoRefreshTimer = nil
                   // }
                    bleService.cancelPeripheralConnection(Utility.shared.connectedPeripheral)
                        self.navigationController?.popViewController(animated: true)
                    }
                }
            }
        })
    }
    
    @IBAction func tempControlButtonAction(_ sender: UIButton) {
        
        if sender == leftBinDownButton && leftBinImageView.image != Fan.red {
            
            if  Utility.shared.connectedDevice.leftBinTemp == FRIDGE.minimumTemp {
                return
            }
            Utility.shared.connectedDevice.leftBinTemp = Utility.shared.connectedDevice.leftBinTemp - 1
            leftBinTempLabel.text = Utility.shared.connectedDevice.getLeftBinTemp()
        }
        else if sender == leftBinUpButton && leftBinImageView.image != Fan.red {
            
            if Utility.shared.connectedDevice.leftBinTemp == FRIDGE.maximumTemp {
                return
            }
            Utility.shared.connectedDevice.leftBinTemp = Utility.shared.connectedDevice.leftBinTemp + 1
            leftBinTempLabel.text = Utility.shared.connectedDevice.getLeftBinTemp()
        }
        else if sender == rightBinDownButton && rightBinImageView.image != Fan.red {
            
            if Utility.shared.connectedDevice.rightBinTemp == FRIDGE.minimumTemp {
                return
            }
            Utility.shared.connectedDevice.rightBinTemp = Utility.shared.connectedDevice.rightBinTemp - 1
            rightBinTempLabel.text = Utility.shared.connectedDevice.getRightBinTemp()
        }
        else if sender == rightBinUpButton && rightBinImageView.image != Fan.red {
            
            if Utility.shared.connectedDevice.rightBinTemp == FRIDGE.maximumTemp {
                return
            }
            Utility.shared.connectedDevice.rightBinTemp = Utility.shared.connectedDevice.rightBinTemp + 1
            rightBinTempLabel.text = Utility.shared.connectedDevice.getRightBinTemp()
        }
        else if sender == singleFridgeDownButton && !singleBinFanButton.isSelected {
            
            if Utility.shared.connectedDevice.singleBinTemp == FRIDGE.minimumTemp {
                return
            }
            Utility.shared.connectedDevice.singleBinTemp = Utility.shared.connectedDevice.singleBinTemp - 1
            singleBinTemplabel.text = "\(Utility.shared.connectedDevice.singleBinTemp)"
        }
        else if sender == singleFridgeUpButton && !singleBinFanButton.isSelected {
            
            if Utility.shared.connectedDevice.singleBinTemp == FRIDGE.maximumTemp {
                return
            }
            Utility.shared.connectedDevice.singleBinTemp = Utility.shared.connectedDevice.singleBinTemp + 1
            singleBinTemplabel.text = "\(Utility.shared.connectedDevice.singleBinTemp)"
        }
        
        Utility.shared.writeValues()
        inputTextView.text = "CHECK WORD CALCULATION : \(Utility.shared.connectedDevice.formWriteHexString().1)\n\nTEMP CHANGE : \(Utility.shared.connectedDevice.formWriteHexString().0)"
    }
    
    
    @IBAction func refreshDataAction(_ sender: UIButton) {
        
    }
    
    @IBAction func switchBatteryButtonAction(_ sender: Any) {
        
        if !powerButton.isSelected {
            return
        }
        
        Utility.shared.connectedDevice.batteryProtectionLeval = Utility.shared.connectedDevice.batteryProtectionLeval + 1
        
        if Utility.shared.connectedDevice.batteryProtectionLeval >= 4 {
            Utility.shared.connectedDevice.batteryProtectionLeval = 1
        }
        
        switch Utility.shared.connectedDevice.batteryProtectionLeval {
        case 1:
            highLabel.backgroundColor = UIColor.lightGray
            mediumLabel.backgroundColor = UIColor.lightGray
            lowLabel.backgroundColor = COLOR.green
            Utility.shared.connectedDevice.voltageCode = "00"
        case 2:
            highLabel.backgroundColor = UIColor.lightGray
            mediumLabel.backgroundColor = COLOR.green
            lowLabel.backgroundColor = UIColor.lightGray
            Utility.shared.connectedDevice.voltageCode = "01"
        case 3:
            highLabel.backgroundColor = COLOR.green
            mediumLabel.backgroundColor = UIColor.lightGray
            lowLabel.backgroundColor = UIColor.lightGray
            Utility.shared.connectedDevice.voltageCode = "10"
            
        default: break
        }
        
        if (sender as! UIButton).tag != 67 {
            Utility.shared.writeValues()
            inputTextView.text = "\nBATTERY PROTECTION CHANGE : \(Utility.shared.connectedDevice.formWriteHexString().0)"
        }
    }
    
    @IBAction func coolingSwitchButtonAction(_ sender: Any) {
        
        if !powerButton.isSelected {
            return
        }
        
        Utility.shared.connectedDevice.coolingSpeed = Utility.shared.connectedDevice.coolingSpeed + 1
        
        if Utility.shared.connectedDevice.coolingSpeed >= 4 {
            Utility.shared.connectedDevice.coolingSpeed = 1
        }
        
        switch Utility.shared.connectedDevice.coolingSpeed {
        case 1:
            quicklabel.backgroundColor = COLOR.green
            normalLabel.backgroundColor = UIColor.lightGray
            econamyLabel.backgroundColor = UIColor.lightGray
            Utility.shared.connectedDevice.compressorCode = "10"
        case 2:
            quicklabel.backgroundColor = UIColor.lightGray
            normalLabel.backgroundColor = COLOR.green
            econamyLabel.backgroundColor = UIColor.lightGray
            Utility.shared.connectedDevice.compressorCode = "01"
        case 3:
            quicklabel.backgroundColor = UIColor.lightGray
            normalLabel.backgroundColor = UIColor.lightGray
            econamyLabel.backgroundColor = COLOR.green
            Utility.shared.connectedDevice.compressorCode = "00"
        default: break
        }
        
        if (sender as! UIButton).tag != 67 {
            Utility.shared.writeValues()
            inputTextView.text = "\nCOOLING SPEED CHANGE : \(Utility.shared.connectedDevice.formWriteHexString().0)"
        }
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        DispatchQueue.main.async {
           // if self.autoRefreshTimer != nil {
            //    self.autoRefreshTimer.invalidate()
            //    self.autoRefreshTimer = nil
          //  }
        }
    }
}

extension HomeViewController : didUpdateValueDelegate {
    
    func pheriperalValue(hexString: String) {
        
        DispatchQueue.main.async {
            
            self.inputTextView.text = "\(self.inputTextView.text!)\n\nDATA RETURNED BY FRIDGE:\(hexString)"
            
            let hexArray = hexString.formHexArr()
            
            if hexArray[8] != "9b" && hexArray[8] != "9a" {
                
                Utility.shared.connectedDevice.rightBinCurrentTemp = hexArray[9].getTemperatureInCelcius()
                Utility.shared.connectedDevice.leftBinCurrentTemp = hexArray[10].getTemperatureInCelcius()
                Utility.shared.connectedDevice.rightBinTemp = hexArray[11].getTemperatureInCelcius()
                Utility.shared.connectedDevice.leftBinTemp = hexArray[12].getTemperatureInCelcius()
                Utility.shared.connectedDevice.voltage = "\(hexArray[13]).\(hexArray[14])V"
                Utility.shared.connectedDevice.splitAndSaveDeviceParameter(value: hexArray[15])
                
                self.setValues()
            }
        }
    }
}

extension UIColor {
    
    convenience init(hex: UInt32, alpha: CGFloat) {
        let red = CGFloat((hex & 0xFF0000) >> 16)/256.0
        let green = CGFloat((hex & 0xFF00) >> 8)/256.0
        let blue = CGFloat(hex & 0xFF)/256.0
        
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
}

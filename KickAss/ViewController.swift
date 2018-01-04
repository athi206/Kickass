//
//  ViewController.swift
//  KickAss
//
//  Created by CIPL108-MOBILITY on 10/11/17.
//  Copyright © 2017 Self. All rights reserved.
//

import UIKit
import CoreBluetooth

protocol deviceAddedToListDelegate {
    func deviceAdded()
}

class ViewController: UIViewController {

    @IBOutlet weak var deviceListTableview: UITableView!
   
    var bleManager : BLEManager!
    
    
    override func viewWillAppear(_ animated: Bool) {
        // Start the Bluetooth discovery process
        deviceListTableview.reloadData()
        _ = btDiscoverySharedInstance
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
       // bleManager = BLEManager.defa
        
        Utility.shared.delegate = self

        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.deviceDetected(notification:)), name: NSNotification.Name(rawValue: BLEDeviceDetectedNotification), object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(HomeViewController.connectionChanged(_:)), name: NSNotification.Name(rawValue: BLEServiceChangedStatusNotification), object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Notification Observer Methods
    
    @objc func deviceDetected(notification : NSNotification) {
        
        Utility.shared.addPeripheral(peripheral: (notification.object as! CBPeripheral))
    }
    
    @objc func connectionChanged(_ notification: Notification) {
        let userInfo = (notification as NSNotification).userInfo as! [String: Bool]
        
        DispatchQueue.main.async(execute: {
            if let isConnected: Bool = userInfo["isConnected"] {
                
                let device = Device()
                
                if isConnected {
                    device.isConnected = true
                    device.name = Utility.shared.connectedPeripheral.name!
                    device.addressCode = String(Utility.shared.connectedPeripheral.name!.suffix(4))
                    Utility.shared.connectedDevice = device
                    Utility.shared.readValues(forViewController: self)
                } else {
                }
            }
        });
    }
}

extension ViewController : didUpdateValueDelegate {
    
    // MARK: - BLE Response delegate
    
    func pheriperalValue(hexString: String) {
        
        DispatchQueue.main.async {
            
            let hexArray = hexString.formHexArr()
            
            if hexArray[8] != "9b" && hexArray[8] != "9a" {
                
                Utility.shared.connectedDevice.fridgeType = hexArray[2]
                Utility.shared.connectedDevice.rightBinCurrentTemp = hexArray[9].getTemperatureInCelcius()
                Utility.shared.connectedDevice.leftBinCurrentTemp = hexArray[10].getTemperatureInCelcius()
                Utility.shared.connectedDevice.rightBinTemp = hexArray[11].getTemperatureInCelcius()
                Utility.shared.connectedDevice.leftBinTemp = hexArray[12].getTemperatureInCelcius()
                Utility.shared.connectedDevice.voltage = "\(hexArray[13].hexToDecimalValue()).\(hexArray[14].hexToDecimalValue())V"
                Utility.shared.connectedDevice.splitAndSaveDeviceParameter(value: hexArray[15])
                
                let vc = Utility.shared.viewControllerWithName(identifier: StoryBoard.HomeViewControllerIdentifier) as? HomeViewController
                
                self.navigationController?.pushViewController(vc!, animated: true)
            }
        }
    }
}

extension ViewController : deviceAddedToListDelegate {
    
    func deviceAdded() {
        DispatchQueue.main.async {
            self.deviceListTableview.reloadData()
        }
    }
}

extension ViewController : UITableViewDelegate, UITableViewDataSource {
   
    // MARK: - Tableview delegate
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return Utility.shared.peripheralArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell : FridgeListTableViewCell = tableView.dequeueReusableCell(withIdentifier: "fridgeCell", for: indexPath) as! FridgeListTableViewCell
        
        let device = Utility.shared.peripheralArray[indexPath.row]
        
        cell.fridgeNamelabel.text = device.name
       
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let bleService = btDiscoverySharedInstance.cManager {
            bleService.connect(Utility.shared.peripheralArray[indexPath.row], options: nil)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
}


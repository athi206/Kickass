//
//  Utility.swift
//  KickAss
//
//  Created by CIPL108-MOBILITY on 10/11/17.
//  Copyright © 2017 Self. All rights reserved.
//

import UIKit
import CoreBluetooth

class Utility: NSObject {

    static let shared = Utility()
    
    var connectedPeripheral : CBPeripheral!
    var connectedDevice : Device!
    var isReadingTemperatureCurve = false
    var peripheralArray : [CBPeripheral] = []
    var delegate : deviceAddedToListDelegate?
    
    //MARK: - Peripheral

    func addPeripheral(peripheral : CBPeripheral) {
        
        var name: String = peripheral.name!
        
        if name.count > 4 {
            let endIndex = name.index(name.endIndex, offsetBy: -4)
            name = name.substring(to: endIndex)
            if !peripheralArray.map({$0.identifier}).contains(peripheral.identifier) && name.uppercased() == "JINSONG" {
                peripheralArray.append(peripheral)
                delegate?.deviceAdded()
            }
        }
    }
    
    func removePeripheral() {
        
        if let index = peripheralArray.index(of: connectedPeripheral) {
        peripheralArray.remove(at: index)
        }
    }
    
    //MARK: - Controller
    
    func getCurrentController() -> UIViewController? {
        
        let rootViewController = UIApplication.shared.windows.first?.rootViewController
        
        if let presented = rootViewController?.presentedViewController {
            return presented
        }
        else if rootViewController is UINavigationController {
            return (rootViewController as? UINavigationController)?.viewControllers.last
        }
        
        return (UIApplication.shared.windows.first?.rootViewController as? UINavigationController)?.viewControllers.last
    }
    
    func viewControllerWithName(identifier: String) ->UIViewController {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        return storyboard.instantiateViewController(withIdentifier: identifier)
    }
    
    //MARK: - BLE Connection
    
    func readValues(forViewController controller:UIViewController) {
        if let bleService = btDiscoverySharedInstance.bleService {
            isReadingTemperatureCurve = false
            bleService.writePosition(hexString: connectedDevice.formReadHexString())
            bleService.delegate = controller as? didUpdateValueDelegate
        }
    }
    
    func readTemperatureCurve(forViewController controller:UIViewController) {
        if let bleService = btDiscoverySharedInstance.bleService {
            isReadingTemperatureCurve = true
            bleService.writePosition(hexString: connectedDevice.formReadTempCurveHexString())
            bleService.delegate = controller as? didUpdateValueDelegate
        }
    }
    
    func writeValues() {
        if let bleService = btDiscoverySharedInstance.bleService {
            bleService.writePosition(hexString: connectedDevice.formWriteHexString().0)
        }
    }
    
    func setFridgeType() {
        if let bleService = btDiscoverySharedInstance.bleService {
            bleService.writePosition(hexString: connectedDevice.formSetRefregiratorTypeHexString())
        }
    }
}

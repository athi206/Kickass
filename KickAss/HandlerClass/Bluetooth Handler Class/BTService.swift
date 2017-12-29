//
//  BTService.swift
//  Arduino_Servo
//
//  Created by Owen L Brown on 10/11/14.
//  Copyright (c) 2014 Razeware LLC. All rights reserved.
//

import Foundation
import CoreBluetooth

/* Services & Characteristics UUIDs */
let BLEServiceUUID = CBUUID(string: "FFE0")
let PositionCharUUID = CBUUID(string: "FFE1")
let BLEServiceChangedStatusNotification = "kBLEServiceChangedStatusNotification"
let BLEDeviceDetectedNotification = "kBLEDeviceDetectedNotification"

class BTService: NSObject, CBPeripheralDelegate {
    
  var peripheral: CBPeripheral?
  var positionCharacteristic: CBCharacteristic?
    var delegate : didUpdateValueDelegate?
    
    var stri = ""
    
  init(initWithPeripheral peripheral: CBPeripheral) {
    super.init()
    
    self.peripheral = peripheral
    self.peripheral?.delegate = self
  }
  
  deinit {
    self.reset()
  }
  
  func startDiscoveringServices() {
    self.peripheral?.discoverServices(nil)
  }
  
  func reset() {
    if peripheral != nil {
      peripheral = nil
    }
    
    // Deallocating therefore send notification
    self.sendBTServiceNotificationWithIsBluetoothConnected(false)
  }
  
  // Mark: - CBPeripheralDelegate
  
  func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
    let uuidsForBTService: [CBUUID] = [PositionCharUUID]
    
    if (peripheral != self.peripheral) {
      // Wrong Peripheral
      return
    }
    
    if (error != nil) {
      return
    }
    
    if ((peripheral.services == nil) || (peripheral.services!.count == 0)) {
      // No Services
      return
    }
    
    for service in peripheral.services! {
      if service.uuid == BLEServiceUUID {
        peripheral.discoverCharacteristics([], for: service)
      }
    }
  }
  
  func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
    if (peripheral != self.peripheral) {
      // Wrong Peripheral
      return
    }
    
    if (error != nil) {
      return
    }
    
    if let characteristics = service.characteristics {
      for characteristic in characteristics {
        
        print("CHARECTERISTICS : \(characteristic.value?.hexadecimal() ?? "")")

       
             if characteristic.uuid == PositionCharUUID {
                self.positionCharacteristic = (characteristic)
                peripheral.setNotifyValue(true, for: characteristic)
                peripheral.readValue(for: characteristic)
                self.sendBTServiceNotificationWithIsBluetoothConnected(true)
            }
        
      }
    }
  }
  
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        
        if characteristic.uuid == PositionCharUUID {
            
            guard let hexString = characteristic.value?.hexadecimal() else {
                return
            }
            
            print(hexString)
            
            if Utility.shared.isReadingTemperatureCurve {
               
                if hexString.prefix(2) == "68" {
                    stri = ""
                }
                
                stri = stri + hexString
                
                if hexString.suffix(2) == "ec" {
                    delegate?.pheriperalValue(hexString: stri)
                }
            }
            else {
                if hexString.count > 10 && hexString.count <= 40 {
                    delegate?.pheriperalValue(hexString: hexString)
                }
            }
        }
    }
    
  // Mark: - Private
  
    func writePosition(hexString : String) {
    // See if characteristic has been discovered before writing to it
    if let positionCharacteristic = self.positionCharacteristic {
        
        //let sd = "68 11 00 00 08 74 12 01 0B 00 00 35 33 00 00 09 01 13 EC"
        
        print("Input : \(hexString)")
        
        let hex = hexString.replacingOccurrences(of: " ", with: "")
        let data = hex.hexadecimal()
        
        self.peripheral?.writeValue(data!, for: positionCharacteristic, type: CBCharacteristicWriteType.withResponse)
    }
  }
  
  func sendBTServiceNotificationWithIsBluetoothConnected(_ isBluetoothConnected: Bool) {
    let connectionDetails = ["isConnected": isBluetoothConnected]
    NotificationCenter.default.post(name: Notification.Name(rawValue: BLEServiceChangedStatusNotification), object: self, userInfo: connectionDetails)
  }
}


extension String {
    
    /// Create `Data` from hexadecimal string representation
    ///
    /// This takes a hexadecimal representation and creates a `Data` object. Note, if the string has any spaces or non-hex characters (e.g. starts with '<' and with a '>'), those are ignored and only hex characters are processed.
    ///
    /// - returns: Data represented by this hexadecimal string.
    
    func hexadecimal() -> Data? {
        var data = Data(capacity: characters.count / 2)
        
        let regex = try! NSRegularExpression(pattern: "[0-9a-f]{1,2}", options: .caseInsensitive)
        regex.enumerateMatches(in: self, range: NSMakeRange(0, utf16.count)) { match, flags, stop in
            let byteString = (self as NSString).substring(with: match!.range)
            var num = UInt8(byteString, radix: 16)!
            data.append(&num, count: 1)
        }
        
        guard data.count > 0 else { return nil }
        
        return data
    }
    
}

extension Data {
    
    /// Create hexadecimal string representation of `Data` object.
    ///
    /// - returns: `String` representation of this `Data` object.
    
    func hexadecimal() -> String {
        return map { String(format: "%02x", $0) }
            .joined(separator: "")
    }
}

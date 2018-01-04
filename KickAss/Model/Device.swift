//
//  Device.swift
//  KickAss
//
//  Created by CIPL108-MOBILITY on 12/12/17.
//  Copyright © 2017 Self. All rights reserved.
//

import UIKit

class Device {

    var leftBinTemp : Int
    var rightBinTemp : Int
    var leftBinCurrentTemp : Int
    var rightBinCurrentTemp : Int
    var batteryProtectionLeval : Int
    var coolingSpeed : Int
    var name : String
    var dataContent : String
    var voltageCode : String
    var tempUnitCode : String
    var onOffCode : String
    var compressorCode : String
    var spareCode : String
    var addressCode : String
    var tempUnit : String
    var isConnected : Bool
    var voltage : String
    var fridgeType : String
    var leftBinOn : Bool
    var rightBinOn : Bool
    
    init() {
        self.leftBinTemp = 0
        self.rightBinTemp = 0
        self.leftBinCurrentTemp = 0
        self.rightBinCurrentTemp = 0
        self.batteryProtectionLeval = 0
        self.coolingSpeed = 0
        self.name = ""
        self.dataContent = ""
        self.voltageCode = ""
        self.tempUnitCode = ""
        self.onOffCode = ""
        self.compressorCode = ""
        self.spareCode = "0"
        self.addressCode = ""
        self.tempUnit = ""
        self.isConnected = false
        self.voltage = ""
        self.fridgeType = ""
        self.leftBinOn = false
        self.rightBinOn = false
    }
}

extension Device {
    
    func formReadHexString() -> String {
        
        return "68 09 FF FF FF 74 12 01 0A 97 EC"
    }
    
    func formSetFridgeTypeHexString() -> String {
        return "68 09 FF FF FF 74 12 01 0E 01 9B EC "
    }
    
    func formReadTempCurveHexString() -> String {
        
        return "68 09 FF FF FF 74 12 01 0C 99 EC"
    }
    
    func formSetRefregiratorTypeHexString(fridgeType : String) -> String {
        
        let checkWord = "0A".hexToDecimalValue() + "FF".hexToDecimalValue() + "\(addressCode.prefix(2))".hexToDecimalValue() + "\(addressCode.suffix(2))".hexToDecimalValue() + "74".hexToDecimalValue() + "12".hexToDecimalValue() + "01".hexToDecimalValue()  +  "0E".hexToDecimalValue() +  "\(fridgeType)".hexToDecimalValue()
        
        let hexForCheckWord = String(format:"%2X", checkWord)
        
        return "68 0A FF \(addressCode.prefix(2)) \(addressCode.suffix(2)) 74 12 01 0E \(fridgeType) \(hexForCheckWord.suffix(2)) EC"
    }
    
    func formWriteHexString() -> String {
        
        var dataContent = "\(spareCode) \(compressorCode) \(onOffCode) \(tempUnitCode) \(voltageCode)"
        
        dataContent = dataContent.replacingOccurrences(of: " ", with: "")
        
        var hexaData = String(Int(dataContent, radix: 2)!, radix: 16)
        
        hexaData = hexaData.pad(toSize: 2)
        
        let checkWord = "11".hexToDecimalValue() + "\(fridgeType)".hexToDecimalValue() + "\(addressCode.prefix(2))".hexToDecimalValue() + "\(addressCode.suffix(2))".hexToDecimalValue() + "74".hexToDecimalValue() + "12".hexToDecimalValue() + "01".hexToDecimalValue() + "0B".hexToDecimalValue() + "\(rightBinTemp.getHex())".hexToDecimalValue() + "\(leftBinTemp.getHex())".hexToDecimalValue() + "\(hexaData)".hexToDecimalValue() + "01".hexToDecimalValue()
        
        let hexForCheckWord = String(format:"%2X", checkWord)
        
        return "68 11 \(fridgeType) \(addressCode.prefix(2)) \(addressCode.suffix(2)) 74 12 01 0B 00 00 \(rightBinTemp.getHex()) \(leftBinTemp.getHex()) 00 00 \(hexaData) 01 \(hexForCheckWord.suffix(2)) EC"
    }
    
    func getLeftBinTemp() -> String {
        
        return tempUnit == TEMP_UNIT.celcius ? "\(leftBinTemp)\(TEMP_UNIT.celcius)" : "\(leftBinTemp.convertToFahrenheit())\(TEMP_UNIT.farenheat)"
    }
    
    func getRightBinTemp() -> String {
      
        return tempUnit == TEMP_UNIT.celcius ? "\(rightBinTemp)\(TEMP_UNIT.celcius)" : "\(rightBinTemp.convertToFahrenheit())\(TEMP_UNIT.farenheat)"
    }
    
    func getRightBinCurrentTemp() -> String {
        
        return tempUnit == TEMP_UNIT.celcius ? "\(rightBinCurrentTemp)\(TEMP_UNIT.celcius)" : "\(rightBinCurrentTemp.convertToFahrenheit())\(TEMP_UNIT.farenheat)"
    }
    
    func getLeftBinCurrentTemp() -> String {
        
        return tempUnit == TEMP_UNIT.celcius ? "\(leftBinCurrentTemp)\(TEMP_UNIT.celcius)" : "\(leftBinCurrentTemp.convertToFahrenheit())\(TEMP_UNIT.farenheat)"
    }
    
    func setBatteryProtectionLevel() {
        batteryProtectionLeval = voltageCode == "00" ? 0 : voltageCode == "01" ? 1 : 2
    }
    
    func setCoolingSpeedLevel() {
        coolingSpeed = compressorCode == "00" ? 2 : compressorCode == "01" ? 1 : 0
    }
    
    func splitAndSaveDeviceParameter(value : String) {
        
        let deviceParameter = value
        
        var binaryCode = String(Int(deviceParameter, radix: 16)!, radix: 2)
        
        binaryCode = binaryCode.pad(toSize: 8)
        
        var dataArray = binaryCode.formHexArr()
        
        voltageCode = dataArray.last!
        
        dataArray.remove(at: dataArray.count-1)
        
        let truncatedString = dataArray.joined()
        
        var truncatedArray = truncatedString.map({String($0)})
        
        tempUnitCode = truncatedArray.last!
        
        tempUnit = tempUnitCode == "0" ? TEMP_UNIT.celcius : TEMP_UNIT.farenheat
        
        truncatedArray.remove(at: truncatedArray.count-1)
        truncatedArray.remove(at: 0) // Removing spare
        
        onOffCode = truncatedArray.joined().formHexArr()[1]
        compressorCode = truncatedArray.joined().formHexArr()[0]
    }
}

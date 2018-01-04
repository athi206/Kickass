//
//  StringExtension.swift
//  KickAss
//
//  Created by CIPL108-MOBILITY on 12/12/17.
//  Copyright © 2017 Self. All rights reserved.
//

import UIKit

extension String {
    
    func formHexArr() -> Array<String>
    {
        var newStrArr:Array<String> = []
        var oldArr = self.characters.map { String($0) }
        for i in 0..<oldArr.count-1
        {
            if i%2 == 0{
                newStrArr.append("\(oldArr[i])\(oldArr[i+1])")
            }
        }
        return newStrArr
    }
    
    func hexToDecimalValue() -> Int {
        return Int(self, radix: 16) ?? 00
    }
    
    func pad(toSize: Int) -> String {
        var padded = self
        for _ in 0..<(toSize - self.characters.count) {
            padded = "0" + padded
        }
        return padded
    }
    
    func getTemperatureInCelcius() -> Int
    {
        if self == "00" {
            return Int(self) ?? 0
        }
        else {
            let decimalValue = self.hexToDecimalValue() - "32".hexToDecimalValue()
            return  decimalValue
        }
    }
    
    func toLengthOf(length:Int) -> String {
        if length <= 0 {
            return self
        } else if let to = self.index(self.startIndex, offsetBy: length, limitedBy: self.endIndex) {
            return self.substring(from: to)
            
        } else {
            return ""
        }
    }
}

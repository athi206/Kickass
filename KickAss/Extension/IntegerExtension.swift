//
//  IntegerExtension.swift
//  KickAss
//
//  Created by CIPL108-MOBILITY on 12/12/17.
//  Copyright © 2017 Self. All rights reserved.
//

import UIKit

extension Int {
    
    func convertToFahrenheit() -> Int {
        return self * 9 / 5 + 32
    }
    
    func convertToCelsius() -> Int {
        return 5 / 9 * (self - 32)
    }
    
    func getHex() -> String {
        
        return String(format:"%2X", self+"32".hexToDecimalValue())
    }
}


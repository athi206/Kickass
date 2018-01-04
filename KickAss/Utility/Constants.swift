//
//  Constants.swift
//  KickAss
//
//  Created by CIPL108-MOBILITY on 10/11/17.
//  Copyright © 2017 Self. All rights reserved.
//

import UIKit

struct FontName {
    static let regular = "MONTSERRAT-REGULAR_0"
    static let light = "MONTSERRAT-LIGHT_0"
    static let bold = "MONTSERRAT-BOLD_0"
}

struct StoryBoard {
    static let HomeViewControllerIdentifier = "HomeViewController"
}

struct Fan {
    static let red = #imageLiteral(resourceName: "redFan")
    static let green = #imageLiteral(resourceName: "greenFan")
}

struct COLOR {
    static let green = UIColor(hex: 0x2A9A28, alpha: 1.0)
}

struct FRIDGE {
    static let minimumTemp = -22
    static let maximumTemp = 10
}

struct TEMP_UNIT {
    static let celcius = "°C"
    static let farenheat = "°F"
}

struct FRIDGETYPE {
    static let leftOff = "01"
    static let rightOff = "02"
    static let Dual = "00"
    static let single = "03"
}

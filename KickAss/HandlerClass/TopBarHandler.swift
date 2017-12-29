//
//  TopBarHandler.swift
//  KickAss
//
//  Created by CIPL108-MOBILITY on 10/11/17.
//  Copyright © 2017 Self. All rights reserved.
//

import UIKit

class TopBarHandler: NSObject {

    static let shared = TopBarHandler()
    
    let window = UIApplication.shared.windows.first!

    func addTopBar() {
        let topBar = TopBarView(frame: CGRect(x: 0, y: 20, width: window.frame.size.width, height: 30))
        topBar.backgroundColor = UIColor.red
        Utility.shared.getCurrentController()?.view.addSubview(topBar)
    }
    
}

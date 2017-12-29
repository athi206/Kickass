//
//  TopBarView.swift
//  KickAss
//
//  Created by CIPL108-MOBILITY on 10/11/17.
//  Copyright © 2017 Self. All rights reserved.
//

import UIKit

class TopBarView: UIView {

    @IBOutlet var contentView: TopBarView!

    // MARK: - Initializers
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    // MARK: - Private Helper Methods
    
    // Performs the initial setup.
    fileprivate func setupView() {
        Bundle.main.loadNibNamed("TopBarView", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
    }
}

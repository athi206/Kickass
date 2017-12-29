//
//  FridgeListTableViewCell.swift
//  KickAss
//
//  Created by CIPL108-MOBILITY on 01/12/17.
//  Copyright © 2017 Self. All rights reserved.
//

import UIKit

class FridgeListTableViewCell: UITableViewCell {

    @IBOutlet weak var fridgeNamelabel: UILabel!    
    @IBOutlet weak var singleFridgeView: UIView!{
        didSet {
            singleFridgeView.layer.cornerRadius = 5.0
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

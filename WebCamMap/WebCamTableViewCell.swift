//
//  WebCamTableViewCell.swift
//  WebCamMap
//
//  Created by Nemanja Petrovic on 03/04/2020.
//  Copyright © 2020 Nemanja Petrovic. All rights reserved.
//

import UIKit

class WebCamTableViewCell: UITableViewCell {
    
    @IBOutlet weak var webCamImage: UIImageView!
    @IBOutlet weak var webCamTitle: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

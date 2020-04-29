//
//  CityNameCell.swift
//  WebCamMap
//
//  Created by Nemanja Petrovic on 09/04/2020.
//  Copyright © 2020 Nemanja Petrovic. All rights reserved.
//

import UIKit

class CityNameCell: UITableViewCell {
    
    @IBOutlet weak var cityName: UILabel!
    
    @IBOutlet weak var favouriteButton: UIButton!
    
    // For creating action on button tap inside cell
    var actionBlock: (() -> Void)? = nil
    
    @IBAction func favouriteButtonTapped(_ sender: Any) {
        actionBlock?()
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

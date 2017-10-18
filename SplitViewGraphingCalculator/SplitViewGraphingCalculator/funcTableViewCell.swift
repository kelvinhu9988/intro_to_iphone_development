//
//  funcTableViewCell.swift
//  GraphingCalculator2
//
//  Created by Craig Frey on 9/23/17.
//  Copyright © 2017 CS2048 Instructor. All rights reserved.
//

import UIKit

class funcTableViewCell: UITableViewCell {

    @IBOutlet weak var expressionLabel: UILabel!
    @IBOutlet weak var expressionImage: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

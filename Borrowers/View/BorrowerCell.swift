//
//  BorrowerCell.swift
//  Borrowers
//
//  Created by Wojciech Karaś on 28/01/2019.
//  Copyright © 2019 Wojciech Karaś. All rights reserved.
//

import UIKit

class BorrowerCell: UICollectionViewCell {
    
    @IBOutlet weak var borrowerPhoto: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var itemsLabel: UILabel!
    @IBOutlet weak var selectionImage: UIImageView!
    
    var isEditing = false {
        didSet {
            selectionImage.isHidden = !isEditing
        }
    }
    
    override var isSelected: Bool {
        didSet {
            selectionImage.image = isSelected ? UIImage(named: "Checked") : UIImage(named: "Unchecked")
        }
    }
    
}

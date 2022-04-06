//
//  AttributeTableViewCell.swift
//  OracleSQLGenerator
//
//  Created by Oluwakamiye Akindele on 05/04/2022.
//

import UIKit

class AttributeTableViewCell: UITableViewCell {
    @IBOutlet weak var typeBarColor: UIView!
    @IBOutlet weak var attributeNameLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    static var reuseIdentifier = "AttributeTableViewCell"
    var attribute: Attribute? {
        didSet {
            attributeNameLabel.text = attribute?.name
            typeLabel.text = attribute?.type.rawValue
            contentView.layer.cornerRadius = 5.0
            if attribute?.isPrimaryKey ?? false {
                typeBarColor.backgroundColor = .red
            }
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

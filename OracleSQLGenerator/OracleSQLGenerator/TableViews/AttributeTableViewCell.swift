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
            guard let attribute = attribute else {
                return
            }
            attributeNameLabel.text = attribute.name
            typeLabel.text = attribute.type.rawValue
            contentView.layer.cornerRadius = 5.0
            if attribute.isPrimaryKey {
                typeBarColor.backgroundColor = .red
            } else if (attribute.foreignKeyConstraint != nil) != nil ?? false {
                typeBarColor.backgroundColor = .systemYellow
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
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 7, left: 7, bottom: 7, right: 7))
    }
}

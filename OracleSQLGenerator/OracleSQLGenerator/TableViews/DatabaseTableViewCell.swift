//
//  DatabaseTableViewCell.swift
//  OracleSQLGenerator
//
//  Created by Oluwakamiye Akindele on 04/04/2022.
//

import UIKit

class DatabaseTableViewCell: UITableViewCell {
    @IBOutlet weak private(set) var databaseLabel: UILabel!
    @IBOutlet weak private(set) var detailLabel: UILabel!
    static var reuseIdentifier = "DatabaseTableViewCell"
    var database: Database? {
        didSet {
            guard let database = database else {
                return
            }
            databaseLabel.text = "\(database.name)"
            detailLabel.text = "\(database.tables.count) table\(database.tables.count != 1 ? "s":"")"
            contentView.layer.cornerRadius = 5.0
        }
    }
    
    var table: Table? {
        didSet {
            guard let table = table else {
                return
            }
            let noOfPrimaryKeys = table.attributes.filter({$0.isPrimaryKey == true}).count
            let noOfForeignKeys = table.attributes.filter({$0.foreignKeyConstraint != nil}).count
            var detailText = "\(table.attributes.count) attribute\(table.attributes.count != 1 ? "s":" ")"
            detailText += "   ·  \(noOfPrimaryKeys) PK\(noOfPrimaryKeys != 1 ? "s":" ")"
            detailText += "   ·  \(noOfForeignKeys) FK\(noOfForeignKeys != 1 ? "s":"")"
            databaseLabel.text = "\(table.name)"
            detailLabel.text = detailText
            contentView.layer.cornerRadius = 5.0
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
        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 7, left: 10, bottom: 7, right: 10))
    }
}

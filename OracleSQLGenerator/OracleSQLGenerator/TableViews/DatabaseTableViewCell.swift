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
            databaseLabel.text = "\(table.name)"
            detailLabel.text = "\(table.attributes.count) attribute\(table.attributes.count != 1 ? "s":"")"
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
    
}

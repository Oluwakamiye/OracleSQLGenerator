//
//  DatabaseViewModel.swift
//  OracleSQLGenerator
//
//  Created by Oluwakamiye Akindele on 04/04/2022.
//

import Foundation

protocol DatabaseViewModelDelegate: BaseModelDelegate {
    func updateDatabaseList(databases: [Database], animatingDifferences: Bool)
}

final class DatabaseViewModel: NSObject {
    weak var delegate: DatabaseViewModelDelegate?
    private var record = Helper.shared.record
    
    func getDatabases() {
        guard let delegate = delegate else {
            return
        }
        delegate.updateDatabaseList(databases: record.databases, animatingDifferences: true)
    }
    
    func addDatabase(name: String?) {
        guard let delegate = delegate else {
            return
        }
        guard name != nil,
              !name!.isEmpty,
              !record.databases.contains(where: {$0.name == name}) else {
            delegate.showError(errorTitle: "Cannot Create Database", errorDetail: name?.isEmpty ?? false ? "Database name cannot be empty" : "Database name exists already")
            return
        }
        var name = name!.capitalized
        name = name.trimming(spaces: .leadingAndTrailing)
        name = name.replacingOccurrences(of: "  ", with: " ")
        name = name.replacingOccurrences(of: " ", with: "_")
        let database = Database(name: name, tables: [])
        record.databases.append(database)
        Helper.shared.record = record
        delegate.updateDatabaseList(databases: record.databases, animatingDifferences: true)
    }
}

//
//  TableViewModel.swift
//  OracleSQLGenerator
//
//  Created by Oluwakamiye Akindele on 06/04/2022.
//

import Foundation

protocol TableViewsModelDelegate: BaseModelDelegate {
    func updateTableList(tables: [Table], animatingDifferences: Bool)
    func displayMailWindow(withQuery: String, databaseName: String)
    func goToAttributesPage(databaseID: String, tableID: String)
}

final class TableViewsModel: NSObject {
    weak var delegate: TableViewsModelDelegate?
    private var record = Helper.shared.record
    var databaseID: String = ""
    
    func getTables() {
        record = Helper.shared.record
        guard let delegate = delegate,
              let database = record.databases.first(where: {$0.id == databaseID}) else {
            return
        }
        delegate.updateTableList(tables: database.tables, animatingDifferences: true)
    }
    
    func addNewTable(name: String?) {
        guard let delegate = delegate,
              let database = record.databases.first(where: {$0.id == databaseID}),
              let databaseIndex = record.databases.firstIndex(of: database) else {
            return
        }
        guard name != nil,
              !name!.isEmpty,
              !database.tables.contains(where: {$0.name == name}) else {
            delegate.showError(errorTitle: "Cannot Create Table", errorDetail: name?.isEmpty ?? false ? "Table name cannot be empty" : "Table name exists already")
            return
        }
        var name = name!.capitalized
        name = name.trimming(spaces: .leadingAndTrailing)
        name = name.replacingOccurrences(of: "  ", with: " ")
        name = name.replacingOccurrences(of: " ", with: "_")
        let table = Table(name: name)
        database.tables.append(table)
        record.databases[databaseIndex] = database
        Helper.shared.record = record
        delegate.updateTableList(tables: database.tables, animatingDifferences: true)
    }
    
    func createQuery() {
        guard let delegate = delegate,
              let database = record.databases.first(where: {$0.id == databaseID}) else {
            return
        }
        delegate.displayMailWindow(withQuery: SQLGenerator.makeSQL(database: database), databaseName: database.name)
    }
    
    func selectTable(table: Table) {
        guard let delegate = delegate else {
            return
        }
        delegate.goToAttributesPage(databaseID: databaseID, tableID: table.id)
    }
}

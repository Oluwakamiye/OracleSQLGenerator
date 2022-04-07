//
//  AttributesViewModel.swift
//  OracleSQLGenerator
//
//  Created by Oluwakamiye Akindele on 06/04/2022.
//

import Foundation

protocol AttributesViewModelDelegate: BaseModelDelegate {
    func updateNavigationTitle(title: String)
    func displayMailWindow(withQuery: String, tableName: String)
    func updateAttributesList(attributes: [Attribute], animatingDifferences: Bool) 
    func goToEditAttributePage(databaseID: String, tableID: String, attributeID: String)
}

final class AttributesViewModel: NSObject {
    weak var delegate: AttributesViewModelDelegate?
    private var record = Helper.shared.record
    var databaseID: String = ""
    var tableID: String = ""
    
    func getAttributes() {
        record = Helper.shared.record
        guard let delegate = delegate,
              let database = record.databases.first(where: {$0.id == databaseID}),
              let table = database.tables.first(where: {$0.id == tableID})
        else {
            return
        }
        delegate.updateAttributesList(attributes: table.attributes, animatingDifferences: true)
    }
    
    func addNewAttribute(name: String?, type: AttributeType) {
        guard let delegate = delegate,
              let database = record.databases.first(where: {$0.id == databaseID}),
              let databaseIndex = record.databases.firstIndex(of: database),
              let table = database.tables.first(where: {$0.id == tableID}),
              let tableIndex = database.tables.firstIndex(of: table) else {
            return
        }
        guard name != nil,
              !name!.isEmpty,
              let table = database.tables.first(where: {$0.id == tableID}),
              !table.attributes.contains(where: {$0.name == name}) else {
            delegate.showError(errorTitle: "Cannot Create Table", errorDetail: name?.isEmpty ?? false ? "Table name cannot be empty" : "Table name exists already")
            return
        }
        var name = name!.lowercased()
        name = name.trimming(spaces: .leadingAndTrailing)
        name = name.replacingOccurrences(of: "  ", with: " ")
        name = name.replacingOccurrences(of: " ", with: "_")
        let isPrimaryKeyInferred = name.caseInsensitiveCompare("ID") == .orderedSame || name.caseInsensitiveCompare("\(table.name)_ID") == .orderedSame
        let attribute = Attribute(name: name, isPrimaryKey: isPrimaryKeyInferred, isNullable: !isPrimaryKeyInferred, isUnique: !isPrimaryKeyInferred, type: type)
        
        table.attributes.append(attribute)
        database.tables[tableIndex] = table
        record.databases[databaseIndex] = database
        Helper.shared.record = record
        delegate.updateAttributesList(attributes: table.attributes, animatingDifferences: true)
    }
    
    func createInsertQuery() {
        guard let delegate = delegate,
              let database = record.databases.first(where: {$0.id == databaseID}),
              let table = database.tables.first(where: {$0.id == tableID}) else {
            return
        }
        delegate.displayMailWindow(withQuery: SQLGenerator.generateInsertQueryForTable(table: table), tableName: table.name)
    }
    
    func updateTableTitle() {
        guard let delegate = delegate,
              let database = record.databases.first(where: {$0.id == databaseID}),
              let table = database.tables.first(where: {$0.id == tableID})
        else {
            return
        }
        delegate.updateNavigationTitle(title: table.name)
    }
    
    func selectAttributeForEditing(attribute: Attribute) {
        guard let delegate = delegate else {
            return
        }
        delegate.goToEditAttributePage(databaseID: databaseID, tableID: tableID, attributeID: attribute.id)
    }
}

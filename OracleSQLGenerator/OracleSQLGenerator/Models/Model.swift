//
//  Model.swift
//  OracleSQLGenerator
//
//  Created by Oluwakamiye Akindele on 04/04/2022.
//

import Foundation

enum Section {
    case main
}

enum AttributeType: String, CaseIterable, Codable {
    case integer = "int"
    case varcharLong = "varchar(255)"
    case varcharShort = "varchar(10)"
    case floatPoint = "float"
    case boolean = "bool"
    case date = "date"
}

class Attribute: Hashable, Codable, NSCopying {
    var id: String = "\(UUID())"
    var name: String
    var isPrimaryKey: Bool
    var isNull: Bool
    var isUnique: Bool
    var type: AttributeType
    var foreignKeyConstraint: ForeignKeyRelationConstraint? = nil
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Attribute, rhs: Attribute) -> Bool {
        lhs.id == rhs.id
    }
    
    init(name: String, isPrimaryKey: Bool, isNull: Bool, isUnique: Bool, type: AttributeType, foreignKeyConstraint: ForeignKeyRelationConstraint? = nil) {
        self.name = name
        self.isPrimaryKey = isPrimaryKey
        self.isNull = isNull
        self.isUnique = isUnique
        self.type = type
        self.foreignKeyConstraint = foreignKeyConstraint
    }
    
    func copy(with zone: NSZone? = nil) -> Any {
        let copy = Attribute(name: name, isPrimaryKey: isPrimaryKey, isNull: isNull, isUnique: isUnique, type: type, foreignKeyConstraint: foreignKeyConstraint)
        return copy
    }
}

class Table: Hashable, Codable, NSCopying {
    var id: String = "\(UUID())"
    var name: String
    var attributes: [Attribute] = []
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Table, rhs: Table) -> Bool {
        lhs.id == rhs.id
    }
    
    init(name: String, attributes: [Attribute] = [Attribute]()) {
        self.name = name
        self.attributes = attributes
    }
    
    func copy(with zone: NSZone? = nil) -> Any {
        let copy = Table(name: name, attributes: attributes)
        return copy
    }
}

class Database: Hashable, Codable, NSCopying {
    var id: String = "\(UUID())"
    var name: String
    var tables: [Table]
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Database, rhs: Database) -> Bool {
        lhs.id == rhs.id
    }
    
    init(name: String, tables: [Table]) {
        self.name = name
        self.tables = tables
    }
    
    func copy(with zone: NSZone? = nil) -> Any {
        let copy = Database(name: name, tables: tables)
        return copy
    }
}

class ForeignKeyRelationConstraint: Hashable, Codable, NSCopying {
    var id: String = "\(UUID())"
    var primaryKeyTableID: String
    var primaryKeyAttributeID: String
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func ==(lhs: ForeignKeyRelationConstraint, rhs: ForeignKeyRelationConstraint) -> Bool {
        lhs.id == rhs.id
    }
    
    init(primaryKeyTableID: String, primaryKeyAttributeID: String) {
        self.primaryKeyTableID = primaryKeyTableID
        self.primaryKeyAttributeID = primaryKeyAttributeID
    }
    
    func copy(with zone: NSZone? = nil) -> Any {
        let copy = ForeignKeyRelationConstraint(primaryKeyTableID: primaryKeyTableID, primaryKeyAttributeID: primaryKeyAttributeID)
        return copy
    }
}

class Record: Codable, NSCopying {
    var databases: [Database]
    var lastModified: Date
    
    init(databases: [Database], lastModified: Date) {
        self.databases = databases
        self.lastModified = lastModified
    }
    
    func copy(with zone: NSZone? = nil) -> Any {
        let copy = Record(databases: databases, lastModified: lastModified)
        return copy
    }
}

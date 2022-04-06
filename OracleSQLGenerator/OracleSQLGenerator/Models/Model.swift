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

class Attribute: Hashable, Codable {
    var id: String = "\(UUID())"
    var name: String
    var isPrimaryKey: Bool
    var isNull: Bool
    var isUnique: Bool
    var type: AttributeType
    var foreignKeyConstraints: [ForeignKeyRelationConstraint] = []
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Attribute, rhs: Attribute) -> Bool {
        lhs.id == rhs.id
    }
    
    init(name: String, isPrimaryKey: Bool, isNull: Bool, isUnique: Bool, type: AttributeType) {
        self.name = name
        self.isPrimaryKey = isPrimaryKey
        self.isNull = isNull
        self.isUnique = isUnique
        self.type = type
    }
}

class Table: Hashable, Codable {
    var id: String = "\(UUID())"
    var name: String
    var attributes: [Attribute] = []
    var foreignKeyConstraints: [ForeignKeyRelationConstraint] = []
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Table, rhs: Table) -> Bool {
        lhs.id == rhs.id
    }
    
    init(name: String) {
        self.name = name
    }
}

class Database: Hashable, Codable {
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
}

class ForeignKeyRelationConstraint: Hashable, Codable {
    var id: String = "\(UUID())"
    var primaryKeyTable: Table
    var primaryKeyAttribute: Attribute
    var foreignKeyAttribute: Attribute
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func ==(lhs: ForeignKeyRelationConstraint, rhs: ForeignKeyRelationConstraint) -> Bool {
        lhs.id == rhs.id
    }
    
    init(primaryKeyTable: Table, primaryKeyAttribute: Attribute, foreignKeyAttribute: Attribute) {
        self.primaryKeyTable = primaryKeyTable
        self.primaryKeyAttribute = primaryKeyAttribute
        self.foreignKeyAttribute = foreignKeyAttribute
    }
}

class Record: Codable {
    var databases: [Database]
    var lastModified: Date
    
    init(databases: [Database], lastModified: Date) {
        self.databases = databases
        self.lastModified = lastModified
    }
}

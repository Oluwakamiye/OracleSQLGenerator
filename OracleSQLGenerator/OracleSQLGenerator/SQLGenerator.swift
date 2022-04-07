//
//  SQLGenerator.swift
//  OracleSQLGenerator
//
//  Created by Oluwakamiye Akindele on 04/04/2022.
//

import Foundation

struct SQLGenerator {
    private static var databaseID = ""
    
    static func getCreateSQLQueries(database: Database, includeInsertQueries: Bool = false) -> String {
        var SQLString = ""
        databaseID = database.id
        for table in database.tables {
            SQLString = SQLString.add("-- Drop and Create \(table.name.capitalized) Table")
            SQLString = SQLString.add(makeSQL(table: table))
            if includeInsertQueries {
                SQLString = SQLString.add(generateInsertQueryForTable(table: table))
            }
            SQLString = SQLString.add("").add("")
        }
        return SQLString
    }
    
    private static func makeSQL(table: Table) -> String {
        var sql = "DROP TABLE \(table.name.uppercased()) CASCADE CONSTRAINTS;"
        sql = sql.add("CREATE TABLE \(table.name.uppercased()) (")
        for attribute in table.attributes {
            let sqlString = "   \(attribute.name.uppercased())     \(getTypeFromAttributeType(type: attribute.type)) \(attribute.isNullable ? "" : "not null") \(attribute.isUnique && !attribute.isPrimaryKey ? "UNIQUE" : "") \(attribute == table.attributes.last ? "" : ",")"
            sql = sql.add(sqlString)
        }
        let contraintSQL = addKeyConstraints(table: table)
        if !contraintSQL.isEmpty {
            sql += ","
        }
        sql = sql.add(contraintSQL)
        //        sql = sql.add(");")
        sql = sql.add(");")
        return sql
    }
    
    private static func getTypeFromAttributeType(type: AttributeType) -> String {
        var typeString = ""
        switch type {
        case .number:
            typeString = "NUMBER"
        case .numberShort:
            typeString = "NUMBER (7)"
        case .numberShorter:
            typeString = "NUMBER (3)"
        case .varcharLong:
            typeString = "VARCHAR2 (255)"
        case .varcharShort:
            typeString = "VARCHAR2 (10)"
        case .amount:
            typeString = "NUMBER (7,2)"
        case .boolean:
            typeString = "CHAR (1)"
        case .date:
            typeString = "DATE"
        }
        return typeString
    }
    
    private static func addKeyConstraints(table: Table) -> String {
        var sql = ""
        let attributesWithForeignContraints = table.attributes.filter({ $0.foreignKeyConstraint != nil })
        if let primaryKeyAttribute = table.attributes.first(where: {$0.isPrimaryKey == true}) {
            sql = sql.add("CONSTRAINT PK_\(table.name.uppercased()) PRIMARY KEY (\(primaryKeyAttribute.name.uppercased()))\(attributesWithForeignContraints.count > 0 ? ",":"")")
        }
        guard !attributesWithForeignContraints.isEmpty,
              let tables = Helper.shared.record.databases.first(where: {$0.id == databaseID})?.tables else {
            return sql
        }
        for attribute in attributesWithForeignContraints  {
            if let primaryKeyTable = tables.first(where: {$0.id == attribute.foreignKeyConstraint?.primaryKeyTableID}),
               let primaryKeyAttribute = primaryKeyTable.attributes.first(where: {$0.id == attribute.foreignKeyConstraint?.primaryKeyAttributeID}) {
                sql = sql.add("CONSTRAINT FK_\(primaryKeyTable.name.capitalized)\(table.name.capitalized) FOREIGN KEY (\(attribute.name.uppercased())) REFERENCES \(primaryKeyTable.name.uppercased())(\(primaryKeyAttribute.name.uppercased()))")
                sql += attribute == attributesWithForeignContraints.last ? "" : ","
            }
        }
        return sql
    }
    
    static func generateInsertQuery(database: Database) -> String {
        var SQLString = ""
        for table in database.tables {
            SQLString = SQLString.add(generateInsertQueryForTable(table: table))
        }
        return SQLString
    }
    
    static func generateInsertQueryForTable(table: Table) -> String {
        let tableName = table.name.uppercased()
        var sql = "INSERT INTO   \(tableName) ("
        for attribute in table.attributes {
            sql += attribute.name.uppercased()
            sql += attribute == table.attributes.last ? "" : ", "
        }
        sql += ")"
        sql += " VALUES ("
        for attribute in table.attributes {
            sql += getDefaultValueFromAttributeType(type: attribute.type)
            sql += attribute == table.attributes.last ? "" : ", "
        }
        sql += ");"
        return sql
    }
    
    private static func getDefaultValueFromAttributeType(type: AttributeType) -> String {
        var typeString = ""
        switch type {
        case .number, .numberShort, .numberShorter:
            typeString = "00"
        case .varcharLong:
            typeString = "\'ABCDE\'"
        case .varcharShort:
            typeString = "\'ABC\'"
        case .amount:
            typeString = "00.00"
        case .boolean:
            typeString = "T"
        case .date:
            typeString = "\'12/17/80\'"
        }
        return typeString
    }
}

//
//  SQLGenerator.swift
//  OracleSQLGenerator
//
//  Created by Oluwakamiye Akindele on 04/04/2022.
//

import Foundation

struct SQLGenerator {
    static func makeSQL(database: Database) -> String {
        var SQLString = ""
        for table in database.tables {
            SQLString = SQLString.add("-- Drop and Create \(table.name.capitalized) Table")
            SQLString = SQLString.add(makeSQL(table: table))
        }
        return SQLString
    }
    
    private static func makeSQL(table: Table) -> String {
        var sql = "DROP TABLE \(table.name.capitalized) CASCADE CONSTRAINTS;"
        sql = sql.add("CREATE TABLE \(table.name.capitalized) (")
        for attribute in table.attributes {
            let sqlString = "\(attribute.name.uppercased()) \(getTypeFromAttributeType(type: attribute.type)) \(attribute.isNull ? "" : "not null") \(attribute.isUnique && !attribute.isPrimaryKey ? "UNIQUE" : "") \(attribute == table.attributes.last ? "" : ",")"
            sql = sql.add(sqlString)
        }
        let contraintSQL = addKeyConstraints(table: table)
        if !contraintSQL.isEmpty {
            sql += ","
        }
        sql = sql.add(contraintSQL)
        sql = sql.add(");")
        return sql
    }
    
    private static func getTypeFromAttributeType(type: AttributeType) -> String {
        var typeString = ""
        switch type {
        case .integer:
            typeString = "int"
        case .varcharLong:
            typeString = "varchar(255)"
        case .varcharShort:
            typeString = "varchar(10)"
        case .floatPoint:
            typeString = "float(10)"
        case .boolean:
            typeString = "char(1)"
        case .date:
            typeString = "varchar(10)"
        }
        return typeString
    }
    
    private static func addKeyConstraints(table: Table) -> String {
        var sql = ""
        if let primaryKeyAttribute = table.attributes.first(where: {$0.isPrimaryKey == true}) {
            sql = sql.add("PRIMARY KEY (\(primaryKeyAttribute.name.uppercased()))\(table.foreignKeyConstraints.count > 0 ? ",":"")")
        }
        for constraint in table.foreignKeyConstraints {
            sql = sql.add("CONSTRAINT FK_\(constraint.primaryKeyTable.name)_\(table.name) FOREIGN KEY (\(constraint.foreignKeyAttribute.name.uppercased())) REFERENCES \(constraint.primaryKeyTable.name.uppercased())(\(constraint.primaryKeyAttribute.name))")
            sql += constraint == table.foreignKeyConstraints.last ? "" : ","
        }
        return sql
    }
}

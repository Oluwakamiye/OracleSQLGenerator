//
//  Helper.swift
//  OracleSQLGenerator
//
//  Created by Oluwakamiye Akindele on 05/04/2022.
//

import Foundation

class Helper {
    private static let recordPathName = "sqlRecord"
    private static let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
    private static var archiveURL: URL? = {
        let archiveURL = documentDirectory?.appendingPathComponent(recordPathName).appendingPathExtension("plist")
        return archiveURL
    }()
    
    var record: Record = Helper.fetchNonEmptyRecord() {
        didSet {
            Helper.saveRecordToDisk(record: record)
        }
    }
    static let shared = Helper()
    private init() {
    }
}

// MARK: Data Saving Helper Methods
extension Helper {
    func updateRecord() {
        Helper.saveRecordToDisk(record: record)
    }
    
    private static func saveRecordToDisk(record: Record) {
        let propertyListEncoder = PropertyListEncoder()
        guard let encodedRecord = try? propertyListEncoder.encode(record),
              let archiveURL = archiveURL else {
            return
        }
        do {
            try encodedRecord.write(to: archiveURL, options: .noFileProtection)
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
    private static func fetchRecord() -> Record? {
        let propertyListDecoder = PropertyListDecoder()
        guard let archiveURL = archiveURL,
              let retrievedRecordData = try? Data(contentsOf: archiveURL),
              let decodedRecord = try? propertyListDecoder.decode(Record.self, from: retrievedRecordData) else {
            return nil
        }
        return decodedRecord
    }
    
    private static func fetchNonEmptyRecord() -> Record {
        var record: Record! = fetchRecord()
        if record == nil {
            saveRecordToDisk(record: Record(databases: [], lastModified: Date()))
            record = fetchRecord()
            if record == nil {
                fatalError("An error has occured")
            }
        }
        return record
    }
}

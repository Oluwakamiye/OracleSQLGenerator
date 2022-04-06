//
//  String+Extension.swift
//  OracleSQLGenerator
//
//  Created by Oluwakamiye Akindele on 04/04/2022.
//

import Foundation


extension String {
    func add(_ additionalString: String) -> String {
        return self + "\n" + additionalString
    }
}

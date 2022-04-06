//
//  BaseProtocol.swift
//  OracleSQLGenerator
//
//  Created by Oluwakamiye Akindele on 05/04/2022.
//

import Foundation

protocol BaseModelDelegate: AnyObject {
    func showError(errorTitle: String, errorDetail: String?)
}

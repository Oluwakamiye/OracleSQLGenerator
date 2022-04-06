//
//  Storyboard+Extension.swift
//  OracleSQLGenerator
//
//  Created by Oluwakamiye Akindele on 04/04/2022.
//

import UIKit

extension UIStoryboard {
    enum Name: String {
        case Main
    }
    
    static func storyboard(_ name: Name) -> UIStoryboard {
        return UIStoryboard(name: name.rawValue, bundle: nil)
    }
}

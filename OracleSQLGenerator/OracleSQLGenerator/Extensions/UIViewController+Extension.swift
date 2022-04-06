//
//  UIViewController+Extension.swift
//  OracleSQLGenerator
//
//  Created by Oluwakamiye Akindele on 05/04/2022.
//

import UIKit

extension UIViewController {
    func customiseNavigation() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
//        appearance.backgroundColor = UIColor.systemGray4
        appearance.titleTextAttributes = [.foregroundColor: UIColor.lightText]
        navigationItem.standardAppearance = appearance
        navigationItem.scrollEdgeAppearance = appearance
        navigationItem.compactAppearance = appearance
    }
    
    func showErrorAlert(error: String, message: String? = nil) {
        let alertController = UIAlertController(title: error, message: message, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Okay", style: .cancel)
        alertController.addAction(cancelAction)
        present(alertController,animated: true)
    }
    
    func goBackTwoViews() {
        let viewControllers: [UIViewController] = self.navigationController!.viewControllers as [UIViewController]
        self.navigationController!.popToViewController(viewControllers[viewControllers.count - 3], animated: true)
    }
}

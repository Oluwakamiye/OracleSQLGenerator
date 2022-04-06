//
//  TablesViewController.swift
//  OracleSQLGenerator
//
//  Created by Oluwakamiye Akindele on 04/04/2022.
//

import UIKit
import MessageUI

class TablesViewController: UIViewController {
    @IBOutlet weak private(set) var tableView: UITableView!
    typealias DataSource = UITableViewDiffableDataSource<Section, Table>
    typealias SnapShot = NSDiffableDataSourceSnapshot<Section, Table>
    private lazy var dataSource = makeDataSource()
    
    private var viewModel = TableViewsModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.delegate = self
        tableView.delegate = self
        tableView.register(UINib(nibName: DatabaseTableViewCell.reuseIdentifier, bundle: nil), forCellReuseIdentifier: DatabaseTableViewCell.reuseIdentifier)
        customiseNavigation()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.getTables()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        customiseNavigation()
        setupView()
    }
    
    private func setupView() {
        let toolBarButton = UIBarButtonItem(title: "➕ Add Table", style: .done, target: self, action: #selector(addNewTable))
        toolBarButton.setTitleTextAttributes([.foregroundColor: UIColor.systemGreen], for: .normal)
        toolBarButton.tintColor = UIColor.green
        navigationController?.toolbar.setItems([toolBarButton], animated: true)
        
        let rightButton = UIButton()
        rightButton.setTitle(" 📗 Create Query  ", for: .normal)
        rightButton.titleLabel?.font = UIFont(name: "Helvetica", size: 15)
        rightButton.setTitleColor(.label, for: .normal)
        rightButton.layer.borderWidth = 1.0
        rightButton.layer.cornerRadius = 6
        rightButton.layer.borderColor = UIColor.label.cgColor
        rightButton.backgroundColor = UIColor.clear
        rightButton.addTarget(self, action: #selector(createQuery), for: .touchUpInside)
        let rightBarButton = UIBarButtonItem(customView: rightButton)
        navigationItem.rightBarButtonItem = rightBarButton
        
        navigationItem.backButtonTitle = "None"
    }
    
    @objc func createQuery() {
        viewModel.createQuery()
    }
    
    @objc func addNewTable() {
        let alert = UIAlertController(title: "Add New Table", message: "Name of new Table", preferredStyle: .alert)
        alert.addTextField()
        guard let textField = alert.textFields?.first else {
            return
        }
        textField.placeholder = "Table Name"
        let createAction = UIAlertAction(title: "Create", style: .default, handler: {
            _ in
            self.viewModel.addNewTable(name: textField.text)
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alert.addAction(createAction)
        alert.addAction(cancelAction)
        present(alert, animated: true)
    }
    
    private func makeDataSource() -> DataSource {
        let dataSource = DataSource(tableView: tableView, cellProvider: {
            (tableView, indexPath, table) -> UITableViewCell? in
            let cell = tableView.dequeueReusableCell(withIdentifier: DatabaseTableViewCell.reuseIdentifier, for: indexPath) as? DatabaseTableViewCell
            cell?.table = table
            return cell
        })
        return dataSource
    }
    
    static func makeSelf(databaseID: String) -> TablesViewController? {
        guard let destinationVC = UIStoryboard.storyboard(.Main).instantiateViewController(withIdentifier: "TablesViewController") as? TablesViewController else { return nil }
        destinationVC.viewModel.databaseID = databaseID
        return destinationVC
    }
}

// MARK: TableView Delegate
extension TablesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let table = dataSource.itemIdentifier(for: indexPath) else {
            return
        }
        navigationItem.backButtonTitle = table.name
        viewModel.selectTable(table: table)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}

// MARK: ViewModel Delegates
extension TablesViewController: TableViewsModelDelegate {
    func updateTableList(tables: [Table], animatingDifferences: Bool) {
        var snapshot = SnapShot()
        snapshot.appendSections([.main])
        snapshot.appendItems(tables)
        dataSource.apply(snapshot, animatingDifferences: animatingDifferences)
    }
    
    func showError(errorTitle: String, errorDetail: String?) {
        showErrorAlert(error: errorTitle, message: errorDetail)
    }
    
    func displayMailWindow(withQuery: String, databaseName: String) {
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
//            mail.setToRecipients(["you@yoursite.com"])
            mail.setMessageBody(withQuery, isHTML: false)
            mail.setSubject("SQL Queries for \(databaseName)")
            
            present(mail, animated: true)
        } else {
            // show failure alert
            showErrorAlert(error: "Cannot Send Mail")
        }
    }
    
    func goToAttributesPage(databaseID: String, tableID: String) {
        guard let destinationVC = AttributesViewController.makeSelf(databaseID: databaseID, tableID: tableID) else {
            return
        }
        navigationController?.pushViewController(destinationVC, animated: true)
    }
}

extension TablesViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        if let _ = error {
            controller.dismiss(animated: true, completion: nil)
            return
        }
        switch result {
        case .cancelled:
            break
        case .failed:
            break
        case .saved:
            break
        case .sent:
            break
        }
        controller.dismiss(animated: true, completion: nil)
    }
}

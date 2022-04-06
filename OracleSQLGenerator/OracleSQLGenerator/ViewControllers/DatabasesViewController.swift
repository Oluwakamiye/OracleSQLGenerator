//
//  DatabasesViewController.swift
//  OracleSQLGenerator
//
//  Created by Oluwakamiye Akindele on 04/04/2022.
//

import UIKit

class DatabasesViewController: UIViewController {
    @IBOutlet weak private(set) var tableView: UITableView!
    typealias DataSource = UITableViewDiffableDataSource<Section, Database>
    typealias SnapShot = NSDiffableDataSourceSnapshot<Section, Database>
    private lazy var dataSource = makeDataSource()
    private var viewModel = DatabaseViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        Helper.saveRecordToDisk(record: Record(databases: getDatabases(), lastModified: Date()))
        viewModel.delegate = self
        tableView.delegate = self
        tableView.register(UINib(nibName: DatabaseTableViewCell.reuseIdentifier, bundle: nil), forCellReuseIdentifier: DatabaseTableViewCell.reuseIdentifier)
        navigationItem.title = "Databases"
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupView()
        customiseNavigation()
        viewModel.getDatabases()
    }
    
//    private func getDatabases() -> [Database] {
//        let table1 = Table(name: "ASA")
//        let table2 = Table(name: "Wizkid")
//        let table3 = Table(name: "Davido")
//        let table4 = Table(name: "Burna")
//        let table5 = Table(name: "Ric Hassani")
//        
//        let database = Database(name: "Grammy Artists", tables: [table1, table2, table3])
//        let database2 = Database(name: "World Cup Artists", tables: [table4, table5])
//        return [database, database2]
//    }
    
    private func setupView() {
        let toolBarButton = UIBarButtonItem(title: "➕ Add Database", style: .done, target: self, action: #selector(addDatabase))
        toolBarButton.setTitleTextAttributes([.foregroundColor: UIColor.systemGreen], for: .normal)
        toolBarButton.tintColor = UIColor.green
        navigationController?.toolbar.setItems([toolBarButton], animated: true)
    }
    
    @objc func addDatabase() {
        let alert = UIAlertController(title: "Add New Database", message: "Name of new Database", preferredStyle: .alert)
        alert.addTextField()
        guard let textField = alert.textFields?.first else {
            return
        }
        textField.placeholder = "Database Name"
        let createAction = UIAlertAction(title: "Create", style: .default, handler: {
            _ in
            self.viewModel.addDatabase(name: textField.text)
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alert.addAction(createAction)
        alert.addAction(cancelAction)
        present(alert, animated: true)
    }

    private func makeDataSource() -> DataSource{
        let dataSource = DataSource(tableView: tableView, cellProvider: {
            (tableView, indexPath, database) -> UITableViewCell? in
            let cell = tableView.dequeueReusableCell(withIdentifier: DatabaseTableViewCell.reuseIdentifier, for: indexPath) as? DatabaseTableViewCell
            cell?.database = database
            return cell
        })
        return dataSource
    }
}

// MARK: TableView Delegate
extension DatabasesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let database = dataSource.itemIdentifier(for: indexPath),
              let destinationVC = TablesViewController.makeSelf(databaseID: database.id) else {
            return
        }
        navigationController?.pushViewController(destinationVC, animated: true)
    }
}

// MARK: ViewModelDelegate
extension DatabasesViewController: DatabaseViewModelDelegate {
    func updateDatabaseList(databases: [Database], animatingDifferences: Bool = true) {
        var snapshot = SnapShot()
        snapshot.appendSections([.main])
        snapshot.appendItems(databases)
        dataSource.apply(snapshot, animatingDifferences: animatingDifferences)
    }
    
    func showError(errorTitle: String, errorDetail: String?) {
        showErrorAlert(error: errorTitle, message: errorDetail)
    }
}

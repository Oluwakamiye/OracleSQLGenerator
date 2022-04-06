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
        viewModel.delegate = self
        tableView.delegate = self
        tableView.register(UINib(nibName: DatabaseTableViewCell.reuseIdentifier, bundle: nil), forCellReuseIdentifier: DatabaseTableViewCell.reuseIdentifier)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.getDatabases()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationItem.title = "Databases"
        customiseNavigation()
        setupView()
    }
    
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
        navigationItem.backButtonTitle = database.name
        navigationController?.pushViewController(destinationVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 62
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

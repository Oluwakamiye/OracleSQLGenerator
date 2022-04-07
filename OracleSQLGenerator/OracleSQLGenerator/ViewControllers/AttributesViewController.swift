//
//  AttributesViewController.swift
//  OracleSQLGenerator
//
//  Created by Oluwakamiye Akindele on 04/04/2022.
//

import UIKit
import MessageUI

class AttributesViewController: UIViewController {
    @IBOutlet weak private(set) var tableView: UITableView!
    typealias DataSource = UITableViewDiffableDataSource<Section, Attribute>
    typealias SnapShot = NSDiffableDataSourceSnapshot<Section, Attribute>
    private lazy var dataSource = makeDataSource()
    private var pickerView = UIPickerView()
    
    private var attributeTypeText: UITextField?
    private var viewModel = AttributesViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.delegate = self
        tableView.delegate = self
        pickerView.dataSource = self
        pickerView.delegate = self
        tableView.register(UINib(nibName: AttributeTableViewCell.reuseIdentifier, bundle: nil), forCellReuseIdentifier: AttributeTableViewCell.reuseIdentifier)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.updateTableTitle()
        viewModel.getAttributes()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        customiseNavigation()
        setupView()
    }
    
    private func setupView() {
        let toolBarButton = UIBarButtonItem(title: "➕ Add Attribute", style: .done, target: self, action: #selector(addAttribute))
        toolBarButton.setTitleTextAttributes([.foregroundColor: UIColor.systemGreen], for: .normal)
        toolBarButton.tintColor = UIColor.green
        
        let rightButton = UIButton()
        rightButton.setTitle("  Get Insert Query  ", for: .normal)
        rightButton.titleLabel?.font = UIFont(name: "Helvetica", size: 15)
        rightButton.setTitleColor(.label, for: .normal)
        rightButton.layer.borderWidth = 1.0
        rightButton.layer.cornerRadius = 6
        rightButton.layer.borderColor = UIColor.label.cgColor
        rightButton.backgroundColor = UIColor.clear
        rightButton.addTarget(self, action: #selector(createInsertQuery), for: .touchUpInside)
        let rightBarButton = UIBarButtonItem(customView: rightButton)
        navigationItem.rightBarButtonItem = rightBarButton
        
        navigationController?.toolbar.setItems([toolBarButton], animated: true)
    }
    
    @objc func createInsertQuery() {
        viewModel.createInsertQuery()
    }
    
    @objc func addAttribute() {
        let alert = UIAlertController(title: "Add New Attribute", message: "Name of new Attribute", preferredStyle: .alert)
        alert.addTextField()
        alert.addTextField()
        guard let nameTextField = alert.textFields?.first,
              let typeTextField = alert.textFields?[1] else {
            return
        }
        attributeTypeText = typeTextField
        nameTextField.placeholder = "Attribute Name"
        typeTextField.placeholder = "Select type"
        typeTextField.inputView = pickerView
        typeTextField.text = AttributeType.allCases[self.pickerView.selectedRow(inComponent: 0)].rawValue
        
        let createAction = UIAlertAction(title: "Create", style: .default, handler: {
            _ in
            self.viewModel.addNewAttribute(name: nameTextField.text, type: AttributeType.allCases[self.pickerView.selectedRow(inComponent: 0)])
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alert.addAction(createAction)
        alert.addAction(cancelAction)
        present(alert, animated: true)
    }
    
    private func makeDataSource() -> DataSource {
        let dataSource = DataSource(tableView: tableView, cellProvider: {
            (tableView, indexPath, attribute) -> UITableViewCell? in
            let cell = tableView.dequeueReusableCell(withIdentifier: AttributeTableViewCell.reuseIdentifier, for: indexPath) as? AttributeTableViewCell
            cell?.attribute = attribute
            return cell
        })
        return dataSource
    }
    
    static func makeSelf(databaseID: String, tableID: String) -> AttributesViewController? {
        guard let destinationVC = UIStoryboard.storyboard(.Main).instantiateViewController(withIdentifier: "AttributesViewController") as? AttributesViewController else { return nil }
        destinationVC.viewModel.databaseID = databaseID
        destinationVC.viewModel.tableID = tableID
        return destinationVC
    }
}

// MARK: TableView Delegates
extension AttributesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let attribute = dataSource.itemIdentifier(for: indexPath) else {
            return
        }
        navigationItem.backButtonTitle = "Attributes"
        viewModel.selectAttributeForEditing(attribute: attribute)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
}

// MARK: PickerView Delegate
extension AttributesViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return AttributeType.allCases.count
    }
    
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return AttributeType.allCases[row].rawValue
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        guard let attributeTypeText = attributeTypeText else {
            return
        }
        attributeTypeText.text = AttributeType.allCases[row].rawValue
        attributeTypeText.resignFirstResponder()
    }
}

// MARK: ViewModel Delegates
extension AttributesViewController: AttributesViewModelDelegate {
    func updateNavigationTitle(title: String) {
        navigationItem.title = "Attributes"
    }
    
    func updateAttributesList(attributes: [Attribute], animatingDifferences: Bool) {
        var snapshot = SnapShot()
        snapshot.appendSections([.main])
        snapshot.appendItems(attributes)
        dataSource.apply(snapshot, animatingDifferences: animatingDifferences)
    }
    
    func displayMailWindow(withQuery: String, tableName: String) {
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
//            mail.setToRecipients(["you@yoursite.com"])
            mail.setMessageBody(withQuery, isHTML: false)
            mail.setSubject("Insert Query for Table \(tableName.capitalized)")
            
            present(mail, animated: true)
        } else {
            // show failure alert
            showErrorAlert(error: "Cannot Send Mail")
        }
    }
    
    func goToEditAttributePage(databaseID: String, tableID: String, attributeID: String) {
        guard let destinationVC = EditAttributeViewController.makeSelf(databaseID: databaseID, tableID: tableID, attributeID: attributeID) else {
            return
        }
        navigationController?.pushViewController(destinationVC, animated: true)
    }
    
    func showError(errorTitle: String, errorDetail: String?) {
        showErrorAlert(error: errorTitle, message: errorDetail)
    }
}


extension AttributesViewController: MFMailComposeViewControllerDelegate {
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
        @unknown default:
            break
        }
        controller.dismiss(animated: true, completion: nil)
    }
}

//
//  CreateEditAttributeViewController.swift
//  OracleSQLGenerator
//
//  Created by Oluwakamiye Akindele on 04/04/2022.
//

import UIKit

class EditAttributeViewController: UIViewController {
    @IBOutlet weak private(set) var attributeNameText: UITextField!
    @IBOutlet weak private(set) var attributeTypeText: UITextField!
    @IBOutlet weak private(set) var nullConstraintButton: UIButton!
    @IBOutlet weak private(set) var uniqueConstraintButton: UIButton!
    @IBOutlet weak private(set) var primaryKeyConstraintButton: UIButton!
    @IBOutlet weak private(set) var addForeignKeyButtonView: UIView!
    @IBOutlet weak private(set) var addFKContraintKeyButton: UIButton!
    @IBOutlet weak private(set) var foreignKeyDetailsStackView: UIStackView!
    @IBOutlet weak private(set) var foreignKeyDetailLabel: UILabel!
    
    private var viewModel = EditAttributeViewModel()
    private var typePickerView = UIPickerView()
    private var tablePicker = UIPickerView()
    private var keyPicker = UIPickerView()
    private var foreignTableText: UITextField?
    private var foreignAttributeText: UITextField?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.delegate = self
        // Setting Tags
        typePickerView.tag = 0
        tablePicker.tag = 1
        keyPicker.tag = 2
        // PickerView Delegates
        typePickerView.delegate = viewModel
        typePickerView.dataSource = viewModel
        tablePicker.delegate = viewModel
        tablePicker.dataSource = viewModel
        keyPicker.delegate = viewModel
        keyPicker.dataSource = viewModel
        // TextView Delegate
        attributeNameText.delegate = viewModel
        attributeTypeText.delegate = viewModel
        navigationController?.navigationBar.prefersLargeTitles = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setupViews()
        viewModel.loadAttributeInformation()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    private func setupViews() {
        attributeTypeText.inputView = typePickerView
        
        foreignKeyDetailsStackView.layer.borderColor = UIColor.label.cgColor
        foreignKeyDetailsStackView.layer.borderWidth = 1.0
        foreignKeyDetailsStackView.layer.cornerRadius = 6
        foreignKeyDetailsStackView.isLayoutMarginsRelativeArrangement = true
        foreignKeyDetailsStackView.layoutMargins = UIEdgeInsets(top: 1, left: 5, bottom: 1, right: 1)
        
        addFKContraintKeyButton.layer.borderColor = UIColor.systemYellow.cgColor
        addFKContraintKeyButton.layer.borderWidth = 1.0
        addFKContraintKeyButton.layer.cornerRadius = 6
        
        let rightButton = UIButton()
        rightButton.setTitle("  Save Changes  ", for: .normal)
        rightButton.titleLabel?.font = UIFont(name: "Helvetica", size: 15)
        rightButton.setTitleColor(.white, for: .normal)
        rightButton.layer.borderWidth = 0.0
        rightButton.layer.cornerRadius = 6
        rightButton.layer.borderColor = UIColor.label.cgColor
        rightButton.backgroundColor = UIColor.systemGreen
        rightButton.addTarget(self, action: #selector(saveChangesTapped), for: .touchUpInside)
        let rightBarButton = UIBarButtonItem(customView: rightButton)
        navigationItem.rightBarButtonItem = rightBarButton
    }
    
    @IBAction func toggleNullConstraintTapped(_ sender: UIButton) {
        viewModel.toggleAttributeNullConstraint()
    }
    
    @IBAction func toggleUniqueConstraintTapped(_ sender: UIButton) {
        viewModel.toggleUniqueKeyConstraint()
    }
    
    @IBAction func makePrimaryKeyTapped(_ sender: UIButton) {
        viewModel.togglePrimaryKeyConstraint()
    }
    
    @objc func saveChangesTapped() {
        let alertController = UIAlertController(title: "Save Changes", message: "Save changes made to attribute", preferredStyle: .alert)
        let saveAction = UIAlertAction(title: "Save changes", style: .default, handler: {
            _ in
            self.viewModel.saveAttributeChanges(name: self.attributeNameText.text)
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alertController.addAction(saveAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true)
    }
    
    @IBAction func cancelTapped(_ sender: UIButton) {
        viewModel.cancelAttributeChanges()
    }
    
    @IBAction func addForeignKeyButtonTapped(_ sender: UIButton) {
        viewModel.updateTablesList()
        // show alert
        let alert = UIAlertController(title: "Add New Foreign Key", message: "Name of new Attribute", preferredStyle: .alert)
        alert.addTextField()
        alert.addTextField()
        guard let foreignTableTextField = alert.textFields?.first,
              let foreignAttributeTextField = alert.textFields?[1] else {
            return
        }
        foreignTableText = foreignTableTextField
        foreignAttributeText = foreignAttributeTextField
        foreignTableTextField.placeholder = "Select table"
        foreignAttributeTextField.placeholder = "Select Foreign Key"
        foreignTableTextField.inputView = tablePicker
        foreignAttributeTextField.inputView = keyPicker
        
        let createAction = UIAlertAction(title: "Create", style: .default, handler: {
            _ in
            self.viewModel.createForeignKeyConstraint()
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alert.addAction(createAction)
        alert.addAction(cancelAction)
        present(alert, animated: true)
    }
    
    static func makeSelf(databaseID: String, tableID: String, attributeID: String) -> EditAttributeViewController? {
        guard let destinationVC = UIStoryboard.storyboard(.Main).instantiateViewController(withIdentifier: "EditAttributeViewController") as? EditAttributeViewController else { return nil }
        destinationVC.viewModel.databaseID = databaseID
        destinationVC.viewModel.tableID = tableID
        destinationVC.viewModel.attributeID = attributeID
        return destinationVC
    }
}

// MARK: ViewModel Delegates
extension EditAttributeViewController: EditAttributeViewModelDelegate {
    func updateViewsWithAttribute(attribute: Attribute) {
        navigationItem.title = attribute.name
        attributeNameText.text = attribute.name
        attributeTypeText.text = attribute.type.rawValue
    }
    
    func dismissView() {
        goBackTwoViews()
//        navigationController?.popViewController(animated: true)
    }
    
    internal func updateButtonImages(attribute: inout Attribute) {
        resignFirstResponder()
        if attribute.isPrimaryKey {
            primaryKeyConstraintButton.setImage(UIImage(systemName: "checkmark.circle.fill"), for: .normal)
            attribute.isUnique = false
            attribute.isNullable = true
            primaryKeyConstraintButton.tintColor = .systemGreen
        } else {
            primaryKeyConstraintButton.setImage(UIImage(systemName: "circle"), for: .normal)
            primaryKeyConstraintButton.tintColor = .darkGray
        }
        
        if attribute.isNullable {
            nullConstraintButton.setImage(UIImage(systemName: "circle"), for: .normal)
            nullConstraintButton.tintColor = .darkGray
        } else {
            nullConstraintButton.setImage(UIImage(systemName: "checkmark.circle.fill"), for: .normal)
            nullConstraintButton.tintColor = .systemGreen
        }
        
        if attribute.isUnique {
            uniqueConstraintButton.setImage(UIImage(systemName: "checkmark.circle.fill"), for: .normal)
            uniqueConstraintButton.tintColor = .systemGreen
        } else {
            uniqueConstraintButton.setImage(UIImage(systemName: "circle"), for: .normal)
            uniqueConstraintButton.tintColor = .darkGray
        }
    }
    
    func updateTypeText(associatedPickerTag: Int, text: String) {
        switch associatedPickerTag {
        case 0:
            attributeTypeText.text = text
        case 1:
            foreignTableText?.text = text
        case 2:
            foreignAttributeText?.text = text
        default:
            return
        }
    }
    
    func giveUpResponder(associatedPickerTag: Int) {
        switch associatedPickerTag {
        case 0:
            attributeTypeText.resignFirstResponder()
        case 1:
            foreignTableText?.resignFirstResponder()
        case 2:
            foreignAttributeText?.resignFirstResponder()
        default:
            return
        }
    }
    
    func shouldDisplayForeignKeyText(shouldShow: Bool) {
        addForeignKeyButtonView.isHidden = shouldShow
        foreignKeyDetailsStackView.isHidden = !shouldShow
    }
    
    func updateForeignKeyLabelText(text: String) {
        foreignKeyDetailLabel.text = text
    }
    
    func reloadTablesPicker() {
        tablePicker.reloadAllComponents()
    }
    
    func reloadAttributesPicker() {
        keyPicker.reloadAllComponents()
    }
    
    func shouldShowAttributesPicker(shouldShow: Bool) {
        foreignAttributeText?.isHidden = !shouldShow
    }
    
    func showError(errorTitle: String, errorDetail: String?) {
        showErrorAlert(error: errorTitle, message: errorDetail)
    }
}

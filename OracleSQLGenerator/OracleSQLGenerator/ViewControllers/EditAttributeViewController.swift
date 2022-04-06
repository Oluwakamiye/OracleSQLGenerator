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
    @IBOutlet weak var nullConstraintButton: UIButton!
    @IBOutlet weak var uniqueConstraintButton: UIButton!
    @IBOutlet weak var primaryKeyConstraintButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    private var viewModel = EditAttributeViewModel()
    private var typePickerView = UIPickerView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.delegate = self
        typePickerView.delegate = viewModel
        typePickerView.dataSource = viewModel
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
        saveButton.layer.cornerRadius = 6.0
        cancelButton.layer.cornerRadius = 6.0
        saveButton.layer.borderColor = UIColor.darkGray.cgColor
        saveButton.layer.borderWidth = 1.0
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
    
    @IBAction func saveChangesTapped(_ sender: UIButton) {
        let alertController = UIAlertController(title: "Save Changes", message: "Save changes made to attribute", preferredStyle: .alert)
        let saveAction = UIAlertAction(title: "Save changes", style: .default, handler: {
            _ in
            self.viewModel.saveAttributeChanges()
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alertController.addAction(saveAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true)
    }
    
    @IBAction func cancelTapped(_ sender: UIButton) {
        viewModel.cancelAttributeChanges()
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
            attribute.isNull = true
            primaryKeyConstraintButton.tintColor = .systemGreen
        } else {
            primaryKeyConstraintButton.setImage(UIImage(systemName: "circle"), for: .normal)
            primaryKeyConstraintButton.tintColor = .darkGray
        }
        
        if attribute.isNull {
            nullConstraintButton.setImage(UIImage(systemName: "checkmark.circle.fill"), for: .normal)
            nullConstraintButton.tintColor = .systemGreen
        } else {
            nullConstraintButton.setImage(UIImage(systemName: "circle"), for: .normal)
            nullConstraintButton.tintColor = .darkGray
        }
        
        if attribute.isUnique {
            uniqueConstraintButton.setImage(UIImage(systemName: "checkmark.circle.fill"), for: .normal)
            uniqueConstraintButton.tintColor = .systemGreen
        } else {
            uniqueConstraintButton.setImage(UIImage(systemName: "circle"), for: .normal)
            uniqueConstraintButton.tintColor = .darkGray
        }
    }
    
    func updateTypeText(text: String) {
        attributeTypeText.text = text
    }
    
    func giveUpResponder() {
        resignFirstResponder()
    }
    
    func showError(errorTitle: String, errorDetail: String?) {
        showErrorAlert(error: errorTitle, message: errorDetail)
    }
}

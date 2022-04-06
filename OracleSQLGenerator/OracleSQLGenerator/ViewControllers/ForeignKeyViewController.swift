//
//  ForeignKeyViewController.swift
//  OracleSQLGenerator
//
//  Created by Oluwakamiye Akindele on 06/04/2022.
//

import UIKit

class ForeignKeyViewController: UIViewController {
    @IBOutlet private(set) weak var foreignKeyStack: UIStackView!
    @IBOutlet private(set) weak var foreignTableTextField: UITextField!
    @IBOutlet private(set) weak var foreignAttributeTextField: UITextField!
    
    private var tablePicker: UIPickerView!
    private var keyPicker: UIPickerView!
    
    private var databaseID: String = ""
    private var tableID: String = ""
    private var attribute: Attribute?
    
    private var database: Database?
    private var tables = [Table]()
    private var foreignAttributes = [Attribute]()
    
    private var selectedTable: Table? {
        didSet {
            if selectedTable != nil {
                foreignTableTextField.text = selectedTable!.name
                keyPicker.reloadAllComponents()
                foreignTableTextField.resignFirstResponder()
                foreignKeyStack.isHidden = false
                foreignAttributes = selectedTable!.attributes
            }
        }
    }
    private var selectedForeignAttribute: Attribute? {
        didSet {
            if selectedForeignAttribute != nil {
                foreignAttributeTextField.text = selectedForeignAttribute!.name
                foreignAttributeTextField.resignFirstResponder()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        tablePicker.delegate = self
        tablePicker.dataSource = self
        keyPicker.delegate = self
        keyPicker.dataSource = self
        foreignTableTextField.inputView = tablePicker
        foreignAttributeTextField.inputView = keyPicker
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        addNavigationButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupTablesData()
    }
    
    func addNavigationButton() {
        let rightButton = UIButton()
        rightButton.setTitle(" ➕ Add ", for: .normal)
        rightButton.titleLabel?.font = UIFont(name: "Helvetica", size: 15)
        rightButton.setTitleColor(.label, for: .normal)
        rightButton.layer.borderWidth = 1.0
        rightButton.layer.cornerRadius = 6
        rightButton.layer.borderColor = UIColor.label.cgColor
        rightButton.backgroundColor = UIColor.clear
        rightButton.addTarget(self, action: #selector(addForeignKeyConstraint), for: .touchUpInside)
        let rightBarButton = UIBarButtonItem(customView: rightButton)
        navigationItem.rightBarButtonItem = rightBarButton
    }
    
    @objc func addForeignKeyConstraint() {
        guard let selectedForeignAttribute = selectedForeignAttribute,
              let attribute = attribute,
              let database = database else {
            return
        }
        if selectedForeignAttribute.type == attribute.type {
            
        } else {
            showErrorAlert(error: "Type Mismatch", message: "Foreign key has a different type from attribute")
            return
        }
        
    }
    
    func setupTablesData() {
        guard let database = Helper.shared.record.databases.first(where: {$0.id == databaseID}) else {
            return
        }
        tables = database.tables
        tablePicker.reloadAllComponents()
    }
    
    static func makeSelf(attribute: Attribute, databaseID: String) -> ForeignKeyViewController? {
        guard let destinationVC = UIStoryboard.storyboard(.Main).instantiateViewController(withIdentifier: "ForeignKeyViewController") as? ForeignKeyViewController else { return nil }
        destinationVC.attribute = attribute
        return destinationVC
    }
}


// MARK: PickerViewDelegates
extension ForeignKeyViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == tablePicker {
            return tables.count
        } else {
            return foreignAttributes.count
        }
    }
    
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == tablePicker {
            return tables[row].name
        } else {
            return foreignAttributes[row].name
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == tablePicker {
            selectedTable = tables[row]
        } else {
            selectedForeignAttribute = foreignAttributes[row]
        }
    }
}

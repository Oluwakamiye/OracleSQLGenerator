//
//  EditAttributeViewModel.swift
//  OracleSQLGenerator
//
//  Created by Oluwakamiye Akindele on 06/04/2022.
//

import UIKit

protocol EditAttributeViewModelDelegate: BaseModelDelegate {
    func updateViewsWithAttribute(attribute: Attribute)
    func updateButtonImages(attribute: inout Attribute)
    func updateTypeText(associatedPickerTag: Int, text: String)
    func giveUpResponder(associatedPickerTag: Int)
    func shouldDisplayForeignKeyText(shouldShow: Bool)
    func updateForeignKeyLabelText(text: String)
    func reloadTablesPicker()
    func reloadAttributesPicker()
    func shouldShowAttributesPicker(shouldShow: Bool)
    func dismissView()
}

final class EditAttributeViewModel: NSObject {
    weak var delegate: EditAttributeViewModelDelegate?
    private var record: Record!
    var databaseID: String = ""
    var tableID: String = ""
    var attributeID: String = ""
    private var attributeCopy: Attribute!
    
    private var database: Database?
    private var tables = [Table]()
    private var foreignAttributes = [Attribute]()
    
    private var selectedTable: Table? {
        didSet {
            guard let selectedTable = selectedTable,
                  let delegate = delegate else {
                return
            }
            foreignAttributes = selectedTable.attributes
            delegate.reloadAttributesPicker()
            delegate.shouldShowAttributesPicker(shouldShow: true)
        }
    }
    private var selectedForeignAttribute: Attribute?
    
    func loadAttributeInformation() {
        record = Helper.shared.record.copy() as? Record
        guard let delegate = delegate,
              let database = record.databases.first(where: {$0.id == databaseID})?.copy() as? Database,
              let table = database.tables.first(where: {$0.id == tableID})?.copy() as? Table,
              let attribute = table.attributes.first(where: {$0.id == attributeID})?.copy() as? Attribute
        else {
            return
        }
        self.database = database
        attributeCopy = attribute
        self.tables = database.tables
        delegate.updateViewsWithAttribute(attribute: attributeCopy)
        delegate.updateButtonImages(attribute: &attributeCopy)
        delegate.shouldDisplayForeignKeyText(shouldShow: attributeCopy.foreignKeyConstraint != nil)
    }
    
    func toggleAttributeNullConstraint() {
        guard let delegate = delegate,
              var attribute = attributeCopy else {
            return
        }
        attribute.isNull.toggle()
        delegate.updateButtonImages(attribute: &attribute)
        self.attributeCopy = attribute
    }
    
    func togglePrimaryKeyConstraint() {
        guard let delegate = delegate,
              let database = record.databases.first(where: {$0.id == databaseID}),
              let table = database.tables.first(where: {$0.id == tableID}),
              var attribute = attributeCopy else {
            return
        }
        attribute.isPrimaryKey.toggle()
        if attribute.isPrimaryKey {
            for attr in table.attributes {
                if attr != attribute {
                    attr.isPrimaryKey = false
                }
            }
        }
        delegate.updateButtonImages(attribute: &attribute)
        self.attributeCopy = attribute
    }
    
    func toggleUniqueKeyConstraint() {
        guard let delegate = delegate,
              var attribute = attributeCopy else {
            return
        }
        attribute.isUnique.toggle()
        delegate.updateButtonImages(attribute: &attribute)
        self.attributeCopy = attribute
    }
    
    func saveAttributeChanges() {
        guard let delegate = delegate,
              let database = record.databases.first(where: {$0.id == databaseID}),
              let databaseIndex = record.databases.firstIndex(of: database),
              let table = database.tables.first(where: {$0.id == tableID}),
              let tableIndex = database.tables.firstIndex(of: table),
              var attribute = table.attributes.first(where: {$0.id == attributeID}),
              let attributeIndex = table.attributes.firstIndex(of: attribute),
              let attributeCopy = attributeCopy else {
            return
        }
        attribute = attributeCopy
        table.attributes[attributeIndex] = attribute
        database.tables[tableIndex] = table
        record.databases[databaseIndex] = database
        Helper.shared.record = record
        delegate.dismissView()
    }
    
    func cancelAttributeChanges() {
        guard let delegate = delegate else {
            return
        }
        delegate.dismissView()
    }
    
    func createForeignKeyConstraint() {
        guard let primaryKeyTable = selectedTable,
              let primaryKeyAttribute = selectedForeignAttribute,
              let delegate = delegate else {
            return
        }
        let constraint = ForeignKeyRelationConstraint(primaryKeyTableID: primaryKeyTable.id, primaryKeyAttributeID: primaryKeyAttribute.id)
        attributeCopy.foreignKeyConstraint = constraint
        delegate.shouldDisplayForeignKeyText(shouldShow: self.attributeCopy.foreignKeyConstraint != nil)
        let text = "REFERENCES COLUMN(\(primaryKeyAttribute.name)) FROM TABLE (\(primaryKeyTable.name))"
        delegate.updateForeignKeyLabelText(text: text)
    }
    
    func updateTablesList() {
        guard let database = database,
                let delegate = delegate else {
            return
        }
        tables = database.tables
        delegate.reloadTablesPicker()
    }
    
    func removeAttribute() {
        
    }
}


// MARK: PickerView Delegate
extension EditAttributeViewModel: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch pickerView.tag {
        case 0:
            return AttributeType.allCases.count
        case 1:
            return tables.count
        case 2:
            return foreignAttributes.count
        default:
            return 0
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch pickerView.tag {
        case 0:
            return AttributeType.allCases[row].rawValue
        case 1:
            return tables[row].name
        case 2:
            return foreignAttributes[row].name
        default:
            return nil
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        guard let delegate = delegate else {
            return
        }
        var text = ""
        switch pickerView.tag {
        case 0:
            attributeCopy?.type = AttributeType.allCases[row]
            text = AttributeType.allCases[row].rawValue
        case 1:
            selectedTable = tables[row]
            text = tables[row].name
        case 2:
            selectedForeignAttribute = foreignAttributes[row]
            text = foreignAttributes[row].name
        default:
            return
        }
        delegate.updateTypeText(associatedPickerTag: pickerView.tag, text: text)
        delegate.giveUpResponder(associatedPickerTag: pickerView.tag)
    }
}

// MARK: TextField Delegate
extension EditAttributeViewModel: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

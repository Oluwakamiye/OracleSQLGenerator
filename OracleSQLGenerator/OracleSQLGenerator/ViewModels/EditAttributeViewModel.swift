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
    func updateTypeText(text: String)
    func giveUpResponder()
    func dismissView()
}

final class EditAttributeViewModel: NSObject {
    weak var delegate: EditAttributeViewModelDelegate?
    private var record = Helper.shared.record
    var databaseID: String = ""
    var tableID: String = ""
    var attributeID: String = ""
    private var attributeCopy: Attribute!
    
    
    func loadAttributeInformation() {
        guard let delegate = delegate,
              let database = record.databases.first(where: {$0.id == databaseID}),
              let table = database.tables.first(where: {$0.id == tableID}),
              let attribute = table.attributes.first(where: {$0.id == attributeID})
        else {
            return
        }
        self.attributeCopy = attribute
        delegate.updateViewsWithAttribute(attribute: attribute)
        delegate.updateButtonImages(attribute: &attributeCopy)
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
    
    func removeAttribute() {
        
    }
}


// MARK: PickerView Delegate
extension EditAttributeViewModel: UIPickerViewDelegate, UIPickerViewDataSource {
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
        guard let delegate = delegate else {
            return
        }
        attributeCopy?.type = AttributeType.allCases[row]
        delegate.updateTypeText(text: AttributeType.allCases[row].rawValue)
        delegate.giveUpResponder()
    }
}

// MARK: TextField Delegate
extension EditAttributeViewModel: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let delegate = delegate else {
            return false
        }
        delegate.giveUpResponder()
        return true
    }
}

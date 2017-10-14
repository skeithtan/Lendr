//
//  AddLoanFormViewController.swift
//  Lendr
//
//  Created by Keith Tan on 14/10/2017.
//  Copyright © 2017 Axis. All rights reserved.
//

import UIKit
import Contacts
import SearchTextField

class AddLoanFormVC: UITableViewController {
    
    @IBOutlet weak var lendingCell: UITableViewCell!
    @IBOutlet weak var borrowingCell: UITableViewCell!
    
    @IBOutlet weak var cashCell: UITableViewCell!
    @IBOutlet weak var itemCell: UITableViewCell!
    
    @IBOutlet weak var itemNameLabel: UILabel!
    @IBOutlet weak var itemValueTextField: SearchTextField!
    
    @IBOutlet weak var personNameLabel: UILabel!
    @IBOutlet weak var personNameTextField: SearchTextField!
    
    @IBOutlet weak var returnDatePicker: UIDatePicker!
    
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    var onAddLoan: ((Loan) -> Void)?
        
    fileprivate var isLend = true {
        didSet {
            self.personNameLabel.text = isLend ? "Lending to" : "Borrowing from"
        }
    }
    fileprivate var isCash = true {
        didSet {
            self.itemValueTextField.resignFirstResponder()
            
            if isCash {
                itemNameLabel.text = "Amount"
                itemValueTextField.text = ""
                itemValueTextField.placeholder = "Amount"
                itemValueTextField.keyboardType = .numberPad
            } else {
                itemNameLabel.text = "Item name"
                itemValueTextField.text = ""
                itemValueTextField.placeholder = "Item name"
                itemValueTextField.keyboardType = .default
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        lendingCell.accessoryType = .checkmark
        cashCell.accessoryType = .checkmark
        
        if CNContactStore.authorizationStatus(for: .contacts) == .notDetermined {
            CNContactStore().requestAccess(for: .contacts) {_, _ in }
        }
                
        personNameTextField.userStoppedTypingHandler = {
            self.validateForm()

            guard let text = self.personNameTextField.text, !text.isEmpty else {
                return
            }
            
            self.personNameTextField.showLoadingIndicator()
            
            let searchItems = self.autocompleteContacts(forString: text)
            
            self.personNameTextField.filterItems(searchItems.map { contact in
                SearchTextFieldItem(title: contact.0, subtitle: contact.1)
            })
            
            self.personNameTextField.stopLoadingIndicator()
            
        }
        
        itemValueTextField.userStoppedTypingHandler = {
            guard let _ = self.itemValueTextField.text else {
                return
            }
            
            self.validateForm()
        }
        
        saveButton.isEnabled = false
    }
    
    func validateForm() {
        let itemFilled = !(itemValueTextField.text?.isEmpty ?? true)
        let personFilled = !(personNameTextField.text?.isEmpty ?? true)
        
        self.saveButton.isEnabled = itemFilled && personFilled
    }
    
    @IBAction func onCancelButtonClick(_ sender: Any) {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onSaveButtonClick(_ sender: Any) {
        self.navigationController?.dismiss(animated: true, completion: nil)
        
        let loan = Loan()
        loan.itemName = itemValueTextField.text ?? ""
        loan.person = personNameTextField.text ?? ""
        loan.dueDate = returnDatePicker.date
        loan.isCash = self.isCash
        loan.typeInt = self.isLend ? Loan.LoanType.lend.rawValue : Loan.LoanType.borrow.rawValue
        
        self.onAddLoan?(loan)
        //TODO: Return data
    }
    
    fileprivate func autocompleteContacts(forString str: String) -> [(String, String?)] {
        guard CNContactStore.authorizationStatus(for: .contacts) == .authorized else {
            return []
        }
        
        let store = CNContactStore()
        
        let predicate = CNContact.predicateForContacts(matchingName: str)
        let keysToFetch = [CNContactFormatter.descriptorForRequiredKeys(for: .fullName)]
        
        guard let contacts = try? store.unifiedContacts(matching: predicate, keysToFetch: keysToFetch) else {
            return []
        }
        
        return contacts.map { contact in
            let nickname = contact.nickname.isEmpty ? nil : contact.nickname
            let name = contact.givenName + " " + contact.familyName
            
            return (name, nickname)
        }
    }
    
    //MARK: - UITableViewDelegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            // Lending vs borrowing
            isLend = indexPath.row == 0
            
            if indexPath.row == 0 {
                lendingCell.accessoryType = .checkmark
                borrowingCell.accessoryType = .none
            } else {
                lendingCell.accessoryType = .none
                borrowingCell.accessoryType = .checkmark
            }
        case 1:
            // Cash vs Item
            
            isCash = indexPath.row == 0
            
            if indexPath.row == 0 {
                cashCell.accessoryType = .checkmark
                itemCell.accessoryType = .none
            } else {
                cashCell.accessoryType = .none
                itemCell.accessoryType = .checkmark
            }
        case 2:
            if indexPath.row == 0 {
                itemValueTextField.becomeFirstResponder()
            } else {
                personNameTextField.becomeFirstResponder()
            }
        default:
            break
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
}


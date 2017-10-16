//
//  AddLoanFormViewController.swift
//  Lendr
//
//  Created by Keith Tan on 14/10/2017.
//  Copyright © 2017 Axis. All rights reserved.
//

import UIKit
import SearchTextField

class AddLoanFormVC: UITableViewController {
    
    @IBOutlet weak var lendingCell: UITableViewCell!
    @IBOutlet weak var borrowingCell: UITableViewCell!
    
    @IBOutlet weak var cashCell: UITableViewCell!
    @IBOutlet weak var itemCell: UITableViewCell!
    
    @IBOutlet weak var itemNameLabel: UILabel!
    @IBOutlet weak var itemNameTextField: SearchTextField!
    
    @IBOutlet weak var personNameLabel: UILabel!
    @IBOutlet weak var personNameTextField: SearchTextField!
    
    @IBOutlet weak var returnDatePicker: UIDatePicker!
    
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    var onAddLoan: ((Loan) -> Void)?
        
    fileprivate var isLend = true {
        didSet {
            self.personNameLabel.text = isLend ? "Lending to" : "Borrowing from"
            
            if isLend {
                lendingCell.accessoryType = .checkmark
                borrowingCell.accessoryType = .none
            } else {
                lendingCell.accessoryType = .none
                borrowingCell.accessoryType = .checkmark
            }
        }
    }
    fileprivate var isCash = true {
        didSet {
            self.itemNameTextField.resignFirstResponder()
            
            if isCash {
                cashCell.accessoryType = .checkmark
                itemCell.accessoryType = .none
                
                itemNameLabel.text = "Amount"
                itemNameTextField.text = ""
                itemNameTextField.placeholder = "Amount"
                itemNameTextField.keyboardType = .numberPad
            } else {
                cashCell.accessoryType = .none
                itemCell.accessoryType = .checkmark
                
                itemNameLabel.text = "Item name"
                itemNameTextField.text = ""
                itemNameTextField.placeholder = "Item name"
                itemNameTextField.keyboardType = .default
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        lendingCell.accessoryType = .checkmark
        cashCell.accessoryType = .checkmark
        
        
                
        personNameTextField.userStoppedTypingHandler = {
            self.validateForm()

            guard let text = self.personNameTextField.text, !text.isEmpty else {
                return
            }
            
            self.personNameTextField.showLoadingIndicator()
            
            let searchItems = UserContacts.autocompleteContacts(forString: text)
            
            self.personNameTextField.filterItems(searchItems.map { contact in
                SearchTextFieldItem(title: contact.0, subtitle: contact.1)
            })
            
            self.personNameTextField.stopLoadingIndicator()
            
        }
        
        itemNameTextField.userStoppedTypingHandler = {
            guard let _ = self.itemNameTextField.text else {
                return
            }
            
            self.validateForm()
        }
        
        saveButton.isEnabled = false
    }
    
    func validateForm() {
        let itemFilled = !(itemNameTextField.text?.isEmpty ?? true)
        let personFilled = !(personNameTextField.text?.isEmpty ?? true)
        
        self.saveButton.isEnabled = itemFilled && personFilled
    }
    
    @IBAction func onCancelButtonClick(_ sender: Any) {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onSaveButtonClick(_ sender: Any) {
        self.navigationController?.dismiss(animated: true, completion: nil)
        
        let loan = Loan()
        loan.itemName = itemNameTextField.text ?? ""
        loan.person = personNameTextField.text ?? ""
        loan.dueDate = returnDatePicker.date
        loan.isCash = self.isCash
        loan.typeInt = self.isLend ? Loan.LoanType.lend.rawValue : Loan.LoanType.borrow.rawValue
        
        self.onAddLoan?(loan)
        //TODO: Return data
    }
    
    
    
    //MARK: - UITableViewDelegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            // Lending vs borrowing
            isLend = indexPath.row == 0
        case 1:
            // Cash vs Item
            
            isCash = indexPath.row == 0
        case 2:
            if indexPath.row == 0 {
                itemNameTextField.becomeFirstResponder()
            } else {
                personNameTextField.becomeFirstResponder()
            }
        default:
            break
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
}


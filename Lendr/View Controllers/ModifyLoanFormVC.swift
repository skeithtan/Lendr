//
//  ModifyLoanFormVC.swift
//  Lendr
//
//  Created by Keith Tan on 15/10/2017.
//  Copyright © 2017 Axis. All rights reserved.
//

import UIKit

class ModifyLoanFormVC: UITableViewController {
    
    @IBOutlet weak var lendingCell: UITableViewCell!
    @IBOutlet weak var borrowingCell: UITableViewCell!
    
    @IBOutlet weak var itemNameLabel: UILabel!
    @IBOutlet weak var itemNameTextField: UITextField!
    
    @IBOutlet weak var personNameLabel: UILabel!
    @IBOutlet weak var personNameTextField: UITextField!
    
    @IBOutlet weak var returnDatePicker: UIDatePicker!
    
    var loan: Loan?
    var onModifyLoan: ((Loan) -> Void)?
    
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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let loan = self.loan else {
            return
        }
        
        self.isLend = loan.type == .lend
        
        if loan.isCash {
            self.itemNameLabel.text = "Amount"
            self.itemNameTextField.keyboardType = .numberPad
        } else {
            self.itemNameLabel.text = "Item Name"
            self.itemNameTextField.keyboardType = .default
        }
        
        self.itemNameTextField.text = loan.itemName
        self.personNameTextField.text = loan.person
        
        self.returnDatePicker.date = loan.dueDate
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        switch indexPath.section {
        case 0:
            self.isLend = indexPath.row == 0
        case 1:
            if indexPath.row == 0 {
                self.itemNameTextField.becomeFirstResponder()
            } else {
                self.personNameTextField.becomeFirstResponder()
            }
        default:
            break
        }
        
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    @IBAction func onSaveButtonClick(_ sender: Any) {
        
        guard let loan = self.loan else {
            self.navigationController?.dismiss(animated: true, completion: nil)
            return
        }
        
        let newLoan = Loan()
        newLoan.id = loan.id
        newLoan.type = self.isLend ? Loan.LoanType.lend : Loan.LoanType.borrow
        newLoan.dueDate = self.returnDatePicker.date
        newLoan.itemName = self.itemNameTextField.text ?? loan.itemName
        newLoan.person = self.personNameTextField.text ?? loan.person
        
        self.onModifyLoan?(newLoan)
        
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onCancelButtonClick(_ sender: Any) {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
}

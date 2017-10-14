//
//  LentItemCell.swift
//  Lendr
//
//  Created by Keith Tan on 12/10/2017.
//  Copyright © 2017 Axis. All rights reserved.
//

import UIKit

class LoanCell: UITableViewCell {
    
    @IBOutlet weak var loanTypeLabel: UILabel!
    @IBOutlet weak var personNameLabel: UILabel!
    @IBOutlet weak var loanItemNameLabel: UILabel!
    @IBOutlet weak var timeLeftLabel: UILabel!
    @IBOutlet weak var colorStripView: UIView!
    
    fileprivate let colorScheme: [String: UIColor] = [
        "Today":  UIColor(red:0.89, green:0.69, blue:0.04, alpha:1.0),
        "Lending": UIColor(red:0.00, green:0.48, blue:1.00, alpha:1.0),
        "Borrowing": UIColor(red:0.27, green:0.76, blue:0.35, alpha:1.0),
        "Overdue": UIColor(red: 1.0, green: 0.1764, blue: 0.333, alpha: 1.0),
    ]
    
    
    func fillWith(loan: Loan) {
        
        print(loanTypeLabel)
        
        loanItemNameLabel?.text = loan.isCash ? "₱\(loan.itemName)" : loan.itemName
        
        switch loan.type {
        case .lend:
            loanTypeLabel.text = "Lending"
            personNameLabel.text = "to \(loan.person)"
            colorStripView.backgroundColor = colorScheme["Lending"]
        case .borrow:
            loanTypeLabel.text = "Borrowing"
            personNameLabel.text = "from \(loan.person)"
            colorStripView.backgroundColor = colorScheme["Borrowing"]
        }
        
        
        let calendar = Calendar.current
        
        let dateDue = calendar.startOfDay(for: loan.dueDate)
        let today = calendar.startOfDay(for: Date())
        
        let components = calendar.dateComponents([.day], from: today, to: dateDue)
        let daysLeft = components.day ?? 0
        
        
        switch daysLeft {
        case 0:
            timeLeftLabel.text = "Today"
            timeLeftLabel.textColor = colorScheme["Today"]
        case 1:
            timeLeftLabel.text = "Tomorrow"
        case 2...Int.max:
            timeLeftLabel.text = "In \(daysLeft) days"
        default:
            timeLeftLabel.text = "Overdue"
            colorStripView.backgroundColor = colorScheme["Overdue"]
            timeLeftLabel.textColor = colorScheme["Overdue"]
        }
        
        
        //TODO: Time Left
        
    }
    
}

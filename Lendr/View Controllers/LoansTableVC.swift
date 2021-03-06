//
//  LoansTableViewController.swift
//  Lendr
//
//  Created by Keith Tan on 13/10/2017.
//  Copyright © 2017 Axis. All rights reserved.
//

import UIKit
import RealmSwift
import LKAlertController

class LoansTableVC: UITableViewController {
    
    fileprivate var realm: Realm = try! Realm()
    
    
    var searchPerson: String? = nil {
        didSet {
            let allLoans = realm
                .objects(Loan.self)
                .sorted(byKeyPath: "dueDate", ascending: true)
            
            if let search = searchPerson {
                self.loans = allLoans.filter("person CONTAINS %@", search)
            } else {
                self.loans = allLoans
            }
            
            tableView.reloadData()
        }
    }
    
    // All Loans
    var loans = try! Realm()
            .objects(Loan.self)
            .sorted(byKeyPath: "dueDate", ascending: true)
    
    // All unreturned
    var unreturnedLoans: [Loan] {
        return loans.filter { loan in !loan.isReturned }
    }
    
    // All returned
    var returnedLoans: [Loan] {
        return loans.filter { loan in loan.isReturned }
    }
    
    // All unreturned and overdue
    var overdueLoans: [Loan] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        return unreturnedLoans.filter { loan in
            let dateDue = calendar.startOfDay(for: loan.dueDate)
            let components = calendar.dateComponents([.day], from: today, to: dateDue)
            
            return components.day! < 0 //No difference between today and date due
        }
    }
    
    // All that should be returned today
    var returnToday: [Loan] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        return unreturnedLoans.filter { loan in
            let dateDue = calendar.startOfDay(for: loan.dueDate)
            let components = calendar.dateComponents([.day], from: today, to: dateDue)
            
            return components.day == 0 //No difference between today and date due
        }
    }
    
    // All unreturned but not overdue
    var onTimeLoans : [Loan] {
        return unreturnedLoans.filter { loan in
            loan.dueDate > Date() // Date now
            }.sorted {
                $0.dueDate < $1.dueDate
        }
        
    }
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Tasty iOS 11 style large text
        self.navigationController?.navigationBar.prefersLargeTitles = true
        
        //Only on the first page
        self.navigationController?.navigationItem.largeTitleDisplayMode = .never
      
        definesPresentationContext = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.searchBar.enablesReturnKeyAutomatically = false
        self.tableView.reloadData()
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        guard let identifier = segue.identifier else {
            return
        }
        
        switch identifier {
        case "AddLoanSegue":
            let navController = segue.destination as! UINavigationController
            let addLoanForm = navController.viewControllers[0] as! AddLoanFormVC
            addLoanForm.onAddLoan = self.onAddLoan
        case "ViewLoanSegue":
            let navController = segue.destination as! UINavigationController
            let modifyLoanForm = navController.viewControllers[0] as! ModifyLoanFormVC
            let indexPath = sender as! IndexPath
            let loan = sections[indexPath.section].rows[indexPath.row]
            modifyLoanForm.loan = loan
            modifyLoanForm.onModifyLoan = self.onModifyLoan
        default:
            return
        }
    }
    
    func onAddLoan(loan: Loan) {
        try! realm.write {
            self.realm.add(loan)
        }
        
        Notifications.scheduleNotification(forLoan: loan)
        self.tableView.reloadData()
    }
    
    func onModifyLoan(loan: Loan) {
        try! realm.write {
            self.realm.add(loan, update: true)
        }
        
        tableView.reloadData()
    }
    
    func onMarkAsReturned(loan: Loan, completion: (Bool) -> Void) {
        try! realm.write {
            loan.isReturned = true
            loan.returnDate = Date() // Current Date
        }
        
        completion(true)
        tableView.reloadData()
    }
    
    func onMarkAsUnreturned(loan: Loan, completion: (Bool) -> Void) {
        try! realm.write {
            loan.isReturned = false
            loan.returnDate = nil
        }
        
        completion(true)
        tableView.reloadData()
    }
    
    func onDeleteLoan(loan: Loan, at indexPath: IndexPath, completion: @escaping (Bool) -> Void) {
        Alert(title: "Are you sure you want to delete this item?", message: "This cannot be undone")
            .addAction("Cancel", style: .cancel) { _ in
                completion(false)
            }
            .addAction("Delete", style: .destructive) { _ in
                let realm = try! Realm()
                try! realm.write {
                    realm.delete(loan)
                }
                
                Notifications.removeNotification(forLoan: loan)
                
                completion(true)
                self.tableView.deleteRows(at: [indexPath], with: .automatic)
            }
            .show()
    }
  
    //MARK: - UITableViewDataSource
    fileprivate struct Section {
        var title: String
        var rows: [Loan]
    }
    
    fileprivate var sections: [Section] {
        var arr = [Section]()
        
        if !returnToday.isEmpty {
            arr.append(Section(title: "Return Today", rows: returnToday))
        }
        
        if !overdueLoans.isEmpty {
            arr.append(Section(title: "Overdue", rows: overdueLoans))
        }
        
        if !onTimeLoans.isEmpty {
            arr.append(Section(title: "Unreturned", rows: onTimeLoans))
        }
        
        if !returnedLoans.isEmpty {
            arr.append(Section(title: "Returned", rows: returnedLoans))
        }
        
        return arr
    }
    
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section].title
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "loanRowCell") as! LoanCell
        let array = sections[indexPath.section].rows
        cell.fillWith(loan: array[indexPath.row])
        
        return cell
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].rows.count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "ViewLoanSegue", sender: indexPath)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let loan = self.sections[indexPath.section].rows[indexPath.row]
        
        if loan.isReturned {
            let markAsUnreturned = UIContextualAction(style: .normal, title: "Mark as Unreturned") { _, _, completion in
                self.onMarkAsUnreturned(loan: loan, completion: completion)
            }
            
            return UISwipeActionsConfiguration(actions: [markAsUnreturned])
        } else {
            
            let markAsReturned = UIContextualAction(style: .normal, title: "Mark as Returned") { _, _, completion in
                self.onMarkAsReturned(loan: loan, completion: completion)
            }
            
            markAsReturned.backgroundColor = UIColor(red:0.00, green:0.48, blue:1.00, alpha:1.0)
            
            return UISwipeActionsConfiguration(actions: [markAsReturned])
        }
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let loan = self.sections[indexPath.section].rows[indexPath.row]
        
        let delete = UIContextualAction(style: .destructive, title: "Delete") { _, _, completion in
            self.onDeleteLoan(loan: loan, at: indexPath, completion: completion)
        }
        
        return UISwipeActionsConfiguration(actions: [delete])
    }
    
    
}

extension LoansTableVC: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.searchPerson = searchText.isEmpty ? nil : searchText
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}

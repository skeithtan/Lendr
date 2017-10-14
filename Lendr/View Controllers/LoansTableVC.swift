//
//  LoansTableViewController.swift
//  Lendr
//
//  Created by Keith Tan on 13/10/2017.
//  Copyright © 2017 Axis. All rights reserved.
//

import UIKit
import RealmSwift

class LoanTableVC: UITableViewController {
    
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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Tasty iOS 11 style large text
        self.navigationController?.navigationBar.prefersLargeTitles = true
        
        //Only on the first page
        self.navigationController?.navigationItem.largeTitleDisplayMode = .never
        
        self.tableView.tableFooterView = UIView(frame: CGRect.zero)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
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
        default:
            return
        }
    }
    
    
    func onAddLoan(loan: Loan) {
        let realm = try! Realm()
        
        try! realm.write {
            realm.add(loan)
        }
        
        self.tableView.reloadData()
    }
    
    
    //MARK: - UITableViewDataSource
    fileprivate struct Section {
        var name: String
        var content: [Loan]
    }
    
    fileprivate var sections: [Section] {
        var arr = [Section]()
        
        if !returnToday.isEmpty {
            arr.append(Section(name: "Return Today", content: returnToday))
        }
        
        if !overdueLoans.isEmpty {
            arr.append(Section(name: "Overdue", content: overdueLoans))
        }
        
        if !onTimeLoans.isEmpty {
            arr.append(Section(name: "Unreturned", content: onTimeLoans))
        }
        
        if !returnedLoans.isEmpty {
            arr.append(Section(name: "Returned", content: returnedLoans))
        }
        
        return arr
    }
    
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section].name
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "loanRowCell") as! LoanCell
        let array = sections[indexPath.section].content
        cell.fillWith(loan: array[indexPath.row])
        
        return cell
    
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].content.count
    }
    
    
}


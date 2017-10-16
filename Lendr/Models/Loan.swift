//
//  CashLoan.swift
//  Lendr
//
//  Created by Keith Tan on 12/10/2017.
//  Copyright © 2017 Axis. All rights reserved.
//

import RealmSwift


class Loan: Object {
    @objc dynamic var id: String = UUID().uuidString
    @objc dynamic var itemName: String = ""
    @objc dynamic var dueDate: Date = Date()
    @objc dynamic var person: String = ""
    @objc dynamic var isReturned: Bool = false
    @objc dynamic var isCash: Bool = false
    @objc dynamic var typeInt: Int = LoanType.lend.rawValue
    @objc dynamic var returnDate: Date? = nil
    
    var type: LoanType {
        get {
            return LoanType(rawValue: self.typeInt)!
        }
        
        set(newType) {
            self.typeInt = newType.rawValue
        }
    }
    
    enum LoanType: Int {
        case lend = 0
        case borrow = 1
    }
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    override static func ignoredProperties() -> [String] {
        return ["type"]
    }
    
    func initWith(name: String, dueDate: Date, person: String, isCash: Bool) {
        self.itemName = name
        self.dueDate = dueDate
        self.person = person
        self.isCash = isCash
    }
}

//
//  Notifications.swift
//  Lendr
//
//  Created by Keith Tan on 16/10/2017.
//  Copyright © 2017 Axis. All rights reserved.
//

import UserNotifications

class Notifications {
    static var hasPermission = false
    
    static func scheduleNotification(forLoan loan: Loan) {
        guard Notifications.hasPermission else {
            return
        }
        
        let content = UNMutableNotificationContent()
        let verb = loan.type == .lend ? "ask \(loan.person) for your" : "return \(loan.person)'s"
        content.title = "\(loan.readableName) should be returned today."
        content.body = "It's time to \(verb) \(loan.readableName) back."

        let components: Set<Calendar.Component> = [.day, .month, .year]
        var dateInfo = Calendar.current.dateComponents(components, from: loan.dueDate)
        dateInfo.hour = 9
        dateInfo.minute = 50
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateInfo, repeats: true)
        let request = UNNotificationRequest(identifier: loan.id, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let notificationError = error {
                print(notificationError.localizedDescription)
            }
        }
    }
    
    static func removeNotification(forLoan loan: Loan) {
        guard Notifications.hasPermission else {
            return
        }
        
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [loan.id])
    }
}

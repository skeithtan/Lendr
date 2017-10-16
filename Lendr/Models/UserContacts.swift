//
//  Contacts.swift
//  Lendr
//
//  Created by Keith Tan on 15/10/2017.
//  Copyright © 2017 Axis. All rights reserved.
//

import Contacts

class UserContacts {
    
    static func getContactsPermission() {
        if CNContactStore.authorizationStatus(for: .contacts) == .notDetermined {
            CNContactStore().requestAccess(for: .contacts) {_, _ in }
        }
    }
    
    static func autocompleteContacts(forString str: String) -> [(String, String?)] {
        
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
    
}

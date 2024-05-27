//
//  ContactsUtils.swift
//  KINN
//
//  Created by Dragos-Robert Neagu on 20/12/2018.
//  Copyright © 2019 Dragos-Robert Neagu. All rights reserved.
//

#if os(iOS)
import Contacts

typealias KNSortingOutcome = (sections: [String], sortedContacts: [CNContact], contactsSortedInSections: [String: [CNContact]])

public typealias KNFilteringPredicate = (_ contact: CNContact) -> Bool

struct KNContactUtils {
    
    static func getContactsKeyDescriptors() -> [CNKeyDescriptor] {
        var array = self.getAllContactsKeys() as [CNKeyDescriptor]
        array.append(CNContactFormatter.descriptorForRequiredKeys(for: .fullName))
        return array
    }
    
    static func getBasicDisplayKeys() -> [CNKeyDescriptor] {
        var array = [
            CNContactIdentifierKey,
            CNContactFamilyNameKey,
            CNContactGivenNameKey,
            CNContactImageDataAvailableKey,
            CNContactImageDataKey,
            CNContactThumbnailImageDataKey,
            CNContactEmailAddressesKey,
            CNContactPhoneNumbersKey,
            CNContactOrganizationNameKey
            ] as [CNKeyDescriptor]
        
        array.append(CNContactFormatter.descriptorForRequiredKeys(for: .fullName))
        return array
    }
    
    static func getAllContactsKeys() -> [String] {
        return [
            //                CNContactNoteKey,
            CNContactTypeKey,
            CNContactDatesKey,
            CNContactUrlAddressesKey,
            CNContainerTypeKey,
            CNContainerNameKey,
            CNContainerIdentifierKey,
            CNContactRelationsKey,
            CNContactSocialProfilesKey,
            CNContactPhoneticOrganizationNameKey,
            CNContactInstantMessageAddressesKey,
            CNContactGivenNameKey,
            CNContactMiddleNameKey,
            CNContactFamilyNameKey,
            CNContactPreviousFamilyNameKey,
            CNContactPostalAddressesKey,
            CNContactPhoneNumbersKey,
            CNContactNameSuffixKey,
            CNContactNicknameKey,
            CNContactOrganizationNameKey,
            CNContactDepartmentNameKey,
            CNContactJobTitleKey,
            CNContactPhoneticGivenNameKey,
            CNContactPhoneticFamilyNameKey,
            CNContactPhoneticMiddleNameKey,
            CNContactImageDataAvailableKey,
            CNContactImageDataKey,
            CNContactThumbnailImageDataKey,
            CNContactEmailAddressesKey,
            CNContactBirthdayKey,
            CNContactNonGregorianBirthdayKey
        ]
    }
    
    static func sortByGivenName(c1: CNContact, c2:CNContact) -> Bool {
        if c1.givenName == c2.givenName {
            return c1.familyName < c2.familyName
        }
        
        let c1Name = c1.givenName == "" ? c1.familyName : c1.givenName
        let c2Name = c2.givenName == "" ? c2.familyName : c2.givenName
        
        return c1Name < c2Name
    }
    
    static func sortByFamilyName(c1: CNContact, c2:CNContact) -> Bool {
        if c1.familyName == c2.familyName {
            return c1.givenName < c2.givenName
        }

        let c1Name = c1.familyName == "" ? c1.givenName : c1.familyName
        let c2Name = c2.familyName == "" ? c2.givenName : c2.familyName
        
        return c1Name < c2Name
    }
    
    static func sortContactsIntoSections(contacts: [CNContact], sortingType: KNContactSortingOption) -> (sections: [String], sortedContacts: [CNContact], contactsSortedInSections: [String: [CNContact]]) {
        
        var sections: [String] = []
        var sortedContacts: [CNContact] = []
        var sortedContactsInSection: [String: [CNContact]] = [:]
        let ALL_OTHERS_VALUE = "#"
        
        
        switch sortingType {
        case .givenName:
            sortedContacts = contacts.sorted(by: { sortByGivenName(c1: $0, c2: $1) })
            for contact in sortedContacts {
                sortedContactsInSection = self.addToSortedContacts(sortedContactsInSection, contact: contact, groupBy: {
                    if (decideOnLetter(for: contact.givenName) == ALL_OTHERS_VALUE) {
                        return self.decideOnLetter(for: contact.familyName)
                    }
                    return String(contact.givenName.first!).uppercased()
                })
            }
        case .familyName:
            sortedContacts = contacts.sorted(by: { sortByFamilyName(c1: $0, c2: $1) })
            for contact in sortedContacts {
                sortedContactsInSection = self.addToSortedContacts(sortedContactsInSection, contact: contact, groupBy: {
                    if (decideOnLetter(for: contact.familyName) == ALL_OTHERS_VALUE) {
                        return self.decideOnLetter(for: contact.givenName)
                    }
                    return String(contact.familyName.first!).uppercased()
                })
            }
        }
        
        
        var containsSpecialKey = false
        var specialKey = String()
        
        
        if sections.contains(ALL_OTHERS_VALUE) {
            containsSpecialKey.toggle()
            specialKey = ALL_OTHERS_VALUE
            sections.removeAll { $0 == ALL_OTHERS_VALUE }
        }
        
        sections = Array(sortedContactsInSection.keys).sorted()
        
        for digit in 0...9 {
            sections.move(String(digit), to: sections.count - 1)
        }
        
        if containsSpecialKey {
            sections.append(specialKey)
        }
        
        return (sections, sortedContacts, sortedContactsInSection)
    }
    
    static private func addToSortedContacts(_ sortedContacts: [String: [CNContact]], contact: CNContact, groupBy groupingFunction: () -> String) -> [String: [CNContact]] {
        
        var sorted = sortedContacts
        let section = groupingFunction()
        var contactsArray = sortedContacts[section] ?? [CNContact]()
        contactsArray.append(contact)
        sorted[section] = contactsArray
        return sorted
    }
    
    static private func decideOnLetter(for word: String, initial: String = "#", returnFull: Bool = false) -> String {
        if (word.isEmpty) { return initial }
        return returnFull ? String(word).uppercased() : String(word.first!).uppercased()
    }
}


public enum KNContactSortingOption {
    case familyName
    case givenName
}
#endif

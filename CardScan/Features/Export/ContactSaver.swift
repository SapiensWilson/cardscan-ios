import Contacts
import ContactsUI
import SwiftUI

/// Saves a CNMutableContact to the user's address book.
/// Handles permission request + conflict check.
actor ContactSaver {

    enum SaveResult {
        case saved
        case permissionDenied
        case failed(Error)
    }

    static func save(fields: ContactFields) async -> SaveResult {
        let store = CNContactStore()

        // Request permission
        let status = CNContactStore.authorizationStatus(for: .contacts)
        if status == .notDetermined {
            guard (try? await store.requestAccess(for: .contacts)) == true else {
                return .permissionDenied
            }
        } else if status != .authorized {
            return .permissionDenied
        }

        let contact = VCardBuilder.makeCNContact(from: fields)
        let saveRequest = CNSaveRequest()
        saveRequest.add(contact, toContainerWithIdentifier: nil)

        do {
            try store.execute(saveRequest)
            return .saved
        } catch {
            return .failed(error)
        }
    }
}

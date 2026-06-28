import Contacts
import Foundation

/// Builds a CNContact and serialises it to vCard 3.0 data.
/// Mirrors generateVcf() in the web app's app.js.
struct VCardBuilder {

    /// Returns vCard 3.0 UTF-8 data for the given fields.
    static func build(from fields: ContactFields) -> Data? {
        let contact = makeCNContact(from: fields)
        return try? CNContactVCardSerialization.data(with: [contact])
    }

    /// Returns a CNContact ready to save to the user's address book.
    static func makeCNContact(from fields: ContactFields) -> CNMutableContact {
        let contact = CNMutableContact()
        contact.contactType = .person

        // Name
        let parts = fields.name.split(separator: " ").map(String.init)
        contact.givenName  = parts.dropLast().joined(separator: " ")
        contact.familyName = parts.last ?? ""
        if parts.count == 1 {
            contact.givenName  = parts[0]
            contact.familyName = ""
        }

        // Job
        contact.jobTitle         = fields.title
        contact.organizationName = fields.company

        // Phones
        if !fields.phone.isEmpty {
            contact.phoneNumbers.append(
                CNLabeledValue(label: CNLabelWork, value: CNPhoneNumber(stringValue: fields.phone))
            )
        }
        if !fields.phone2.isEmpty {
            contact.phoneNumbers.append(
                CNLabeledValue(label: CNLabelPhoneNumberMobile, value: CNPhoneNumber(stringValue: fields.phone2))
            )
        }

        // Email
        if !fields.email.isEmpty {
            contact.emailAddresses.append(
                CNLabeledValue(label: CNLabelWork, value: fields.email as NSString)
            )
        }

        // Website
        if !fields.website.isEmpty {
            contact.urlAddresses.append(
                CNLabeledValue(label: CNLabelWork, value: fields.website as NSString)
            )
        }

        // Address
        if !fields.address.isEmpty {
            let postal = CNMutablePostalAddress()
            postal.street = fields.address
            contact.postalAddresses.append(
                CNLabeledValue(label: CNLabelWork, value: postal)
            )
        }

        // LinkedIn as social profile
        if !fields.linkedin.isEmpty {
            let profile = CNSocialProfile(
                urlString: "https://" + fields.linkedin,
                username: String(fields.linkedin.split(separator: "/").last ?? ""),
                userIdentifier: nil,
                service: CNSocialProfileServiceLinkedIn
            )
            contact.socialProfiles.append(
                CNLabeledValue(label: CNLabelWork, value: profile)
            )
        }

        // Notes
        if !fields.notes.isEmpty {
            contact.note = fields.notes
        }

        return contact
    }

    /// Suggested filename for the exported .vcf file.
    static func filename(for fields: ContactFields) -> String {
        let name = fields.name.isEmpty ? "contact" : fields.name
        return name.replacingOccurrences(of: " ", with: "-") + ".vcf"
    }
}

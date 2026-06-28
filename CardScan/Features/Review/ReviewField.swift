import SwiftUI

/// Enum of all editable contact fields shown in ReviewView.
/// Drives field order, labels, icons, keyboard types, and AppState bindings.
enum ReviewField: String, CaseIterable, Hashable {
    case name, title, company, phone, phone2, email, website, address, linkedin, notes

    var label: String {
        switch self {
        case .name:     return "Full Name"
        case .title:    return "Job Title"
        case .company:  return "Company"
        case .phone:    return "Phone"
        case .phone2:   return "Alt Phone"
        case .email:    return "Email"
        case .website:  return "Website"
        case .address:  return "Address"
        case .linkedin: return "LinkedIn"
        case .notes:    return "Notes"
        }
    }

    var placeholder: String {
        switch self {
        case .name:     return "First Last"
        case .title:    return "Director of Operations"
        case .company:  return "Acme Corp"
        case .phone:    return "+1 (555) 000-0000"
        case .phone2:   return "+1 (555) 000-0001"
        case .email:    return "name@company.com"
        case .website:  return "https://company.com"
        case .address:  return "123 Main St, City, ST 00000"
        case .linkedin: return "linkedin.com/in/username"
        case .notes:    return "Met at conference…"
        }
    }

    var icon: String {
        switch self {
        case .name:     return "person"
        case .title:    return "briefcase"
        case .company:  return "building.2"
        case .phone:    return "phone"
        case .phone2:   return "phone.badge.plus"
        case .email:    return "envelope"
        case .website:  return "globe"
        case .address:  return "mappin.and.ellipse"
        case .linkedin: return "link"
        case .notes:    return "note.text"
        }
    }

    /// Full-width fields span both grid columns.
    var fullWidth: Bool {
        switch self {
        case .name, .email, .website, .address, .linkedin, .notes: return true
        default: return false
        }
    }

    var keyboardType: UIKeyboardType {
        switch self {
        case .phone, .phone2: return .phonePad
        case .email:          return .emailAddress
        case .website:        return .URL
        default:              return .default
        }
    }

    var textContentType: UITextContentType? {
        switch self {
        case .name:    return .name
        case .company: return .organizationName
        case .phone:   return .telephoneNumber
        case .phone2:  return .telephoneNumber
        case .email:   return .emailAddress
        case .website: return .URL
        case .address: return .streetAddressLine1
        default:       return nil
        }
    }

    var noAutoCorrect: Bool {
        switch self {
        case .email, .website, .phone, .phone2, .linkedin: return true
        default: return false
        }
    }

    /// Two-way binding into AppState.contact for this field.
    func binding(in appState: AppState) -> Binding<String> {
        switch self {
        case .name:     return Binding(get: { appState.contact.name },     set: { appState.contact.name = $0 })
        case .title:    return Binding(get: { appState.contact.title },    set: { appState.contact.title = $0 })
        case .company:  return Binding(get: { appState.contact.company },  set: { appState.contact.company = $0 })
        case .phone:    return Binding(get: { appState.contact.phone },    set: { appState.contact.phone = $0 })
        case .phone2:   return Binding(get: { appState.contact.phone2 },   set: { appState.contact.phone2 = $0 })
        case .email:    return Binding(get: { appState.contact.email },    set: { appState.contact.email = $0 })
        case .website:  return Binding(get: { appState.contact.website },  set: { appState.contact.website = $0 })
        case .address:  return Binding(get: { appState.contact.address },  set: { appState.contact.address = $0 })
        case .linkedin: return Binding(get: { appState.contact.linkedin }, set: { appState.contact.linkedin = $0 })
        case .notes:    return Binding(get: { appState.contact.notes },    set: { appState.contact.notes = $0 })
        }
    }
}

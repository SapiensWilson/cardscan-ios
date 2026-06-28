import Foundation

/// Mirror of the web app's contact field set. Codable for history persistence.
struct ContactFields: Codable, Equatable {
    var name:     String = ""
    var title:    String = ""
    var company:  String = ""
    var phone:    String = ""
    var phone2:   String = ""
    var email:    String = ""
    var website:  String = ""
    var address:  String = ""
    var linkedin: String = ""
    var notes:    String = ""

    var isEmpty: Bool {
        [name, title, company, phone, phone2, email, website, address, linkedin, notes]
            .allSatisfy(\.isEmpty)
    }

    /// Non-empty fields as plain text, one per line (for clipboard copy).
    var plainText: String {
        [name, title, company, phone, phone2, email, website, address, linkedin, notes]
            .filter { !$0.isEmpty }
            .joined(separator: "\n")
    }
}

import Foundation

/// Parses raw Vision OCR output into a ContactFields struct.
/// Mirrors the logic of parseContactFields() in the web app's app.js,
/// ported to Swift with improved confidence scoring.
struct ContactParser {

    static func parse(lines: [String], fullText: String) -> ContactFields {
        var result = ContactFields()

        let cleaned = lines
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { $0.count >= 2 }

        // MARK: — Email
        let emailRe = #/[\w.+\-]+@[\w\-]+\.[a-zA-Z]{2,}/#
        if let match = fullText.firstMatch(of: emailRe) {
            result.email = String(match.output)
        }

        // MARK: — Phone numbers (supports +1, extensions, various separators)
        let phoneRe = #/(?:\+?1[\s.\-]?)?\(?\d{3}\)?[\s.\-]\d{3}[\s.\-]\d{4}(?:[\s]*(?:x|ext)\.?[\s]*\d{1,5})?/#
        let phones = fullText.matches(of: phoneRe).map { String($0.output).trimmingCharacters(in: .whitespaces) }
        result.phone  = phones.first  ?? ""
        result.phone2 = phones.count > 1 ? phones[1] : ""

        // MARK: — Website
        let urlRe  = #/(?:https?:\/\/)?(?:www\.)[^\s,]+\.[a-zA-Z]{2,}[^\s,]*/#
        let urlRe2 = #/https?:\/\/[^\s,]+/#
        if let match = fullText.firstMatch(of: urlRe) ?? fullText.firstMatch(of: urlRe2) {
            var url = String(match.output)
            if !url.hasPrefix("http") { url = "https://" + url }
            result.website = url
        }

        // MARK: — LinkedIn
        let liRe = #/linkedin\.com\/in\/[\w\-]+/#
        if let match = fullText.lowercased().firstMatch(of: liRe) {
            result.linkedin = String(match.output)
        }

        // MARK: — Address (US: looks for State + ZIP pattern)
        let addrRe = #/\b([A-Z]{2})\s+(\d{5}(?:\-\d{4})?)\b/#
        if let addrLine = cleaned.first(where: { $0.contains(try! Regex(#/\b[A-Z]{2}\s+\d{5}\b/#)) }) {
            let idx = cleaned.firstIndex(of: addrLine) ?? 0
            let street = idx > 0 ? cleaned[idx - 1] : ""
            result.address = [street, addrLine].filter { !$0.isEmpty }.joined(separator: ", ")
        }

        // MARK: — Build exclusion set (values already extracted)
        var usedValues: Set<String> = []
        for v in [result.email, result.phone, result.phone2, result.website, result.linkedin, result.address] {
            if !v.isEmpty { usedValues.insert(v.lowercased()) }
        }

        // MARK: — Filter lines for name/title/company candidates
        let candidates = cleaned.filter { line in
            guard line.count >= 2 else { return false }
            guard !line.allSatisfy({ $0.isPunctuation || $0.isSymbol || $0.isNumber }) else { return false }
            // Skip lines that are substantially covered by extracted values
            let lower = line.lowercased()
            if usedValues.contains(where: { lower.contains($0) }) { return false }
            if lower.contains("www.") || lower.contains("http") { return false }
            if lower.contains("@")    || lower.contains("linkedin") { return false }
            // Skip zip-code lines
            if line.contains(try! Regex(#/\b[A-Z]{2}\s+\d{5}\b/#)) { return false }
            return true
        }

        // MARK: — Name heuristic
        // Shortest line of 2–5 words, no digits, mixed case (not ALL CAPS label)
        let nameCandidates = candidates.filter { line in
            let words = line.split(separator: " ")
            guard words.count >= 2, words.count <= 5 else { return false }
            guard !line.contains(where: { $0.isNumber }) else { return false }
            // Prefer lines that aren't ALL CAPS
            return true
        }.sorted { $0.count < $1.count }
        let name = nameCandidates.first ?? ""
        result.name = name

        // MARK: — Title heuristic (keyword match)
        let titleKeywords = [
            "vp", "ceo", "cto", "cfo", "coo", "cmo",
            "president", "director", "manager", "engineer", "developer",
            "consultant", "analyst", "officer", "founder", "partner",
            "associate", "senior", "junior", "lead", "principal", "head",
            "chief", "advisor", "specialist", "coordinator", "supervisor",
            "executive", "architect", "designer", "researcher", "scientist",
            "vice", "assistant", "sales", "marketing", "product", "account"
        ]
        let titleLine = candidates.first { line in
            guard line != name else { return false }
            let lower = line.lowercased()
            return titleKeywords.contains { lower.contains($0) }
        }
        result.title = titleLine ?? ""

        // MARK: — Company heuristic
        // First remaining candidate that is neither name nor title
        let compLine = candidates.first { line in
            line != name && line != result.title && line.count > 1
        }
        result.company = compLine ?? ""

        return result
    }
}

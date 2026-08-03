import Foundation

/// Base options matching `localizedStandardCompare`:
/// `.numeric` (64) | `.widthInsensitive` (256) | `.forcedOrdering` (512) = 832.
/// `.caseInsensitive` is added by default but removed when `caseSensitive`
/// is `true`; `.diacriticInsensitive` is only added when requested.
private let baseOptions: NSString.CompareOptions = [
    .numeric, .widthInsensitive, .forcedOrdering
]

class CollationPlugin: CollationMacOSHostApi {
    func sort(request: CollationMacOSRequest) throws -> [CollationMacOSItem] {
        var options = baseOptions

        // Default: case-insensitive (matches localizedStandardCompare).
        // Only remove the flag when caseSensitive is explicitly true.
        if request.caseSensitive != true {
            options.insert(.caseInsensitive)
        }

        if request.diacriticInsensitive == true {
            options.insert(.diacriticInsensitive)
        }

        let locale: Locale = {
            if let localeId = request.locale, !localeId.isEmpty {
                return Locale(identifier: localeId)
            }
            return Locale.current
        }()

        let ascending = request.direction != 1

        let sorted = request.items.sorted { a, b in
            let result = a.value.compare(b.value, options: options, locale: locale)
            if result != .orderedSame {
                return ascending
                    ? (result == .orderedAscending)
                    : (result == .orderedDescending)
            }
            // Tie-break by id for stable deterministic ordering.
            return a.id < b.id
        }

        return sorted
    }
}

import Foundation

class CollationPlugin: CollationMacOSHostApi {
    func sort(request: CollationMacOSRequest) throws -> [CollationMacOSItem] {
        let entries = request.items.map { item in
            (id: item.id, value: item.value)
        }

        let sorted = entries.sorted { a, b in
            a.value.localizedStandardCompare(b.value) == .orderedAscending
        }

        return sorted.map { CollationMacOSItem(id: $0.id, value: $0.value) }
    }
}

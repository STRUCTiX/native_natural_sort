import Foundation

class CollationPlugin: CollationIOSHostApi {
    func sort(request: CollationIOSRequest) throws -> [CollationIOSItem] {
        let entries = request.items.map { item in
            (id: item.id, value: item.value)
        }

        let sorted = entries.sorted { a, b in
            a.value.localizedStandardCompare(b.value) == .orderedAscending
        }

        return sorted.map { CollationIOSItem(id: $0.id, value: $0.value) }
    }
}

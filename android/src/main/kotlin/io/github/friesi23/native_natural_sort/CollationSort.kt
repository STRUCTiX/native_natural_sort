package io.github.friesi23.native_natural_sort

fun sortByCollationKey(
    items: List<CollationItem>,
    collationKeyOf: (String) -> Comparable<*>,
): List<String> = items
    .map {
        val key = collationKeyOf(it.value)
        Triple(it.id, it.value, key)
    }
    .sortedWith(
        compareBy<Triple<String, String, Comparable<*>>> { it.third }
            .thenBy { it.first },
    )
    .map { it.first }

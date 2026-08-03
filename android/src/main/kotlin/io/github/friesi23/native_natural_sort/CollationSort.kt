package io.github.friesi23.native_natural_sort

fun sortByCollationKey(
    items: List<CollationAndroidItem>,
    collationKeyOf: (String) -> Comparable<*>,
): List<CollationAndroidItem> = items
    .map {
        val key = collationKeyOf(it.value)
        Triple(it.id, it.value, key)
    }
    .sortedWith(
        compareBy<Triple<String, String, Comparable<*>>> { it.third }
            .thenBy { it.first },
    )
    .map { CollationAndroidItem(id = it.first, value = it.second) }

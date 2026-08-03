package io.github.friesi23.native_natural_sort

import kotlin.test.Test
import kotlin.test.assertEquals

class CollationSortTest {

    @Test
    fun sortByCollationKey_sortsByIdentifier() {
        val items = listOf(
            CollationAndroidItem("id2", "b"),
            CollationAndroidItem("id1", "a"),
            CollationAndroidItem("id3", "a"),
        )
        val result = sortByCollationKey(items) { it }
        assertEquals(
            listOf(
                CollationAndroidItem("id1", "a"),
                CollationAndroidItem("id3", "a"),
                CollationAndroidItem("id2", "b"),
            ),
            result,
        )
    }

    @Test
    fun sortByCollationKey_handlesNumbersWithNaturalOrder() {
        val items = listOf(
            CollationAndroidItem("10", "item10"),
            CollationAndroidItem("2", "item2"),
            CollationAndroidItem("1", "item1"),
        )
        val result = sortByCollationKey(items) { it }
        assertEquals(
            listOf(
                CollationAndroidItem("1", "item1"),
                CollationAndroidItem("10", "item10"),
                CollationAndroidItem("2", "item2"),
            ),
            result,
        )
    }

    @Test
    fun sortByCollationKey_emptyList() {
        val result = sortByCollationKey(emptyList<CollationAndroidItem>()) { it }
        assertEquals(emptyList(), result)
    }

    @Test
    fun sortByCollationKey_singleItem() {
        val items = listOf(CollationAndroidItem("only", "value"))
        val result = sortByCollationKey(items) { it }
        assertEquals(listOf(CollationAndroidItem("only", "value")), result)
    }
}

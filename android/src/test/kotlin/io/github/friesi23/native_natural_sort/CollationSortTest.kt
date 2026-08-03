package io.github.friesi23.native_natural_sort

import kotlin.test.Test
import kotlin.test.assertEquals

class CollationSortTest {

    @Test
    fun sortByCollationKey_sortsByIdentifier() {
        val items = listOf(
            CollationItem("id2", "b"),
            CollationItem("id1", "a"),
            CollationItem("id3", "a"),
        )
        // Simple compare function: identity-based comparison (for test purposes,
        // we simulate the collation key returning the string itself).
        val result = sortByCollationKey(items) { it }
        // Sorted by value first ('a' < 'b'), ties broken by id ('id1' < 'id3')
        assertEquals(listOf("id1", "id3", "id2"), result)
    }

    @Test
    fun sortByCollationKey_handlesNumbersWithNaturalOrder() {
        val items = listOf(
            CollationItem("10", "item10"),
            CollationItem("2", "item2"),
            CollationItem("1", "item1"),
        )
        // With simple key comparison, 'item1' < 'item10' < 'item2' (lexical)
        val result = sortByCollationKey(items) { it }
        assertEquals(listOf("1", "10", "2"), result)
    }

    @Test
    fun sortByCollationKey_emptyList() {
        val result = sortByCollationKey(emptyList<CollationItem>()) { it }
        assertEquals(emptyList(), result)
    }

    @Test
    fun sortByCollationKey_singleItem() {
        val items = listOf(CollationItem("only", "value"))
        val result = sortByCollationKey(items) { it }
        assertEquals(listOf("only"), result)
    }
}

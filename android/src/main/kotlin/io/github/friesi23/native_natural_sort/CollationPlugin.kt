package io.github.friesi23.native_natural_sort

import android.icu.text.Collator
import android.icu.util.ULocale

class CollationPlugin : CollationAndroidHostApi {
    override fun sort(request: CollationAndroidRequest): List<CollationAndroidItem> {
        // Resolve locale with numeric keyword.
        val baseLocale =
            request.locale?.takeIf { it.isNotBlank() }?.let { ULocale.forLanguageTag(it) }
                ?: ULocale.getDefault()

        val numeric = request.numeric ?: true
        val uLocale = baseLocale.setKeywordValue(
            "colNumeric",
            if (numeric) "yes" else "no",
        )

        // Build collator with strength and decomposition.
        val collator = Collator.getInstance(uLocale).apply {
            strength = when (request.strength) {
                0L -> Collator.PRIMARY
                1L -> Collator.SECONDARY
                3L -> Collator.IDENTICAL
                else -> Collator.TERTIARY
            }
            decomposition = when (request.decomposition) {
                0L -> Collator.NO_DECOMPOSITION
                2L -> Collator.FULL_DECOMPOSITION
                else -> Collator.CANONICAL_DECOMPOSITION
            }
        }

        val sorted = sortByCollationKey(request.items) {
            collator.getCollationKey(it)
        }

        return if (request.direction == 1L) sorted.reversed() else sorted
    }
}


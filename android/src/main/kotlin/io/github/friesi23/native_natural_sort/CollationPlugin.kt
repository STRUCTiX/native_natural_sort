package io.github.friesi23.native_natural_sort

import android.icu.text.Collator
import android.icu.util.ULocale

class CollationPlugin : CollationAndroidHostApi {
    override fun sort(request: CollationAndroidRequest): List<CollationAndroidItem> {
        val uLocale = request.locale
            ?.takeIf { it.isNotBlank() }
            ?.let { ULocale.forLanguageTag(it) }
            ?.setKeywordValue("colNumeric", "yes")
            ?: ULocale.getDefault().setKeywordValue("colNumeric", "yes")

        val collator = Collator.getInstance(uLocale).apply {
            strength = Collator.TERTIARY
            decomposition = Collator.CANONICAL_DECOMPOSITION
        }

        return sortByCollationKey(request.items) { collator.getCollationKey(it) }
    }
}

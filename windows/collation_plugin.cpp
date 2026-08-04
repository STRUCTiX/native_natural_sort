#include "collation_plugin.h"

#include <windows.h>

#include <algorithm>
#include <string>
#include <utility>
#include <vector>

namespace native_natural_sort {

namespace {

/// Builds CompareStringEx flags from request parameters.
DWORD BuildFlags(const CollationWindowsRequest &request) {
  DWORD flags = SORT_DIGITSASNUMBERS;

  // caseSensitive: null/false → NORM_IGNORECASE (backward-compatible default)
  const auto *case_sens = request.case_sensitive();
  if (!case_sens || !*case_sens) {
    flags |= NORM_IGNORECASE;
  }

  // diacriticInsensitive: true → NORM_IGNORENONSPACE
  const auto *diac_ins = request.diacritic_insensitive();
  if (diac_ins && *diac_ins) {
    flags |= NORM_IGNORENONSPACE;
  }

  return flags;
}

/// Compares two wide strings using CompareStringEx.
int CompareWide(const std::wstring &a, const std::wstring &b,
                const wchar_t *locale_name, DWORD flags) {
  return CompareStringEx(locale_name, flags, a.c_str(),
                         static_cast<int>(a.length()), b.c_str(),
                         static_cast<int>(b.length()), nullptr, nullptr, 0);
}

} // namespace

std::wstring CollationPlugin::ToWide(const std::string &utf8) {
  if (utf8.empty())
    return {};
  int len = MultiByteToWideChar(CP_UTF8, 0, utf8.c_str(),
                                static_cast<int>(utf8.length()), nullptr, 0);
  if (len <= 0)
    return {};
  std::wstring wide(static_cast<size_t>(len), L'\0');
  MultiByteToWideChar(CP_UTF8, 0, utf8.c_str(), static_cast<int>(utf8.length()),
                      &wide[0], len);
  return wide;
}

std::vector<std::pair<std::string, std::string>>
CollationPlugin::ExtractItems(const CollationWindowsRequest &request) {
  std::vector<std::pair<std::string, std::string>> items;
  const auto &raw = request.items();
  items.reserve(raw.size());
  for (const auto &encodable : raw) {
    const auto &item = std::any_cast<const CollationWindowsItem &>(
        std::get<::flutter::CustomEncodableValue>(encodable));
    items.emplace_back(item.id(), item.value());
  }
  return items;
}

ErrorOr<::flutter::EncodableList>
CollationPlugin::Sort(const CollationWindowsRequest &request) {
  struct SortEntry {
    std::string id;
    std::string value;
    std::wstring wide_value;
  };

  auto raw = ExtractItems(request);
  std::vector<SortEntry> entries;
  entries.reserve(raw.size());
  for (auto &item : raw) {
    entries.push_back(
        {std::move(item.first), item.second, ToWide(item.second)});
  }

  // Resolve locale: use requested locale when available, otherwise
  // fall back to the user's default locale.  Locale is already
  // normalized to BCP-47 by the Dart layer.
  const auto *locale_str = request.locale();
  std::wstring locale_name;
  if (locale_str && !locale_str->empty()) {
    locale_name = ToWide(*locale_str);
  }
  const wchar_t *effective_locale =
      locale_name.empty() ? LOCALE_NAME_USER_DEFAULT : locale_name.c_str();

  // Build CompareStringEx flags from request tuning parameters.
  const DWORD flags = BuildFlags(request);

  // Resolve sort direction.
  const auto *direction = request.direction();
  const bool descending = direction && *direction == 1;

  // Sort by collation order (using pre-converted wide strings),
  // then by id as tie-break for consistency with other platforms.
  std::stable_sort(
      entries.begin(), entries.end(),
      [effective_locale, flags, descending](const auto &a, const auto &b) {
        int cmp = CompareWide(a.wide_value, b.wide_value, effective_locale,
                              flags);
        bool less;
        if (cmp == CSTR_LESS_THAN)
          less = true;
        else if (cmp == CSTR_GREATER_THAN)
          less = false;
        else
          return descending ? a.id > b.id : a.id < b.id;
        return descending ? !less : less;
      });

  ::flutter::EncodableList result;
  result.reserve(entries.size());
  for (const auto &e : entries) {
    result.push_back(::flutter::CustomEncodableValue(
        CollationWindowsItem(e.id, e.value)));
  }
  return result;
}

} // namespace native_natural_sort

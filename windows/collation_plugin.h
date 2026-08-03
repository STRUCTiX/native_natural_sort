#ifndef FLUTTER_PLUGIN_COLLATION_PLUGIN_H_
#define FLUTTER_PLUGIN_COLLATION_PLUGIN_H_

#include "collation_api.g.h"

#include <string>
#include <vector>

namespace native_natural_sort {

/// Windows implementation of CollationWindowsHostApi using CompareStringEx.
class CollationPlugin : public CollationWindowsHostApi {
 public:
  CollationPlugin() = default;

  /// Sorts items by collation order using CompareStringEx.
  ///
  /// Uses the locale from the request when provided, otherwise falls
  /// back to the user's default locale. Numeric values within strings
  /// are sorted naturally (SORT_DIGITSASNUMBERS).
  ErrorOr<::flutter::EncodableList> Sort(
      const CollationWindowsRequest& request) override;

 private:
  /// Converts a UTF-8 string to a wide string (UTF-16).
  static std::wstring ToWide(const std::string& utf8);

  /// Extracts (id, value) pairs from the request items.
  static std::vector<std::pair<std::string, std::string>> ExtractItems(
      const CollationWindowsRequest& request);
};

}  // namespace native_natural_sort

#endif  // FLUTTER_PLUGIN_COLLATION_PLUGIN_H_

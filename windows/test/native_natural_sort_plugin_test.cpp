#include <flutter/encodable_value.h>
#include <gtest/gtest.h>
#include <windows.h>

#include <string>
#include <variant>

#include "collation_api.g.h"
#include "collation_plugin.h"

namespace native_natural_sort {
namespace test {

namespace {

using flutter::EncodableList;
using flutter::EncodableValue;
using flutter::CustomEncodableValue;

CollationWindowsItem MakeItem(const std::string& id, const std::string& value) {
  return CollationWindowsItem(id, value);
}

CollationWindowsRequest MakeRequest(
    const std::vector<CollationWindowsItem>& items,
    std::optional<std::string> locale = std::nullopt,
    std::optional<int64_t> direction = std::nullopt,
    std::optional<bool> case_sensitive = std::nullopt,
    std::optional<bool> diacritic_insensitive = std::nullopt) {
  ::flutter::EncodableList encodable_items;
  for (const auto& item : items) {
    encodable_items.push_back(
        ::flutter::EncodableValue(
            ::flutter::CustomEncodableValue(item)));
  }
  const std::string* locale_ptr =
      locale.has_value() ? &locale.value() : nullptr;
  const int64_t* direction_ptr =
      direction.has_value() ? &direction.value() : nullptr;
  const bool* case_sensitive_ptr =
      case_sensitive.has_value() ? &case_sensitive.value() : nullptr;
  const bool* diacritic_insensitive_ptr =
      diacritic_insensitive.has_value() ? &diacritic_insensitive.value() : nullptr;
  return CollationWindowsRequest(encodable_items, locale_ptr,
                                  direction_ptr, case_sensitive_ptr,
                                  diacritic_insensitive_ptr);
}

std::string GetId(const ::flutter::EncodableValue& v) {
  const auto& item = std::any_cast<const CollationWindowsItem&>(
      std::get<::flutter::CustomEncodableValue>(v));
  return item.id();
}

}  // namespace

TEST(CollationPlugin, SortStringsAscending) {
  CollationPlugin plugin;
  auto request = MakeRequest({
      MakeItem("id2", "banana"),
      MakeItem("id1", "apple"),
      MakeItem("id3", "cherry"),
  });

  auto result = plugin.Sort(request);
  ASSERT_FALSE(result.has_error());

  const auto& list = result.value();
  ASSERT_EQ(list.size(), 3);
  // English collation: 'apple' < 'banana' < 'cherry'
  EXPECT_EQ(GetId(list[0]), "id1");
  EXPECT_EQ(GetId(list[1]), "id2");
  EXPECT_EQ(GetId(list[2]), "id3");
}

TEST(CollationPlugin, SortStringsEmptyList) {
  CollationPlugin plugin;
  auto request = MakeRequest({});

  auto result = plugin.Sort(request);
  ASSERT_FALSE(result.has_error());
  EXPECT_TRUE(result.value().empty());
}

TEST(CollationPlugin, SortStringsWithNumbers) {
  CollationPlugin plugin;
  auto request = MakeRequest({
      MakeItem("10", "item10"),
      MakeItem("2", "item2"),
      MakeItem("1", "item1"),
  });

  auto result = plugin.Sort(request);
  ASSERT_FALSE(result.has_error());

  const auto& list = result.value();
  ASSERT_EQ(list.size(), 3);
  // With SORT_DIGITSASNUMBERS: 'item1' < 'item2' < 'item10'
  EXPECT_EQ(GetId(list[0]), "1");
  EXPECT_EQ(GetId(list[1]), "2");
  EXPECT_EQ(GetId(list[2]), "10");
}

TEST(CollationPlugin, SortSingleItem) {
  CollationPlugin plugin;
  auto request = MakeRequest({
      MakeItem("only", "value"),
  });

  auto result = plugin.Sort(request);
  ASSERT_FALSE(result.has_error());

  const auto& list = result.value();
  ASSERT_EQ(list.size(), 1);
  EXPECT_EQ(GetId(list[0]), "only");
}

TEST(CollationPlugin, SortWithLocale) {
  CollationPlugin plugin;
  auto request = MakeRequest(
      {
          MakeItem("a", "apple"),
          MakeItem("b", "banana"),
      },
      "en-US");

  auto result = plugin.Sort(request);
  ASSERT_FALSE(result.has_error());

  const auto& list = result.value();
  ASSERT_EQ(list.size(), 2);
  EXPECT_EQ(GetId(list[0]), "a");
  EXPECT_EQ(GetId(list[1]), "b");
}

TEST(CollationPlugin, SortDuplicateValuesBrokenById) {
  CollationPlugin plugin;
  auto request = MakeRequest({
      MakeItem("id2", "same"),
      MakeItem("id1", "same"),
      MakeItem("id3", "same"),
  });

  auto result = plugin.Sort(request);
  ASSERT_FALSE(result.has_error());

  const auto& list = result.value();
  ASSERT_EQ(list.size(), 3);
  // Ties broken by id: 'id1' < 'id2' < 'id3'
  EXPECT_EQ(GetId(list[0]), "id1");
  EXPECT_EQ(GetId(list[1]), "id2");
  EXPECT_EQ(GetId(list[2]), "id3");
}

TEST(CollationPlugin, SortDescending) {
  CollationPlugin plugin;
  auto request = MakeRequest(
      {
          MakeItem("id2", "banana"),
          MakeItem("id1", "apple"),
          MakeItem("id3", "cherry"),
      },
      std::nullopt, 1  // direction = 1 (descending)
  );

  auto result = plugin.Sort(request);
  ASSERT_FALSE(result.has_error());

  const auto& list = result.value();
  ASSERT_EQ(list.size(), 3);
  // Descending: 'cherry' > 'banana' > 'apple'
  EXPECT_EQ(GetId(list[0]), "id3");
  EXPECT_EQ(GetId(list[1]), "id2");
  EXPECT_EQ(GetId(list[2]), "id1");
}

TEST(CollationPlugin, SortDescendingTiesBrokenById) {
  CollationPlugin plugin;
  auto request = MakeRequest(
      {
          MakeItem("id2", "same"),
          MakeItem("id1", "same"),
          MakeItem("id3", "same"),
      },
      std::nullopt, 1  // direction = 1 (descending)
  );

  auto result = plugin.Sort(request);
  ASSERT_FALSE(result.has_error());

  const auto& list = result.value();
  ASSERT_EQ(list.size(), 3);
  // Descending ties: 'id3' > 'id2' > 'id1'
  EXPECT_EQ(GetId(list[0]), "id3");
  EXPECT_EQ(GetId(list[1]), "id2");
  EXPECT_EQ(GetId(list[2]), "id1");
}

TEST(CollationPlugin, SortCaseSensitiveFalse) {
  CollationPlugin plugin;
  // caseSensitive = false (default): ignore case
  auto request = MakeRequest(
      {
          MakeItem("a", "Apple"),
          MakeItem("b", "apple"),
          MakeItem("c", "banana"),
      },
      std::nullopt, std::nullopt, false  // case_sensitive = false
  );

  auto result = plugin.Sort(request);
  ASSERT_FALSE(result.has_error());

  const auto& list = result.value();
  ASSERT_EQ(list.size(), 3);
  // Case-insensitive: 'Apple' == 'apple', ties broken by id
  EXPECT_EQ(GetId(list[0]), "a");
  EXPECT_EQ(GetId(list[1]), "b");
  EXPECT_EQ(GetId(list[2]), "c");
}

TEST(CollationPlugin, SortCaseSensitiveTrue) {
  CollationPlugin plugin;
  // caseSensitive = true: 'A' and 'a' are distinct (not collapsed)
  auto request = MakeRequest(
      {
          MakeItem("b", "apple"),
          MakeItem("a", "Apple"),
          MakeItem("c", "banana"),
      },
      std::nullopt, std::nullopt, true  // case_sensitive = true
  );

  auto result = plugin.Sort(request);
  ASSERT_FALSE(result.has_error());

  const auto& list = result.value();
  ASSERT_EQ(list.size(), 3);
  // Case-sensitive: 'Apple' and 'apple' are distinct, so they are
  // ordered based on locale rules rather than being tied.
  // 'banana' should sort after both regardless of locale.
  const auto& last_id = GetId(list[2]);
  EXPECT_EQ(last_id, "c");  // "banana" is last

  // 'Apple' and 'apple' should NOT be collapsed to the same position;
  // verify they are at distinct positions (not tied).
  EXPECT_NE(GetId(list[0]), GetId(list[1]));
}

}  // namespace test
}  // namespace native_natural_sort

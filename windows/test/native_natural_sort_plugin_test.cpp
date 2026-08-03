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

CollationItem MakeItem(const std::string& id, const std::string& value) {
  return CollationItem(id, value);
}

CollationRequest MakeRequest(
    const std::vector<CollationItem>& items,
    std::optional<std::string> locale = std::nullopt) {
  ::flutter::EncodableList encodable_items;
  for (const auto& item : items) {
    encodable_items.push_back(
        ::flutter::EncodableValue(
            ::flutter::CustomEncodableValue(item)));
  }
  return CollationRequest(encodable_items, locale);
}

}  // namespace

TEST(CollationPlugin, SortStringsAscending) {
  CollationPlugin plugin;
  auto request = MakeRequest({
      MakeItem("id2", "banana"),
      MakeItem("id1", "apple"),
      MakeItem("id3", "cherry"),
  });

  auto result = plugin.SortStrings(request);
  ASSERT_FALSE(result.has_error());

  const auto& list = result.value();
  ASSERT_EQ(list.size(), 3);
  // English collation: 'apple' < 'banana' < 'cherry'
  EXPECT_EQ(std::get<std::string>(list[0]), "id1");
  EXPECT_EQ(std::get<std::string>(list[1]), "id2");
  EXPECT_EQ(std::get<std::string>(list[2]), "id3");
}

TEST(CollationPlugin, SortStringsEmptyList) {
  CollationPlugin plugin;
  auto request = MakeRequest({});

  auto result = plugin.SortStrings(request);
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

  auto result = plugin.SortStrings(request);
  ASSERT_FALSE(result.has_error());

  const auto& list = result.value();
  ASSERT_EQ(list.size(), 3);
  // With SORT_DIGITSASNUMBERS: 'item1' < 'item2' < 'item10'
  EXPECT_EQ(std::get<std::string>(list[0]), "1");
  EXPECT_EQ(std::get<std::string>(list[1]), "2");
  EXPECT_EQ(std::get<std::string>(list[2]), "10");
}

TEST(CollationPlugin, SortSingleItem) {
  CollationPlugin plugin;
  auto request = MakeRequest({
      MakeItem("only", "value"),
  });

  auto result = plugin.SortStrings(request);
  ASSERT_FALSE(result.has_error());

  const auto& list = result.value();
  ASSERT_EQ(list.size(), 1);
  EXPECT_EQ(std::get<std::string>(list[0]), "only");
}

TEST(CollationPlugin, SortWithLocale) {
  CollationPlugin plugin;
  auto request = MakeRequest(
      {
          MakeItem("a", "apple"),
          MakeItem("b", "banana"),
      },
      "en-US");

  auto result = plugin.SortStrings(request);
  ASSERT_FALSE(result.has_error());

  const auto& list = result.value();
  ASSERT_EQ(list.size(), 2);
  EXPECT_EQ(std::get<std::string>(list[0]), "a");
  EXPECT_EQ(std::get<std::string>(list[1]), "b");
}

TEST(CollationPlugin, SortDuplicateValuesBrokenById) {
  CollationPlugin plugin;
  auto request = MakeRequest({
      MakeItem("id2", "same"),
      MakeItem("id1", "same"),
      MakeItem("id3", "same"),
  });

  auto result = plugin.SortStrings(request);
  ASSERT_FALSE(result.has_error());

  const auto& list = result.value();
  ASSERT_EQ(list.size(), 3);
  // Ties broken by id: 'id1' < 'id2' < 'id3'
  EXPECT_EQ(std::get<std::string>(list[0]), "id1");
  EXPECT_EQ(std::get<std::string>(list[1]), "id2");
  EXPECT_EQ(std::get<std::string>(list[2]), "id3");
}

}  // namespace test
}  // namespace native_natural_sort

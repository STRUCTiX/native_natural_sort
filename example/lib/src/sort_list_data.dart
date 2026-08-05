// Copyright 2026 Fries_I23
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     https://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'package:native_natural_sort/native_natural_sort.dart';

const List<SortItem> kTestItems = [
  SortItem(id: 'en-banana', value: 'Banana'),
  SortItem(id: 'en-elderberry', value: 'elderberry'),
  SortItem(id: 'en-apple', value: 'apple'),
  SortItem(id: 'en-cherry', value: 'cherry'),
  SortItem(id: 'en-date', value: 'Date'),

  SortItem(id: 'num-file20', value: 'file20.txt'),
  SortItem(id: 'num-file2', value: 'file2.txt'),
  SortItem(id: 'num-file100', value: 'file100.txt'),
  SortItem(id: 'num-file10', value: 'file10.txt'),
  SortItem(id: 'num-file1', value: 'file1.txt'),

  SortItem(id: 'zh-wangwu', value: '王五'),
  SortItem(id: 'zh-zhangsan', value: '张三'),
  SortItem(id: 'zh-zhaoliu', value: '赵六'),
  SortItem(id: 'zh-aili', value: '艾丽'),
  SortItem(id: 'zh-lisi', value: '李四'),

  SortItem(id: 'ja-ue', value: 'うえ'),
  SortItem(id: 'ja-tanaka', value: '田中'),
  SortItem(id: 'ja-ao', value: 'あお'),
  SortItem(id: 'ja-sato', value: '佐藤'),
  SortItem(id: 'ja-ichi', value: 'いち'),
  SortItem(id: 'ja-yamada', value: '山田'),

  SortItem(id: 'ko-dari', value: '다리'),
  SortItem(id: 'ko-nabi', value: '나비'),
  SortItem(id: 'ko-gabang', value: '가방'),
  SortItem(id: 'ko-maeum', value: '마음'),
  SortItem(id: 'ko-ramyeon', value: '라면'),

  SortItem(id: 'de-uber', value: 'Über'),
  SortItem(id: 'de-apfel', value: 'Äpfel'),
  SortItem(id: 'de-strasse', value: 'Straße'),
  SortItem(id: 'de-osterreich', value: 'Österreich'),

  SortItem(id: 'fr-garcon', value: 'garçon'),
  SortItem(id: 'fr-eleve', value: 'élève'),
  SortItem(id: 'fr-cafe', value: 'café'),
  SortItem(id: 'fr-naive', value: 'naïve'),
  SortItem(id: 'fr-hopital', value: 'hôpital'),

  SortItem(id: 'ar-bab', value: 'باب'),
  SortItem(id: 'ar-qalam', value: 'قلم'),
  SortItem(id: 'ar-kitab', value: 'كتاب'),
  SortItem(id: 'ar-maktab', value: 'مكتب'),

  SortItem(id: 'ru-vishnya', value: 'вишня'),
  SortItem(id: 'ru-arbuz', value: 'арбуз'),
  SortItem(id: 'ru-yabloko', value: 'яблоко'),
  SortItem(id: 'ru-banan', value: 'банан'),

  SortItem(id: 'ch-ch10', value: 'Chapter 10'),
  SortItem(id: 'ch-sec1_10', value: 'Section 1.10'),
  SortItem(id: 'ch-ch2', value: 'Chapter 2'),
  SortItem(id: 'ch-sec1_2', value: 'Section 1.2'),
  SortItem(id: 'ch-ch1', value: 'Chapter 1'),

  SortItem(id: 'sp-a_1', value: 'a_1'),
  SortItem(id: 'sp-a.1', value: 'a.1'),
  SortItem(id: 'sp-a1', value: 'a1'),
  SortItem(id: 'sp-a-1', value: 'a-1'),
  SortItem(id: 'sp-a 1', value: 'a 1'),
];

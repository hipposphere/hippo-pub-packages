/*
// ---------------------------------------------------------------------------
// Copyright (c) 2025 HippoSphere UG (haftungsbeschränkt). All rights reserved.
// Use, copying, modification, or distribution of this software is prohibited 
// without express written permission from Hipposphere UG.
//
// SPDX-License-Identifier: LicenseRef-Hipposphere-Proprietary
// ---------------------------------------------------------------------------
*/
// import 'package:intl/intl.dart';
import 'package:isoweek/isoweek.dart';

class Date {
  final String _iso8601String;

  factory Date.parse(String dateString) {
    final dateTime = DateTime.tryParse(dateString);
    if (dateTime == null) {
      throw ArgumentError.value(dateString, 'dateString', 'Could not parse date');
    }
    return Date.fromDateTime(dateTime);
  }

  static Date? tryParse(dynamic dateString) {
    try {
      return Date.parse(dateString);
    } catch (e) {
      return null;
    }
  }

  const Date.internal(this._iso8601String);

  factory Date.create(int year, [int month = 1, int day = 1]) {
    return Date.fromDateTime(DateTime(year, month, day));
  }

  factory Date.fromDateTime(DateTime dateTime) {
    return Date.internal(dateTime.toIso8601String().substring(0, 10));
  }

  factory Date.today() => Date.fromDateTime(DateTime.now());

  @override
  int get hashCode => _iso8601String.hashCode;

  @override
  bool operator ==(other) {
    return other is Date && _iso8601String == other._iso8601String;
  }

  int compareTo(Date other) {
    return _iso8601String.compareTo(other._iso8601String);
  }

  bool isAfter(Date other) {
    return _iso8601String.compareTo(other._iso8601String) > 0;
  }

  bool isSameDay(Date other) {
    return _iso8601String == other._iso8601String;
  }

  bool isBefore(Date other) {
    return _iso8601String.compareTo(other._iso8601String) < 0;
  }

  int getDaysDifference(Date other) {
    return toDateTime.difference(other.toDateTime).abs().inDays;
  }

  bool isInsideDateRange(Date start, Date end) {
    // CHECKS IF DATE IS AT THE INTERVALL ENDS
    if (isSameDay(start) || isSameDay(end)) return true;
    // CHECKS IF DATE IS BETWEEN START AND END
    return isAfter(start) && isBefore(end);
  }

  int get year => toDateTime.year;

  int get month => toDateTime.month;

  int get dayOfMonth => toDateTime.day;

  // 1 for Monday, 7 for Sunday
  int get weekDay => toDateTime.weekday;

  WeekDayEnum get weekDayEnum => WeekDayEnum.values[weekDay - 1];

  // int get weekNumber => getWeekNumber(toDateTime);

  int get toMillis => DateTime.parse(_iso8601String).millisecondsSinceEpoch;

  String get toDateString => _iso8601String;

  DateTime get toDateTime => DateTime.parse(_iso8601String);

  // DateParser get parser => DateParser(this);

  Date addDays(int days) {
    return Date.fromDateTime(toDateTime.copyWith(hour: 12).add(Duration(days: days)));
  }

  Date subtractDays(int days) {
    return addDays(-days);
  }

  List<Date> buildListForDaysAdded(int days) {
    return [this, for (int i = 1; i <= days; i++) addDays(i)];
  }

  Date addYears(int addedYears) {
    return Date.fromDateTime(DateTime(year + addedYears, month, dayOfMonth));
  }

  @override
  String toString() {
    return 'Date: ($_iso8601String)';
  }
}

class DateHelper {
  const DateHelper._();

  static Date getMondayOfWeek(Date date) {
    return date.subtractDays(date.weekDay - 1);
  }
}

enum WeekDayEnum {
  monday(0, 'Montag'),
  tuesday(1, 'Dienstag'),
  wednesday(2, 'Mittwoch'),
  thursday(3, 'Donnerstag'),
  friday(4, 'Freitag'),
  saturday(5, 'Samstag'),
  sunday(6, 'Sonntag');

  final int weekDayIndex;
  final String weekDayName;

  String get enumKey {
    return toString().split('.')[1];
  }

  const WeekDayEnum(this.weekDayIndex, this.weekDayName);
}

int getWeekNumber(DateTime datetime) {
  final week = Week.fromDate(datetime);
  return week.weekNumber;
}

// class DateParser {
//   final Date _date;

//   const DateParser(this._date);

//   String get toYMMMEd {
//     return DateFormat.yMMMEd().format(_date.toDateTime);
//   }

//   String get toYMMMd {
//     return DateFormat.yMMMd().format(_date.toDateTime);
//   }

//   String get toMMMEd {
//     return DateFormat.MMMEd().format(_date.toDateTime);
//   }

//   String get toYMMMM {
//     return DateFormat.yMMMM().format(_date.toDateTime);
//   }

//   String get toYMMMMEEEEd {
//     return DateFormat.yMMMMEEEEd().format(_date.toDateTime);
//   }

//   String get toDDMMYYYY {
//     return DateFormat('dd.MM.yyyy').format(_date.toDateTime);
//   }

//   String get weekDayName {
//     return DateFormat.EEEE().format(_date.toDateTime);
//   }
// }

// int getWeekNumber(DateTime datetime) {
//   final week = Week.fromDate(datetime);
//   return week.weekNumber;
// }

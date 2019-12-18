/// File formatting with dates for rotation date logging
/// with TimedRollingFileTree.
///
class LogFileNameFormatter {
  static const _year2charToken = "YY";
  static const _fullYearToken = "YYYY";
  static const _month2charToken = "MM";
  static const _month3charToken = "MMM";
  static const _monthToken = "MMMM";
  static const _dayToken = "DD";
  static const _dayOfWeekToken = "ddd";
  static const _hour12Token = "hh";
  static const _hour24Token = "HH";
  static const _hourPmAmToken = "aa";
  static const _minutesToken = "mm";
  static const _secondsToken = "SS";

  static const _dayFormat = "$_fullYearToken$_month2charToken$_dayToken";
  static const _timeFormat = "$_hour24Token$_minutesToken$_secondsToken";

  /// Filename format for files created with this formatter.
  String filenameFormat = "log_YYMMDD-HH.txt";

  /// Creates LogFileNameFormatter with given format or by default
  LogFileNameFormatter({this.filenameFormat = "log_YYMMDD-HH.txt"});

  /// Factory method to create date and time filename formatter with
  /// prefix and postfix.
  factory LogFileNameFormatter.full(
      {String prefix = "log_", String postfix = ".txt"}) {
    return LogFileNameFormatter(
        filenameFormat: "$prefix${_dayFormat}_$_timeFormat$postfix");
  }

  /// Factory method to create hourly filename formatter with
  /// prefix and postifx.
  factory LogFileNameFormatter.hourly(
      {String prefix = "log_", String postfix = ".txt"}) {
    return LogFileNameFormatter(
        filenameFormat: "$prefix${_dayFormat}_$_dayToken$postfix");
  }

  /// Factory method to create daily filename formatter with
  /// prefix and postfix
  factory LogFileNameFormatter.daily(
      {String prefix = "log_", String postfix = ".txt"}) {
    return LogFileNameFormatter(
        filenameFormat: "$prefix${_dayFormat}_$_dayToken$postfix");
  }

  /// Factory method to create weekly filename formatter with
  /// prefix and postfix
  factory LogFileNameFormatter.weekly(
      {String prefix = "log_", String postfix = ".txt"}) {
    return LogFileNameFormatter(filenameFormat: "$prefix$_dayFormat$postfix");
  }

  /// Formats date time based on defined formatter
  String format(DateTime dateTime) {
    var name = filenameFormat;
    return name
        .replaceAll(_fullYearToken, dateTime.year.toString().padLeft(4, '0'))
        .replaceAll(
            _year2charToken, (dateTime.year % 1000).toString().padLeft(2, '0'))
        .replaceAll(_monthToken, _month(dateTime.month))
        .replaceAll(_month3charToken, _month3(dateTime.month))
        .replaceAll(_month2charToken, dateTime.month.toString().padLeft(2, '0'))
        .replaceAll(_dayToken, dateTime.day.toString().padLeft(2, '0'))
        .replaceAll(_dayOfWeekToken, _dayOfWeek(dateTime.weekday))
        .replaceAll(
        _hour12Token, (dateTime.hour % 12).toString().padLeft(2, '0'))
        .replaceAll(_hour24Token, dateTime.hour.toString().padLeft(2, '0'))
        .replaceAll(_hourPmAmToken, _amPmHour(dateTime.hour))
        .replaceAll(_hourPmAmToken.toUpperCase(),
            _amPmHour(dateTime.hour).toUpperCase())
        .replaceAll(_secondsToken, dateTime.second.toString().padLeft(2, '0'))
        .replaceAll(_minutesToken, dateTime.minute.toString().padLeft(2, '0'));
  }

  String _amPmHour(int hour) {
    if (hour > 12) {
      return "pm";
    } else {
      return "am";
    }
  }

  String _dayOfWeek(int day) {
    switch (day) {
      case DateTime.monday:
        return "Mon";
      case DateTime.tuesday:
        return "Tue";
      case DateTime.wednesday:
        return "Wed";
      case DateTime.thursday:
        return "Thu";
      case DateTime.friday:
        return "Fri";
      case DateTime.saturday:
        return "Sat";
      case DateTime.sunday:
        return "Sun";
      default:
        return "NA";
    }
  }

  String _month3(int month) {
    switch (month) {
      // todo internationalization from external file
      case 1:
        return "Jan";
      case 2:
        return "Feb";
      case 3:
        return "Mar";
      case 4:
        return "Arp";
      case 5:
        return "May";
      case 6:
        return "Jun";
      case 7:
        return "Jul";
      case 8:
        return "Aug";
      case 9:
        return "Sep";
      case 10:
        return "Oct";
      case 11:
        return "Nov";
      case 12:
        return "Dec";
      default:
        return "NA";
    }
  }

  String _month(int month) {
    switch (month) {
      // todo internationalization from external file
      case 1:
        return "January";
      case 2:
        return "February";
      case 3:
        return "March";
      case 4:
        return "Arpil";
      case 5:
        return "May";
      case 6:
        return "June";
      case 7:
        return "July";
      case 8:
        return "August";
      case 9:
        return "September";
      case 10:
        return "October";
      case 11:
        return "November";
      case 12:
        return "December";
      default:
        return "NA";
    }
  }
}

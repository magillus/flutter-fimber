/// File formatting with dates for rotation date logging with TimedRollingFileTree.
///
class LogFileNameFormatter {
  static const _YEAR2_TOKEN = "YY";
  static const _YEAR4_TOKEN = "YYYY";
  static const _MONTH2_TOKEN = "MM";
  static const _MONTH3_TOKEN = "MMM";
  static const _MONTH_TOKEN = "MMMM";
  static const _DAY_TOKEN = "DD";
  static const _DAY_OF_WEEK_TOKEN = "ddd";
  static const _HOUR12_TOKEN = "hh";
  static const _HOUR24_TOKEN = "HH";
  static const _HOURAMPM_TOKEN = "aa";
  static const _MINUTES_TOKEN = "mm";
  static const _SECONDS_TOKEN = "SS";

  static const _DAY_FORMAT = "$_YEAR4_TOKEN$_MONTH2_TOKEN$_DAY_TOKEN";
  static const _TIME_FORMAT = "$_HOUR24_TOKEN$_MINUTES_TOKEN$_SECONDS_TOKEN";

  String filenameFormat = "log_YYMMDD-HH.txt";

  LogFileNameFormatter({String format = "log_YYMMDD-HH.txt"}) {
    this.filenameFormat = format;
  }

  factory LogFileNameFormatter.full(
      {String prefix = "log_", String postfix = ".txt"}) {
    return LogFileNameFormatter(
        format: "$prefix${_DAY_FORMAT}_${_TIME_FORMAT}$postfix");
  }

  factory LogFileNameFormatter.hourly(
      {String prefix = "log_", String postfix = ".txt"}) {
    return LogFileNameFormatter(
        format: "$prefix${_DAY_FORMAT}_$_DAY_TOKEN$postfix");
  }

  factory LogFileNameFormatter.daily(
      {String prefix = "log_", String postfix = ".txt"}) {
    return LogFileNameFormatter(
        format: "$prefix${_DAY_FORMAT}_$_DAY_TOKEN$postfix");
  }

  factory LogFileNameFormatter.weekly(
      {String prefix = "log_", String postfix = ".txt"}) {
    return LogFileNameFormatter(format: "$prefix$_DAY_FORMAT$postfix");
  }

  String format(DateTime dateTime) {
    String name = filenameFormat;
    return name
        .replaceAll(_YEAR4_TOKEN, dateTime.year.toString().padLeft(4, '0'))
        .replaceAll(
            _YEAR2_TOKEN, (dateTime.year % 1000).toString().padLeft(2, '0'))
        .replaceAll(_MONTH_TOKEN, _month(dateTime.month))
        .replaceAll(_MONTH3_TOKEN, _month3(dateTime.month))
        .replaceAll(_MONTH2_TOKEN, dateTime.month.toString().padLeft(2, '0'))
        .replaceAll(_DAY_TOKEN, dateTime.day.toString().padLeft(2, '0'))
        .replaceAll(_DAY_OF_WEEK_TOKEN, _dayOfWeek(dateTime.weekday))
        .replaceAll(
            _HOUR12_TOKEN, (dateTime.hour % 12).toString().padLeft(2, '0'))
        .replaceAll(_HOUR24_TOKEN, dateTime.hour.toString().padLeft(2, '0'))
        .replaceAll(_HOURAMPM_TOKEN, _amPmHour(dateTime.hour))
        .replaceAll(_HOURAMPM_TOKEN.toUpperCase(),
            _amPmHour(dateTime.hour).toUpperCase())
        .replaceAll(_SECONDS_TOKEN, dateTime.second.toString().padLeft(2, '0'))
        .replaceAll(_MINUTES_TOKEN, dateTime.minute.toString().padLeft(2, '0'));
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

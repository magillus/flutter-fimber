class DataSize {
  static const KB = 1024;
  static const MB = KB * KB;
  static const GB = MB * KB;
  static const TB = GB * KB;

  int realSize;

  DataSize(
      {int kilobytes = 0,
      int megabytes = 0,
      int gigabytes = 0,
      int terabytes = 0,
      int bytes = 0}) {
    realSize = bytes;
    realSize += kilobytes * KB;
    realSize += megabytes * MB;
    realSize += gigabytes * GB;
    realSize += terabytes * TB;
  }

  @override
  String toString() {
    if (realSize / TB > 0) {
      return "${realSize / TB} TB";
    } else if (realSize / GB > 0) {
      return "${realSize / GB} GB";
    } else if (realSize / MB > 0) {
      return "${realSize / MB} MB";
    } else if (realSize / KB > 0) {
      return "${realSize / KB} KB";
    }
    return "$realSize B";
  }

  factory DataSize.bytes(int value) {
    return DataSize(bytes: value);
  }

  factory DataSize.kb(int value) {
    return DataSize(kilobytes: value);
  }

  factory DataSize.mb(int value) {
    return DataSize(megabytes: value);
  }

  factory DataSize.gb(int value) {
    return DataSize(gigabytes: value);
  }

  factory DataSize.tb(int value) {
    return DataSize(terabytes: value);
  }
}

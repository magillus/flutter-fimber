/// Data size helper to help to calculate bytes/kilobytes, etc...
class DataSize {
  /// Kilo bytes value in bytes
  static const bytesInKilo = 1024;

  /// Mega bytes value in bytes
  static const byteInMega = bytesInKilo * bytesInKilo;

  /// Giga bytes value in bytes
  static const bytesInGiga = byteInMega * bytesInKilo;

  /// Tera bytes value in bytes
  static const bytesInTera = bytesInGiga * bytesInKilo;

  /// Real size in bytes.
  int realSize = 0;

  /// Create DataSize object with predefined size as optional.
  DataSize({
    int kilobytes = 0,
    int megabytes = 0,
    int gigabytes = 0,
    int terabytes = 0,
    int bytes = 0,
  }) {
    realSize = bytes;
    realSize += kilobytes * bytesInKilo;
    realSize += megabytes * byteInMega;
    realSize += gigabytes * bytesInGiga;
    realSize += terabytes * bytesInTera;
  }

  @override
  String toString() {
    if (realSize / bytesInTera > 0) {
      return "${realSize / bytesInTera} TB";
    } else if (realSize / bytesInGiga > 0) {
      return "${realSize / bytesInGiga} GB";
    } else if (realSize / byteInMega > 0) {
      return "${realSize / byteInMega} MB";
    } else if (realSize / bytesInKilo > 0) {
      return "${realSize / bytesInKilo} KB";
    }
    return "$realSize B";
  }

  /// Creates DataSize object with bytes value.
  factory DataSize.bytes(int value) {
    return DataSize(bytes: value);
  }

  /// Creates DataSize object with kilo bytes value.
  factory DataSize.kilo(int value) {
    return DataSize(kilobytes: value);
  }

  /// Creates DataSize object with mega bytes value.
  factory DataSize.mega(int value) {
    return DataSize(megabytes: value);
  }

  /// Creates DataSize object with giga bytes value.
  factory DataSize.giga(int value) {
    return DataSize(gigabytes: value);
  }

  /// Creates DataSize object with tera bytes value.
  factory DataSize.tera(int value) {
    return DataSize(terabytes: value);
  }
}

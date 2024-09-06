import 'package:logger/logger.dart';

/// Globally available instance available for easy logging.
late final Logger log;

/// Manages logging for the app.
class LoggingManager {
  /// Singleton instance for easy access.
  static late final LoggingManager instance;

  LoggingManager._() {
    instance = this;
  }

  static Future<LoggingManager> initialize({required bool verbose}) async {
    log = Logger(
      filter: ProductionFilter(),
      level: (verbose) ? Level.trace : Level.warning,
      output: ConsoleOutput(),
      printer: PrefixPrinter(PrettyPrinter(colors: true)),
    );

    log.t('Logger initialized.');

    return LoggingManager._();
  }

  /// Close the logger and release resources.
  void close() => log.close();
}

import 'dart:io';

import 'package:args/args.dart';
import 'package:linux_packaging_updater/src/args/src/models/args.dart';

/// Message to be displayed if called with an unknown argument.
String _helpTextGreeting = '''
Linux Package Updater

Automatically updates Linux packaging files for eg Flatpak.

Supported arguments:

''';

final _parser = ArgParser(usageLineLength: 80);

/// Parse received arguments.
Args parseArgs(List<String> args) {
  String? projectId;
  String? repository;
  String? user;
  bool? verbose;

  _parser
    ..addOption(
      'projectId',
      mandatory: true,
      callback: (String? value) => projectId = value,
    )
    ..addOption(
      'repository',
      mandatory: true,
      callback: (String? value) => repository = value,
    )
    ..addOption(
      'user',
      mandatory: true,
      callback: (String? value) => user = value,
    )
    ..addFlag(
      'verbose',
      abbr: 'v',
      negatable: false,
      callback: (bool value) => verbose = value,
      help: 'Output verbose logs for troubleshooting and debugging.',
    );

  // Add usage to the help text.
  _helpTextGreeting = '$_helpTextGreeting${_parser.usage}\n\n';

  try {
    final result = _parser.parse(args);
    if (result.rest.isNotEmpty) _outputHelpText();
  } on ArgParserException {
    _outputHelpText();
  }

  return Args(
    projectId: projectId!,
    repository: repository!,
    user: user!,
    verbose: verbose ?? false,
  );
}

void _outputHelpText() {
  stdout.writeln(_helpTextGreeting);
  exit(0);
}

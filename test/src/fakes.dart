import 'package:github/github.dart';
import 'package:mockito/mockito.dart';

class FakeReleaseAsset extends Fake implements ReleaseAsset {
  @override
  String? get browserDownloadUrl =>
      'https://github.com/Merrit/nyrna/releases/download/v2.9.3/Nyrna-Linux-Portable.tar.gz';
}

abstract class FakeRelease {
  static String body = '''
A few new features and improvements in this release:

## Improvements
- Updated Italian translations. [#102](https://github.com/Merrit/feeling_finder/pull/102) [@albanobattistella](https://github.com/albanobattistella)

## Bug Fixes
- Fixed an issue where the settings page was not scrollable. [#104](https://github.com/Merrit/feeling_finder/pull/104) [40f1745](https://github.com/Merrit/feeling_finder/commit/40f1745209f0c01726271eba7f3a2604ffdd4ab4)
- Fixed an issue with app icon alignment and shadows. [386b108](https://github.com/Merrit/feeling_finder/commit/386b108de9e92c099292c2e4248a8380329b3b76)

## Documentation
- Mentioned Ctrl+F shortcut in README. [#103](https://github.com/Merrit/feeling_finder/pull/103) [dbeeb338](https://github.com/Merrit/feeling_finder/commit/dbeeb338e4b6e8f624e644e1dffc7eacf4078bc6)

## Other Changes
- Added a debug menu to improve debugging. [#104](https://github.com/Merrit/feeling_finder/pull/104)
- Miscellaneous code cleanup, updates, and improvements.
''';

  static String htmlUrl = 'https://github.com/merrit/nyrna/releases/v2.9.3';

  static DateTime? publishedAt = DateTime.tryParse('2023-01-23 23:41:33.000Z');

  static String tagName = 'v2.9.3';
}

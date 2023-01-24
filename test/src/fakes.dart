import 'package:github/github.dart';
import 'package:linux_packaging_updater/src/github/github_info.dart';
import 'package:mocktail/mocktail.dart';

class MockGitHubInfo extends Mock implements GitHubInfo {}

class MockRepository extends Mock implements Repository {}

class FakeReleaseAsset extends Fake implements ReleaseAsset {
  @override
  String? get browserDownloadUrl =>
      'https://github.com/Merrit/nyrna/releases/download/v2.9.3/Nyrna-Linux-Portable.tar.gz';
}

class FakeRelease extends Fake implements Release {
  @override
  String? get body => '''
<!-- Release notes generated using configuration in .github/release.yml at v2.9.3 -->

## Bug Fixes
- trigger first run dialog https://github.com/Merrit/nyrna/commit/4d671d8f91076106cb697f6d32e01ca985daa72a
- improve dependency check logic https://github.com/Merrit/nyrna/commit/99d202d88965fd698c783b4ab2b1fe2fdca7362f
- add verbose logs for flatpak run https://github.com/Merrit/nyrna/commit/5ebd9bf2686f4cddbf2a28115b4aacca1e12e4cf
- add check and warning for Wayland session https://github.com/Merrit/nyrna/commit/901e4cc0e8af52017cf1fbd30bad535ce480c5da

**Full Changelog**: https://github.com/Merrit/nyrna/compare/v2.9.2...v2.9.3
''';

  @override
  DateTime? get publishedAt => DateTime.tryParse('2023-01-23 23:41:33.000Z');

  @override
  String? get tagName => 'v2.9.3';
}

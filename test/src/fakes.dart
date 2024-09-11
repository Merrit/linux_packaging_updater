import 'package:github/github.dart';
import 'package:mockito/mockito.dart';

class FakeReleaseAsset extends Fake implements ReleaseAsset {
  @override
  String? get browserDownloadUrl =>
      'https://github.com/Merrit/nyrna/releases/download/v2.9.3/Nyrna-Linux-Portable.tar.gz';
}

abstract class FakeRelease {
  static String body = '''
<!-- Release notes generated using configuration in .github/release.yml at v2.9.3 -->

## Bug Fixes
- trigger first run dialog https://github.com/Merrit/nyrna/commit/4d671d8f91076106cb697f6d32e01ca985daa72a
- improve dependency check logic https://github.com/Merrit/nyrna/commit/99d202d88965fd698c783b4ab2b1fe2fdca7362f
- add verbose logs for flatpak run https://github.com/Merrit/nyrna/commit/5ebd9bf2686f4cddbf2a28115b4aacca1e12e4cf
- add check and warning for Wayland session https://github.com/Merrit/nyrna/commit/901e4cc0e8af52017cf1fbd30bad535ce480c5da

## Documentation
- add privacy policy https://github.com/Merrit/nyrna/commit/57e778682ee6804727e6aecd13aa84c065cf5307
- update README description https://github.com/Merrit/nyrna/commit/4490930afb41a7b27bd5485604ad7df6ee740014
- update website description https://github.com/Merrit/nyrna/commit/5b38c88758cdb9789fbe5394c2901df2a6bccd2c
- update website promo image https://github.com/Merrit/nyrna/commit/475d7e977e4d518eeb89a93cc4014e6c23bcafe2
- improve disclaimer wording https://github.com/Merrit/nyrna/commit/2ab72a9a2720967b25a591c89f9e8c705c5b36a6

## Code Refactoring
- apply new lint suggestions https://github.com/Merrit/nyrna/commit/d3e8a40cadc0a2052efa8afc22970bd9fd51c934
- **settings**: cleanup updateAutoRefresh https://github.com/Merrit/nyrna/commit/97f701c46c0109539286aad3f41403b046f580c0

**Full Changelog**: https://github.com/Merrit/nyrna/compare/v2.9.2...v2.9.3
''';

  static String htmlUrl = 'https://github.com/merrit/nyrna/releases/v2.9.3';

  static DateTime? publishedAt = DateTime.tryParse('2023-01-23 23:41:33.000Z');

  static String tagName = 'v2.9.3';
}

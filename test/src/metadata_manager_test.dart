import 'package:github/github.dart';
import 'package:linux_packaging_updater/src/environment.dart';
import 'package:linux_packaging_updater/src/github/github_info.dart';
import 'package:linux_packaging_updater/src/logs/logs.dart';
import 'package:linux_packaging_updater/src/metadata_manager.dart';
import 'package:logger/logger.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';
import 'package:xml/xml.dart';

import 'fakes.dart';

@GenerateNiceMocks(<MockSpec>[
  MockSpec<GitHubInfo>(),
  MockSpec<Release>(),
])
import 'metadata_manager_test.mocks.dart';

const kExampleMetadata = '''
<?xml version="1.0" encoding="UTF-8"?>
<!-- 
    Generator for metainfo & .desktop files:
https://www.freedesktop.org/software/appstream/metainfocreator/#/
-->
<component type="desktop-application">
  <id>codes.merritt.Nyrna</id>
  <name>Nyrna</name>
  <summary>Suspend games and applications</summary>
  <developer_name>Merritt Codes</developer_name>
  <url type="homepage">https://nyrna.merritt.codes/</url>
  <url type="donation">https://merritt.codes/support/</url>
  <metadata_license>MIT</metadata_license>
  <project_license>GPL-3.0-or-later</project_license>
  <supports>
    <control>pointing</control>
    <control>keyboard</control>
    <control>touch</control>
  </supports>
  <description>
    <p>
      Similar to the incredibly useful sleep/suspend function found in consoles like the Nintendo
      Switch and Sony PlayStation; suspend your game (and its resource usage) at any time, and
      resume whenever you wish - at the push of a button.
    </p>
    <p>
      Nyrna can be used to suspend normal, non-game applications as well. For example:
    </p>
    <ul>
      <li>3D renders</li>
      <li>video encoding</li>
      <li>software compilation</li>
    </ul>
    <p>
      The CPU and GPU resources are being used by said task - maybe for hours - when you would like
      to use the system for something else. With Nyrna you can suspend that program, freeing up the
      resources (excluding RAM) until the process is resumed, without losing where you were - like
      the middle of a long job, or a gaming session between save points.
    </p>
  </description>
  <launchable type="desktop-id">codes.merritt.Nyrna.desktop</launchable>
  <screenshots>
    <screenshot type="default">
      <image>https://github.com/Merrit/nyrna/raw/main/assets/images/promo/promo.jpg</image>
    </screenshot>
    <screenshot>
      <image>https://nyrna.merritt.codes/assets/images/nyrna-window.png</image>
    </screenshot>
  </screenshots>
  <content_rating type="oars-1.1" />
  <releases>
    <release version="2.9.2" date="2023-01-18">
      <description>
      </description>
    </release>
  </releases>
</component>
''';

late GitHubInfo gitHubInfo;
late Release release;

void main() {
  log = Logger(level: Level.off);

  projectId = 'codes.merritt.Nyrna';
  repository = 'nyrna';
  user = 'merrit';

  setUp(() {
    release = MockRelease();
    when(release.publishedAt).thenReturn(FakeRelease.publishedAt);
    when(release.htmlUrl).thenReturn(FakeRelease.htmlUrl);
    when(release.tagName).thenReturn(FakeRelease.tagName);
    when(release.body).thenReturn(FakeRelease.body);

    gitHubInfo = MockGitHubInfo();
    when(gitHubInfo.latestRelease).thenReturn(release);
  });

  group('MetadataManager:', () {
    test('update() does not add full changelog', () async {
      expect(
        gitHubInfo.latestRelease.body!.contains('<!-- Release notes'),
        true,
      );
      expect(gitHubInfo.latestRelease.body!.contains('**Full Changelog'), true);

      final metadataManager = MetadataManager(
        githubInfo: gitHubInfo,
        projectId: projectId,
      );

      final updatedMetadataString = metadataManager.update(kExampleMetadata);
      expect(updatedMetadataString == kExampleMetadata, false);
      expect(updatedMetadataString.contains('<!-- Release notes'), false);
      expect(updatedMetadataString.contains('**Full Changelog'), false);
    });

    test('update() adds new release to list of releases', () async {
      final release = MockRelease();

      when(release.tagName).thenReturn('v3.1.0');
      when(release.publishedAt).thenReturn(DateTime.tryParse('2024-03-01 23:41:33.000Z'));
      when(gitHubInfo.latestRelease).thenReturn(release);

      final metadataManager = MetadataManager(
        githubInfo: gitHubInfo,
        projectId: projectId,
      );

      final updatedMetadataString = metadataManager.update(kExampleMetadata);
      final metainfo = XmlDocument.parse(updatedMetadataString);

      final releases = metainfo.findAllElements('release');
      final latestRelease = releases.first;

      expect(latestRelease.getAttribute('version'), '3.1.0');
      expect(latestRelease.getAttribute('date'), '2024-03-01');

      final previousRelease = releases.elementAt(1);
      expect(previousRelease.getAttribute('version'), '2.9.2');
      expect(previousRelease.getAttribute('date'), '2023-01-18');
    });

    test('new release includes link to detailed release notes', () async {
      final metadataManager = MetadataManager(
        githubInfo: gitHubInfo,
        projectId: projectId,
      );

      final updatedMetadataString = metadataManager.update(kExampleMetadata);
      final metainfo = XmlDocument.parse(updatedMetadataString);

      final releases = metainfo.findAllElements('releases').first;
      final newRelease = releases.findElements('release').first;

      final releaseNotesLink = newRelease.findElements('url').first;
      expect(releaseNotesLink.getAttribute('type'), 'details');
      expect(releaseNotesLink.text, release.htmlUrl);
      print(metainfo.toXmlString(pretty: true));
    });
  });
}

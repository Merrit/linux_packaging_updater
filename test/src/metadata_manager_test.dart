import 'package:linux_packaging_updater/src/environment.dart';
import 'package:linux_packaging_updater/src/github/github_info.dart';
import 'package:linux_packaging_updater/src/logs/logs.dart';
import 'package:linux_packaging_updater/src/metadata_manager.dart';
import 'package:logger/logger.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import 'fakes.dart';

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

void main() {
  log = Logger(level: Level.nothing);

  projectId = 'codes.merritt.Nyrna';
  repository = 'nyrna';
  user = 'merrit';

  setUp(() {
    gitHubInfo = MockGitHubInfo();
    when(() => gitHubInfo.latestRelease).thenReturn(FakeRelease());
  });

  group('MetadataManager:', () {
    test('update', () async {
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
  });
}

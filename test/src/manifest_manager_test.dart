import 'package:github/github.dart';
import 'package:linux_packaging_updater/src/environment.dart';
import 'package:linux_packaging_updater/src/github/github_info.dart';
import 'package:linux_packaging_updater/src/logs/logs.dart';
import 'package:linux_packaging_updater/src/manifest_manager.dart';
import 'package:logger/logger.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';
import 'package:yaml/yaml.dart';
import 'package:yaml_edit/yaml_edit.dart';

import 'fakes.dart';

@GenerateNiceMocks(<MockSpec>[
  MockSpec<GitHubInfo>(),
  MockSpec<Release>(),
  MockSpec<Repository>(),
])
import 'manifest_manager_test.mocks.dart';

const kExampleManifest = r'''
# yaml-language-server: $schema=https://raw.githubusercontent.com/flatpak/flatpak-builder/main/data/flatpak-manifest.schema.json
# Reference docs: https://docs.flatpak.org/en/latest/flatpak-builder-command-reference.html#flatpak-manifest

---
app-id: codes.merritt.Nyrna
runtime: org.freedesktop.Platform
runtime-version: "22.08"
sdk: org.freedesktop.Sdk
command: nyrna
separate-locales: false
finish-args:
  - --share=ipc
  - --socket=x11
  - --device=dri
  - --socket=pulseaudio
  - --share=network
  - --talk-name=org.freedesktop.Flatpak # Access host processes
modules:
  - name: keybinder3
    buildsystem: autotools
    post-install:
      - install -Dm644 COPYING /app/share/licenses/keybinder-3/COPYING
    sources:
      - type: archive
        url: https://github.com/kupferlauncher/keybinder/releases/download/keybinder-3.0-v0.3.2/keybinder-3.0-0.3.2.tar.gz
        sha256: e6e3de4e1f3b201814a956ab8f16dfc8a262db1937ff1eee4d855365398c6020
  # libappindicator
  - shared-modules/libappindicator/libappindicator-gtk3-12.10.json
  # Nyrna
  - name: nyrna
    buildsystem: simple
    only-arches:
      - x86_64
    build-commands:
      - ./build-flatpak.sh
    sources:
      - type: file
        url: https://github.com/Merrit/nyrna/releases/download/v2.9.2/Nyrna-Linux-Portable.tar.gz
        sha256: 4b905764e83fe96175adc0474ccced9c0d281190d3137ac774fb4dcbe0b6dff5
      - type: git
        url: https://github.com/Merrit/nyrna.git
        commit: d79731503b4ff831f9e9310c2dcea64b5f8279cc
      - type: file
        path: build-flatpak.sh
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
    when(gitHubInfo.linuxAsset).thenReturn(FakeReleaseAsset());
    when(gitHubInfo.linuxAssetHash()).thenAnswer(
        (_) async => '6k754264e83fe96175adc0474ccced9c0d281190d3137ac774fb4dcbe0b6dcc7');

    final repo = MockRepository();
    when(repo.cloneUrl).thenReturn('https://github.com/Merrit/nyrna.git');

    when(gitHubInfo.repo).thenReturn(repo);
    when(gitHubInfo.headCommitSha).thenReturn('j73511503b4ff831f9e9310c2dcea64b5f8573kj');
  });

  group('Manifest:', () {
    test('update manifest', () async {
      final manifestManager = ManifestManager(
        projectId: projectId,
        githubInfo: gitHubInfo,
      );

      final updatedManifestString = await manifestManager.update(
        kExampleManifest,
      );

      final yaml = YamlEditor(updatedManifestString);
      final int modulesLength = (yaml.parseAt(['modules']) as YamlList).length;
      final int appModuleIndex = modulesLength - 1;
      final assetMap =
          (yaml.parseAt(['modules', appModuleIndex, 'sources', 0])) as YamlMap;
      final gitMap = (yaml.parseAt(['modules', appModuleIndex, 'sources', 1])) as YamlMap;
      expect(assetMap['url'], gitHubInfo.linuxAsset!.browserDownloadUrl);
      expect(assetMap['sha256'], await gitHubInfo.linuxAssetHash());
      expect(gitMap['url'], gitHubInfo.repo.cloneUrl);
      expect(gitMap['commit'], gitHubInfo.headCommitSha);
    });
  });
}

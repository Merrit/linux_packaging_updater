import 'dart:io';

import 'package:yaml/yaml.dart';
import 'package:yaml_edit/yaml_edit.dart';

import 'github/github_info.dart';

class ManifestManager {
  final String projectId;
  final GitHubInfo githubInfo;

  const ManifestManager({
    required this.projectId,
    required this.githubInfo,
  });

  Future<String> read() async {
    File manifestFile = File('$projectId.yml');
    final manifestContents = await manifestFile.readAsString();
    return manifestContents;
  }

  Future<void> write(String manifestString) async {
    File manifestFile = File('$projectId.yml');
    await manifestFile.writeAsString(manifestString);
  }

  /// Update the manifest with the necessary info for latest release:
  ///
  /// - archive url
  /// - archive sha256
  /// - latest commit sha of the main branch
  Future<String> update(String manifestString) async {
    final yaml = YamlEditor(manifestString);
    final int modulesLength = (yaml.parseAt(['modules']) as YamlList).length;
    // App should be the final module.
    final int appModuleIndex = modulesLength - 1;

    // First source should be the app archive.
    yaml.update(
      ['modules', appModuleIndex, 'sources', 0],
      {
        'type': 'file',
        'url': githubInfo.linuxAsset!.browserDownloadUrl,
        'sha256': await githubInfo.linuxAssetHash(),
      },
    );

    // Second source should be the git repo with most recent commit.
    yaml.update(
      ['modules', appModuleIndex, 'sources', 1],
      {
        'type': 'git',
        'url': githubInfo.repo.cloneUrl,
        'commit': githubInfo.headCommitSha,
      },
    );

    return yaml.toString();
  }
}

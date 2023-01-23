import 'package:linux_packaging_updater/src/args/src/parser.dart';
import 'package:linux_packaging_updater/src/environment.dart';
import 'package:linux_packaging_updater/src/github/github_info.dart';
import 'package:linux_packaging_updater/src/logs/logs.dart';
import 'package:linux_packaging_updater/src/manifest_manager.dart';
import 'package:linux_packaging_updater/src/update_metainfo.dart';

Future<void> main(List<String> arguments) async {
  final parsedArgs = parseArgs(arguments);
  projectId = parsedArgs.projectId;
  repository = parsedArgs.repository;
  user = parsedArgs.user;

  await LoggingManager.initialize(verbose: parsedArgs.verbose);

  final githubInfo = await GitHubInfo.fetch(
    projectId: projectId,
    repository: repository,
    user: user,
  );

  if (githubInfo.linuxAsset == null) {
    throw Exception('Asset not found.');
  }

  await _updateManifest(githubInfo);

  updateMetainfo(projectId, githubInfo);
}

Future<void> _updateManifest(GitHubInfo gitHubInfo) async {
  final manifestManager = ManifestManager(
    projectId: projectId,
    githubInfo: gitHubInfo,
  );

  final yamlString = await manifestManager.read();
  final updatedManifestString = await manifestManager.update(yamlString);
  await manifestManager.write(updatedManifestString);
}

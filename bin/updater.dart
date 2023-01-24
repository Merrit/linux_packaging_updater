import 'package:linux_packaging_updater/src/args/src/parser.dart';
import 'package:linux_packaging_updater/src/environment.dart';
import 'package:linux_packaging_updater/src/github/github_info.dart';
import 'package:linux_packaging_updater/src/logs/logs.dart';
import 'package:linux_packaging_updater/src/manifest_manager.dart';
import 'package:linux_packaging_updater/src/metadata_manager.dart';

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

  if (parsedArgs.updateManifest) await _updateManifest(githubInfo);
  if (parsedArgs.updateMetadata) await _updateMetadata(githubInfo);
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

Future<void> _updateMetadata(GitHubInfo gitHubInfo) async {
  final metadataManager = MetadataManager(
    projectId: projectId,
    githubInfo: gitHubInfo,
  );

  final metadataString = await metadataManager.read();
  final updatedMetadataString = metadataManager.update(metadataString);
  await metadataManager.write(updatedMetadataString);
}

/// The CLI arguments after being parsed.
class Args {
  final String projectId;
  final String repository;
  final String user;
  final bool updateManifest;
  final bool updateMetadata;
  final bool verbose;

  const Args({
    required this.projectId,
    required this.repository,
    required this.user,
    required this.updateManifest,
    required this.updateMetadata,
    required this.verbose,
  });
}

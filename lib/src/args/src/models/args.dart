/// The CLI arguments after being parsed.
class Args {
  final String projectId;
  final String repository;
  final String user;
  final bool verbose;

  const Args({
    required this.projectId,
    required this.repository,
    required this.user,
    required this.verbose,
  });
}

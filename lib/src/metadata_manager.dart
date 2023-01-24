import 'dart:io';

import 'package:intl/intl.dart';
import 'package:xml/xml.dart';

import 'github/github_info.dart';

class MetadataManager {
  final String projectId;
  final GitHubInfo githubInfo;

  const MetadataManager({
    required this.projectId,
    required this.githubInfo,
  });

  Future<String> read() async {
    final metainfoFile = File('packaging/linux/$projectId.metainfo.xml');
    final metainfoContents = await metainfoFile.readAsString();
    return metainfoContents;
  }

  Future<void> write(String metadataString) async {
    final metainfoFile = File('packaging/linux/$projectId.metainfo.xml');
    await metainfoFile.writeAsString(metadataString);
  }

  /// Update the $projectId.metainfo.xml file with the
  /// date, version, and changelog of the new release.
  String update(String metadataString) {
    final metainfo = XmlDocument.parse(metadataString);

    final publishDate = githubInfo.latestRelease.publishedAt;
    final date = DateFormat('yyyy-MM-dd').format(publishDate!);

    final String releaseNotes = githubInfo.latestRelease.body ?? '';
    final List<String> releaseNotesLines = releaseNotes //
        .split('\n')
        .map((String line) {
      // Strip links as Flathub disallows them.
      line = line.replaceAll(RegExp(r'http\S*'), '');
      // Remove HTML comments
      line = line.replaceAll(RegExp(r'<!--.*-->'), '');
      // Remove the full changelog link
      line = line.replaceAll(RegExp(r'\*\*Full Changelog.*'), '');
      return line;
    }).toList();

    // Remove leading blank lines
    while (releaseNotesLines[0].trim() == '') {
      releaseNotesLines.removeAt(0);
    }

    // Remove trailing blank lines
    while (releaseNotesLines.last.trim() == '') {
      releaseNotesLines.removeLast();
    }

    // Update the xml
    metainfo.findAllElements('release').first.replace(
          XmlElement(
            XmlName('release'),
            [
              XmlAttribute(
                XmlName('version'),
                githubInfo.latestRelease.tagName!.substring(1),
              ),
              XmlAttribute(
                XmlName('date'),
                date,
              ),
            ],
            [
              XmlElement(
                XmlName('description'),
                [],
                [
                  for (var item in releaseNotesLines)
                    XmlElement(
                      XmlName('p'),
                      [],
                      [XmlText(item)],
                    ),
                  // XmlText(releaseNotes),
                ],
              ),
            ],
          ),
        );

    return metainfo.toXmlString(pretty: true);
  }
}

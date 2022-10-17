import 'dart:io';

import 'package:intl/intl.dart';
import 'package:xml/xml.dart';

import 'src.dart';

/// Update the $projectId.metainfo.xml file with the
/// date and version of the new release.
void updateMetainfo(String projectId, GitHubInfo githubInfo) {
  final metainfoFile = File('packaging/linux/$projectId.metainfo.xml');
  final metainfo = XmlDocument.parse(metainfoFile.readAsStringSync());

  final publishDate = githubInfo.latestRelease.publishedAt;
  final date = DateFormat('yyyy-MM-dd').format(publishDate!);

  final String releaseNotes = githubInfo.latestRelease.body ?? '';
  final List<String> releaseNotesLines = releaseNotes
      .split('\n')
      // Strip links as Flathub disallows them.
      .map((e) => e.replaceAll(RegExp(r'http\S*'), ''))
      .toList();

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

  metainfoFile.writeAsStringSync(metainfo.toXmlString(pretty: true));
}

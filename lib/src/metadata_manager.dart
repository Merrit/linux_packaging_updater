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
    final XmlDocument metainfo = XmlDocument.parse(metadataString);

    final publishDate = githubInfo.latestRelease.publishedAt;
    final date = DateFormat('yyyy-MM-dd').format(publishDate!);

    // Add the new release to the list of releases
    // Find the `releases` element
    final releases = metainfo.findAllElements('releases').first;

    // Create the new release element
    final newRelease = XmlElement(
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
        // Link to detailed release notes
        // <url type="details">https://example.org/changelog.html#version_1.0.1</url>
        if (githubInfo.latestRelease.htmlUrl != null)
          XmlElement(
            XmlName('url'),
            [
              XmlAttribute(
                XmlName('type'),
                'details',
              ),
            ],
            [
              XmlText(githubInfo.latestRelease.htmlUrl!),
            ],
          ),
        _parseReleaseNotes(),
      ],
    );

    // Add the new release to the list of releases
    releases.children.insert(0, newRelease);

    return metainfo.toXmlString(pretty: true);
  }

  /// Parses the release notes from the latest release and returns an XML element
  /// containing the release notes.
  XmlElement _parseReleaseNotes() {
    final description = XmlElement(XmlName('description'), [], []);

    final releaseNotes = githubInfo.latestRelease.body;

    if (releaseNotes == null) {
      // If there are no release notes, return an empty description element, as a
      // description element is required for every release.
      return description;
    }

    final lines = releaseNotes.split('\n');

    // The current list element being populated, if there are bullet lists in the release
    // notes.
    XmlElement? currentList;

    for (final line in lines) {
      if (line.trim().isEmpty) {
        // If the line is empty, skip it.
        continue;
      } else if (line.startsWith('#')) {
        // If the line starts with a heading marker ('#'), create a paragraph element.
        final headingText = RegExp(r'^#+\s(.*)').firstMatch(line)?.group(1) ?? '';
        description.children.add(XmlElement(XmlName('p'), [], [XmlText(headingText)]));
        currentList = null; // Reset the current bullet list, if any.
      } else if (line.startsWith('- ')) {
        // If the line starts with a list marker ('- '), create or add to a list element.
        String listItemText = line.substring(2);
        listItemText = _cleanReleaseNotesLine(listItemText);
        // If there is no current list, create a new 'ul' element.
        if (currentList == null) {
          currentList = XmlElement(XmlName('ul'), [], []);
          description.children.add(currentList);
        }
        // Add the list item to the current list.
        currentList.children.add(XmlElement(XmlName('li'), [], [XmlText(listItemText)]));
      } else {
        // If the line is not a heading or a list item, add it as a paragraph element.
        final paragraphText = _cleanReleaseNotesLine(line);
        description.children.add(XmlElement(XmlName('p'), [], [XmlText(paragraphText)]));
        currentList = null; // Reset the current bullet list, if any.
      }
    }

    // If there is a section in the release notes called `Other Changes`, remove it and
    // its bullet list. This section contains verbose information that is not useful or
    // relevant to the user.
    final otherChangesIndex = description.children.indexWhere((element) {
      if (element is XmlElement) {
        return element.name.local == 'p' && element.innerText == 'Other Changes';
      }
      return false;
    });
    if (otherChangesIndex != -1) {
      description.children.removeAt(otherChangesIndex);
      description.children.removeAt(otherChangesIndex);
    }

    // Return the populated 'description' element.
    return description;
  }

  /// Cleans up a line from the release notes.
  ///
  /// This method cleans up a line so as to be presentable to end users.
  String _cleanReleaseNotesLine(String line) {
    line = _stripMarkdownFormatting(line);
    line = _removeGitHubAttributions(line);
    // Remove links.
    line = line.replaceAll(RegExp(r'https?://\S+'), '').trim();
    return line;
  }

  /// Strips markdown formatting from a string.
  String _stripMarkdownFormatting(String text) {
    // Remove bold, italic, and underline formatting
    text = text.replaceAll(RegExp(r'(\*|_)'), '');
    return text;
  }

  /// Remove GitHub attributions.
  ///
  /// e.g.
  /// ```
  /// Updated Italian translations. [#102](https://github.com/Merrit/feeling_finder/pull/102) by [@albanobattistella](https://github.com/albanobattistella)
  /// ```
  /// becomes:
  /// ```
  /// Updated Italian translations.
  /// ```
  ///
  /// or
  /// ```
  /// Added a debug menu to improve debugging. [#104](https://github.com/Merrit/feeling_finder/pull/104)
  /// ```
  /// becomes:
  /// ```
  /// Added a debug menu to improve debugging.
  /// ```
  ///
  /// or
  ///
  /// ```
  /// Added hint to search bar for the keyboard shortcut. [#109](https://github.com/Merrit/feeling_finder/pull/109) ([f15c35b](https://github.com/Merrit/feeling_finder/commit/f15c35b43ebe13008425ada01f6fa44dbfab4ed6))
  /// ```
  ///
  /// becomes:
  /// ```
  /// Added hint to search bar for the keyboard shortcut.
  /// ```
  String _removeGitHubAttributions(String text) {
    // Remove any text that is enclosed in square brackets and parentheses.
    text = text.replaceAll(RegExp(r'\[.*?\]\(.*?\)'), '');
    // Remove any trailing empty parentheses.
    text = text.replaceAll(RegExp(r'\(\s*\)'), '');
    // Remove any trailing whitespace.
    text = text.trim();
    return text;
  }
}

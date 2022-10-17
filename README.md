<!-- 
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/guides/libraries/writing-package-pages). 

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-library-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/developing-packages). 
-->

Updater for Linux app metadata and packaging.

## Features

<!-- TODO: List what your package can do. Maybe include images, gifs, or videos. -->

- Update Flatpak manifest with new build info
- Update AppStream metadata file

<!-- 
## Getting started

TODO: List prerequisites and provide or point to information on how to
start using the package.
 -->

## Usage

*<project_id> should be the reverse domain name identifier for the app.*

The Flathub manifest should be `<project_root>/packaging/linux/flatpak/<project_id>.json`

The AppStream metadata should be `<project_root>/packaging/linux/<project_id>.metainfo.xml`

### Enable package

```shell
dart pub global activate --source git https://github.com/Merrit/linux_packaging_updater.git
```

### Run the updater from project root

```shell
updater <project_id> <github_repository_name> <github_username>
```

Example:

```shell
updater codes.merritt.bargain unit_bargain_hunter merrit
```

<!-- ## Additional information

TODO: Tell users more about the package: where to find more information, how to 
contribute to the package, how to file issues, what response they can expect 
from the package authors, and more.
 -->

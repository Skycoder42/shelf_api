# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.2.3] - 2025-07-30
### Changed
- Updated min sdk version to ^3.8.0
- Updated dependencies

## [1.2.2] - 2025-03-16
### Changed
- Updated dependencies
- Updated min dart sdk to 3.7.0
- Updated min `shelf_api` to 1.3.2

## [1.2.1] - 2024-12-31
### Changed
- Updated dependencies
- Updated min dart sdk to 3.6.0
- Updated min `shelf_api` to 1.3.1

## [1.2.0+1] - 2024-11-28
### Changed
- Updated dependencies

## [1.2.0] - 2024-09-08
### Added
- Added support for automatic handling of enums as path and query parameters
  - Are converter to value strings via `enum.name` and parsed using
  `enum.values.byName`
- Added support for URL encoding of path parameters
  - Ensures that all path parameters are correctly encoded by the api client and
  decoded by the server
  - Enabled by default, can be turned of via `PathParam.urlEncode` annotation

### Changed
- Updated min `shelf_api` to 1.3.0

## [1.1.1] - 2024-08-29
### Changed
- Updated dependencies
- Updated min dart sdk to 3.5.0

## [1.1.0] - 2024-05-29
### Added
- Added middleware support

## [1.0.1] - 2024-05-16
### Fixed
- Add missing linter ignore
- Add missing close method to client

## [1.0.0+1] - 2024-05-15
### Added
- Initial release

[1.2.3]: https://github.com/Skycoder42/shelf_api/compare/shelf_api_builder-v1.2.2...shelf_api_builder-v1.2.3
[1.2.2]: https://github.com/Skycoder42/shelf_api/compare/shelf_api_builder-v1.2.1...shelf_api_builder-v1.2.2
[1.2.1]: https://github.com/Skycoder42/shelf_api/compare/shelf_api_builder-v1.2.0+1...shelf_api_builder-v1.2.1
[1.2.0+1]: https://github.com/Skycoder42/shelf_api/compare/shelf_api_builder-v1.2.0...shelf_api_builder-v1.2.0+1
[1.2.0]: https://github.com/Skycoder42/shelf_api/compare/shelf_api_builder-v1.1.1...shelf_api_builder-v1.2.0
[1.1.1]: https://github.com/Skycoder42/shelf_api/compare/shelf_api_builder-v1.1.0...shelf_api_builder-v1.1.1
[1.1.0]: https://github.com/Skycoder42/shelf_api/compare/shelf_api_builder-v1.0.1...shelf_api_builder-v1.1.0
[1.0.1]: https://github.com/Skycoder42/shelf_api/compare/shelf_api_builder-v1.0.0+1...shelf_api_builder-v1.0.1
[1.0.0+1]: https://github.com/Skycoder42/shelf_api/releases/tag/shelf_api_builder-v1.0.0+1

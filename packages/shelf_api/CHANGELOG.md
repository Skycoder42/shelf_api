# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.3.0] - 2024-09-08
### Added
- Added `urlEncode` to `PathParam`
  - Ensures that all path parameters are correctly encoded by the api client and
  decoded by the server.

## [1.2.2] - 2024-08-29
### Changed
- Updated dependencies
- Updated min dart sdk to 3.5.0

## [1.2.1] - 2024-06-17
### Changed
- Updated dependencies

### Fixed
- Ensure request provider is always up to date with the newest request

## [1.2.0] - 2024-05-29
### Added
- Added middleware support to `ShelfApi` and `ApiEndpoint` annotations

## [1.1.0] - 2024-05-16
### Added
- Added rivershelfContainer middleware

## [1.0.2] - 2024-05-15
### Added
- Added content types to body annotation

### Changed
- Remove dependencies to dart:io to make the package web compatible

## [1.0.1] - 2024-05-13
### Changed
- rename requestProvider to shelfRequestProvider

## [1.0.0+1] - 2024-05-13
### Added
- Initial Release

[1.3.0]: https://github.com/Skycoder42/shelf_api/compare/shelf_api-v1.2.2...shelf_api-v1.3.0
[1.2.2]: https://github.com/Skycoder42/shelf_api/compare/shelf_api-v1.2.1...shelf_api-v1.2.2
[1.2.1]: https://github.com/Skycoder42/shelf_api/compare/shelf_api-v1.2.0...shelf_api-v1.2.1
[1.2.0]: https://github.com/Skycoder42/shelf_api/compare/shelf_api-v1.1.0...shelf_api-v1.2.0
[1.1.0]: https://github.com/Skycoder42/shelf_api/compare/shelf_api-v1.0.2...shelf_api-v1.1.0
[1.0.2]: https://github.com/Skycoder42/shelf_api/compare/shelf_api-v1.0.1...shelf_api-v1.0.2
[1.0.1]: https://github.com/Skycoder42/shelf_api/compare/shelf_api-v1.0.0+1...shelf_api-v1.0.1
[1.0.0+1]: https://github.com/Skycoder42/shelf_api/releases/tag/shelf_api-v1.0.0+1

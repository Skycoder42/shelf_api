# shelf_api
[![CI/CD for shelf_api_builder](https://github.com/Skycoder42/shelf_api/actions/workflows/shelf_api_builder_ci.yaml/badge.svg)](https://github.com/Skycoder42/shelf_api/actions/workflows/shelf_api_builder_ci.yaml)
[![Pub Version](https://img.shields.io/pub/v/shelf_api_builder)](https://pub.dev/packages/shelf_api_builder)

A code generator to create RESTful API endpoints to be integrated with shelf.

## Table of contents

## Features
- Code generation to build a [shelf](https://pub.dev/packages/shelf) based REST API
- Supports various body types (text, binary, streams and JSON)
- Supports custom path and query parameters (all string-parsable types)
- Supports use of custom type converters
- Automatic de/serialization of JSON types
- Generates [dio](https://pub.dev/packages/dio) based API client for easy consumption.
- Provides various middlewares via [shelf_api](https://pub.dev/packages/shelf_api) for convenient use:
  - `rivershelf` to integrate [riverpod](https://pub.dev/packages/riverpod) with shelf.
  - `handleFormatExceptions` to generate badRequest responses from `FormatException`s

## Installation
As this is a code generation package, you need to install the following packages:

```yaml
dependencies:
  shelf_api: <latest>

dev_dependencies:
  build_runner: <latest>
  shelf_api_builder: <latest>
```

# shelf_api
[![CI/CD for shelf_api_builder](https://github.com/Skycoder42/shelf_api/actions/workflows/shelf_api_builder_ci.yaml/badge.svg)](https://github.com/Skycoder42/shelf_api/actions/workflows/shelf_api_builder_ci.yaml)
[![Pub Version](https://img.shields.io/pub/v/shelf_api_builder)](https://pub.dev/packages/shelf_api_builder)

A code generator to create RESTful API endpoints to be integrated with shelf.

## Table of contents
* [Features](#features)
* [Installation](#installation)
* [Usage](#usage)
  + [1. Creating Endpoints](#1-creating-endpoints)
  + [2. Building an API](#2-building-an-api)
  + [3. Using the API](#3-using-the-api)
* [Generator Configuration](#generator-configuration)
* [Taking advantage of the riverpod integration](#taking-advantage-of-the-riverpod-integration)
  + [Understanding scoping of providers](#understanding-scoping-of-providers)
  + [Accessing providers outside of endpoints](#accessing-providers-outside-of-endpoints)
* [Documentation](#documentation)
  + [API docs](#api-docs)
  + [Using the package in combination with dart_frog](#using-the-package-in-combination-with-dart-frog)

<small><i><a href='https://ecotrust-canada.github.io/markdown-toc/'>Table of contents generated with markdown-toc</a></i></small>

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
As this is a code generation package, you need to install the following packages. In addition to the shelf_api packages
themselves you will also have to add a few other packages that will be referenced by the generated code:

```yaml
dependencies:
  # Code annotation package
  shelf_api: <latest>
  # Required API packages (if generateApi is enabled - defaults to true)
  shelf: <latest>
  shelf_router: <latest>
  # Required client packages (if generateClient is enabled - defaults to true)
  dio: <latest>

dev_dependencies:
  build_runner: <latest>
  shelf_api_builder: <latest>
```

## Usage
Using the package consists of three simple steps: First, you have to declare one more `Endpoint`s. Endpoints are
basically REST-Controllers, that can serve multiple routes. These Endpoints are then combined to a single API class,
which is used by the generator to create the shelf handler from the Endpoints as well as the Dio client wrapper.
Finally, you will have to mount the handler as part of your shelf server setup.

> **Note:** You can check out the
[Example](https://github.com/Skycoder42/shelf_api/tree/main/packages/shelf_api_builder/example) to get a full example
that showcases most of the features.

### 1. Creating Endpoints
Endpoint definitions are fairly straight forward:

```dart
import 'package:shelf_api/shelf_api.dart';

/// Optional annotation, if left out, no path will be prefixed
@ApiEndpoint('/basic')
class ExampleEndpoint extends ShelfEndpoint {
  ExampleEndpoint(super.request);

  /// @Get marks this method as "GET" endpoint for "/basic/"
  /// Named parameters are mapped to URL query parameters
  /// Invoking "GET /basic?name=Car" would respond with "Hello, Car!"
  @Get('/')
  String get({String name = 'World'}) => 'Hello, $name!';

  /// You can also have path parameters, a body and asynchronous returns
  @Post('/comments/<topic>')
  Future<Comment> postComment(String topic, @bodyParam Comment comment) async {
    /// If the rivershelf middleware is activated, you can access a ref here:
    final myService = ref.read(myServiceProvider);

    // ...
  }

  /// and much, much more - Check out the example!
}
```

### 2. Building an API
Simply declare a placeholder class somewhere and add the endpoints to it:

```dart
@ShelfApi(
  /// List all endpoints this API should serve
  [
    ExampleEndpoint,
  ],
  /// Optional base path for all Endpoints in this API
  basePath: '/api/v1/',
)
// ignore: unused_element
class _ExampleApi {}
```

This will generate two files. Both are standalone libraries and **not** part files:
- `example_api.api.dart`: Contains the shelf handler class named `ExampleApi`
- `example_api.client.dart`: Contains the dio client wrapper named `ExampleApiClient`

### 3. Using the API
To create a basic server, simply create a shelf pipeline ad serve it:

```dart
void main() async {
  final app = const Pipeline()
      .addMiddleware(handleFormatExceptions()) /// Recommended to gracefully handle JSON errors
      .addMiddleware(logRequests()) /// If you use this, it must come AFTER the handleFormatExceptions
      .addMiddleware(rivershelf()) /// Required if you want to be able to access a ref in you endpoints
      .addHandler(ExampleApi().call); /// Required. Registers the actual API as handler

  final server = await serve(app, 'localhost', 8080);
  print('Serving at http://${server.address.host}:${server.port}');
}
```

## Generator Configuration
The generator supports the following configuration options

 Key              | Type   | Default Value | Description
------------------|--------|---------------|-------------
 `generateApi`    | `bool` | `true`        | If set to `true` (the default), the Shelf API handler code will be generated
 `generateClient` | `bool` | `true`        | If set to `true` (the default), the Dio client code will be generated

**Note:** Checkout https://pub.dev/packages/build_config for more details on how to configure builders. If you disable
api or client code generation, you can safely remove the unneeded dependencies (as declared in the
[Installation](#Installation) section).

## Taking advantage of the riverpod integration
While the integration itself is straightforward - simply access the `ref` property in you endpoints, there are a few
usage hints to get the most out of it.

### Understanding scoping of providers
First, one has to understand how scoping of services work. By default, all request providers are managed **globally**.
This means keep-alive providers are the same for all requests. Auto disposable providers are always kept alive for at
least as long as the request is still processing, but will be cleaned up afterwards. However, that does **not** make
the transient. If two requests want to access an auto disposable provider at the same time, they *will* get the same
instance.

To get a unique instance for every request, you can use the `shelfRequestProvider` as manual dependency. Doing so will
ensure that the provider will be unique for the request and will be cleaned up afterwards, regardless of whether it is
kept alive or not:

```dart
@Riverpod(dependencies: [shelfRequest])
User requestUser(RequestUserRef ref) {
  /// You do not have to use the shelfRequestProvider here. Declaring it as
  /// dependency is enough to make it work.
  /// However, if you are using it to access the original request, you MUST
  /// add the dependency as well!
  // ...
}
```

Please note that there is no `watch` method on the the request ref. This is because the concept of watch only applies
to something that can be rebuild, like a widget. Thus, it makes no sense in this context. Currently, `listen` is not
supported as well, because requests should be short living and not watch for changes on a provider.

### Accessing providers outside of endpoints
Under the hood, the middleware is independent from Endpoints. This means you can access providers in any shelf handler
(or middleware), as long as the `rivershelf` middleware has been registered before. To do so, you can simply use the
`ref` extension on the request:

```dart
Future<Response> myHandler(Request request) async {
  final myService = request.ref.read(myServiceProvider)
}
```

## Documentation
### API docs
The documentation for the annotations and helper classes is available at
https://pub.dev/documentation/shelf_api/latest/.

A full example of the code generator can be found at https://pub.dev/packages/shelf_api_builder/example. An example that
displays the riverpod integration is available at https://pub.dev/packages/shelf_api/example

### Using the package in combination with dart_frog
It is possible to easily integrate this generate APIs and middlewares with
[dart_frog](https://pub.dev/packages/dart_frog) by using their shelf wrapper helper functions
[`fromShelfHandler`](https://pub.dev/documentation/dart_frog/latest/dart_frog/fromShelfHandler.html) and
[`fromShelfMiddleware`](https://pub.dev/documentation/dart_frog/latest/dart_frog/fromShelfMiddleware.html). For example,
if you would like to use the `ExampleApi` from before

```dart
/// in the _middleware.dart, add the following

Handler middleware(Handler handler) {
  return handler.use(fromShelfMiddleware(rivershelf()));
}

/// in your route.dart, wrap the api as such:
final onRequest = fromShelfHandler(ExampleApi().call);
```

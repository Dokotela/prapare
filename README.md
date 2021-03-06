# PRAPARE

A patient-facing Flutter app that allows for entry of Social Determinants of Health (SDOH) data in their own native language.

This app directly builds off of the work pioneered in the [PRAPARE] project, though at this time it is not formally affiliated with PRAPARE.

A related [Youtube playlist] and a [demo repository] exist to teach the concepts & components used when building this app.

<img align="right" src="demo.gif" width="250"/>

## Design

A basic [prototype] and relevant [wireframes] were created in Figma prior to app creation.

## Architecture

This app loosely follows the [Model-View-Controller+Services] `(MVC+S) architecture`, which has both [simple] and [production-level] examples of use. Whereas the above examples make heavy use of Provider, ChangeNotifier, and StatefulWidgets, we are instead using [Get] and some of the [Getx pattern] to simplify state management, routing, and dependency injection.

Our take on MVC+S is as follows:

- `model`: Class/objects created specifically for this app
- `views`: The UI layer, which is separated into multiple `pages` and may optionally be managed via a `viewcontroller`
- `controller`: Manages state of the model and resultant data. Controller classes typically extend `GetxController` (automatically disposed) and `GetxService` (rarely/never disposed)
- `service`: Connects your app with the outside world (e.g. internet or local file system).
- `command`: A high level function that performs a specific task, such as login/logout. It may utilize controllers, APIs, models, etc as necessary.
<img align="center" src="getMVCS.png" width="550"/>

## Folder Structure

The following is the folder structure under the `/lib` folder:

| **Folder**   | **Subfolder**                          | **Description**                                                                                        |
| ------------ | -------------------------------------- | ------------------------------------------------------------------------------------------------------ |
| /_internal   |                                        | custom modifications, constants / enums, utility classes                                               |
|              | /components                            | custom components / variations on Flutter widgets                                                      |
|              | /constants                             | local constants created for the app                                                                    |
|              | /enums                                 | predefined, named constants                                                                            |
|              | /utils                                 | local functions that do things like formatting                                                         |
| /api         |                                        | optional API key location                                                                              |
|              | &lt;custom>.dart                       | private API keys                                                                                       |
|              | api_public.dart                        | public API keys (no gitignore)                                                                         |
|              | api.dart                               | generic export file                                                                                    |
| /controllers |                                        | manages state of the model and resultant data                                                          |
|              | /commands                              | performs a specific global task (login, logout, change password)                                       |
|              | ../&lt;custom>_command.dart            | custom command class                                                                                   |
|              | ../abstract_command.dart               | abstract class for commonly used controllers, placeholder execute() method for commands                |
|              | &lt;custom>_controller.dart            | custom controller, typically used for state management                                                 |
| /models      |                                        | classes / objects created specifically for this app                                                    |
|              | &lt;custom>_data.dart                  | custom data class                                                                                      |
|              | &lt;custom>_model.dart                 | data model that typically modifies or shapes a data class                                              |
| /routes      |                                        | maps route to screen widgets                                                                           |
|              | app_pages.dart                         | the directory of each page within an app                                                               |
|              | app_routes.dart                        | string route names used in the app                                                                     |
| /services    |                                        | interaction with the outside world (REST, FHIR, http, file storage)                                    |
| /ui          |                                        | essentially all things a user sees in the app                                                          |
|              | /styled_components                     | shared widgets that use a common design system / theme so that the app seems consistent across screens |
|              | ../styled_&lt;widget_name>.dart        |                                                                                                        |
|              | /views                                 | top level widgets that are loaded via a route                                                          |
|              | ../&lt;screen_name>/                   |                                                                                                        |
|              | ../../&lt;screen_name>.dart            | the screen widget, may optionally include 'page', 'card', or 'panel' at the end based on view type     |
|              | ../../&lt;screen_name>_binding.dart    | controllers/services that are loaded (or lazy-loaded) in a view                                        |
|              | ../../&lt;screen_name>_controller.dart | the viewcontroller that only affects this screen widget                                                |
|              | ../../&lt;screen_name>_test.dart       | any relevant tests for the screen widget or its viewcontroller                                         |
|              | icons.dart                             | icon asset locations                                                                                   |
|              | localization.dart                      | strings with multiple translations                                                                     |
|              | strings.dart                           | strings used throughout an app                                                                         |
|              | themes.dart                            | custom themes and font sizes                                                                           |
| main.dart    |                                        | the first file a Dart app runs                                                                         |

## Questionnaire vs Survey

To differentiate between FHIR and our local data model, we have employed the term ```Survey```

- When an item is specifically related to FHIR and it's formatting, the term Questionnaire is used, along with the formatting for that FHIR resource
- When it is part of the local model (including locally stored surveys/questionnaires) the term survey is used 

## To Use the Questionnaire Package

You would create a new object:

```dart
var questionnaire = FhirQuestionnaire();
```

Load the survey (currently hardcoded into the app, but will soon have ability to download from url)

```dart
questionnaire.loadAndCreateSurvey();
```

Anytime that a user has answered questions that you would like to keep track of, you can pass them back like this:

```dart
final responses = [
  UserResponse(
      surveyCode: '/93043-8',
      questionCode: '/93043-8/56051-6',
      answerCode: 'LA33-6'),
  UserResponse(
      surveyCode: '/93043-8',
      questionCode: '/93043-8/32624-9',
      answerCode: 'LA14042-8'),
];

questionnaire.getUserResponses(responses);
```

This can be done multiple times or once, the object will simply keep it as a list until you are finished. Then, when you're ready to create the final response, call the method:

```dart
questionnaire.createResponse();
```

Now you have a QuestionnaireResponse item that you can do with as you will. To print for instance:

```dart
print(questionnaire.response.toJson());
```

## Fix Compile Time API Errors

With the exception of `/api/api_public.dart`, all files and classes in the `/api` folder are ignored by Git. Unless you're intentionally planning for an API key to exist in the public domain, **DO NOT COMMIT YOUR API KEYS DIRECTLY INTO YOUR GITHUB REPOSITORY**. Deleting them from your Git cache does nothing if the key has already been committed. They can still be found. If you did this accidentally, just inactivate that key (so others can't use it) and register a new one for use. Also, be careful of where and how you share your keys, since that may also serve as a point of failure.

Because our app connects to multiple FHIR servers, checking out this repository as is will give you compile time errors. To fix this, create the following files in the `/api` folder. Note that `YOUR_API_CLASS.dart` can be named whatever you want.

```dart
api.dart

export 'api_public.dart';
export 'YOUR_API_CLASS.dart';
```

```dart
YOUR_API_CLASS.dart

class ApiPrivate {
  static const prapareRedirectUrl = 'com.fhirfli.prapare://callback';
  static const aidboxUrl = 'YOUR_AIDBOX_URL';
  static const aidboxClientId = 'YOUR_CLIENT_ID';
  static const aidboxClientSecret = 'YOUR_SECRET';
  static const aidboxAuthUrl = null;
  static const aidboxTokenUrl = null;
  static const mihinUrl = 'YOUR_MIHIN_URL';
  static const mihinClientId =
      'YOUR_MIHIN_CLIENT_ID';
  static const mihinClientSecret =
      'YOUR_MIHIN_CLIENT_SECRET';
  static const mihinAuthUrl = null;
  static const mihinTokenUrl = null;
}
```

You can also use multiple classes, harness keys that are split into multiple strings/files, etc. We are intentionally including `api.dart` as part of our architecture to help you hide your private API class filename(s) from the rest of your code (assuming you only import this library at the top of your class). Keep in mind that class names are still discoverable.

It is also possible to harness [encrypted secrets] in GitHub for added security during build. We also **strongly** suggest [obfuscating your Dart code] when it is time to build a release version of your app.

## Style Guide

Follow the [Dart style guide].

Of note, you should:

- Use `UpperCamelCase` for types.
- Use `lowercase_snake_case` for libraries, packages, directories, and files.
- Use `lowerCamelCase` for constant names.
- Use `lowerCamelCase` for everything else (like variable names).
- Capitalize acronyms and abbreviations longer than two letters (Http rather than HTTP or http).
- A leading underscore makes a member variable private. Only use it if it is private.
- You can use single line if statements for returns.
- Use `///` instead of `/** */` for multi-line comments.

For VS Code, install the Dart and Flutter plugin. Set your editor to [format on save].

## Questions

We have a [Slack channel] and welcome new members/contributors.

[demo repository]: https://github.com/FireJuun/get_fluttered
[Dart style guide]: https://dart.dev/guides/language/effective-dart/style
[format on save]: https://flutter.dev/docs/development/tools/formatting#automatically-formatting-code-in-vs-code
[Get]: https://pub.dev/packages/get#the-three-pillars
[Getx pattern]: https://github.com/kauemurakami/getx_pattern
[encrypted secrets]: https://docs.github.com/en/free-pro-team@latest/actions/reference/encrypted-secrets
[Model-View-Controller+Services]: https://blog.gskinner.com/archives/2020/09/flutter-state-management-with-mvcs.html
[obfuscating your Dart code]: https://flutter.dev/docs/deployment/obfuscate
[PRAPARE]: https://www.nachc.org/research-and-data/prapare/
[production-level]: https://github.com/gskinnerTeam/flokk
[prototype]: https://www.figma.com/proto/cWKc5iTzhoddhxMov05rWG/PRAPARE?node-id=5%3A2&scaling=scale-down
[simple]: https://github.com/gskinnerTeam/flutter-mvcs-hello-world
[Slack channel]: https://bit.ly/flutterjuun-slack
[wireframes]: https://www.figma.com/file/cWKc5iTzhoddhxMov05rWG/PRAPARE?node-id=0%3A1
[Youtube playlist]: https://www.youtube.com/playlist?list=PL_e311Xg2aCQX98onj3OZ2XAE5vm8fCI1

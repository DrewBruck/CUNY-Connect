# CUNY Connect
## Drew Bruck, Mohammed Saab, Stanley Wong


## Overview
CUNY Connect is an application to assist CUNY students in streamlining communication
with their classmates. Users can communicate with their classmates in course-specific
conversations as well as direct communication with student(s) outside of course-specific
conversations. Students now have access to fast, real-time chat capability with their
classmates to promote academic success.


## App Features
- Login Page
- Registration Page with Firebase Authentication
- Forgot Password Button
- Administrative Course Chats / Group Chats / Individual Chats
- Real time chat.
- Most recent conversation moves to the top of the chat log page.
- Customizable Bio / Profile with avatars 
- Automated Scheduling
- Conversation Participants Lookup
- Group chats where messages are distinguishable by sender of messages.


## Next Steps
- Create a search conversation feature.
- Add the capability to send pictures. 
- Add encryption.
- Optimize algorithms to increase the speed of the app.


# Dependencies, Technologies, and Packages

| **Package**           | **Version**        | **Description**                                                                                     |
|-----------------------|--------------------|-----------------------------------------------------------------------------------------------------|
| `flutter`             | `sdk: flutter`     | The core Flutter SDK, providing the framework and essential components for building Flutter apps.   |
| `hive`                | `^2.0.4`           | A lightweight and blazing fast key-value database written in pure Dart, used for local storage.     |
| `hive_flutter`        | `^1.1.0`           | A Flutter plugin to integrate Hive database seamlessly with Flutter apps.                           |
| `hive_generator`      | `^2.0.1`           | A code generator for creating TypeAdapters for Hive, enabling custom object serialization.          |
| `build_runner`        | `^2.1.1`           | A build system for Dart, used for code generation and other build tasks.                            |
| `cupertino_icons`     | `^1.0.6`           | A collection of Cupertino (iOS-style) icons for use in Flutter applications.                        |
| `firebase_core`       | `^2.27.1`          | Flutter plugin to connect your Flutter app to Firebase.                                             |
| `firebase_auth`       | `^4.17.9`          | Flutter plugin for Firebase Authentication, enabling user sign-in and authentication.               |
| `cloud_firestore`     | `^4.15.10`         | Flutter plugin for Cloud Firestore, a NoSQL document database built for automatic scaling.          |
| `firebase_storage`    | `^11.6.11`         | Flutter plugin for Firebase Storage, providing cloud storage for storing and serving user-generated content. |
| `provider`            | `^6.0.0`           | A wrapper around InheritedWidget to make state management easier and more reusable in Flutter apps. |
| `flutter_test`        | `sdk: flutter`     | Testing framework provided by Flutter to write unit and widget tests.                               |
| `socket_io_client`    | `^2.0.0-beta.4-nullsafety.0` | A Dart client for Socket.IO, enabling real-time bi-directional communication between clients and servers. |
| `intl`                | `^0.19.0`          | Provides internationalization and localization facilities, including date and number formatting.    |
| `flutter_lints`       | `^3.0.0`           | A set of recommended lint rules to encourage good coding practices in Flutter and Dart projects.    |


## Useful Commands

### GitHub

__Clone Repo__
```
git clone https://copy-github-link-here.git
```

__Commit and Push Files__

```
git add .
git commit -m "Message"
git push 
```

__Get Current Files__

```
git pull
```

__Error With Pull__

```
git reset --hard
```

### Flutter
__Compile a dot G File__

```
dart run build_runner build
```


### Deploy App

__Install Firebase Tools__
```
npm install -g firebase-tools
```

__Initialize Firebase__
```
firebase login
firebase init
```

__Deploy Onto Server__
```
flutter build web
firebase deploy --only hosting
```

## Useful Links
- [Flutter SDK Install](https://docs.flutter.dev/get-started/install)
- [Use Linode For SocketIO](https://www.linode.com/docs/guides/using-socket-io/)
- [Cloud Firestore rules on subcollection](https://stackoverflow.com/questions/47809552/cloud-firestore-rules-on-subcollection)
- [How to avoid permission denied with a subcollection in firestore](https://stackoverflow.com/questions/67074480/how-to-avoid-permission-denied-with-a-subcollection-in-firestore)

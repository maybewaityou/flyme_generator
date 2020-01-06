# flyme_generator

> Just for Flutter.

flyme_generator is a generator for flyme (framework for flutter).

## Getting Started

### Edit Config file

1. add [flyme_annotation](https://github.com/maybewaityou/flyme_annotation) to pubspec.yaml:

```yaml
dependencies:
  flyme_annotation:
    git:
      url: https://github.com/maybewaityou/flyme_annotation.git
```

2. add [flyme_generator](https://github.com/maybewaityou/flyme_generator) to pubspec.yaml:

```yaml
dev_dependencies:
  flyme_generator:
    git:
      url: https://github.com/maybewaityou/flyme_generator.git
```

### Edit ViewModel file

just see the code:

```dart
import 'package:$PROJECT_NAME$/core/provider/view_model/view_model.dart';
import 'package:flyme_annotation/flyme_annotation.dart';
import 'user.dart';

part '$VIEW_MODEL_FILE_NAME$.g.dart';

@Properties([
  Property(name: "name", type: "String", initial: ""),
  Property(name: "age", type: "num", initial: "-1"),
  Property(
      name: "user",
      type: "User",
      initial: '''User(name: "", age: -1, email: "")'''),
  Property(name: "haha", type: "String"),
  Property(name: "asd", type: "String", initial: "Welcome"),
])
class TestModel extends _ViewModelProxy {
  String test = 'Hello Test';

  @override
  void init() {
    print("==== Test init ====");
  }
}
```

### Generate ViewModelProxy file

run build command:

```shell
flutter packages pub run build_runner build
```

`.g.dart` file is generated after run the command.



## What does the .g.dart look like

.g.dart

```dart
// GENERATED CODE - DO NOT MODIFY BY HAND

part of '$VIEW_MODEL_FILE_NAME$.dart';

// **************************************************************************
// ViewModelGenerator
// **************************************************************************

class _ViewModelProxy extends ViewModel {
  String _name = "";
  String get name => _name;
  set name(String args) {
    _name = args;
    notifyListeners();
  }

  num _age = -1;
  num get age => _age;
  set age(num args) {
    _age = args;
    notifyListeners();
  }

  User _user = User(name: "", age: -1, email: "");
  User get user => _user;
  set user(User args) {
    _user = args;
    notifyListeners();
  }

  String _haha = null;
  String get haha => _haha;
  set haha(String args) {
    _haha = args;
    notifyListeners();
  }

  String _asd = "Welcome";
  String get asd => _asd;
  set asd(String args) {
    _asd = args;
    notifyListeners();
  }
}
```


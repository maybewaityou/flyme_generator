// Copyright (c) 2018, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:dart_style/dart_style.dart';
import 'package:flyme_annotation/flyme_annotation.dart';
import 'package:source_gen/source_gen.dart';

class TranslatorGenerator extends GeneratorForAnnotation<Translator> {
  @override
  String generateForAnnotatedElement(
      Element element, ConstantReader annotation, BuildStep buildStep) {
    final name = element.name;
    print('== name ===>>>> $name');

    final dataModelTranslator = _makeClass(name);
    return DartFormatter().format(dataModelTranslator).toString();
  }
}

String _makeClass(String name) {
  return '''
class ${name}Translator extends DataModelTranslator<$name> {
  const ${name}Translator._();
  factory ${name}Translator() => ${name}Translator._();

  @override
  $name translate(Map<String, dynamic> json) {
    return $name.fromJson(json);
  }
}
  ''';
}

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
    final className = element.name;
    final translatorClassName = '${className}Translator';

    final translatorCode = _makeClass(
      className: className,
      translatorClassName: translatorClassName,
    );
    return DartFormatter().format(translatorCode).toString();
  }
}

String _makeClass({String className, String translatorClassName}) {
  return '''
class $translatorClassName extends DataModelTranslator<$className> {
  const $translatorClassName._();
  factory $translatorClassName() => $translatorClassName._();

  @override
  $className translate(Map<String, dynamic> json) {
    return $className.fromJson(json);
  }
}
  ''';
}

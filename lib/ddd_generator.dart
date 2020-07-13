// Copyright (c) 2018, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:built_collection/built_collection.dart';
import 'package:code_builder/code_builder.dart';
import 'package:dart_style/dart_style.dart';
import 'package:flyme_annotation/flyme_annotation.dart';
import 'package:source_gen/source_gen.dart';

const _DomainRegistry = '_\$DomainRegistry';
final _domainRegistryRef = ListBuilder<Reference>([refer('IDomainRegistry')]);

class DomainRegistryGenerator extends GeneratorForAnnotation<DomainFactory> {
  @override
  String generateForAnnotatedElement(
      Element element, ConstantReader annotation, BuildStep buildStep) {
    final domainRegistryClass = _makeDomainRegistryClass();

    final emitter = DartEmitter();
    return DartFormatter()
        .format(domainRegistryClass.accept(emitter).toString())
        .toString();
  }
}

Class _makeDomainRegistryClass() {
  final methods = ListBuilder<Method>();
  methods.add(_generateGetterMethod());
  return Class(
    (b) => b
      ..name = _DomainRegistry
      ..implements = _domainRegistryRef
      ..methods = methods,
  );
}

Method _generateGetterMethod() {
  return Method(
    (b) => b
      ..name = 'instance'
      ..lambda = true
      ..body = Code('getIt.get()')
      ..returns = refer('AuthenticationService'),
  );
}

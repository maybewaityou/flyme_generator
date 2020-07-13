// Copyright (c) 2018, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:built_collection/built_collection.dart';
import 'package:code_builder/code_builder.dart';
import 'package:dart_style/dart_style.dart';
import 'package:flyme_annotation/flyme_annotation.dart';
import 'package:flyme_generator/src/ddd/Collector.dart';
import 'package:source_gen/source_gen.dart';

const _DomainRegistry = '_\$DomainRegistry';
final _domainRegistryRef = ListBuilder<Reference>([refer('IDomainRegistry')]);

class DomainInstanceGenerator extends GeneratorForAnnotation<DomainInstance> {
  static Collector collector = Collector();

  @override
  String generateForAnnotatedElement(
      Element element, ConstantReader annotation, BuildStep buildStep) {
    collector.collect(element, annotation, buildStep);
    return null;
  }
}

class DomainRegistryGenerator extends GeneratorForAnnotation<DomainFactory> {
  Collector collector() {
    return DomainInstanceGenerator.collector;
  }

  @override
  String generateForAnnotatedElement(
      Element element, ConstantReader annotation, BuildStep buildStep) {
    final domainRegistryClass = _makeDomainRegistryClass(collector());

    final emitter = DartEmitter();
    return DartFormatter()
        .format(domainRegistryClass.accept(emitter).toString())
        .toString();
  }
}

Class _makeDomainRegistryClass(Collector collector) {
  final methodList = collector.metaInfoList
      .map((metaInfo) => _generateGetterMethod(metaInfo))
      .toList();
  return Class(
    (b) => b
      ..name = _DomainRegistry
      ..implements = _domainRegistryRef
      ..methods = ListBuilder<Method>(methodList),
  );
}

Method _generateGetterMethod(MetaInfo metaInfo) {
  final className = metaInfo.returnType;
//  final returnType = metaInfo.returnType;
  final methodName =
      className.substring(0, 1).toLowerCase() + className.substring(1);
  return Method(
    (b) => b
      ..name = methodName
      ..lambda = true
      ..body = Code('getIt.get()')
      ..returns = refer(className),
  );
}

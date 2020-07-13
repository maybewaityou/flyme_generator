// Copyright (c) 2018, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:build/build.dart';
import 'package:built_collection/built_collection.dart';
import 'package:code_builder/code_builder.dart';
import 'package:dart_style/dart_style.dart';
import 'package:flyme_annotation/flyme_annotation.dart';
import 'package:flyme_generator/src/model/tuple.dart';
import 'package:source_gen/source_gen.dart';

const _DomainRegistry = '_\$DomainRegistry';
final _domainRegistryRef = ListBuilder<Reference>([refer('IDomainRegistry')]);

class DomainRegistryGenerator extends GeneratorForAnnotation<DomainFactory> {
  @override
  String generateForAnnotatedElement(
      Element element, ConstantReader annotation, BuildStep buildStep) {
    final list = annotation.objectValue.getField('properties').toListValue();
    final registryClass = _makeDomainRegistryClass(list);

    final emitter = DartEmitter();
    return DartFormatter()
        .format(registryClass.accept(emitter).toString())
        .toString();
  }
}

Class _makeDomainRegistryClass(List<DartObject> list) {
  final methods = _parseListToTuple(list).item2;
  return Class((b) => b
        ..name = _DomainRegistry
        ..implements = _domainRegistryRef
//      ..methods.addAll(methods),
      );
}

Tuple2<List<Field>, List<Method>> _parseListToTuple(List<DartObject> list) {
  final fields = List<Field>();
  final methods = List<Method>();
  list.forEach((item) {
    fields.add(_parseItem2Field(item));
    methods.addAll(_parseItem2Methods(item));
  });

  return Tuple2<List<Field>, List<Method>>(fields, methods);
}

String _parsePropertyType(DartObject item) {
  final propertyType = item.getField('type').toTypeValue();
  final generic = item.getField('generic').toTypeValue();
  final generics = item.getField('generics').toListValue();

  var type = '$propertyType';
  if (generic != null) {
    type = type.replaceFirst('dynamic', '$generic');
  } else if (generics != null) {
    generics.forEach((g) {
      type = type.replaceFirst('dynamic', '$g');
    });
  }
  return type;
}

Field _parseItem2Field(DartObject item) {
  final name = item.getField('name').toStringValue();
  final propertyType = item.getField('type').toTypeValue();
  final desc = item.getField('desc').toStringValue();
  final descs = item.getField('descs').toListValue();

  final type = _parsePropertyType(item);
  final initial =
      _unwrapInitial(propertyType, item.getField('initial').toStringValue());

  return Field((b) {
    b
      ..name = '_$name'
      ..type = refer(type);

    // set initial value
    if (initial.isEmpty) {
      b..assignment = Code("''");
    } else {
      if (propertyType != null && propertyType.isDartCoreString) {
        b..assignment = Code("'$initial'");
      } else {
        b..assignment = Code(initial);
      }
    }

    // set document comment
    if (desc != null) {
      b..docs.add('  // $desc');
    } else if (descs != null) {
      b..docs.addAll(descs.map((d) => '  // ${d.toStringValue()}'));
    }

    return b;
  });
}

List<Method> _parseItem2Methods(DartObject item) {
  final name = item.getField('name').toStringValue();
  final type = _parsePropertyType(item);

  return [
    _generateGetterMethod(name: name, type: type),
    _generateSetterMethod(name: name, type: type)
  ];
}

Method _generateGetterMethod({String name, String type}) {
  return Method(
    (b) => b
      ..name = name
      ..lambda = true
      ..type = MethodType.getter
      ..body = Code('_$name')
      ..returns = refer(type),
  );
}

Method _generateSetterMethod({String name, String type}) {
  return Method(
    (b) => b
      ..name = name
      ..type = MethodType.setter
      ..requiredParameters.add(
        Parameter(
          (b) => b
            ..name = 'args'
            ..type = refer(type),
        ),
      )
      ..body = Code('''
        _$name = args;
        notifyListeners();
      '''),
  );
}

dynamic _unwrapInitial(DartType type, dynamic value) {
  if (value != null) return value;

  if (type.isDartCoreString) {
    return '';
  } else if (type.isDartCoreBool) {
    return 'false';
  } else if (type.isDartCoreNum ||
      type.isDartCoreInt ||
      type.isDartCoreDouble) {
    return '0';
  }
  return value;
}

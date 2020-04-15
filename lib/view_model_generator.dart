// Copyright (c) 2018, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/dart/constant/value.dart';
import 'package:build/build.dart';
import 'package:flyme_annotation/flyme_annotation.dart';
import 'package:flyme_generator/src/model/tuple.dart';
import 'package:source_gen/source_gen.dart';
import 'package:code_builder/code_builder.dart';
import 'package:dart_style/dart_style.dart';

const _viewModelName = '_\$ViewModel';
final _viewModelRef = refer('ViewModel');

class ViewModelGenerator extends GeneratorForAnnotation<Properties> {
  @override
  String generateForAnnotatedElement(
      Element element, ConstantReader annotation, BuildStep buildStep) {
    final list = annotation.objectValue.getField("properties").toListValue();
    final viewModelClass = _makeViewModelClass(list);

    final emitter = DartEmitter();
    return DartFormatter()
        .format(viewModelClass.accept(emitter).toString())
        .toString();
  }
}

Class _makeViewModelClass(List<DartObject> list) {
  final fields = _parseListToTuple(list).item;
  final methods = _parseListToTuple(list).item2;
  return Class(
    (b) => b
      ..name = _viewModelName
      ..extend = _viewModelRef
      ..fields.addAll(fields)
      ..methods.addAll(methods),
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
  final propertyType = item.getField("type").toTypeValue();
  final generic = item.getField("generic").toTypeValue();
  final generics = item.getField("generics").toListValue();

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
  final name = item.getField("name").toStringValue();
  final propertyType = item.getField("type").toTypeValue();

  final type = _parsePropertyType(item);
  final initial =
      _unwrapInitial(propertyType, item.getField("initial").toStringValue());

  return Field((b) {
    b
      ..name = '_$name'
      ..type = refer(type);
    if (initial.isNotEmpty) {
      b..assignment = Code(initial);
    }
    return b;
  });
}

List<Method> _parseItem2Methods(DartObject item) {
  final name = item.getField("name").toStringValue();
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

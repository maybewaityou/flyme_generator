// Copyright (c) 2018, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:code_builder/code_builder.dart';
import 'package:flyme_annotation/flyme_annotation.dart';
import 'package:flyme_generator/utils/parameters.dart';
import 'package:source_gen/source_gen.dart';

const _kFlutterWidgetsPath = 'package:flutter/material.dart';

final _widgetRef = refer('Widget', _kFlutterWidgetsPath);
final _statelessWidgetRef = refer('StatelessWidget', _kFlutterWidgetsPath);
final _keyRef = refer('Key', _kFlutterWidgetsPath);
final _buildContextRef = refer('BuildContext', _kFlutterWidgetsPath);

const _kOverrideDecorator = CodeExpression(Code('override'));

String _toTitle(String string) {
  return string.replaceFirstMapped(
      RegExp('[a-zA-Z]'), (match) => match.group(0).toUpperCase());
}

FunctionalWidget parseFunctionalWidgetAnnotation(ConstantReader reader) {
  return FunctionalWidget();
}

class FunctionalWidgetGenerator
    extends GeneratorForAnnotation<FunctionalWidget> {
  final _emitter = DartEmitter();

  @override
  String generateForAnnotatedElement(
      Element element, ConstantReader annotation, BuildStep buildStep) {
    final function = _checkValidElement(element);
    final type = parseFunctionalWidgetAnnotation(annotation);

    return _makeClassFromFunctionElement(function, type)
        .accept(_emitter)
        .toString();
  }

  Spec _makeClassFromFunctionElement(
      FunctionElement functionElement, FunctionalWidget annotation) {
    final parameters = FunctionParameters.parseFunctionElement(functionElement);

    final userDefined = parameters.userDefined;
    final positional = _computeBuildPositionalParametersExpression(parameters);
    final named = _computeBuildNamedParametersExpression(parameters);

    return Class(
      (b) {
        b
          ..name = _toTitle(functionElement.name)
          ..types.addAll(
              _parseTypeParameters(functionElement.typeParameters).toList())
          ..extend = _statelessWidgetRef
          ..fields.addAll(_paramsToFields(userDefined,
              doc: functionElement.documentationComment))
          ..constructors.add(_getConstructor(userDefined,
              doc: functionElement.documentationComment))
          ..methods.add(_createBuildMethod(
              functionElement.displayName, positional, named, functionElement));
        if (functionElement.documentationComment != null) {
          b.docs.add(functionElement.documentationComment);
        }
      },
    );
  }

  FunctionElement _checkValidElement(Element element) {
    if (element is! FunctionElement) {
      throw InvalidGenerationSourceError(
        'Error, the decorated element is not a function',
        element: element,
      );
    }
    final function = element as FunctionElement;
    if (function.isAsynchronous ||
        function.isExternal ||
        function.isGenerator ||
        function.returnType?.displayName != 'Widget') {
      throw InvalidGenerationSourceError(
        'Invalid prototype. The function must be synchronous, top level, and return a Widget',
        element: function,
      );
    }
    final className = _toTitle(function.name);
    if (className == function.name) {
      throw InvalidGenerationSourceError(
        'The function name must start with a lowercase',
        element: function,
      );
    }
    return function;
  }

  List<Expression> _computeBuildPositionalParametersExpression(
      FunctionParameters parameters) {
    final positional = <Expression>[];
    if (parameters.startsWithContext)
      positional.add(const CodeExpression(Code('_context')));
    if (parameters.startsWithKey)
      positional.add(const CodeExpression(Code('key')));
    if (parameters.followedByContext)
      positional.add(const CodeExpression(Code('_context')));
    if (parameters.followedByKey)
      positional.add(const CodeExpression(Code('key')));
    positional.addAll(parameters.userDefined
        .where((p) => !p.named)
        .map((p) => CodeExpression(Code(p.name))));
    return positional;
  }

  Map<String, Expression> _computeBuildNamedParametersExpression(
      FunctionParameters parameters) {
    final named = <String, Expression>{};
    for (final p in parameters.userDefined.where((p) => p.named)) {
      named[p.name] = CodeExpression(Code(p.name));
    }
    return named;
  }

  Iterable<Reference> _parseTypeParameters(
    List<TypeParameterElement> typeParameters,
  ) {
    return typeParameters.map((e) {
      return e.bound?.displayName != null
          ? refer('${e.displayName} extends ${e.bound.displayName}')
          : refer(e.displayName);
    });
  }

  Iterable<Field> _paramsToFields(List<Parameter> params, {String doc}) sync* {
    for (final param in params) {
      yield Field(
        (b) => b
          ..name = param.name
          ..modifier = FieldModifier.final$
          ..docs.add(doc ?? '')
          ..type = param.type,
      );
    }
  }

  Constructor _getConstructor(List<Parameter> fields, {String doc}) {
    return Constructor(
      (b) => b
        ..constant = true
        ..optionalParameters.add(Parameter((b) => b
          ..named = true
          ..name = 'key'
          ..docs.clear()
          ..type = _keyRef))
        ..docs.add(doc ?? '')
        ..requiredParameters
            .addAll(fields.where((p) => !p.named).map((p) => p.rebuild((b) => b
              ..toThis = true
              ..docs.clear()
              ..type = null)))
        ..optionalParameters
            .addAll(fields.where((p) => p.named).map((p) => p.rebuild((b) => b
              ..toThis = true
              ..docs.clear()
              ..type = null)))
        ..initializers.add(const Code('super(key: key)')),
    );
  }

  Method _createBuildMethod(String functionName, List<Expression> positional,
      Map<String, Expression> named, FunctionElement function) {
    return Method(
      (b) => b
        ..name = 'build'
        ..annotations.add(_kOverrideDecorator)
        ..returns = _widgetRef
        ..requiredParameters.add(
          Parameter((b) => b
            ..name = '_context'
            ..type = _buildContextRef),
        )
        ..body = CodeExpression(Code(functionName))
            .call(
                positional,
                named,
                function.typeParameters
                    ?.map((p) => refer(p.displayName))
                    ?.toList())
            .code,
    );
  }
}

// Copyright (c) 2018, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';

import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:build/build.dart';
import 'package:flyme_annotation/flyme_annotation.dart';
import 'package:flyme_generator/src/route/collector.dart';
import 'package:flyme_generator/src/route/writer.dart';
import 'package:source_gen/source_gen.dart';

class RouteGenerator implements GeneratorForAnnotation<FRoute> {
  static Collector collector = Collector();

  @override
  dynamic generateForAnnotatedElement(
      Element element, ConstantReader annotation, BuildStep buildStep) {
    collector.collect(element, annotation, buildStep);
    return null;
  }

  @override
  FutureOr<String> generate(LibraryReader library, BuildStep buildStep) {
    return null;
  }

  @override
  TypeChecker get typeChecker => TypeChecker.fromRuntime(FRoute);
}

class RouteConfigGenerator implements GeneratorForAnnotation<FRouteConfig> {
  Collector collector() {
    return RouteGenerator.collector;
  }

  @override
  dynamic generateForAnnotatedElement(
      Element element, ConstantReader annotation, BuildStep buildStep) {
    return Writer(collector()).write();
  }

  @override
  FutureOr<String> generate(LibraryReader library, BuildStep buildStep) {
    return null;
  }

  @override
  TypeChecker get typeChecker => TypeChecker.fromRuntime(FRouteConfig);
}

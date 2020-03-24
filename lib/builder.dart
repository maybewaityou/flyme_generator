// Copyright (c) 2018, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// Configuration for using `package:build`-compatible build systems.
///
/// See:
/// * [build_runner](https://pub.dev/packages/build_runner)
///
/// This library is **not** intended to be imported by typical end-users unless
/// you are creating a custom compilation pipeline. See documentation for
/// details, and `build.yaml` for how these builders are configured by default.
library flyme_generator.builder;

import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';
import 'package:flyme_generator/src/utils.dart';
import 'package:flyme_generator/route_generator.dart';
import 'package:flyme_generator/view_model_generator.dart';
import 'package:flyme_generator/function_to_widget_class.dart';

/// view model generator builder
Builder viewModelGeneratorBuilder(BuilderOptions options) =>
    SharedPartBuilder([ViewModelGenerator()], 'view_model');

// Builder viewModelGeneratorBuilder(BuilderOptions options) =>
//     PartBuilder([ViewModelGenerator()], '.flyme.dart');

/// route generator builder
Builder routeConfigGeneratorBuilder(BuilderOptions options) =>
    LibraryBuilder(RouteConfigGenerator(), generatedExtension: '.config.dart');
Builder routeGeneratorBuilder(BuilderOptions options) =>
    LibraryBuilder(RouteGenerator(), generatedExtension: '.route.dart');

/// functional widget generator builder
Builder functionalWidgetGeneratorBuilder(BuilderOptions options) {
  final parse = parseBuilderOptions(options);
  return SharedPartBuilder(
    [FunctionalWidgetGenerator(parse)],
    'functional_widget',
  );
}

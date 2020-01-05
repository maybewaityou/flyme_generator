// Copyright (c) 2018, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

import 'annotations.dart';

class RouteGenerator extends GeneratorForAnnotation<LivingString> {
  @override
  String generateForAnnotatedElement(
      Element element, ConstantReader annotation, BuildStep buildStep) {
    // final path = annotation.read('path').literalValue as String;
    print('== element.name ===>>>> ${element.name}');
    // return '// ${element.name} * $path;';
    return '''
      String _\$${element.name} = "";
      String get \$${element.name} => __\$${element.name};
      set _\$${element.name}(String str) {
        __\$${element.name} = str;
      }
      ''';
  }
}

// class RouteGenerator extends GeneratorForAnnotation<Route> {
//   @override
//   String generateForAnnotatedElement(
//       Element element, ConstantReader annotation, BuildStep buildStep) {
//     final path = annotation.read('path').literalValue as String;

//     return '// ${element.name} * $path;';
//   }
// }

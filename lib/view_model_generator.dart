// Copyright (c) 2018, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

import 'annotations.dart';

class ViewModelGenerator extends GeneratorForAnnotation<Properties> {
  @override
  String generateForAnnotatedElement(
      Element element, ConstantReader annotation, BuildStep buildStep) {
    final list = annotation.objectValue.getField("properties").toListValue();
    StringBuffer sb = StringBuffer();

    sb.writeln("class _ViewModelProxy extends ViewModel {");
    list.forEach((itemObj) {
      final item = Property(
          name: itemObj.getField("name").toStringValue(),
          type: itemObj.getField("type").toStringValue(),
          initial: itemObj.getField("initial").toStringValue());
      final name = item.name;
      final type = item.type;
      final initial = item.initial;
      if (type == "String" && initial != null) {
        sb.writeln("$type _$name = \"$initial\";");
      } else {
        sb.writeln("$type _$name = $initial;");
      }
      sb.writeln("$type get $name => _$name;");
      sb.writeln("set $name($type args) {");
      sb.writeln("  _$name = args;");
      sb.writeln("  notifyListeners();");
      sb.writeln("}");
      sb.writeln("\n");
    });
    sb.writeln("}");

    return sb.toString();
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

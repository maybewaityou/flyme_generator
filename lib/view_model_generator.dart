// Copyright (c) 2018, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:build/build.dart';
import 'package:flyme_annotation/flyme_annotation.dart';
import 'package:source_gen/source_gen.dart';

class ViewModelGenerator extends GeneratorForAnnotation<Properties> {
  @override
  String generateForAnnotatedElement(
      Element element, ConstantReader annotation, BuildStep buildStep) {
    final list = annotation.objectValue.getField("properties").toListValue();
    StringBuffer sb = StringBuffer();

    sb.writeln("class _\$ViewModel extends ViewModel {");
    list.forEach((itemObj) {
      final name = itemObj.getField("name").toStringValue();
      final originType = itemObj.getField("type").toTypeValue();
      final generic = itemObj.getField("generic").toTypeValue();
      final initial = unwrapInitial(
          originType, itemObj.getField("initial").toStringValue());

      var type = "$originType";

      if (originType.isDartCoreString && initial != null) {
        sb.writeln("$type _$name = \"$initial\";");
      } else {
        if (generic != null) type = "$type<$generic>";

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

dynamic unwrapInitial(DartType type, dynamic value) {
  if (value != null) return value;

  if (type.isDartCoreString) {
    return "";
  } else if (type.isDartCoreBool) {
    return "false";
  } else if (type.isDartCoreNum ||
      type.isDartCoreInt ||
      type.isDartCoreDouble) {
    return "0";
  }
  return value;
}

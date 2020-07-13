import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

class MetaInfo {
  final String className;
  final String path;
  final String returnType;

  const MetaInfo({this.className, this.path, this.returnType});

  @override
  String toString() {
    return 'MetaInfo{className: $className, path: $path, returnType: $returnType}';
  }
}

class Collector {
  List<MetaInfo> metaInfoList = <MetaInfo>[];
  void collect(
      ClassElement element, ConstantReader annotation, BuildStep buildStep) {
    final String className = element.name;
    final type = annotation.objectValue.getField('as').toString();
    final returnType = type.contains("null")
        ? className
        : type
            .toString()
            .replaceAll('Type', '')
            .replaceAll('*', '')
            .replaceAll('(', '')
            .replaceAll(')', '')
            .trim();

    var path = buildStep.inputId.path;
    if (buildStep.inputId.path.contains('lib/')) {
      path =
          "package:${buildStep.inputId.package}/${buildStep.inputId.path.replaceFirst('lib/', '')}";
    }

    final metaInfo =
        MetaInfo(className: className, path: path, returnType: returnType);
    metaInfoList.add(metaInfo);
  }

  @override
  String toString() {
    return 'Collector{metaInfoList: $metaInfoList}';
  }
}

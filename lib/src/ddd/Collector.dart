import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

class MetaInfo {
  final String className;
  final String path;
  final String returnType;
  final String project;

  const MetaInfo({this.className, this.path, this.returnType, this.project});

  @override
  String toString() {
    return 'MetaInfo{className: $className, path: $path, returnType: $returnType, project: $project}';
  }
}

class Collector {
  List<MetaInfo> metaInfoList = <MetaInfo>[];
  String project;

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
    var project = 'flyme_app';
    if (buildStep.inputId.path.contains('lib/')) {
      path =
          "package:${buildStep.inputId.package}/${buildStep.inputId.path.replaceFirst('lib/', '')}";
      project = buildStep.inputId.package;
      this.project = project;
    }

    final metaInfo = MetaInfo(
      className: className,
      path: path,
      returnType: returnType,
      project: project,
    );
    metaInfoList.add(metaInfo);
  }

  @override
  String toString() {
    return 'Collector{metaInfoList: $metaInfoList}';
  }
}

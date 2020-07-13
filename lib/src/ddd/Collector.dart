import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

class MetaInfo {
  final String className;
  final String path;
  final String supertype;

  const MetaInfo({this.className, this.path, this.supertype});

  @override
  String toString() {
    return 'MetaInfo{className: $className, path: $path, supertype: $supertype}';
  }
}

class Collector {
  List<MetaInfo> metaInfoList = <MetaInfo>[];
  void collect(
      ClassElement element, ConstantReader annotation, BuildStep buildStep) {
    final String className = element.name;

    var path = buildStep.inputId.path;
    if (buildStep.inputId.path.contains('lib/')) {
      path =
          "package:${buildStep.inputId.package}/${buildStep.inputId.path.replaceFirst('lib/', '')}";
    }
    print('== element.interfaces ===>>>> ${element.interfaces}');
//    print('== annotation.objectValue ===>>>> ${annotation.objectValue}');
    print('== annotation.listValue ===>>>> ${annotation.listValue}');
    final metaInfo = MetaInfo(className: className, path: path, supertype: '');
    metaInfoList.add(metaInfo);
  }

  @override
  String toString() {
    return 'Collector{metaInfoList: $metaInfoList}';
  }
}

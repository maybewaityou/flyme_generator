import 'package:flyme_generator/src/route/tpl.dart';
import 'package:mustache4dart/mustache4dart.dart';

import 'collector.dart';

class Writer {
  Collector collector;
  Writer(this.collector);

  String instanceCreated() {
    return instanceCreatedTpl;
  }

  String instanceFromClazz() {
    final StringBuffer buffer = new StringBuffer();
    buffer..writeln('switch(clazz) {');
    final Map<String, bool> mappedClazz = <String, bool>{};
    final Function writeClazzCase = (Map<String, dynamic> config) {
      final dynamic clazz = config['clazz'];
      if (mappedClazz[clazz] == null) {
        mappedClazz[clazz] = true;
      } else {
        return;
      }
      buffer.writeln('case ${clazz}: return new ${clazz}(option);');
    };
    collector.routerMap
        .forEach((String url, List<Map<String, dynamic>> configList) {
      configList.forEach(writeClazzCase);
    });
    buffer..writeln('default:return null;')..writeln('}');
    return buffer.toString();
  }

  String write() {
    final List<Map<String, String>> refs = <Map<String, String>>[];
    final Function addRef = (String path) {
      refs.add(<String, String>{'path': path});
    };
    collector.importList.forEach(addRef);
    final pages =
        collector.routerMap.map((key, value) => MapEntry(key, value[0]));
    print('== pages ===>>>> ${pages.toString()}');
    print('== collector ===>>>> ${collector.routerMap.toString()}');
    return render(clazzTpl, <String, dynamic>{
      'refs': refs,
      'pages': pages,
      'routerMap': collector.routerMap.toString(),
    });
  }
}

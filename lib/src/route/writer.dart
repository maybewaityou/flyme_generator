import 'package:flyme_generator/src/route/tpl.dart';
import 'package:mustache4dart/mustache4dart.dart';

import 'collector.dart';

class Writer {
  Collector collector;
  Writer(this.collector);

  String write() {
    final List<Map<String, String>> refs = <Map<String, String>>[];
    final List<Map<String, dynamic>> pages = <Map<String, dynamic>>[];
    final Function addRef = (String path) {
      refs.add(<String, String>{'path': path});
    };
    final Function addPage = (key, List<Map<String, dynamic>> value) {
      final target = value.first;
      if (target['params'] == null) {
        pages.add(<String, String>{
          'url': key,
          'page': '${target["clazz"]}(params)',
        });
      } else {
        pages.add(<String, String>{
          'url': key,
          'page': '${target["clazz"]}()',
        });
      }
    };
    collector.importList.forEach(addRef);
    collector.routerMap.forEach(addPage);

    print('== pages ===>>>> ${pages.toString()}');
    return render(clazzTpl, <String, dynamic>{
      'refs': refs,
      'pages': pages,
      'routerMap': collector.routerMap.toString(),
    });
  }
}

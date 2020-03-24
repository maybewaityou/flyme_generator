import 'package:flyme_generator/src/functional.dart';
import 'package:flyme_generator/src/route/collector.dart';
import 'package:flyme_generator/src/route/tpl.dart';
import 'package:mustache4dart/mustache4dart.dart';

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
      final fieldName = getFieldName(key);

      if (isNotFoundUrl(key.toString())) return;

      if (target['params'] != null) {
        pages.add(<String, String>{
          'url': key,
          'fieldName': fieldName,
          'page': '${target["clazz"]}(params)',
        });
      } else {
        pages.add(<String, String>{
          'url': key,
          'fieldName': fieldName,
          'page': '${target["clazz"]}()',
        });
      }
    };
    collector.importList.forEach(addRef);
    collector.routerMap.forEach(addPage);

    return render(clazzTpl, <String, dynamic>{
      'refs': refs,
      'pages': pages,
      'routerMap': collector.routerMap.toString(),
    });
  }
}

String getFieldName(String string) {
  return camelize(string.split('/').last);
}

bool isNotFoundUrl(String url) {
  return url.contains('NotFound') ||
      url.contains('notFound') ||
      url.contains('not-found') ||
      url.contains('not_found');
}

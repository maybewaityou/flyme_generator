const String clazzTpl = """
import 'package:flyme_ddd/flyme_ddd.dart';
import 'package:{{ project }}/common/app/application.dart';
{{# refs }}
import '{{ path }}';
{{/ refs }}

{{ content }}
""";

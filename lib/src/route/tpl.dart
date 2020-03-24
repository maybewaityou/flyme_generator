const String clazzTpl = """
import 'package:fluro/fluro.dart';
{{#refs}}
import '{{{path}}}';
{{/refs}}

class AppRoutePath {
  {{#pages}}
  static const {{{fieldName}}} = {{{url}}},
  {{/pages}}
}


final _routesMap = {
  {{#pages}}
  AppRoutePath.{{{fieldName}}}: (params) => {{{page}}},
  {{/pages}}
};

void setupRoutes(Router router) {
  _routesMap.forEach((key, pageBuilder) {
    router.define(
      key,
      handler: Handler(handlerFunc: (context, params) => pageBuilder(params)),
    );
  });
}

""";

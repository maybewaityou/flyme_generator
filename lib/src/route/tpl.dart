const String clazzTpl = """
import 'package:fluro/fluro.dart';
{{#refs}}
import '{{{path}}}';
{{/refs}}

class AppRoutesPath {
  {{#pages}}
  static const {{{fieldName}}} = {{{url}}};
  {{/pages}}
}

final _routesMap = {
  {{#pages}}
  AppRoutesPath.{{{fieldName}}}: (params) => {{{page}}},
  {{/pages}}
};

void setupRoutes(Router router) {
  router.notFoundHandler = _notFoundHandler;
  _routesMap.forEach((key, pageBuilder) {
    router.define(
      key,
      handler: Handler(handlerFunc: (context, params) => pageBuilder(params)),
    );
  });
}

final _notFoundHandler =
    Handler(handlerFunc: (context, params) => NotFoundPage());

""";

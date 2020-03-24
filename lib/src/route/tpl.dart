const String clazzTpl = """
import 'package:fluro/fluro.dart';
{{#refs}}
import '{{{path}}}';
{{/refs}}

final _routesMap = {
  {{#pages}}
  {{{path}}}: (params) => {{{value}}},
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

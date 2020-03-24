const String clazzTpl = """
{{#refs}}
import '{{{path}}}';
{{/refs}}

final _routesMap = {
  {{#pages}}
  {{{pages.key}}}(params) => {{{pages.value}}},
  {{/pages}}
};

final _routesMap = {{{routerMap}}};

""";

const String instanceCreatedTpl = """
""";

const String clazzTpl = """
{{#refs}}
import '{{{path}}}';
{{/refs}}

final _routesMap = {
  {{#pages}}
  {{{path}}}(params) => {{{page}}},
  {{/pages}}
};

""";

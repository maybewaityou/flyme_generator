/// Convert `camelCase` to `underscore_separated` and vice versa.
/// Top-level constant provides access to the API of this library.

/// Convert keys of given map from `camelCase` to `underscores`.
///
/// This function is recursive meaning it will convert keys of nested maps
/// if present.
Map<String, dynamic> decamelizeKeys(Map<String, dynamic> map) {
  var result = new Map();
  for (var key in map.keys) {
    if (key is! String) {
      throw new ArgumentError.value(
          key, 'key', 'Only string keys are supported in key converter.');
    }
    var value = map[key];
    if (value is Map<String, dynamic>) {
      value = decamelizeKeys(value);
    }
    result[decamelize(key)] = value;
  }
  return result;
}

/// Converts given string from `camelCase` to underscore.
///
/// This function will attempt to detect sequences of uppercase characters
/// and separate them in a smart way. E.g.:
///
///     userId => user_id
///     userID => user_id
///     userVIPStatus => user_vip_status.
String decamelize(String key) {
  RegExp regex = new RegExp(r'([A-Z]+)');

  var r = key.replaceAllMapped(regex, (m) {
    var s = m.group(0);
    if (s.length > 1 && !key.endsWith(s)) {
      var s1 = s.substring(0, s.length - 1).toLowerCase();
      var s2 = s.substring(s.length - 1, s.length).toLowerCase();
      return '_${s1}_$s2}';
    } else {
      return '_' + s.toLowerCase();
    }
  });
  if (r.startsWith('_')) {
    r = r.replaceFirst('_', '');
  }

  return r;
}

/// Converts keys of given map from `underscores` to `camelCase`.
///
/// This function is recursive meaning it will convert keys of nested maps
/// if present.
Map<String, dynamic> camelizeKeys(Map<String, dynamic> map) {
  var result = new Map();
  for (var key in map.keys) {
    if (key is! String) {
      throw new ArgumentError.value(
          key, 'key', 'Only string keys are supported in key converter.');
    }
    var value = map[key];
    if (value is Map<String, dynamic>) {
      value = camelizeKeys(value);
    }
    result[camelize(key)] = value;
  }
  return result;
}

/// Converts given string from `underscores` to `camelCase`.
String camelize(String key) {
  RegExp regex = new RegExp(r'[_]+(.)');

  return key.replaceAllMapped(regex, (m) {
    return m.group(1).toUpperCase();
  });
}

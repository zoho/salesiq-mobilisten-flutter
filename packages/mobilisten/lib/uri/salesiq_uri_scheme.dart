/// A Dart representation of a URI scheme with hosts and path matchers.
class PathMatcher {
  /// Private constructor to prevent direct instantiation.
  const PathMatcher();
}

/// An exact path matcher.
class Exact extends PathMatcher {
  /// The exact path string to match against.
  final String path;

  /// Constructor for the Exact path matcher.
  const Exact(this.path);
}

/// A prefix path matcher.
class Prefix extends PathMatcher {
  /// The prefix string to match against.
  final String prefix;

  /// Constructor for the Prefix path matcher.
  const Prefix(this.prefix);
}

/// A suffix path matcher.
class Suffix extends PathMatcher {
  /// The suffix string to match against.
  final String suffix;

  /// Constructor for the Suffix path matcher.
  const Suffix(this.suffix);
}

/// A pattern matcher using simple wildcard patterns.
class Pattern extends PathMatcher {
  /// The pattern string to match against.
  final String pattern;

  /// Constructor for the Pattern matcher.
  const Pattern(this.pattern);
}

/// Represents a URI scheme with associated hosts and path matchers.
class SalesIQUriScheme {
  /// The scheme part of the URI (e.g., "https", "myapp").
  final String scheme;

  /// The host/domain part of the URI (e.g., "www.example.com").
  /// In Dart, `final` on a collection means the reference cannot be changed,
  /// but the contents of the collection itself can be modified.
  final Set<String> hosts = {};

  /// A list of path conditions to match against.
  final List<PathMatcher> paths = [];

  /// Constructor for the class.
  SalesIQUriScheme(this.scheme);

  /// Adds one or more hostnames (e.g., "example.com", "api.example.com").
  /// Dart doesn't have `vararg`, so we accept a List of strings.
  SalesIQUriScheme addHosts(List<String> newHosts) {
    hosts.addAll(newHosts);
    return this; // Return `this` to allow for a fluent, chainable API.
  }

  /// Adds one or more path conditions.
  SalesIQUriScheme addPaths(List<PathMatcher> newPaths) {
    paths.addAll(newPaths);
    return this;
  }

  /// Converts the instance to a Map representation.
  Map<String, dynamic> toMap() {
    return {
      "scheme": scheme,
      "hosts": hosts.toList(),
      "paths": paths.map((pathMatcher) {
        if (pathMatcher is Exact) {
          return {"type": "exact", "value": pathMatcher.path};
        } else if (pathMatcher is Prefix) {
          return {"type": "prefix", "value": pathMatcher.prefix};
        } else if (pathMatcher is Suffix) {
          return {"type": "suffix", "value": pathMatcher.suffix};
        } else if (pathMatcher is Pattern) {
          return {"type": "pattern", "value": pathMatcher.pattern};
        } else {
          return {"type": "unknown", "value": ""};
        }
      }).toList(),
    };
  }
}

/// The Dart form of a URI scheme with hosts and path matchers.
class PathMatcher {
  /// Creates a path matcher. Use one of its subclasses: [Exact], [Prefix],
  /// [Suffix], or [Pattern].
  const PathMatcher();
}

/// A path matcher that matches the exact path.
class Exact extends PathMatcher {
  /// The exact path to match.
  final String path;

  /// Creates an exact path matcher.
  const Exact(this.path);
}

/// A path matcher that matches a prefix.
class Prefix extends PathMatcher {
  /// The prefix to match.
  final String prefix;

  /// Creates a prefix path matcher.
  const Prefix(this.prefix);
}

/// A path matcher that matches a suffix.
class Suffix extends PathMatcher {
  /// The suffix to match.
  final String suffix;

  /// Creates a suffix path matcher.
  const Suffix(this.suffix);
}

/// A path matcher that uses simple wildcard patterns.
class Pattern extends PathMatcher {
  /// The pattern to match.
  final String pattern;

  /// Creates a pattern matcher.
  const Pattern(this.pattern);
}

/// Represents a URI scheme with associated hosts and path matchers.
class SalesIQUriScheme {
  /// The scheme part of the URI, such as "https" or "myapp".
  final String scheme;

  /// The hosts or domains of the URI to match, such as "www.example.com".
  final Set<String> hosts = {};

  /// The list of path conditions to match.
  final List<PathMatcher> paths = [];

  /// Creates a URI scheme with the given [scheme].
  SalesIQUriScheme(this.scheme);

  /// Adds one or more hostnames in [newHosts], such as "example.com" and
  /// "api.example.com". Returns `this`, so you can chain calls.
  SalesIQUriScheme addHosts(List<String> newHosts) {
    hosts.addAll(newHosts);
    return this; // Return `this` to allow for a fluent, chainable API.
  }

  /// Adds one or more path conditions in [newPaths]. Returns `this`, so you can
  /// chain calls.
  SalesIQUriScheme addPaths(List<PathMatcher> newPaths) {
    paths.addAll(newPaths);
    return this;
  }

  /// Converts this instance to a Map.
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

// Non namespaced. At least they're not monkeypatching core javascript objects, ok?

var toSlug = function(string) {
  return string.trim().toLowerCase().replace(/[^-a-z0-9~\s\.:;+=_]/g, '').replace(/[\s\.:;=+]+/g, '-');
}
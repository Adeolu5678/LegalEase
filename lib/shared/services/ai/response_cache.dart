class ResponseCache {
  final _cache = <String, String>{};
  final _accessOrder = <String>[];
  static const _maxSize = 100;
  
  String? get(String key) {
    if (_cache.containsKey(key)) {
      _accessOrder.remove(key);
      _accessOrder.add(key);
      return _cache[key];
    }
    return null;
  }
  
  void set(String key, String value) {
    if (_cache.containsKey(key)) {
      _accessOrder.remove(key);
    } else if (_cache.length >= _maxSize) {
      final oldestKey = _accessOrder.removeAt(0);
      _cache.remove(oldestKey);
    }
    _cache[key] = value;
    _accessOrder.add(key);
  }
  
  void clear() {
    _cache.clear();
    _accessOrder.clear();
  }
  
  String generateKey(String operation, String content, String? personaId) {
    return '$operation:${content.hashCode}:$personaId';
  }
}

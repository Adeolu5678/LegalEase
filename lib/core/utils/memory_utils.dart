import 'dart:async';
import 'dart:io';

/// A token that can be used to signal cancellation of an asynchronous operation.
///
/// Pass a [CancellationToken] to long-running operations and call [cancel]
/// to signal that the operation should be aborted.
///
/// Example:
/// ```dart
/// final token = CancellationToken();
/// 
/// // Later, to cancel:
/// token.cancel();
/// 
/// // In the operation:
/// if (token.isCancelled) {
///   throw CancellationException();
/// }
/// ```
class CancellationToken {
  bool _isCancelled = false;

  /// Whether cancellation has been requested.
  bool get isCancelled => _isCancelled;

  /// Signals that cancellation has been requested.
  void cancel() => _isCancelled = true;

  /// Resets the token to its non-cancelled state.
  ///
  /// This allows reusing the same token instance for multiple operations.
  void reset() => _isCancelled = false;
}

/// Exception thrown when an operation is cancelled via a [CancellationToken].
///
/// This exception should be thrown by operations that support cancellation
/// when they detect that [CancellationToken.isCancelled] is true.
class CancellationException implements Exception {
  /// A message describing the cancellation.
  final String message;

  /// Creates a new [CancellationException] with an optional [message].
  CancellationException([this.message = 'Operation was cancelled']);

  @override
  String toString() => 'CancellationException: $message';
}

/// Represents the level of memory pressure on the system.
enum MemoryPressureLevel {
  /// No memory pressure detected.
  none,

  /// Moderate memory pressure - consider releasing non-essential resources.
  moderate,

  /// Critical memory pressure - release all possible resources immediately.
  critical,
}

/// A monitor for system memory pressure levels.
///
/// This is a stub implementation that always reports no memory pressure.
/// Platform-specific implementations should override [currentLevel] to
/// provide actual memory pressure information.
///
/// Example:
/// ```dart
/// MemoryPressureMonitor.onLevelChanged = (level) {
///   if (level == MemoryPressureLevel.critical) {
///     cache.clear();
///   }
/// };
/// ```
class MemoryPressureMonitor {
  /// The current memory pressure level.
  ///
  /// Returns [MemoryPressureLevel.none] in this stub implementation.
  static MemoryPressureLevel get currentLevel => MemoryPressureLevel.none;

  /// Whether the system is currently under any memory pressure.
  static bool get isUnderPressure => currentLevel != MemoryPressureLevel.none;

  /// Callback invoked when memory pressure level changes.
  ///
  /// Platform-specific implementations should call this when the
  /// system memory pressure state changes.
  static void Function(MemoryPressureLevel)? onLevelChanged;
}

/// A pool that limits the number of concurrent operations.
///
/// Use this to prevent resource exhaustion when performing many
/// concurrent operations, such as network requests or file I/O.
///
/// Example:
/// ```dart
/// final pool = ResourcePool(5); // Max 5 concurrent operations
///
/// Future<void> processItem(Item item) async {
///   await pool.acquire();
///   try {
///     await doExpensiveWork(item);
///   } finally {
///     pool.release();
///   }
/// }
/// ```
class ResourcePool {
  /// The maximum number of concurrent operations allowed.
  final int maxConcurrent;

  int _current = 0;
  final _waiting = <Completer<void>>[];

  /// Creates a new [ResourcePool] with the specified [maxConcurrent] limit.
  ResourcePool(this.maxConcurrent);

  /// Acquires a slot in the pool.
  ///
  /// If the pool is at capacity, this will wait until a slot becomes
  /// available. Call [release] when done to free the slot.
  Future<void> acquire() async {
    if (_current < maxConcurrent) {
      _current++;
      return;
    }

    final completer = Completer<void>();
    _waiting.add(completer);
    await completer.future;
  }

  /// Releases a slot back to the pool.
  ///
  /// If there are waiting operations, the next one will be allowed to proceed.
  void release() {
    if (_waiting.isNotEmpty) {
      final completer = _waiting.removeAt(0);
      completer.complete();
      return;
    }

    if (_current > 0) {
      _current--;
    }
  }

  /// The current number of acquired slots.
  int get current => _current;

  /// The number of operations waiting for a slot.
  int get waitingCount => _waiting.length;

  /// Whether the pool is at capacity.
  bool get isAtCapacity => _current >= maxConcurrent;
}

/// A mixin that provides disposal tracking for resources.
///
/// Classes that manage resources that need explicit cleanup should
/// mix in this class and implement [onDispose].
///
/// Example:
/// ```dart
/// class FileReader with Disposable {
///   final File file;
///   RandomAccessFile? _raf;
///
///   FileReader(this.file);
///
///   @override
///   void onDispose() {
///     _raf?.close();
///     _raf = null;
///   }
/// }
/// ```
mixin Disposable {
  bool _isDisposed = false;

  /// Whether this object has been disposed.
  bool get isDisposed => _isDisposed;

  /// Disposes this object and calls [onDispose].
  ///
  /// This method is idempotent - calling it multiple times will only
  /// invoke [onDispose] once.
  void dispose() {
    if (!_isDisposed) {
      _isDisposed = true;
      onDispose();
    }
  }

  /// Called when the object is disposed.
  ///
  /// Override this method to perform cleanup of resources.
  void onDispose();

  /// Throws a [StateError] if this object has been disposed.
  ///
  /// Call this at the start of methods that require the object
  /// to still be active.
  void checkDisposed() {
    if (_isDisposed) {
      throw StateError('$runtimeType has been disposed');
    }
  }
}

/// Manages temporary files, ensuring they are tracked and cleaned up.
///
/// Use this to create temporary files that will be automatically
/// cleaned up when no longer needed.
///
/// Example:
/// ```dart
/// final tempManager = TempFileManager();
///
/// final tempFile = tempManager.createTempFile('cache', '.tmp');
/// // Use tempFile...
///
/// await tempManager.cleanup(); // Clean up tracked files
/// ```
class TempFileManager {
  final _files = <File>{};

  /// Creates a temporary file with the given [prefix] and [extension].
  ///
  /// The file is automatically tracked for cleanup. The actual file
  /// is created on disk with a unique name.
  File createTempFile(String prefix, String extension) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = DateTime.now().microsecond;
    final fileName = '${prefix}_${timestamp}_$random$extension';
    final tempDir = Directory.systemTemp;
    final file = File('${tempDir.path}$separator$fileName');
    _files.add(file);
    return file;
  }

  /// Tracks an existing [file] for cleanup.
  ///
  /// The file will be included in subsequent [cleanup] or [cleanupAll] calls.
  void track(File file) {
    _files.add(file);
  }

  /// Stops tracking a file without deleting it.
  ///
  /// Use this when a temporary file should be preserved.
  void untrack(File file) {
    _files.remove(file);
  }

  /// Cleans up all tracked temporary files.
  ///
  /// Files that fail to delete are silently ignored. Successfully
  /// deleted files are removed from tracking.
  Future<void> cleanup() async {
    final toRemove = <File>[];

    for (final file in _files) {
      try {
        if (await file.exists()) {
          await file.delete();
        }
        toRemove.add(file);
      } catch (_) {
        // Ignore errors during cleanup
      }
    }

    for (final file in toRemove) {
      _files.remove(file);
    }
  }

  /// Cleans up all tracked files, forcing deletion if possible.
  ///
  /// This attempts to delete all tracked files regardless of errors.
  Future<void> cleanupAll() async {
    final filesToRemove = Set<File>.from(_files);

    for (final file in filesToRemove) {
      try {
        if (await file.exists()) {
          await file.delete(recursive: true);
        }
      } catch (_) {
        // Ignore errors during cleanup
      }
    }

    _files.clear();
  }

  /// The number of files currently being tracked.
  int get trackedCount => _files.length;

  /// All files currently being tracked.
  Set<File> get trackedFiles => Set.unmodifiable(_files);

  /// Removes all tracked files without deleting them.
  void clearTracking() {
    _files.clear();
  }
}

/// Gets the platform-specific path separator.
String get separator => Platform.pathSeparator;

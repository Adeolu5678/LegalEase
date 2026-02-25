import 'package:legalease/shared/models/persona_model.dart';

/// Repository interface for managing user personas.
///
/// Provides CRUD operations and active persona management for
/// premium users' custom AI personas.
abstract class PersonaRepository {
  /// Retrieves all personas for a given user.
  ///
  /// Returns a list of [Persona] objects owned by the user.
  Future<List<Persona>> getPersonas(String userId);

  /// Retrieves a specific persona by its ID.
  ///
  /// Returns the [Persona] if found, otherwise null.
  Future<Persona?> getPersona(String userId, String personaId);

  /// Creates a new persona for the user.
  ///
  /// Returns the created [Persona] with generated ID.
  Future<Persona> createPersona(String userId, Persona persona);

  /// Updates an existing persona.
  ///
  /// Returns the updated [Persona].
  Future<Persona> updatePersona(String userId, Persona persona);

  /// Deletes a persona.
  ///
  /// Throws [PersonaException] if the persona doesn't exist or
  /// belongs to another user.
  Future<void> deletePersona(String userId, String personaId);

  /// Sets the active persona for a user.
  ///
  /// Only one persona can be active at a time.
  Future<void> setActivePersona(String userId, String personaId);

  /// Gets the currently active persona for a user.
  ///
  /// Returns null if no persona is active.
  Future<Persona?> getActivePersona(String userId);

  /// Streams the active persona for real-time updates.
  ///
  /// Emits null if no persona is active.
  Stream<Persona?> watchActivePersona(String userId);

  /// Clears the active persona for a user.
  Future<void> clearActivePersona(String userId);

  /// Streams all personas for a user in real-time.
  Stream<List<Persona>> watchPersonas(String userId);
}

/// Exception thrown when persona operations fail.
class PersonaException implements Exception {
  final String message;
  final String code;

  const PersonaException(this.message, this.code);

  @override
  String toString() => 'PersonaException: $message (code: $code)';
}

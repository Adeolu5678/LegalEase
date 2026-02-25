import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:legalease/features/persona/domain/repositories/persona_repository.dart';
import 'package:legalease/shared/models/persona_model.dart';

/// Firebase implementation of [PersonaRepository].
///
/// Personas are stored as subcollections under each user:
/// - Collection path: `users/{userId}/personas`
/// - Active persona reference: `users/{userId}/settings/activePersona`
class FirebasePersonaRepository implements PersonaRepository {
  final FirebaseFirestore _firestore;

  FirebasePersonaRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Returns the personas subcollection for a user.
  CollectionReference<Map<String, dynamic>> _personasRef(String userId) =>
      _firestore.collection('users/$userId/personas');

  /// Returns the settings document for a user.
  DocumentReference<Map<String, dynamic>> _settingsRef(String userId) =>
      _firestore.doc('users/$userId/settings');

  @override
  Future<List<Persona>> getPersonas(String userId) async {
    try {
      final snapshot = await _personasRef(userId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => _mapToPersona(doc.id, doc.data()))
          .toList();
    } on FirebaseException catch (e) {
      throw PersonaException(
        'Failed to fetch personas: ${e.message}',
        e.code,
      );
    } catch (e) {
      throw PersonaException(
        'An unexpected error occurred while fetching personas',
        'unknown',
      );
    }
  }

  @override
  Future<Persona?> getPersona(String userId, String personaId) async {
    try {
      final doc = await _personasRef(userId).doc(personaId).get();

      if (!doc.exists) return null;

      return _mapToPersona(doc.id, doc.data()!);
    } on FirebaseException catch (e) {
      throw PersonaException(
        'Failed to fetch persona: ${e.message}',
        e.code,
      );
    } catch (e) {
      throw PersonaException(
        'An unexpected error occurred while fetching persona',
        'unknown',
      );
    }
  }

  @override
  Future<Persona> createPersona(String userId, Persona persona) async {
    try {
      final docRef = _personasRef(userId).doc();
      final now = DateTime.now();

      final newPersona = persona.copyWith(
        id: docRef.id,
        userId: userId,
        createdAt: now,
        updatedAt: now,
      );

      await docRef.set(_personaToMap(newPersona, isNew: true));

      return newPersona;
    } on FirebaseException catch (e) {
      throw PersonaException(
        'Failed to create persona: ${e.message}',
        e.code,
      );
    } catch (e) {
      throw PersonaException(
        'An unexpected error occurred while creating persona',
        'unknown',
      );
    }
  }

  @override
  Future<Persona> updatePersona(String userId, Persona persona) async {
    try {
      final docRef = _personasRef(userId).doc(persona.id);

      final updatedPersona = persona.copyWith(
        updatedAt: DateTime.now(),
      );

      await docRef.update(_personaToMap(updatedPersona));

      return updatedPersona;
    } on FirebaseException catch (e) {
      if (e.code == 'not-found') {
        throw PersonaException(
          'Persona not found',
          'persona-not-found',
        );
      }
      throw PersonaException(
        'Failed to update persona: ${e.message}',
        e.code,
      );
    } catch (e) {
      throw PersonaException(
        'An unexpected error occurred while updating persona',
        'unknown',
      );
    }
  }

  @override
  Future<void> deletePersona(String userId, String personaId) async {
    try {
      final docRef = _personasRef(userId).doc(personaId);

      final doc = await docRef.get();
      if (!doc.exists) {
        throw PersonaException(
          'Persona not found',
          'persona-not-found',
        );
      }

      final settingsDoc = await _settingsRef(userId).get();
      if (settingsDoc.exists) {
        final activePersonaId = settingsDoc.data()?['activePersonaId'] as String?;
        if (activePersonaId == personaId) {
          await _settingsRef(userId).update({'activePersonaId': null});
        }
      }

      await docRef.delete();
    } on PersonaException {
      rethrow;
    } on FirebaseException catch (e) {
      throw PersonaException(
        'Failed to delete persona: ${e.message}',
        e.code,
      );
    } catch (e) {
      throw PersonaException(
        'An unexpected error occurred while deleting persona',
        'unknown',
      );
    }
  }

  @override
  Future<void> setActivePersona(String userId, String personaId) async {
    try {
      final personaDoc = await _personasRef(userId).doc(personaId).get();

      if (!personaDoc.exists) {
        throw PersonaException(
          'Persona not found',
          'persona-not-found',
        );
      }

      await _settingsRef(userId).set({
        'activePersonaId': personaId,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } on PersonaException {
      rethrow;
    } on FirebaseException catch (e) {
      throw PersonaException(
        'Failed to set active persona: ${e.message}',
        e.code,
      );
    } catch (e) {
      throw PersonaException(
        'An unexpected error occurred while setting active persona',
        'unknown',
      );
    }
  }

  @override
  Future<Persona?> getActivePersona(String userId) async {
    try {
      final settingsDoc = await _settingsRef(userId).get();

      if (!settingsDoc.exists) return null;

      final activePersonaId = settingsDoc.data()?['activePersonaId'] as String?;

      if (activePersonaId == null) return null;

      return await getPersona(userId, activePersonaId);
    } on FirebaseException catch (e) {
      throw PersonaException(
        'Failed to fetch active persona: ${e.message}',
        e.code,
      );
    } catch (e) {
      throw PersonaException(
        'An unexpected error occurred while fetching active persona',
        'unknown',
      );
    }
  }

  @override
  Stream<Persona?> watchActivePersona(String userId) {
    return _settingsRef(userId).snapshots().asyncMap((settingsDoc) async {
      if (!settingsDoc.exists) return null;

      final activePersonaId = settingsDoc.data()?['activePersonaId'] as String?;

      if (activePersonaId == null) return null;

      final personaDoc = await _personasRef(userId).doc(activePersonaId).get();

      if (!personaDoc.exists) return null;

      return _mapToPersona(personaDoc.id, personaDoc.data()!);
    }).handleError((error) {
      if (error is FirebaseException) {
        throw PersonaException(
          'Failed to watch active persona: ${error.message}',
          error.code,
        );
      }
      throw PersonaException(
        'An unexpected error occurred while watching active persona',
        'unknown',
      );
    });
  }

  @override
  Future<void> clearActivePersona(String userId) async {
    try {
      await _settingsRef(userId).update({'activePersonaId': null});
    } on FirebaseException catch (e) {
      throw PersonaException(
        'Failed to clear active persona: ${e.message}',
        e.code,
      );
    }
  }

  @override
  Stream<List<Persona>> watchPersonas(String userId) {
    return _personasRef(userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => _mapToPersona(doc.id, doc.data()))
            .toList())
        .handleError((error) {
      if (error is FirebaseException) {
        throw PersonaException(
          'Failed to watch personas: ${error.message}',
          error.code,
        );
      }
      throw PersonaException(
        'An unexpected error occurred while watching personas',
        'unknown',
      );
    });
  }

  /// Maps Firestore document data to a [Persona] object.
  Persona _mapToPersona(String id, Map<String, dynamic> data) {
    final createdAt = _timestampToDateTime(data['createdAt']);
    final updatedAt = _timestampToDateTime(data['updatedAt']);

    return Persona(
      id: id,
      userId: data['userId'] as String?,
      name: data['name'] as String,
      description: data['description'] as String,
      tone: PersonaTone.values.firstWhere(
        (e) => e.name == data['tone'],
        orElse: () => PersonaTone.professional,
      ),
      style: PersonaStyle.values.firstWhere(
        (e) => e.name == data['style'],
        orElse: () => PersonaStyle.detailed,
      ),
      language: data['language'] as String? ?? 'en',
      systemPrompt: data['systemPrompt'] as String,
      isPremium: data['isPremium'] as bool? ?? false,
      isDefault: data['isDefault'] as bool? ?? false,
      isActive: data['isActive'] as bool? ?? false,
      createdAt: createdAt ?? DateTime.now(),
      updatedAt: updatedAt,
    );
  }

  /// Maps a [Persona] object to Firestore document data.
  Map<String, dynamic> _personaToMap(Persona persona, {bool isNew = false}) {
    final map = <String, dynamic>{
      'userId': persona.userId,
      'name': persona.name,
      'description': persona.description,
      'tone': persona.tone.name,
      'style': persona.style.name,
      'language': persona.language,
      'systemPrompt': persona.systemPrompt,
      'isPremium': persona.isPremium,
      'isDefault': persona.isDefault,
      'isActive': persona.isActive,
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (isNew) {
      map['createdAt'] = FieldValue.serverTimestamp();
    }

    return map;
  }

  /// Converts a Firestore Timestamp to DateTime.
  DateTime? _timestampToDateTime(dynamic timestamp) {
    if (timestamp == null) return null;
    if (timestamp is Timestamp) {
      return timestamp.toDate();
    }
    if (timestamp is String) {
      try {
        return DateTime.parse(timestamp);
      } catch (_) {
        return null;
      }
    }
    return null;
  }
}

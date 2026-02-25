import 'package:flutter_test/flutter_test.dart';
import 'package:legalease/shared/models/persona_model.dart';

void main() {
  group('Persona Model', () {
    group('defaultTemplates', () {
      test('provides 5 default personas', () {
        expect(Persona.defaultTemplates.length, equals(5));
      });

      test('contains Corporate Counsel persona', () {
        expect(
          Persona.defaultTemplates.any((p) => p.name == 'Corporate Counsel'),
          isTrue,
        );
      });

      test('contains Friendly Advisor persona', () {
        expect(
          Persona.defaultTemplates.any((p) => p.name == 'Friendly Advisor'),
          isTrue,
        );
      });

      test('contains Assertive Advocate persona', () {
        expect(
          Persona.defaultTemplates.any((p) => p.name == 'Assertive Advocate'),
          isTrue,
        );
      });

      test('contains Technical Analyst persona', () {
        expect(
          Persona.defaultTemplates.any((p) => p.name == 'Technical Analyst'),
          isTrue,
        );
      });

      test('contains Plain English Translator persona', () {
        expect(
          Persona.defaultTemplates.any((p) => p.name == 'Plain English Translator'),
          isTrue,
        );
      });

      test('some default personas are premium', () {
        final premiumCount = Persona.defaultTemplates.where((p) => p.isPremium).length;
        expect(premiumCount, greaterThan(0));
      });

      test('all default personas have isDefault set to true', () {
        expect(
          Persona.defaultTemplates.every((p) => p.isDefault),
          isTrue,
        );
      });
    });

    group('persona properties', () {
      test('creates persona with correct properties', () {
        final persona = Persona(
          id: 'test-1',
          userId: 'user-1',
          name: 'Test Persona',
          description: 'A test description',
          systemPrompt: 'Test system prompt',
          tone: PersonaTone.formal,
          style: PersonaStyle.concise,
          language: 'en',
          isPremium: false,
          isDefault: false,
          createdAt: DateTime(2024, 1, 1),
        );

        expect(persona.id, equals('test-1'));
        expect(persona.userId, equals('user-1'));
        expect(persona.name, equals('Test Persona'));
        expect(persona.description, equals('A test description'));
        expect(persona.systemPrompt, equals('Test system prompt'));
        expect(persona.tone, equals(PersonaTone.formal));
        expect(persona.style, equals(PersonaStyle.concise));
        expect(persona.language, equals('en'));
        expect(persona.isPremium, isFalse);
        expect(persona.isDefault, isFalse);
      });

      test('copyWith creates new instance with updated properties', () {
        final original = Persona(
          id: 'test-1',
          name: 'Original',
          description: 'Original description',
          systemPrompt: 'Original prompt',
          tone: PersonaTone.professional,
          style: PersonaStyle.detailed,
          isPremium: false,
          isDefault: false,
          createdAt: DateTime.now(),
        );

        final updated = original.copyWith(
          name: 'Updated',
          tone: PersonaTone.casual,
        );

        expect(updated.name, equals('Updated'));
        expect(updated.tone, equals(PersonaTone.casual));
        expect(updated.description, equals('Original description'));
        expect(updated.id, equals('test-1'));
      });
    });

    group('PersonaTone', () {
      test('has all expected values', () {
        expect(PersonaTone.values.length, equals(6));
        expect(PersonaTone.values, contains(PersonaTone.formal));
        expect(PersonaTone.values, contains(PersonaTone.casual));
        expect(PersonaTone.values, contains(PersonaTone.professional));
        expect(PersonaTone.values, contains(PersonaTone.friendly));
        expect(PersonaTone.values, contains(PersonaTone.assertive));
        expect(PersonaTone.values, contains(PersonaTone.diplomatic));
      });
    });

    group('PersonaStyle', () {
      test('has all expected values', () {
        expect(PersonaStyle.values.length, equals(4));
        expect(PersonaStyle.values, contains(PersonaStyle.concise));
        expect(PersonaStyle.values, contains(PersonaStyle.detailed));
        expect(PersonaStyle.values, contains(PersonaStyle.technical));
        expect(PersonaStyle.values, contains(PersonaStyle.plainEnglish));
      });
    });
  });
}

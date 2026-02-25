import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:legalease/features/auth/domain/providers/auth_providers.dart';
import 'package:legalease/features/persona/domain/providers/persona_providers.dart';
import 'package:legalease/features/settings/presentation/widgets/persona_form.dart';
import 'package:legalease/shared/models/persona_model.dart';

class PersonaCreateScreen extends ConsumerStatefulWidget {
  final String? personaId;
  final Persona? persona;

  const PersonaCreateScreen({super.key, this.personaId, this.persona});

  @override
  ConsumerState<PersonaCreateScreen> createState() => _PersonaCreateScreenState();
}

class _PersonaCreateScreenState extends ConsumerState<PersonaCreateScreen> {
  bool _isLoading = false;
  Persona? _existingPersona;
  bool _isEditMode = false;

  @override
  void initState() {
    super.initState();
    _isEditMode = widget.personaId != null || widget.persona != null;
    if (widget.persona != null) {
      _existingPersona = widget.persona;
    } else if (_isEditMode) {
      _loadPersona();
    }
  }

  Future<void> _loadPersona() async {
    setState(() => _isLoading = true);

    try {
      final personas = await ref.read(personasProvider.future);
      _existingPersona = personas.firstWhere(
        (p) => p.id == widget.personaId,
        orElse: () => throw Exception('Persona not found'),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading persona: $e')),
        );
        context.pop();
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleSave(PersonaFormData formData) async {
    setState(() => _isLoading = true);

    try {
      final currentUser = ref.read(currentUserProvider);
      if (currentUser == null) {
        throw Exception('You must be logged in to create personas');
      }

      final service = ref.read(personaServiceProvider);
      if (service == null) {
        throw Exception('AI service is not available. Please try again.');
      }

      if (_isEditMode && _existingPersona != null) {
        final updatedPersona = _existingPersona!.copyWith(
          name: formData.name,
          description: formData.description,
          systemPrompt: formData.systemPrompt,
          tone: formData.tone,
          style: formData.style,
          language: formData.language,
          updatedAt: DateTime.now(),
        );
        await service.updateCustomPersona(currentUser.id, updatedPersona);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Persona updated successfully')),
          );
          context.pop(true);
        }
      } else {
        await service.createCustomPersona(
          userId: currentUser.id,
          name: formData.name,
          description: formData.description,
          systemPrompt: formData.systemPrompt,
          tone: formData.tone,
          style: formData.style,
          language: formData.language,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Persona created successfully')),
          );
          context.pop(true);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving persona: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _handleCancel() {
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? 'Edit Persona' : 'Create Persona'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
      ),
      body: _isLoading && _isEditMode && _existingPersona == null
          ? const Center(child: CircularProgressIndicator())
          : _buildForm(),
    );
  }

  Widget _buildForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 24),
          PersonaForm(
            initialPersona: _existingPersona,
            onSave: _handleSave,
            onCancel: _handleCancel,
            isLoading: _isLoading,
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.person_add_outlined,
              color: colorScheme.onPrimaryContainer,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isEditMode ? 'Edit Your Persona' : 'Create New Persona',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _isEditMode
                      ? 'Modify your persona settings and behavior.'
                      : 'Define how your AI assistant should behave and respond.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

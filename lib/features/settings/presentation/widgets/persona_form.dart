import 'package:flutter/material.dart';
import 'package:legalease/shared/models/persona_model.dart';

class PersonaForm extends StatefulWidget {
  final Persona? initialPersona;
  final void Function(PersonaFormData) onSave;
  final VoidCallback? onCancel;
  final bool isLoading;

  const PersonaForm({
    super.key,
    this.initialPersona,
    required this.onSave,
    this.onCancel,
    this.isLoading = false,
  });

  @override
  State<PersonaForm> createState() => _PersonaFormState();
}

class _PersonaFormState extends State<PersonaForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _systemPromptController;
  PersonaTone _selectedTone = PersonaTone.professional;
  PersonaStyle _selectedStyle = PersonaStyle.detailed;
  String _selectedLanguage = 'en';

  final List<String> _availableLanguages = [
    'en',
    'es',
    'fr',
    'de',
    'it',
    'pt',
    'zh',
    'ja',
    'ko',
    'ar',
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialPersona?.name ?? '');
    _descriptionController = TextEditingController(text: widget.initialPersona?.description ?? '');
    _systemPromptController = TextEditingController(text: widget.initialPersona?.systemPrompt ?? '');
    _selectedTone = widget.initialPersona?.tone ?? PersonaTone.professional;
    _selectedStyle = widget.initialPersona?.style ?? PersonaStyle.detailed;
    _selectedLanguage = widget.initialPersona?.language ?? 'en';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _systemPromptController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (_formKey.currentState?.validate() ?? false) {
      final formData = PersonaFormData(
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        systemPrompt: _systemPromptController.text.trim(),
        tone: _selectedTone,
        style: _selectedStyle,
        language: _selectedLanguage,
      );
      widget.onSave(formData);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildNameField(),
          const SizedBox(height: 16),
          _buildDescriptionField(),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildToneDropdown()),
              const SizedBox(width: 12),
              Expanded(child: _buildStyleDropdown()),
            ],
          ),
          const SizedBox(height: 16),
          _buildLanguageDropdown(),
          const SizedBox(height: 16),
          _buildSystemPromptField(),
          const SizedBox(height: 24),
          _buildPreviewSection(context),
          const SizedBox(height: 24),
          _buildActions(colorScheme),
        ],
      ),
    );
  }

  Widget _buildNameField() {
    return TextFormField(
      controller: _nameController,
      decoration: const InputDecoration(
        labelText: 'Persona Name',
        hintText: 'e.g., Contract Specialist',
        prefixIcon: Icon(Icons.label_outline),
      ),
      textCapitalization: TextCapitalization.words,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please enter a name';
        }
        if (value.trim().length < 3) {
          return 'Name must be at least 3 characters';
        }
        return null;
      },
    );
  }

  Widget _buildDescriptionField() {
    return TextFormField(
      controller: _descriptionController,
      decoration: const InputDecoration(
        labelText: 'Description',
        hintText: 'Brief description of this persona',
        prefixIcon: Icon(Icons.description_outlined),
      ),
      maxLines: 2,
      textCapitalization: TextCapitalization.sentences,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please enter a description';
        }
        return null;
      },
    );
  }

  Widget _buildToneDropdown() {
    return DropdownButtonFormField<PersonaTone>(
      initialValue: _selectedTone,
      decoration: const InputDecoration(
        labelText: 'Tone',
        prefixIcon: Icon(Icons.record_voice_over_outlined),
      ),
      items: PersonaTone.values.map((tone) {
        return DropdownMenuItem(
          value: tone,
          child: Text(_toneLabel(tone)),
        );
      }).toList(),
      onChanged: (value) {
        if (value != null) {
          setState(() => _selectedTone = value);
        }
      },
    );
  }

  Widget _buildStyleDropdown() {
    return DropdownButtonFormField<PersonaStyle>(
      initialValue: _selectedStyle,
      decoration: const InputDecoration(
        labelText: 'Style',
        prefixIcon: Icon(Icons.style_outlined),
      ),
      items: PersonaStyle.values.map((style) {
        return DropdownMenuItem(
          value: style,
          child: Text(_styleLabel(style)),
        );
      }).toList(),
      onChanged: (value) {
        if (value != null) {
          setState(() => _selectedStyle = value);
        }
      },
    );
  }

  Widget _buildLanguageDropdown() {
    return DropdownButtonFormField<String>(
      initialValue: _selectedLanguage,
      decoration: const InputDecoration(
        labelText: 'Language',
        prefixIcon: Icon(Icons.language_outlined),
      ),
      items: _availableLanguages.map((lang) {
        return DropdownMenuItem(
          value: lang,
          child: Text(_languageLabel(lang)),
        );
      }).toList(),
      onChanged: (value) {
        if (value != null) {
          setState(() => _selectedLanguage = value);
        }
      },
    );
  }

  Widget _buildSystemPromptField() {
    return TextFormField(
      controller: _systemPromptController,
      decoration: const InputDecoration(
        labelText: 'System Prompt',
        hintText: 'Define how this persona should behave',
        prefixIcon: Icon(Icons.psychology_outlined),
        alignLabelWithHint: true,
      ),
      maxLines: 4,
      textCapitalization: TextCapitalization.sentences,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please enter a system prompt';
        }
        return null;
      },
    );
  }

  Widget _buildPreviewSection(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.preview_outlined,
                size: 18,
                color: colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'Prompt Preview',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _buildPreviewPrompt(),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
            maxLines: 6,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  String _buildPreviewPrompt() {
    final name = _nameController.text.isEmpty ? 'Persona' : _nameController.text;
    final description = _descriptionController.text.isEmpty
        ? 'A legal assistant'
        : _descriptionController.text;
    final systemPrompt = _systemPromptController.text.isEmpty
        ? 'Provide helpful legal guidance.'
        : _systemPromptController.text;

    return '''You are $name.

Description: $description

Communication Tone: ${_toneDescription(_selectedTone)}
Response Style: ${_styleDescription(_selectedStyle)}

Core Instructions:
$systemPrompt''';
  }

  Widget _buildActions(ColorScheme colorScheme) {
    return Row(
      children: [
        if (widget.onCancel != null) ...[
          Expanded(
            child: OutlinedButton(
              onPressed: widget.isLoading ? null : widget.onCancel,
              child: const Text('Cancel'),
            ),
          ),
          const SizedBox(width: 12),
        ],
        Expanded(
          flex: 2,
          child: FilledButton(
            onPressed: widget.isLoading ? null : _handleSubmit,
            child: widget.isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(widget.initialPersona == null ? 'Create Persona' : 'Save Changes'),
          ),
        ),
      ],
    );
  }

  String _toneLabel(PersonaTone tone) {
    switch (tone) {
      case PersonaTone.formal:
        return 'Formal';
      case PersonaTone.casual:
        return 'Casual';
      case PersonaTone.professional:
        return 'Professional';
      case PersonaTone.friendly:
        return 'Friendly';
      case PersonaTone.assertive:
        return 'Assertive';
      case PersonaTone.diplomatic:
        return 'Diplomatic';
    }
  }

  String _styleLabel(PersonaStyle style) {
    switch (style) {
      case PersonaStyle.concise:
        return 'Concise';
      case PersonaStyle.detailed:
        return 'Detailed';
      case PersonaStyle.technical:
        return 'Technical';
      case PersonaStyle.plainEnglish:
        return 'Plain English';
    }
  }

  String _languageLabel(String code) {
    const languages = {
      'en': 'English',
      'es': 'Spanish',
      'fr': 'French',
      'de': 'German',
      'it': 'Italian',
      'pt': 'Portuguese',
      'zh': 'Chinese',
      'ja': 'Japanese',
      'ko': 'Korean',
      'ar': 'Arabic',
    };
    return languages[code] ?? code.toUpperCase();
  }

  String _toneDescription(PersonaTone tone) {
    switch (tone) {
      case PersonaTone.formal:
        return 'Professional and structured communication';
      case PersonaTone.casual:
        return 'Relaxed and conversational communication';
      case PersonaTone.professional:
        return 'Business-appropriate communication';
      case PersonaTone.friendly:
        return 'Warm and approachable communication';
      case PersonaTone.assertive:
        return 'Direct and confident communication';
      case PersonaTone.diplomatic:
        return 'Tactful and balanced communication';
    }
  }

  String _styleDescription(PersonaStyle style) {
    switch (style) {
      case PersonaStyle.concise:
        return 'Brief and to-the-point responses';
      case PersonaStyle.detailed:
        return 'Comprehensive and thorough responses';
      case PersonaStyle.technical:
        return 'Precise and specialized terminology';
      case PersonaStyle.plainEnglish:
        return 'Simple and accessible language';
    }
  }
}

class PersonaFormData {
  final String name;
  final String description;
  final String systemPrompt;
  final PersonaTone tone;
  final PersonaStyle style;
  final String language;

  const PersonaFormData({
    required this.name,
    required this.description,
    required this.systemPrompt,
    required this.tone,
    required this.style,
    required this.language,
  });
}

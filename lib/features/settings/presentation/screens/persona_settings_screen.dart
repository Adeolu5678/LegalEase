import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:legalease/features/settings/domain/providers/settings_providers.dart';
import 'package:legalease/features/settings/presentation/widgets/persona_card.dart';
import 'package:legalease/shared/models/persona_model.dart';

class PersonaSettingsScreen extends ConsumerStatefulWidget {
  const PersonaSettingsScreen({super.key});

  @override
  ConsumerState<PersonaSettingsScreen> createState() => _PersonaSettingsScreenState();
}

class _PersonaSettingsScreenState extends ConsumerState<PersonaSettingsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(settingsScreenViewModelProvider.notifier).refresh();
    });
  }

  void _handlePersonaTap(Persona persona) {
    final state = ref.read(settingsScreenViewModelProvider);
    if (persona.isPremium && !state.isPremiumUser) {
      _showPremiumDialog();
      return;
    }

    ref.read(settingsScreenViewModelProvider.notifier).setActivePersona(persona);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${persona.name} activated'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _handleEditPersona(Persona persona) {
    context.push('/settings/personas/edit/${persona.id}');
  }

  void _handleDeletePersona(Persona persona) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Persona'),
        content: Text('Are you sure you want to delete "${persona.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              _deletePersona(persona);
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _deletePersona(Persona persona) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${persona.name} deleted'),
        behavior: SnackBarBehavior.floating,
      ),
    );
    ref.read(settingsScreenViewModelProvider.notifier).refresh();
  }

  void _showPremiumDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.workspace_premium),
        title: const Text('Premium Required'),
        content: const Text(
          'This persona is available for premium subscribers only. '
          'Upgrade to access all premium personas.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Maybe Later'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              context.push('/subscription');
            },
            child: const Text('Upgrade Now'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final defaultPersonas = ref.watch(settingsScreenViewModelProvider.select((s) => s.defaultPersonas));
    final customPersonas = ref.watch(settingsScreenViewModelProvider.select((s) => s.customPersonas));
    final activePersona = ref.watch(settingsScreenViewModelProvider.select((s) => s.activePersona));
    final isPremiumUser = ref.watch(settingsScreenViewModelProvider.select((s) => s.isPremiumUser));
    final status = ref.watch(settingsScreenViewModelProvider.select((s) => s.status));
    final personas = ref.watch(settingsScreenViewModelProvider.select((s) => s.personas));
    final errorMessage = ref.watch(settingsScreenViewModelProvider.select((s) => s.errorMessage));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Personas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showInfoDialog(),
            tooltip: 'About Personas',
          ),
        ],
      ),
      body: _buildBody(status, personas, errorMessage, defaultPersonas, customPersonas, activePersona, isPremiumUser),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/settings/personas/create'),
        icon: const Icon(Icons.add),
        label: const Text('New Persona'),
      ),
    );
  }

  Widget _buildBody(
    SettingsScreenStatus status, 
    List<dynamic> personas, 
    String? errorMessage,
    List<dynamic> defaultPersonas,
    List<dynamic> customPersonas,
    dynamic activePersona,
    bool isPremiumUser,
  ) {
    switch (status) {
      case SettingsScreenStatus.loading:
        return const Center(child: CircularProgressIndicator());
      case SettingsScreenStatus.error:
        return _buildErrorState(errorMessage ?? 'An error occurred');
      case SettingsScreenStatus.loaded:
      case SettingsScreenStatus.initial:
        if (personas.isEmpty) {
          return _buildEmptyState();
        }
        return _buildPersonaList(defaultPersonas, customPersonas, activePersona, isPremiumUser);
    }
  }

  Widget _buildPersonaList(
    List<dynamic> defaultPersonas,
    List<dynamic> customPersonas,
    dynamic activePersona,
    bool isPremiumUser,
  ) {
    return ListView(
      padding: const EdgeInsets.only(bottom: 80),
      children: [
        if (defaultPersonas.isNotEmpty) ...[
          _buildSectionHeader('Default Personas', Icons.folder_outlined),
          ...defaultPersonas.map((persona) => PersonaCard(
            persona: persona,
            isActive: activePersona?.id == persona.id,
            isPremiumUser: isPremiumUser,
            onTap: () => _handlePersonaTap(persona),
          )),
        ],
        if (customPersonas.isNotEmpty) ...[
          _buildSectionHeader('Custom Personas', Icons.person_outline),
          ...customPersonas.map((persona) => PersonaCard(
            persona: persona,
            isActive: activePersona?.id == persona.id,
            isPremiumUser: isPremiumUser,
            onTap: () => _handlePersonaTap(persona),
            onEdit: () => _handleEditPersona(persona),
            onDelete: () => _handleDeletePersona(persona),
          )),
        ],
        _buildPremiumBanner(isPremiumUser),
      ],
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 8),
          Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.person_outline,
                size: 40,
                color: colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No Personas Available',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            Text(
              'Create your first custom persona to personalize your AI assistant.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String message) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Something went wrong',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () {
                ref.read(settingsScreenViewModelProvider.notifier).refresh();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPremiumBanner(bool isPremiumUser) {
    if (isPremiumUser) return const SizedBox.shrink();

    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorScheme.tertiaryContainer,
            colorScheme.tertiaryContainer.withValues(alpha: 0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: colorScheme.onTertiaryContainer.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.workspace_premium_outlined,
              color: colorScheme.onTertiaryContainer,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Unlock Premium Personas',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onTertiaryContainer,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Get access to advanced personas and create unlimited custom personas.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.onTertiaryContainer.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          FilledButton(
            onPressed: () => context.push('/subscription'),
            style: FilledButton.styleFrom(
              backgroundColor: colorScheme.onTertiaryContainer,
              foregroundColor: colorScheme.tertiaryContainer,
            ),
            child: const Text('Upgrade'),
          ),
        ],
      ),
    );
  }

  void _showInfoDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About Personas'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Personas customize how the AI assistant responds to your queries.',
            ),
            SizedBox(height: 16),
            _InfoItem(
              icon: Icons.check_circle_outline,
              text: 'Tap a persona to make it active',
            ),
            _InfoItem(
              icon: Icons.workspace_premium_outlined,
              text: 'PRO badges indicate premium personas',
            ),
            _InfoItem(
              icon: Icons.add_circle_outline,
              text: 'Create custom personas for your needs',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoItem({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}

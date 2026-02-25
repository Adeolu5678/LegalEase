import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:legalease/core/theme/app_colors.dart';
import 'package:legalease/core/theme/app_spacing.dart';
import 'package:legalease/features/templates/data/models/legal_template.dart';
import 'package:legalease/features/templates/domain/providers/template_providers.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class TemplatePreviewScreen extends ConsumerStatefulWidget {
  final LegalTemplate template;

  const TemplatePreviewScreen({super.key, required this.template});

  @override
  ConsumerState<TemplatePreviewScreen> createState() => _TemplatePreviewScreenState();
}

class _TemplatePreviewScreenState extends ConsumerState<TemplatePreviewScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();
  final Map<String, TextEditingController> _controllers = {};
  bool _showPreview = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    
    for (final field in widget.template.fields) {
      _controllers[field.id] = TextEditingController(text: field.defaultValue ?? '');
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.template.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _shareTemplate,
          ),
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: _exportTemplate,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Fill Template'),
            Tab(text: 'Preview'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildForm(context),
          _buildPreview(context),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _tabController.animateTo(1);
          setState(() => _showPreview = true);
        },
        icon: const Icon(Icons.visibility),
        label: const Text('Preview'),
      ),
    );
  }

  Widget _buildForm(BuildContext context) {
    return Form(
      key: _formKey,
      child: ListView.builder(
        padding: const EdgeInsets.all(AppSpacing.md),
        itemCount: widget.template.fields.length + 1,
        itemBuilder: (context, index) {
          if (index == widget.template.fields.length) {
            return Padding(
              padding: const EdgeInsets.only(top: AppSpacing.lg),
              child: FilledButton.icon(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _tabController.animateTo(1);
                    setState(() => _showPreview = true);
                  }
                },
                icon: const Icon(Icons.preview),
                label: const Text('Generate Preview'),
              ),
            );
          }

          final field = widget.template.fields[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: _buildFormField(context, field),
          );
        },
      ),
    );
  }

  Widget _buildFormField(BuildContext context, TemplateFieldDefinition field) {
    final controller = _controllers[field.id]!;

    switch (field.type) {
      case TemplateField.multilineText:
        return TextFormField(
          controller: controller,
          decoration: InputDecoration(
            labelText: field.label,
            hintText: field.placeholder,
            border: const OutlineInputBorder(),
            alignLabelWithHint: true,
          ),
          maxLines: 4,
          validator: field.required
              ? (value) => value?.isEmpty ?? true ? 'Required' : null
              : null,
        );

      case TemplateField.date:
        return TextFormField(
          controller: controller,
          decoration: InputDecoration(
            labelText: field.label,
            border: const OutlineInputBorder(),
            suffixIcon: const Icon(Icons.calendar_today),
          ),
          readOnly: true,
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
            );
            if (date != null) {
              controller.text = '${date.month}/${date.day}/${date.year}';
            }
          },
          validator: field.required
              ? (value) => value?.isEmpty ?? true ? 'Required' : null
              : null,
        );

      case TemplateField.number:
        return TextFormField(
          controller: controller,
          decoration: InputDecoration(
            labelText: field.label,
            hintText: field.placeholder,
            border: const OutlineInputBorder(),
          ),
          keyboardType: TextInputType.number,
          validator: field.required
              ? (value) => value?.isEmpty ?? true ? 'Required' : null
              : null,
        );

      case TemplateField.email:
        return TextFormField(
          controller: controller,
          decoration: InputDecoration(
            labelText: field.label,
            hintText: field.placeholder,
            border: const OutlineInputBorder(),
          ),
          keyboardType: TextInputType.emailAddress,
          validator: (value) {
            if (field.required && (value?.isEmpty ?? true)) return 'Required';
            if (value != null && value.isNotEmpty) {
              final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
              if (!emailRegex.hasMatch(value)) return 'Invalid email';
            }
            return null;
          },
        );

      case TemplateField.phone:
        return TextFormField(
          controller: controller,
          decoration: InputDecoration(
            labelText: field.label,
            hintText: field.placeholder,
            border: const OutlineInputBorder(),
          ),
          keyboardType: TextInputType.phone,
          validator: field.required
              ? (value) => value?.isEmpty ?? true ? 'Required' : null
              : null,
        );

      case TemplateField.currency:
        return TextFormField(
          controller: controller,
          decoration: InputDecoration(
            labelText: field.label,
            hintText: '\$0.00',
            border: const OutlineInputBorder(),
            prefixText: '\$',
          ),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          validator: field.required
              ? (value) => value?.isEmpty ?? true ? 'Required' : null
              : null,
        );

      case TemplateField.selection:
        return DropdownButtonFormField<String>(
          value: controller.text.isNotEmpty ? controller.text : null,
          decoration: InputDecoration(
            labelText: field.label,
            border: const OutlineInputBorder(),
          ),
          items: (field.options ?? []).map((option) {
            return DropdownMenuItem(
              value: option,
              child: Text(option),
            );
          }).toList(),
          onChanged: (value) {
            controller.text = value ?? '';
          },
          validator: field.required
              ? (value) => value == null ? 'Required' : null
              : null,
        );

      case TemplateField.text:
      case TemplateField.address:
        return TextFormField(
          controller: controller,
          decoration: InputDecoration(
            labelText: field.label,
            hintText: field.placeholder,
            border: const OutlineInputBorder(),
          ),
          maxLines: field.type == TemplateField.address ? 2 : 1,
          validator: field.required
              ? (value) => value?.isEmpty ?? true ? 'Required' : null
              : null,
        );

      case TemplateField.percentage:
        return TextFormField(
          controller: controller,
          decoration: InputDecoration(
            labelText: field.label,
            hintText: '0%',
            border: const OutlineInputBorder(),
            suffixText: '%',
          ),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          validator: field.required
              ? (value) => value?.isEmpty ?? true ? 'Required' : null
              : null,
        );
    }
  }

  Widget _buildPreview(BuildContext context) {
    final values = <String, dynamic>{};
    for (final entry in _controllers.entries) {
      values[entry.key] = entry.value.text;
    }

    final filledContent = widget.template.fillTemplate(values);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, size: 20, color: AppColors.info),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    'This is a preview of the document with your filled values.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          SelectableText(
            filledContent,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontFamily: 'monospace',
                  height: 1.6,
                ),
          ),
        ],
      ),
    );
  }

  Future<void> _shareTemplate() async {
    final values = <String, dynamic>{};
    for (final entry in _controllers.entries) {
      values[entry.key] = entry.value.text;
    }
    final filledContent = widget.template.fillTemplate(values);

    await Clipboard.setData(ClipboardData(text: filledContent));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Content copied to clipboard')),
      );
    }
  }

  Future<void> _exportTemplate() async {
    final values = <String, dynamic>{};
    for (final entry in _controllers.entries) {
      values[entry.key] = entry.value.text;
    }
    final filledContent = widget.template.fillTemplate(values);

    final pdf = pw.Document();
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          pw.Header(
            level: 0,
            text: widget.template.name,
            textStyle: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 20),
          pw.Text(filledContent, style: const pw.TextStyle(fontSize: 11, lineSpacing: 1.5)),
        ],
      ),
    );

    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
  }
}

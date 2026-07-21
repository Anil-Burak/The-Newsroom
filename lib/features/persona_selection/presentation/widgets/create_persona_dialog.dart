import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../domain/persona.dart';
import '../../../../core/theme/app_theme.dart';

class CreatePersonaDialog extends StatefulWidget {
  const CreatePersonaDialog({super.key});

  @override
  State<CreatePersonaDialog> createState() => _CreatePersonaDialogState();
}

class _CreatePersonaDialogState extends State<CreatePersonaDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _biasController = TextEditingController();
  final _ethicsController = TextEditingController();
  double _clickbaitThreshold = 50;
  String _selectedEmoji = '🗞️';

  static const _emojiOptions = ['🗞️', '📰', '📺', '📻', '🎙️', '🖥️', '📡', '✏️'];

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _biasController.dispose();
    _ethicsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.inkSurface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                children: [
                  Text('Create Persona',
                      style: Theme.of(context).textTheme.displaySmall),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, color: AppColors.textMuted),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Emoji picker
              Text('Icon', style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: _emojiOptions.map((e) {
                  final selected = e == _selectedEmoji;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedEmoji = e),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: selected
                            ? AppColors.gold.withOpacity(0.2)
                            : AppColors.glassSurface,
                        border: Border.all(
                          color: selected
                              ? AppColors.gold
                              : AppColors.glassBorder,
                        ),
                      ),
                      child:
                          Center(child: Text(e, style: const TextStyle(fontSize: 22))),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),

              _buildField(_nameController, 'Persona Name', 'e.g. Activist Blog'),
              const SizedBox(height: 12),
              _buildField(_descController, 'Description',
                  'What drives this editor?', maxLines: 2),
              const SizedBox(height: 12),
              _buildField(_biasController, 'Bias Description',
                  'e.g. Left-leaning, pro-environment'),
              const SizedBox(height: 12),
              _buildField(_ethicsController, 'Ethical Standards',
                  'e.g. High – fact-checks everything'),
              const SizedBox(height: 20),

              // Clickbait slider
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Clickbait Threshold',
                      style: Theme.of(context).textTheme.bodySmall),
                  Text('${_clickbaitThreshold.round()}%',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: AppColors.gold,
                          )),
                ],
              ),
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: AppColors.gold,
                  inactiveTrackColor: AppColors.glassSurface,
                  thumbColor: AppColors.gold,
                  overlayColor: AppColors.gold.withOpacity(0.2),
                ),
                child: Slider(
                  value: _clickbaitThreshold,
                  min: 0,
                  max: 100,
                  divisions: 20,
                  onChanged: (v) => setState(() => _clickbaitThreshold = v),
                ),
              ),
              const SizedBox(height: 24),

              // Save button
              ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 52)),
                child: const Text('SAVE PERSONA'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(
    TextEditingController controller,
    String label,
    String hint, {
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      style: Theme.of(context)
          .textTheme
          .bodyMedium
          ?.copyWith(color: AppColors.textPrimary),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: TextStyle(color: AppColors.textMuted),
        hintStyle: TextStyle(color: AppColors.textMuted.withOpacity(0.6)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.glassBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.gold),
        ),
        filled: true,
        fillColor: AppColors.glassSurface,
      ),
      validator: (v) =>
          (v == null || v.trim().isEmpty) ? 'This field is required' : null,
    );
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final newPersona = Persona(
        id: 'persona_custom_${const Uuid().v4()}',
        name: _nameController.text.trim(),
        description: _descController.text.trim(),
        iconEmoji: _selectedEmoji,
        isDefault: false,
        aiConfig: PersonaAiConfig(
          bias: _biasController.text.trim(),
          ethics: _ethicsController.text.trim(),
          clickbaitThreshold: _clickbaitThreshold.round(),
        ),
      );
      Navigator.pop(context, newPersona);
    }
  }
}

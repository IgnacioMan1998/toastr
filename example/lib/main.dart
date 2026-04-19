import 'package:flutter/material.dart';
import 'package:toastr_flutter/toastr.dart';

void main() {
  runApp(const ToastrExampleApp());
}

class ToastrExampleApp extends StatelessWidget {
  const ToastrExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Toastr Example',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: const Color(0xFF6366F1),
        useMaterial3: true,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        colorSchemeSeed: const Color(0xFF6366F1),
        useMaterial3: true,
        brightness: Brightness.dark,
      ),
      home: const ToastrDemoScreen(),
    );
  }
}

class ToastrDemoScreen extends StatefulWidget {
  const ToastrDemoScreen({super.key});

  @override
  State<ToastrDemoScreen> createState() => _ToastrDemoScreenState();
}

class _ToastrDemoScreenState extends State<ToastrDemoScreen> {
  final _titleController = TextEditingController();
  final _messageController = TextEditingController(text: 'This is a sample notification message');

  ToastrType _selectedType = ToastrType.success;
  ToastrPosition _selectedPosition = ToastrPosition.topRight;
  ToastrShowMethod _selectedShowMethod = ToastrShowMethod.fadeIn;
  ToastrHideMethod _selectedHideMethod = ToastrHideMethod.fadeOut;

  int _showDuration = 300;
  int _hideDuration = 1000;
  int _timeout = 5000;

  bool _showProgressBar = false;
  bool _showCloseButton = false;
  bool _preventDuplicates = false;

  void _showToast() {
    final config = ToastrConfig(
      type: _selectedType,
      message: _messageController.text.isNotEmpty
          ? _messageController.text
          : 'Sample message',
      title: _titleController.text.isNotEmpty ? _titleController.text : null,
      position: _selectedPosition,
      showMethod: _selectedShowMethod,
      hideMethod: _selectedHideMethod,
      showDuration: Duration(milliseconds: _showDuration),
      hideDuration: Duration(milliseconds: _hideDuration),
      duration: _timeout > 0
          ? Duration(milliseconds: _timeout)
          : const Duration(milliseconds: 100),
      showProgressBar: _showProgressBar,
      showCloseButton: _showCloseButton,
      preventDuplicates: _preventDuplicates,
    );

    ToastrHelper.custom(config);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          // App bar
          SliverAppBar.large(
            title: const Text('Toastr Demo'),
            centerTitle: false,
            actions: [
              IconButton(
                onPressed: ToastrHelper.clearAll,
                icon: const Icon(Icons.clear_all_rounded),
                tooltip: 'Clear all toasts',
              ),
              const SizedBox(width: 8),
            ],
          ),

          // Quick actions
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Quick Actions',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      _QuickActionChip(
                        label: 'Success',
                        icon: Icons.check_circle_rounded,
                        color: const Color(0xFF16A34A),
                        onTap: () => ToastrHelper.success(
                          'Operation completed successfully!',
                          title: 'Success',
                          showProgressBar: true,
                        ),
                      ),
                      _QuickActionChip(
                        label: 'Error',
                        icon: Icons.cancel_rounded,
                        color: const Color(0xFFDC2626),
                        onTap: () => ToastrHelper.error(
                          'Something went wrong. Please try again.',
                          title: 'Error',
                        ),
                      ),
                      _QuickActionChip(
                        label: 'Warning',
                        icon: Icons.warning_rounded,
                        color: const Color(0xFFD97706),
                        onTap: () => ToastrHelper.warning(
                          'Please check your input before continuing.',
                          title: 'Warning',
                        ),
                      ),
                      _QuickActionChip(
                        label: 'Info',
                        icon: Icons.info_rounded,
                        color: const Color(0xFF2563EB),
                        onTap: () => ToastrHelper.info(
                          'Here is some useful information for you.',
                          title: 'Info',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Configuration section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Configuration',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Message card
                  _ConfigCard(
                    title: 'Content',
                    icon: Icons.text_fields_rounded,
                    children: [
                      TextField(
                        controller: _titleController,
                        decoration: const InputDecoration(
                          labelText: 'Title (optional)',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _messageController,
                        decoration: const InputDecoration(
                          labelText: 'Message',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                        maxLines: 2,
                      ),
                      const SizedBox(height: 12),
                      _SegmentedSelector<ToastrType>(
                        label: 'Type',
                        value: _selectedType,
                        items: ToastrType.values,
                        labelBuilder: (t) => t.name,
                        onChanged: (v) => setState(() => _selectedType = v),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Position & Animation card
                  _ConfigCard(
                    title: 'Position & Animation',
                    icon: Icons.swap_vert_rounded,
                    children: [
                      _DropdownField<ToastrPosition>(
                        label: 'Position',
                        value: _selectedPosition,
                        items: ToastrPosition.values,
                        onChanged: (v) =>
                            setState(() => _selectedPosition = v!),
                      ),
                      const SizedBox(height: 8),
                      _DropdownField<ToastrShowMethod>(
                        label: 'Show animation',
                        value: _selectedShowMethod,
                        items: ToastrShowMethod.values,
                        onChanged: (v) =>
                            setState(() => _selectedShowMethod = v!),
                      ),
                      const SizedBox(height: 8),
                      _DropdownField<ToastrHideMethod>(
                        label: 'Hide animation',
                        value: _selectedHideMethod,
                        items: ToastrHideMethod.values,
                        onChanged: (v) =>
                            setState(() => _selectedHideMethod = v!),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Timing card
                  _ConfigCard(
                    title: 'Timing',
                    icon: Icons.timer_rounded,
                    children: [
                      _SliderField(
                        label: 'Duration',
                        value: _timeout,
                        min: 100,
                        max: 10000,
                        suffix: 'ms',
                        onChanged: (v) =>
                            setState(() => _timeout = v.round()),
                      ),
                      _SliderField(
                        label: 'Show speed',
                        value: _showDuration,
                        min: 100,
                        max: 2000,
                        suffix: 'ms',
                        onChanged: (v) =>
                            setState(() => _showDuration = v.round()),
                      ),
                      _SliderField(
                        label: 'Hide speed',
                        value: _hideDuration,
                        min: 100,
                        max: 2000,
                        suffix: 'ms',
                        onChanged: (v) =>
                            setState(() => _hideDuration = v.round()),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Options card
                  _ConfigCard(
                    title: 'Options',
                    icon: Icons.tune_rounded,
                    children: [
                      SwitchListTile(
                        title: const Text('Progress bar'),
                        value: _showProgressBar,
                        onChanged: (v) =>
                            setState(() => _showProgressBar = v),
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                      SwitchListTile(
                        title: const Text('Close button'),
                        value: _showCloseButton,
                        onChanged: (v) =>
                            setState(() => _showCloseButton = v),
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                      SwitchListTile(
                        title: const Text('Prevent duplicates'),
                        value: _preventDuplicates,
                        onChanged: (v) =>
                            setState(() => _preventDuplicates = v),
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),

      // Show toast FAB
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showToast,
        icon: const Icon(Icons.notifications_active_rounded),
        label: const Text('Show Toast'),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _messageController.dispose();
    super.dispose();
  }
}

// --- Reusable UI components ---

class _QuickActionChip extends StatelessWidget {
  const _QuickActionChip({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ConfigCard extends StatelessWidget {
  const _ConfigCard({
    required this.title,
    required this.icon,
    required this.children,
  });

  final String title;
  final IconData icon;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 20, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _SegmentedSelector<T> extends StatelessWidget {
  const _SegmentedSelector({
    required this.label,
    required this.value,
    required this.items,
    required this.labelBuilder,
    required this.onChanged,
  });

  final String label;
  final T value;
  final List<T> items;
  final String Function(T) labelBuilder;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 6),
        SegmentedButton<T>(
          segments: items
              .map((e) => ButtonSegment(value: e, label: Text(labelBuilder(e))))
              .toList(),
          selected: {value},
          onSelectionChanged: (s) => onChanged(s.first),
          showSelectedIcon: false,
          style: ButtonStyle(
            visualDensity: VisualDensity.compact,
            textStyle: WidgetStatePropertyAll(
              Theme.of(context).textTheme.labelSmall,
            ),
          ),
        ),
      ],
    );
  }
}

class _DropdownField<T extends Enum> extends StatelessWidget {
  const _DropdownField({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final String label;
  final T value;
  final List<T> items;
  final ValueChanged<T?> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      initialValue: value,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        isDense: true,
      ),
      items: items
          .map((e) => DropdownMenuItem(
                value: e,
                child: Text(e.name, style: const TextStyle(fontSize: 14)),
              ))
          .toList(),
      onChanged: onChanged,
    );
  }
}

class _SliderField extends StatelessWidget {
  const _SliderField({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.suffix,
    required this.onChanged,
  });

  final String label;
  final int value;
  final int min;
  final int max;
  final String suffix;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 90,
          child: Text(label, style: Theme.of(context).textTheme.bodyMedium),
        ),
        Expanded(
          child: Slider(
            value: value.toDouble(),
            min: min.toDouble(),
            max: max.toDouble(),
            divisions: (max - min) ~/ 100,
            onChanged: onChanged,
          ),
        ),
        SizedBox(
          width: 64,
          child: Text(
            '$value $suffix',
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }
}

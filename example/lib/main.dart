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
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
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
  // Form controllers
  final _titleController = TextEditingController();
  final _messageController = TextEditingController(text: 'Sample message');
  
  // Configuration options
  ToastrType _selectedType = ToastrType.success;
  ToastrPosition _selectedPosition = ToastrPosition.topRight;
  ToastrShowMethod _selectedShowMethod = ToastrShowMethod.fadeIn;
  ToastrHideMethod _selectedHideMethod = ToastrHideMethod.fadeOut;
  Curve _selectedShowEasing = Curves.easeOut;
  Curve _selectedHideEasing = Curves.easeIn;
  
  int _showDuration = 300;
  int _hideDuration = 1000;
  int _timeout = 5000;
  int _extendedTimeout = 1000;
  
  bool _showProgressBar = false;
  bool _showCloseButton = false;
  bool _preventDuplicates = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Initialize the toastr service with the overlay state
    ToastrService.instance.initialize(Overlay.of(context));
  }

  void _showToast() {
    final config = ToastrConfig(
      type: _selectedType,
      message: _messageController.text.isNotEmpty ? _messageController.text : 'Sample message',
      title: _titleController.text.isNotEmpty ? _titleController.text : null,
      position: _selectedPosition,
      showMethod: _selectedShowMethod,
      hideMethod: _selectedHideMethod,
      showEasing: _selectedShowEasing,
      hideEasing: _selectedHideEasing,
      showDuration: Duration(milliseconds: _showDuration),
      hideDuration: Duration(milliseconds: _hideDuration),
      duration: _timeout > 0 ? Duration(milliseconds: _timeout) : Duration.zero,
      extendedTimeout: Duration(milliseconds: _extendedTimeout),
      showProgressBar: _showProgressBar,
      showCloseButton: _showCloseButton,
      preventDuplicates: _preventDuplicates,
    );

    ToastrHelper.custom(config);
  }

  Widget _buildFormField(String label, Widget child) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(child: child),
        ],
      ),
    );

  Widget _buildTextField(String label, TextEditingController controller) => _buildFormField(
      label,
      TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: label,
          border: const OutlineInputBorder(),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
      ),
    );

  Widget _buildDropdown<T>(String label, T value, List<T> items, void Function(T?) onChanged) => _buildFormField(
      label,
      DropdownButton<T>(
        value: value,
        isExpanded: true,
        items: items.map((T item) => DropdownMenuItem<T>(
            value: item,
            child: Text(item.toString().split('.').last),
          )).toList(),
        onChanged: onChanged,
      ),
    );

  Widget _buildSlider(String label, int value, int min, int max, void Function(double) onChanged) => _buildFormField(
      label,
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$value ms'),
          Slider(
            value: value.toDouble(),
            min: min.toDouble(),
            max: max.toDouble(),
            divisions: (max - min) ~/ 100,
            onChanged: onChanged,
          ),
        ],
      ),
    );

  Widget _buildSwitch(String label, bool value, void Function(bool) onChanged) => _buildFormField(
      label,
      Switch(
        value: value,
        onChanged: onChanged,
      ),
    );

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
        title: const Text('Toastr Demo'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Toastr Configuration',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            
            // Message configuration
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Message',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    _buildTextField('Title', _titleController),
                    _buildTextField('Message', _messageController),
                    _buildDropdown<ToastrType>(
                      'Toast Type',
                      _selectedType,
                      ToastrType.values,
                      (value) => setState(() => _selectedType = value!),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Position and Animation configuration
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Position & Animation',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    _buildDropdown<ToastrPosition>(
                      'Position',
                      _selectedPosition,
                      ToastrPosition.values,
                      (value) => setState(() => _selectedPosition = value!),
                    ),
                    _buildDropdown<ToastrShowMethod>(
                      'Show Method',
                      _selectedShowMethod,
                      ToastrShowMethod.values,
                      (value) => setState(() => _selectedShowMethod = value!),
                    ),
                    _buildDropdown<ToastrHideMethod>(
                      'Hide Method',
                      _selectedHideMethod,
                      ToastrHideMethod.values,
                      (value) => setState(() => _selectedHideMethod = value!),
                    ),
                    _buildDropdown<Curve>(
                      'Show Easing',
                      _selectedShowEasing,
                      [Curves.easeOut, Curves.easeIn, Curves.linear, Curves.bounceOut, Curves.elasticOut],
                      (value) => setState(() => _selectedShowEasing = value!),
                    ),
                    _buildDropdown<Curve>(
                      'Hide Easing',
                      _selectedHideEasing,
                      [Curves.easeIn, Curves.easeOut, Curves.linear, Curves.bounceIn, Curves.elasticIn],
                      (value) => setState(() => _selectedHideEasing = value!),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Timing configuration
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Timing',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    _buildSlider(
                      'Show Duration',
                      _showDuration,
                      100,
                      2000,
                      (value) => setState(() => _showDuration = value.round()),
                    ),
                    _buildSlider(
                      'Hide Duration',
                      _hideDuration,
                      100,
                      2000,
                      (value) => setState(() => _hideDuration = value.round()),
                    ),
                    _buildSlider(
                      'Timeout',
                      _timeout,
                      0,
                      10000,
                      (value) => setState(() => _timeout = value.round()),
                    ),
                    _buildSlider(
                      'Extended Timeout',
                      _extendedTimeout,
                      0,
                      5000,
                      (value) => setState(() => _extendedTimeout = value.round()),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Options configuration
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Options',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    _buildSwitch(
                      'Progress Bar',
                      _showProgressBar,
                      (value) => setState(() => _showProgressBar = value),
                    ),
                    _buildSwitch(
                      'Close Button',
                      _showCloseButton,
                      (value) => setState(() => _showCloseButton = value),
                    ),
                    _buildSwitch(
                      'Prevent Duplicates',
                      _preventDuplicates,
                      (value) => setState(() => _preventDuplicates = value),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Action buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _showToast,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Show Toast', style: TextStyle(fontSize: 16)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: ToastrHelper.clearAll,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Clear Toasts', style: TextStyle(fontSize: 16)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: ToastrHelper.clearLast,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Clear Last', style: TextStyle(fontSize: 16)),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Quick test buttons
            const Text(
              'Quick Tests',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton.icon(
                  onPressed: () => ToastrHelper.success('Operation completed successfully!'),
                  icon: const Icon(Icons.check_circle, color: Colors.green),
                  label: const Text('Success'),
                ),
                ElevatedButton.icon(
                  onPressed: () => ToastrHelper.error('Something went wrong!'),
                  icon: const Icon(Icons.error, color: Colors.red),
                  label: const Text('Error'),
                ),
                ElevatedButton.icon(
                  onPressed: () => ToastrHelper.warning('Please check your input'),
                  icon: const Icon(Icons.warning, color: Colors.orange),
                  label: const Text('Warning'),
                ),
                ElevatedButton.icon(
                  onPressed: () => ToastrHelper.info('Here is some information'),
                  icon: const Icon(Icons.info, color: Colors.blue),
                  label: const Text('Info'),
                ),
              ],
            ),
          ],
        ),
      ),
    );

  @override
  void dispose() {
    _titleController.dispose();
    _messageController.dispose();
    super.dispose();
  }
}

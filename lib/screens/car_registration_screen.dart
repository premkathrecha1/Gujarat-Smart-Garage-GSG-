// lib/screens/car_registration_screen.dart
// Saves car to Firestore via FirebaseService.addCar()
// isNewUser flag: if false (returning user adding another car), skip manualLogin
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/car_model.dart';
import '../models/user_model.dart';
import '../services/app_state.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';
import 'main_shell.dart';

class CarRegistrationScreen extends StatefulWidget {
  final AppState appState;
  final UserModel user;
  final bool isNewUser;
  const CarRegistrationScreen({
    super.key,
    required this.appState,
    required this.user,
    this.isNewUser = false,
  });

  @override
  State<CarRegistrationScreen> createState() => _CarRegistrationScreenState();
}

class _CarRegistrationScreenState extends State<CarRegistrationScreen> {
  int _step = 0;
  String? _selectedBrand;
  String? _selectedModel;
  String? _selectedFuel;
  int? _selectedYear;
  String? _selectedVariant;
  String? _selectedColor;
  final _plateCtrl = TextEditingController();
  final _kmCtrl = TextEditingController();
  final _lastKmCtrl = TextEditingController();
  bool _isLoading = false;

  final List<String> _colors = ['White', 'Silver', 'Black', 'Blue', 'Red', 'Grey', 'Maroon', 'Orange', 'Green', 'Yellow'];

  @override
  void dispose() {
    _plateCtrl.dispose();
    _kmCtrl.dispose();
    _lastKmCtrl.dispose();
    super.dispose();
  }

  String get _brandEmoji => getBrandEmoji(_selectedBrand ?? '');
  List<String> get _modelList => AppConstants.carModels[_selectedBrand] ?? [];

  void _goToShell() {
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => MainShell(appState: widget.appState)),
      (route) => false,
    );
  }

  Future<void> _finish() async {
    if (_plateCtrl.text.isEmpty || _kmCtrl.text.isEmpty) {
      showSnackBar(context, 'Please fill plate number and current KM', isError: true);
      return;
    }
    setState(() => _isLoading = true);

    final car = CarModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(), // temp id, replaced by Firestore
      brand: _selectedBrand ?? 'Unknown',
      model: _selectedModel ?? 'Unknown',
      variant: _selectedVariant ?? 'Base',
      year: _selectedYear ?? DateTime.now().year,
      fuelType: _selectedFuel ?? 'Petrol',
      plateNumber: _plateCtrl.text.toUpperCase().trim(),
      currentKm: int.tryParse(_kmCtrl.text.trim()) ?? 0,
      lastServiceKm: int.tryParse(_lastKmCtrl.text.trim()) ?? 0,
      color: _selectedColor ?? 'White',
      insuranceExpiry: '2026-12-31',
    );

    try {
      // Try Firebase save first
      await widget.appState.addCarToFirebase(car);
    } catch (e) {
      // Fallback: local only (demo mode)
      widget.appState.addCar(car);
    }

    _goToShell();
  }

  void _skipAndEnter() => _goToShell();

  bool get _canStep0 => _selectedBrand != null && _selectedModel != null;
  bool get _canStep1 => _selectedYear != null && _selectedFuel != null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Add Your Car', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white)),
          Text('Step ${_step + 1} of 3', style: const TextStyle(fontSize: 12, color: Colors.white70)),
        ]),
        actions: [
          TextButton(
            onPressed: _skipAndEnter,
            child: const Text('Skip', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
      body: Column(
        children: [
          // Progress bar
          Container(
            color: AppColors.primary,
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
            child: Row(
              children: List.generate(3, (i) => Expanded(
                child: Container(
                  height: 4,
                  margin: EdgeInsets.only(right: i < 2 ? 6 : 0),
                  decoration: BoxDecoration(
                    color: i <= _step ? Colors.white : Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              )),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                    CircularProgressIndicator(color: AppColors.primary),
                    SizedBox(height: 16),
                    Text('Saving to Firebase...', style: TextStyle(color: AppColors.textSecondary)),
                  ]))
                : [_buildStep0(), _buildStep1(), _buildStep2()][_step],
          ),
          _buildNavButtons(),
        ],
      ),
    );
  }

  Widget _buildStep0() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _title('Brand & Model'),
        const SizedBox(height: 16),
        _lbl('Car Brand *'),
        DropdownButtonFormField<String>(
          value: _selectedBrand,
          decoration: const InputDecoration(prefixIcon: Icon(Icons.directions_car_outlined, color: AppColors.primary, size: 20)),
          hint: const Text('Select Brand'),
          items: AppConstants.carBrands.map((b) => DropdownMenuItem(value: b, child: Text(b))).toList(),
          onChanged: (v) => setState(() { _selectedBrand = v; _selectedModel = null; }),
        ),
        if (_selectedBrand != null) ...[
          const SizedBox(height: 16),
          _lbl('Model *'),
          DropdownButtonFormField<String>(
            value: _selectedModel,
            decoration: InputDecoration(prefixIcon: Text(_brandEmoji, style: const TextStyle(fontSize: 20))),
            hint: const Text('Select Model'),
            items: _modelList.map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
            onChanged: (v) => setState(() => _selectedModel = v),
          ),
        ],
      ]),
    );
  }

  Widget _buildStep1() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _title('Year & Fuel'),
        const SizedBox(height: 16),
        _lbl('Year *'),
        DropdownButtonFormField<int>(
          value: _selectedYear,
          decoration: const InputDecoration(prefixIcon: Icon(Icons.calendar_today_outlined, color: AppColors.primary, size: 20)),
          hint: const Text('Select Year'),
          items: AppConstants.years.map((y) => DropdownMenuItem(value: y, child: Text('$y'))).toList(),
          onChanged: (v) => setState(() => _selectedYear = v),
        ),
        const SizedBox(height: 16),
        _lbl('Fuel Type *'),
        Wrap(
          spacing: 10, runSpacing: 10,
          children: AppConstants.fuelTypes.map((f) => ChoiceChip(
            label: Text(f),
            selected: _selectedFuel == f,
            onSelected: (v) => setState(() => _selectedFuel = v ? f : null),
            selectedColor: AppColors.primary,
            labelStyle: TextStyle(color: _selectedFuel == f ? Colors.white : AppColors.textPrimary, fontWeight: FontWeight.w600),
          )).toList(),
        ),
        const SizedBox(height: 16),
        _lbl('Variant (optional)'),
        TextField(onChanged: (v) => setState(() => _selectedVariant = v),
          decoration: const InputDecoration(hintText: 'e.g. ZXi, VXI, Top', prefixIcon: Icon(Icons.tune_outlined, color: AppColors.primary, size: 20))),
      ]),
    );
  }

  Widget _buildStep2() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _title('Plate & Mileage'),
        const SizedBox(height: 16),
        _lbl('License Plate *'),
        TextField(controller: _plateCtrl,
          textCapitalization: TextCapitalization.characters,
          inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9 ]'))],
          decoration: const InputDecoration(hintText: 'GJ 01 AA 1234', prefixIcon: Icon(Icons.credit_card_outlined, color: AppColors.primary, size: 20))),
        const SizedBox(height: 16),
        _lbl('Current KM *'),
        TextField(controller: _kmCtrl, keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: const InputDecoration(hintText: '45000', prefixIcon: Icon(Icons.speed_outlined, color: AppColors.primary, size: 20), suffixText: 'km')),
        const SizedBox(height: 16),
        _lbl('Last Service KM'),
        TextField(controller: _lastKmCtrl, keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: const InputDecoration(hintText: '40000', prefixIcon: Icon(Icons.build_outlined, color: AppColors.primary, size: 20), suffixText: 'km')),
        const SizedBox(height: 16),
        _lbl('Color'),
        Wrap(spacing: 8, runSpacing: 8,
          children: _colors.map((c) => GestureDetector(
            onTap: () => setState(() => _selectedColor = c),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: _selectedColor == c ? AppColors.primary : AppColors.accentLight,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _selectedColor == c ? AppColors.primary : AppColors.borderColor),
              ),
              child: Text(c, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: _selectedColor == c ? Colors.white : AppColors.textPrimary)),
            ),
          )).toList(),
        ),
      ]),
    );
  }

  Widget _buildNavButtons() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      color: AppColors.surface,
      child: Row(children: [
        if (_step > 0) ...[
          Expanded(child: OutlinedButton(
            onPressed: () => setState(() => _step--),
            style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.borderColor)),
            child: const Text('← Back', style: TextStyle(color: AppColors.textSecondary)),
          )),
          const SizedBox(width: 12),
        ],
        Expanded(flex: 2, child: ElevatedButton(
          onPressed: _isLoading ? null : () {
            if (_step == 0 && !_canStep0) { showSnackBar(context, 'Please select brand and model', isError: true); return; }
            if (_step == 1 && !_canStep1) { showSnackBar(context, 'Please select year and fuel type', isError: true); return; }
            if (_step < 2) setState(() => _step++);
            else _finish();
          },
          child: Text(_step < 2 ? 'Next →' : 'Save to Firebase ☁️'),
        )),
      ]),
    );
  }

  Widget _title(String t) => Text(t, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary));
  Widget _lbl(String t) => Padding(padding: const EdgeInsets.only(bottom: 8),
    child: Text(t, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textSecondary, letterSpacing: 0.4)));
}
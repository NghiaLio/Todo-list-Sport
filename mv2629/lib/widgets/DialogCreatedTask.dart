import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mv2629/constants/theme.dart';

class MatchDialog extends StatefulWidget {
  const MatchDialog({super.key});

  @override
  State<MatchDialog> createState() => _MatchDialogState();
}

class _MatchDialogState extends State<MatchDialog> {
  final _timeController = TextEditingController(text: '00:00');
  final _scoreController = TextEditingController(text: '00-00');
  final _locationController = TextEditingController(
    text: 'My Dinh basketball court',
  );

  bool _isValidTimeFormat(String value) {
    return RegExp(r'^(?:[0-1]?\d|2[0-3]):(?:[0-5]?\d)$').hasMatch(value);
  }

  bool _isValidScoreFormat(String value) {
    return RegExp(r'^\d{1,2}-\d{1,2}$').hasMatch(value);
  }

  void _onSave() {
    final timeValue = _timeController.text.trim();
    final scoreValue = _scoreController.text.trim();
    final locationValue = _locationController.text.trim();

    if (!_isValidTimeFormat(timeValue)) {
      Navigator.pop(context, {
        'status': 'error',
        'message': 'Time must be in the format HH:mm',
      });
      return;
    }

    if (!_isValidScoreFormat(scoreValue)) {
      Navigator.pop(context, {
        'status': 'error',
        'message': 'Scored is not in valid format (e.g., 21-18)',
      });
      return;
    }
    if (locationValue.isEmpty) {
      Navigator.pop(context, {
        'status': 'error',
        'message': 'Location is required',
      });
      return;
    }

    Navigator.pop(context, {
      'status': 'success',
      'time': timeValue,
      'scored': scoreValue,
      'location': locationValue,
    });
  }

  @override
  void dispose() {
    _timeController.dispose();
    _scoreController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  void _onClose() {
    Navigator.pop(context);
  }

  Widget _buildCloseButton() {
    return GestureDetector(
      onTap: _onClose,
      child: Container(
        width: 25,
        height: 25,
        decoration: const BoxDecoration(
          color: AppTheme.blackColor,
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.close, color: AppTheme.whiteColor, size: 18),
      ),
    );
  }

  Widget _buildTopSection() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildCloseButton(),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildInfoCard(
                label: 'Time',
                controller: _timeController,
                keyboardType: TextInputType.text,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9:]')),
                  LengthLimitingTextInputFormatter(5),
                ],
              ),
              const SizedBox(width: 10),
              _buildInfoCard(
                label: 'Scored',
                controller: _scoreController,
                keyboardType: TextInputType.text,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9\-]')),
                  LengthLimitingTextInputFormatter(5),
                ],
              ),
            ],
          ),
        ),
        const Icon(Icons.notifications, size: 28, color: AppTheme.grey700Color),
      ],
    );
  }

  Widget _buildLocationBox() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Text(
            'Location',
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: TextField(
                  controller: _locationController,
                  onTap: () => _locationController.clear(),
                  keyboardType: TextInputType.text,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.grey700Color,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: const InputDecoration(
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                    border: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    enabledBorder: InputBorder.none,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.3,
      child: ElevatedButton(
        onPressed: _onSave,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryColor,
          foregroundColor: AppTheme.whiteColor,
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          elevation: 0,
        ),
        child: Text(
          'Save',
          style: Theme.of(
            context,
          ).textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required String label,
    required TextEditingController controller,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Container(
      width: 80, // Tăng width một chút cho vừa TextField
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          SizedBox(
            height: 24,
            child: TextField(
              controller: controller,
              onTap: () => controller.clear(),
              keyboardType: keyboardType,
              inputFormatters: inputFormatters,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.black87Color,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
              decoration: const InputDecoration(
                isDense: true,
                contentPadding: EdgeInsets.zero,
                border: InputBorder.none,
                focusedBorder: InputBorder.none,
                enabledBorder: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: AppTheme.whiteColor,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildTopSection(),
            const SizedBox(height: 16),
            _buildLocationBox(),
            const SizedBox(height: 16),
            _buildSaveButton(),
          ],
        ),
      ),
    );
  }
}

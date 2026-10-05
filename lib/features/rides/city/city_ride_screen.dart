import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';

class CityRideScreen extends StatefulWidget {
  const CityRideScreen({super.key});

  @override
  State<CityRideScreen> createState() => _CityRideScreenState();
}

class _CityRideScreenState extends State<CityRideScreen> {
  final TextEditingController pickupController = TextEditingController();
  final TextEditingController destinationController = TextEditingController();
  final TextEditingController notesController = TextEditingController();

  String selectedVehicle = 'سيارة';
  int passengers = 1;

  final double estimatedDistance = 8.0;
  final double estimatedMinutes = 20.0;

  final Map<String, Map<String, dynamic>> vehicles = {
    'دراجة': {
      'icon': Icons.two_wheeler,
      'multiplier': 0.50,
      'description': 'أسرع وأوفر',
    },
    'ركشة': {
      'icon': Icons.electric_rickshaw,
      'multiplier': 0.75,
      'description': 'مناسبة داخل المدينة',
    },
    'سيارة': {
      'icon': Icons.directions_car,
      'multiplier': 1.00,
      'description': 'الخيار الأكثر استخدامًا',
    },
    'بوكس': {
      'icon': Icons.local_shipping,
      'multiplier': 1.45,
      'description': 'مناسبة للأمتعة',
    },
  };

  double get baseFare => 3000;

  double get distanceFare => estimatedDistance * 4000;

  double get timeFare => estimatedMinutes * 100;

  double get vehicleMultiplier =>
      vehicles[selectedVehicle]?['multiplier'] as double? ?? 1.0;

  double get estimatedFare =>
      (baseFare + distanceFare + timeFare) * vehicleMultiplier;

  @override
  void dispose() {
    pickupController.dispose();
    destinationController.dispose();
    notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text(
            'رحلة داخل المدينة',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildRouteCard(),
                const SizedBox(height: 24),
                _buildSectionTitle('اختر نوع المركبة'),
                const SizedBox(height: 12),
                _buildVehicleSelector(),
                const SizedBox(height: 24),
                _buildSectionTitle('عدد الركاب'),
                const SizedBox(height: 12),
                _buildPassengersSelector(),
                const SizedBox(height: 24),
                _buildSectionTitle('ملاحظات للسائق'),
                const SizedBox(height: 12),
                _buildNotesField(),
                const SizedBox(height: 24),
                _buildFareCard(),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _requestRide,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.lime,
                      foregroundColor: Colors.black,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(17),
                      ),
                    ),
                    child: const Text(
                      'طلب الرحلة',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildRouteCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.06),
        ),
      ),
      child: Column(
        children: [
          _buildLocationField(
            controller: pickupController,
            icon: Icons.my_location,
            iconColor: AppColors.lime,
            label: 'نقطة الانطلاق',
            hint: 'أين تريد أن نلتقطك؟',
          ),
          Padding(
            padding: const EdgeInsets.only(right: 18),
            child: Align(
              alignment: Alignment.centerRight,
              child: Container(
                width: 1,
                height: 20,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          _buildLocationField(
            controller: destinationController,
            icon: Icons.location_on,
            iconColor: Colors.redAccent,
            label: 'الوجهة',
            hint: 'إلى أين تريد الذهاب؟',
          ),
        ],
      ),
    );
  }

  Widget _buildLocationField({
    required TextEditingController controller,
    required IconData icon,
    required Color iconColor,
    required String label,
    required String hint,
  }) {
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: iconColor,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: TextField(
            controller: controller,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
            ),
            decoration: InputDecoration(
              labelText: label,
              labelStyle: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 13,
              ),
              hintText: hint,
              hintStyle: TextStyle(
                color: Colors.grey.shade700,
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVehicleSelector() {
    return Column(
      children: vehicles.entries.map((entry) {
        final name = entry.key;
        final data = entry.value;
        final isSelected = selectedVehicle == name;

        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: InkWell(
            onTap: () {
              setState(() {
                selectedVehicle = name;
              });
            },
            borderRadius: BorderRadius.circular(18),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.lime.withValues(alpha: 0.10)
                    : AppColors.surface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: isSelected
                      ? AppColors.lime
                      : Colors.white.withValues(alpha: 0.06),
                  width: isSelected ? 1.5 : 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.lime.withValues(alpha: 0.15)
                          : Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      data['icon'] as IconData,
                      color: isSelected
                          ? AppColors.lime
                          : Colors.grey.shade400,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isSelected
                                ? AppColors.lime
                                : Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          data['description'] as String,
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    isSelected
                        ? Icons.check_circle
                        : Icons.radio_button_unchecked,
                    color: isSelected
                        ? AppColors.lime
                        : Colors.grey.shade700,
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPassengersSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 14,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.people_outline,
            color: AppColors.lime,
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Text(
              'عدد الركاب',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          _counterButton(
            icon: Icons.remove,
            enabled: passengers > 1,
            onTap: () {
              if (passengers > 1) {
                setState(() {
                  passengers--;
                });
              }
            },
          ),
          SizedBox(
            width: 42,
            child: Center(
              child: Text(
                '$passengers',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          _counterButton(
            icon: Icons.add,
            enabled: passengers < 14,
            onTap: () {
              if (passengers < 14) {
                setState(() {
                  passengers++;
                });
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _counterButton({
    required IconData icon,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: enabled
              ? AppColors.lime.withValues(alpha: 0.12)
              : Colors.white.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          size: 18,
          color: enabled ? AppColors.lime : Colors.grey.shade700,
        ),
      ),
    );
  }

  Widget _buildNotesField() {
    return TextField(
      controller: notesController,
      maxLines: 3,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 14,
      ),
      decoration: InputDecoration(
        hintText: 'مثلاً: سأكون أمام البوابة الرئيسية',
        hintStyle: TextStyle(
          color: Colors.grey.shade600,
        ),
        filled: true,
        fillColor: AppColors.surface,
        prefixIcon: const Padding(
          padding: EdgeInsets.only(
            left: 14,
            right: 10,
            top: 12,
          ),
          child: Icon(
            Icons.notes_outlined,
            color: Colors.grey,
          ),
        ),
        prefixIconConstraints: const BoxConstraints(
          minWidth: 45,
          minHeight: 45,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildFareCard() {
    final fare = estimatedFare.round();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.lime,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(
                Icons.payments_outlined,
                color: Colors.black,
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'السعر التقديري',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text(
                '$fare جنيه',
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            height: 1,
            color: Colors.black.withValues(alpha: 0.12),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _fareDetail(
                'المسافة',
                '${estimatedDistance.toStringAsFixed(1)} كم',
              ),
              _fareDetail(
                'الوقت',
                '${estimatedMinutes.round()} دقيقة',
              ),
              _fareDetail(
                'المركبة',
                selectedVehicle,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _fareDetail(String title, String value) {
    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.black54,
            fontSize: 11,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  void _requestRide() {
    if (pickupController.text.trim().isEmpty ||
        destinationController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'يرجى تحديد نقطة الانطلاق والوجهة أولاً',
          ),
        ),
      );
      return;
    }

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      enableDrag: true,
      isDismissible: true,
      useSafeArea: true,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.70,
          minChildSize: 0.45,
          maxChildSize: 0.94,
          expand: false,
          snap: true,
          snapSizes: const [
            0.70,
            0.94,
          ],
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(28),
                ),
              ),
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.fromLTRB(
                  20,
                  12,
                  20,
                  30,
                ),
                children: [
                  Center(
                    child: Container(
                      width: 45,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade700,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),
                  const Text(
                    'تأكيد طلب الرحلة',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _summaryRow(
                    Icons.my_location,
                    'من',
                    pickupController.text.trim(),
                  ),
                  const SizedBox(height: 12),
                  _summaryRow(
                    Icons.location_on,
                    'إلى',
                    destinationController.text.trim(),
                  ),
                  const SizedBox(height: 12),
                  _summaryRow(
                    Icons.directions_car,
                    'المركبة',
                    selectedVehicle,
                  ),
                  const SizedBox(height: 12),
                  _summaryRow(
                    Icons.people_outline,
                    'الركاب',
                    '$passengers',
                  ),
                  const SizedBox(height: 18),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.lime.withValues(
                        alpha: 0.10,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'السعر التقديري',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Text(
                          '${estimatedFare.round()} جنيه',
                          style: const TextStyle(
                            color: AppColors.lime,
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        context.push('/driver-offers');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.lime,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'تأكيد وإرسال الطلب',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _summaryRow(
    IconData icon,
    String title,
    String value,
  ) {
    return Row(
      children: [
        const SizedBox(width: 2),
        Icon(
          icon,
          color: AppColors.lime,
          size: 21,
        ),
        const SizedBox(width: 12),
        Text(
          '$title: ',
          style: const TextStyle(
            color: Colors.grey,
          ),
        ),
        Expanded(
          child: Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
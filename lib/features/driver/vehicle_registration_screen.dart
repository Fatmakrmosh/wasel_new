import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/theme/app_theme.dart';

class VehicleRegistrationScreen extends StatefulWidget {
  const VehicleRegistrationScreen({super.key});

  @override
  State<VehicleRegistrationScreen> createState() =>
      _VehicleRegistrationScreenState();
}

class _VehicleRegistrationScreenState
    extends State<VehicleRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();

  XFile? vehicleLicensePhoto;
  XFile? insurancePhoto;
  XFile? vehiclePhoto;

  final plateController = TextEditingController();
  final modelController = TextEditingController();
  final yearController = TextEditingController();
  final colorController = TextEditingController();

  String selectedVehicleType = 'سيارة';
  String selectedBrand = 'Toyota';
  String selectedSeats = '4 مقاعد';

  bool get hasVehicleLicense => vehicleLicensePhoto != null;
  bool get hasVehiclePhoto => vehiclePhoto != null;
  bool get hasInsurance => insurancePhoto != null;
  bool agreedToTerms = false;

  final List<String> vehicleTypes = [
    'دراجة',
    'ركشة',
    'سيارة',
    'بوكس',
    'حافلة صغيرة',
    'باص',
    'شاحنة',
  ];

  final List<String> brands = [
    'Toyota',
    'Hyundai',
    'Kia',
    'Nissan',
    'Honda',
    'Suzuki',
    'Mitsubishi',
    'Isuzu',
    'Mercedes-Benz',
    'أخرى',
  ];

  final List<String> seats = [
    '1 مقعد',
    '2 مقاعد',
    '4 مقاعد',
    '5 مقاعد',
    '7 مقاعد',
    '14 مقعد',
    '18 مقعد',
    '24 مقعد',
    '30 مقعد',
    '40 مقعد',
    '50 مقعد',
  ];

  @override
  void dispose() {
    plateController.dispose();
    modelController.dispose();
    yearController.dispose();
    colorController.dispose();
    super.dispose();
  }

  Future<void> _choosePhoto(String document) async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 45,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'إضافة الصورة',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  document,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white60,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 18),
                ListTile(
                  leading: const Icon(
                    Icons.photo_camera_outlined,
                    color: AppColors.lime,
                  ),
                  title: const Text('تصوير بالكاميرا'),
                  onTap: () =>
                      Navigator.pop(sheetContext, ImageSource.camera),
                ),
                ListTile(
                  leading: const Icon(
                    Icons.photo_library_outlined,
                    color: AppColors.lime,
                  ),
                  title: const Text('اختيار من الهاتف'),
                  onTap: () =>
                      Navigator.pop(sheetContext, ImageSource.gallery),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (source == null) return;

    try {
      final photo = await _picker.pickImage(
        source: source,
        imageQuality: 90,
        maxWidth: 2000,
        maxHeight: 2000,
      );
      if (photo == null) return;

      setState(() {
        if (document == 'رخصة المركبة') {
          vehicleLicensePhoto = photo;
        } else if (document == 'التأمين') {
          insurancePhoto = photo;
        } else {
          vehiclePhoto = photo;
        }
      });
    } catch (_) {
      _showMessage('تعذر إضافة الصورة. حاول مرة أخرى.');
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          textAlign: TextAlign.right,
        ),
      ),
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (!hasVehicleLicense) {
      _showMessage('يرجى إضافة صورة رخصة المركبة');
      return;
    }

    if (!hasInsurance) {
      _showMessage('يرجى إضافة صورة التأمين');
      return;
    }

    if (!hasVehiclePhoto) {
      _showMessage('يرجى إضافة صورة المركبة');
      return;
    }

    if (!agreedToTerms) {
      _showMessage('يرجى الموافقة على بيانات المركبة');
      return;
    }

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 30),
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(28),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 45,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 22),
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: AppColors.lime.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  color: AppColors.lime,
                  size: 46,
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'تم تسجيل المركبة',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'تم حفظ بيانات المركبة بنجاح. سيخضع طلبك للمراجعة قبل تفعيل حساب السائق.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 22),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: const Color(0xFF252525),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  children: [
                    _summaryRow('نوع المركبة', selectedVehicleType),
                    const SizedBox(height: 8),
                    _summaryRow('الماركة', selectedBrand),
                    const SizedBox(height: 8),
                    _summaryRow('الموديل', modelController.text),
                    const SizedBox(height: 8),
                    _summaryRow('رقم اللوحة', plateController.text),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    context.go('/account-mode');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.lime,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'الانتقال إلى لوحة السائق',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _summaryRow(String title, String value) {
    return Row(
      children: [
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.left,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Text(
          title,
          textAlign: TextAlign.right,
          style: const TextStyle(
            color: Colors.white54,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hint,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      textAlign: TextAlign.right,
      style: const TextStyle(
        color: Colors.white,
      ),
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: const TextStyle(
          color: Colors.white54,
        ),
        hintStyle: const TextStyle(
          color: Colors.white30,
        ),
        prefixIcon: Icon(
          icon,
          color: AppColors.lime,
        ),
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(
            color: Colors.white10,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(
            color: AppColors.lime,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(
            color: Colors.redAccent,
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown<T>({
    required String label,
    required IconData icon,
    required T value,
    required List<T> items,
    required ValueChanged<T?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: Colors.white10,
        ),
      ),
      child: DropdownButtonFormField<T>(
        initialValue: value,
        decoration: InputDecoration(
          border: InputBorder.none,
          labelText: label,
          labelStyle: const TextStyle(
            color: Colors.white54,
          ),
          prefixIcon: Icon(
            icon,
            color: AppColors.lime,
          ),
        ),
        dropdownColor: const Color(0xFF252525),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
        ),
        items: items.map((item) {
          return DropdownMenuItem<T>(
            value: item,
            child: Text(
              item.toString(),
            ),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildDocumentCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool uploaded,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(
          color: uploaded
              ? AppColors.lime.withValues(alpha: 0.45)
              : Colors.white10,
        ),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 5,
        ),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: uploaded
                ? AppColors.lime.withValues(alpha: 0.12)
                : Colors.white10,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            uploaded ? Icons.check_rounded : icon,
            color: uploaded ? AppColors.lime : Colors.white70,
          ),
        ),
        title: Text(
          title,
          textAlign: TextAlign.right,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          uploaded ? 'تمت الإضافة بنجاح' : subtitle,
          textAlign: TextAlign.right,
          style: TextStyle(
            color: uploaded ? AppColors.lime : Colors.white54,
            fontSize: 11,
          ),
        ),
        trailing: Icon(
          uploaded
              ? Icons.verified_rounded
              : Icons.add_a_photo_outlined,
          color: uploaded ? AppColors.lime : Colors.white54,
          size: 22,
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(
        right: 4,
        bottom: 10,
      ),
      child: Text(
        title,
        textAlign: TextAlign.right,
        style: const TextStyle(
          color: AppColors.lime,
          fontSize: 15,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'تسجيل المركبة',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
            size: 20,
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 35),
          children: [
            _buildHeader(),
            const SizedBox(height: 25),
            _buildSectionTitle('بيانات المركبة'),
            _buildDropdown<String>(
              label: 'نوع المركبة',
              icon: Icons.directions_car_outlined,
              value: selectedVehicleType,
              items: vehicleTypes,
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    selectedVehicleType = value;
                  });
                }
              },
            ),
            const SizedBox(height: 13),
            _buildDropdown<String>(
              label: 'الماركة',
              icon: Icons.directions_car_filled_outlined,
              value: selectedBrand,
              items: brands,
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    selectedBrand = value;
                  });
                }
              },
            ),
            const SizedBox(height: 13),
            _buildTextField(
              controller: modelController,
              label: 'الموديل',
              icon: Icons.car_repair_outlined,
              hint: 'مثال: Corolla',
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'يرجى إدخال موديل المركبة';
                }
                return null;
              },
            ),
            const SizedBox(height: 13),
            _buildTextField(
              controller: yearController,
              label: 'سنة الصنع',
              icon: Icons.calendar_today_outlined,
              hint: 'مثال: 2020',
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'يرجى إدخال سنة الصنع';
                }

                final year = int.tryParse(value.trim());

                if (year == null || year < 1980 || year > 2030) {
                  return 'يرجى إدخال سنة صحيحة';
                }

                return null;
              },
            ),
            const SizedBox(height: 13),
            _buildTextField(
              controller: plateController,
              label: 'رقم اللوحة',
              icon: Icons.pin_outlined,
              hint: 'مثال: خ ط 12345',
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'يرجى إدخال رقم اللوحة';
                }
                return null;
              },
            ),
            const SizedBox(height: 13),
            _buildTextField(
              controller: colorController,
              label: 'لون المركبة',
              icon: Icons.palette_outlined,
              hint: 'مثال: أبيض',
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'يرجى إدخال لون المركبة';
                }
                return null;
              },
            ),
            const SizedBox(height: 13),
            _buildDropdown<String>(
              label: 'عدد المقاعد',
              icon: Icons.event_seat_outlined,
              value: selectedSeats,
              items: seats,
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    selectedSeats = value;
                  });
                }
              },
            ),
            const SizedBox(height: 28),
            _buildSectionTitle('المستندات والصور'),
            const Text(
              'أضف المستندات والصور المطلوبة لمراجعة المركبة.',
              textAlign: TextAlign.right,
              style: TextStyle(
                color: Colors.white54,
                fontSize: 12,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 13),
            _buildDocumentCard(
              title: 'رخصة المركبة / الترخيص',
              subtitle: hasVehicleLicense
                  ? 'تمت إضافة الصورة'
                  : 'الكاميرا أو اختيار صورة من الهاتف',
              icon: Icons.description_outlined,
              uploaded: hasVehicleLicense,
              onTap: () => _choosePhoto('رخصة المركبة'),
            ),
            _buildDocumentCard(
              title: 'التأمين',
              subtitle: hasInsurance
                  ? 'تمت إضافة الصورة'
                  : 'الكاميرا أو اختيار صورة من الهاتف',
              icon: Icons.verified_user_outlined,
              uploaded: hasInsurance,
              onTap: () => _choosePhoto('التأمين'),
            ),
            _buildDocumentCard(
              title: 'صورة المركبة',
              subtitle: hasVehiclePhoto
                  ? 'تمت إضافة الصورة'
                  : 'صورة واضحة للمركبة من الخارج',
              icon: Icons.directions_car_outlined,
              uploaded: hasVehiclePhoto,
              onTap: () => _choosePhoto('صورة المركبة'),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.lime.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: AppColors.lime.withValues(alpha: 0.18),
                ),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    color: AppColors.lime,
                    size: 20,
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'تنبيه: ارفع صورًا أصلية وواضحة وغير معدلة بفلتر أو فوتوشوب أو أي برنامج تعديل. الصور غير الواضحة أو المعدلة قد تُرفض عند المراجعة.',
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 11,
                        height: 1.6,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(15),
              ),
              child: CheckboxListTile(
                value: agreedToTerms,
                onChanged: (value) {
                  setState(() {
                    agreedToTerms = value ?? false;
                  });
                },
                activeColor: AppColors.lime,
                checkColor: Colors.black,
                controlAffinity: ListTileControlAffinity.leading,
                title: const Text(
                  'أقر بأن بيانات المركبة صحيحة وأوافق على مراجعتها من إدارة واصل.',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    height: 1.5,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 25),
            SizedBox(
              height: 54,
              child: ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.lime,
                  foregroundColor: Colors.black,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'حفظ بيانات المركبة',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(
                      Icons.arrow_forward_rounded,
                      size: 21,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.lime.withValues(alpha: 0.16),
            AppColors.surface,
          ],
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: AppColors.lime.withValues(alpha: 0.20),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: const BoxDecoration(
              color: AppColors.lime,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.directions_car_rounded,
              color: Colors.black,
              size: 31,
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'بيانات مركبتك',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'أدخل بيانات المركبة التي ستستخدمها في خدمات واصل.',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    color: Colors.white60,
                    fontSize: 12,
                    height: 1.5,
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
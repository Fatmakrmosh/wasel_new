import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/theme/app_theme.dart';

class DriverRegistrationScreen extends StatefulWidget {
  const DriverRegistrationScreen({super.key});

  @override
  State<DriverRegistrationScreen> createState() =>
      _DriverRegistrationScreenState();
}

class _DriverRegistrationScreenState
    extends State<DriverRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();

  XFile? personalPhoto;
  XFile? nationalIdPhoto;
  XFile? drivingLicensePhoto;

  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final nationalIdController = TextEditingController();
  final addressController = TextEditingController();

  String selectedCity = 'الخرطوم';
  DateTime? birthDate;
  bool agreedToTerms = false;

  bool get hasNationalId => nationalIdPhoto != null;
  bool get hasDrivingLicense => drivingLicensePhoto != null;
  bool get hasPersonalPhoto => personalPhoto != null;

  final List<String> cities = [
    'الخرطوم',
    'بحري',
    'أم درمان',
    'شندي',
    'عطبرة',
    'بورتسودان',
    'مدني',
    'القضارف',
    'كسلا',
    'سنار',
    'ربك',
    'الدويم',
    'مروي',
    'كريمة',
  ];

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    nationalIdController.dispose();
    addressController.dispose();
    super.dispose();
  }

  Future<void> _selectBirthDate() async {
    final now = DateTime.now();

    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(now.year - 30),
      firstDate: DateTime(1950),
      lastDate: DateTime(now.year - 18),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.lime,
              onPrimary: Colors.black,
              surface: AppColors.surface,
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        birthDate = picked;
      });
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (birthDate == null) {
      _showMessage('يرجى اختيار تاريخ الميلاد');
      return;
    }

    if (!hasPersonalPhoto) {
      _showMessage('يرجى التقاط الصورة الشخصية بالكاميرا');
      return;
    }

    if (!hasNationalId) {
      _showMessage('يرجى إضافة صورة الهوية الوطنية');
      return;
    }

    if (!hasDrivingLicense) {
      _showMessage('يرجى إضافة صورة رخصة القيادة');
      return;
    }

    if (!agreedToTerms) {
      _showMessage('يرجى الموافقة على شروط التسجيل');
      return;
    }

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
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
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: AppColors.lime.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  color: AppColors.lime,
                  size: 45,
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'تم حفظ بياناتك',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'الخطوة التالية هي تسجيل بيانات المركبة حتى يكتمل طلب الانضمام كسائق في واصل.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    context.push('/vehicle-register');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.lime,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'متابعة تسجيل المركبة',
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

  Future<void> _takePersonalPhoto() async {
    try {
      final photo = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 90,
        maxWidth: 1600,
        maxHeight: 1600,
      );
      if (photo != null && mounted) {
        setState(() {
          personalPhoto = photo;
        });
      }
    } catch (_) {
      _showMessage('تعذر فتح الكاميرا. تأكد من منح الإذن للكاميرا.');
    }
  }

  Future<void> _chooseDocument(String document) async {
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
                  'إضافة المستند',
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
                  onTap: () => Navigator.pop(
                    sheetContext,
                    ImageSource.camera,
                  ),
                ),
                ListTile(
                  leading: const Icon(
                    Icons.photo_library_outlined,
                    color: AppColors.lime,
                  ),
                  title: const Text('اختيار من الهاتف'),
                  onTap: () => Navigator.pop(
                    sheetContext,
                    ImageSource.gallery,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (source == null) {
      return;
    }

    try {
      final photo = await _picker.pickImage(
        source: source,
        imageQuality: 90,
        maxWidth: 2000,
        maxHeight: 2000,
      );

      if (photo == null || !mounted) {
        return;
      }

      setState(() {
        if (document == 'الهوية الوطنية') {
          nationalIdPhoto = photo;
        } else if (document == 'رخصة القيادة') {
          drivingLicensePhoto = photo;
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hint,
    TextInputType? keyboardType,
    int? maxLength,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLength: maxLength,
      inputFormatters: inputFormatters,
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
        prefixIcon: const Icon(
          Icons.person_outline_rounded,
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
            color: uploaded
                ? AppColors.lime
                : Colors.white70,
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
            color: uploaded
                ? AppColors.lime
                : Colors.white54,
            fontSize: 11,
          ),
        ),
        trailing: Icon(
          uploaded
              ? Icons.verified_rounded
              : Icons.add_a_photo_outlined,
          color: uploaded
              ? AppColors.lime
              : Colors.white54,
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
          'التسجيل كسائق',
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
            _buildSectionTitle('البيانات الشخصية'),
            _buildTextField(
              controller: nameController,
              label: 'الاسم الكامل',
              icon: Icons.person_outline_rounded,
              hint: 'اكتب اسمك الكامل',
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'يرجى إدخال الاسم';
                }
                if (value.trim().length < 3) {
                  return 'الاسم قصير جدًا';
                }
                return null;
              },
            ),
            const SizedBox(height: 13),
            _buildTextField(
              controller: phoneController,
              label: 'رقم الهاتف',
              icon: Icons.phone_outlined,
              hint: '09XXXXXXXX',
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'يرجى إدخال رقم الهاتف';
                }
                if (value.trim().length < 9) {
                  return 'يرجى إدخال رقم هاتف صحيح';
                }
                return null;
              },
            ),
            const SizedBox(height: 13),
            _buildTextField(
              controller: nationalIdController,
              label: 'الرقم الوطني',
              icon: Icons.badge_outlined,
              hint: 'أدخل الرقم الوطني المكون من 11 رقمًا',
              keyboardType: TextInputType.number,
              maxLength: 11,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
              validator: (value) {
                final nationalId = value?.trim() ?? '';
                if (nationalId.isEmpty) {
                  return 'يرجى إدخال الرقم الوطني';
                }
                if (nationalId.length != 11 ||
                    int.tryParse(nationalId) == null) {
                  return 'الرقم الوطني يجب أن يتكون من 11 رقمًا';
                }
                return null;
              },
            ),
            const SizedBox(height: 13),
            InkWell(
              onTap: _selectBirthDate,
              borderRadius: BorderRadius.circular(15),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 17,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: Colors.white10,
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.calendar_month_outlined,
                      color: AppColors.lime,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        birthDate == null
                            ? 'اختر تاريخ الميلاد'
                            : '${birthDate!.day.toString().padLeft(2, '0')}/${birthDate!.month.toString().padLeft(2, '0')}/${birthDate!.year}',
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          color: birthDate == null
                              ? Colors.white54
                              : Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const Text(
                      'تاريخ الميلاد',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 13),
            Container(
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
              child: DropdownButtonFormField<String>(
                initialValue: selectedCity,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  labelText: 'مدينة العمل',
                  labelStyle: TextStyle(
                    color: Colors.white54,
                  ),
                  prefixIcon: Icon(
                    Icons.location_city_outlined,
                    color: AppColors.lime,
                  ),
                ),
                dropdownColor: const Color(0xFF252525),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
                items: cities.map((city) {
                  return DropdownMenuItem<String>(
                    value: city,
                    child: Text(city),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      selectedCity = value;
                    });
                  }
                },
              ),
            ),
            const SizedBox(height: 13),
            _buildTextField(
              controller: addressController,
              label: 'العنوان',
              icon: Icons.home_outlined,
              hint: 'الحي / المنطقة',
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'يرجى إدخال العنوان';
                }
                return null;
              },
            ),
            const SizedBox(height: 28),
            _buildSectionTitle('الصورة الشخصية والمستندات'),
            const Text(
              'الصورة الشخصية تُلتقط بالكاميرا. ويمكن تصوير المستندات أو اختيار صورها من الهاتف.',
              textAlign: TextAlign.right,
              style: TextStyle(
                color: Colors.white54,
                fontSize: 12,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 13),
            _buildDocumentCard(
              title: 'الصورة الشخصية (الوجه)',
              subtitle: personalPhoto == null
                  ? 'التقاط صورة واضحة للوجه بالكاميرا'
                  : 'تم التقاط الصورة',
              icon: Icons.face_retouching_natural_outlined,
              uploaded: hasPersonalPhoto,
              onTap: _takePersonalPhoto,
            ),
            _buildDocumentCard(
              title: 'الهوية الوطنية',
              subtitle: nationalIdPhoto == null
                  ? 'الكاميرا أو اختيار صورة من الهاتف'
                  : 'تمت إضافة الصورة',
              icon: Icons.badge_outlined,
              uploaded: hasNationalId,
              onTap: () => _chooseDocument('الهوية الوطنية'),
            ),
            _buildDocumentCard(
              title: 'رخصة القيادة',
              subtitle: drivingLicensePhoto == null
                  ? 'الكاميرا أو اختيار صورة من الهاتف'
                  : 'تمت إضافة الصورة',
              icon: Icons.credit_card_outlined,
              uploaded: hasDrivingLicense,
              onTap: () => _chooseDocument('رخصة القيادة'),
            ),
            const SizedBox(height: 16),
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
            const SizedBox(height: 25),
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
                  'أوافق على شروط وأحكام التسجيل كسائق في منصة واصل.',
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
                      'متابعة',
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
              Icons.drive_eta_rounded,
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
                  'انضم إلى سائقي واصل',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'أكمل بياناتك للبدء في إجراءات التسجيل والمراجعة.',
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
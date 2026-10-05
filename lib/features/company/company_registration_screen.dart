import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CompanyRegistrationScreen extends StatefulWidget {
  const CompanyRegistrationScreen({super.key});

  @override
  State<CompanyRegistrationScreen> createState() =>
      _CompanyRegistrationScreenState();
}

class _CompanyRegistrationScreenState
    extends State<CompanyRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();

  final _companyNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _licenseController = TextEditingController();
  final _addressController = TextEditingController();
  final _managerNameController = TextEditingController();
  final _managerPhoneController = TextEditingController();

  String selectedCity = 'الخرطوم';
  String selectedActivity = 'نقل الركاب';
  bool licenseUploaded = false;
  bool commercialDocumentUploaded = false;
  bool agreementAccepted = false;

  final List<String> cities = [
    'الخرطوم',
    'بحري',
    'أم درمان',
    'شندي',
    'عطبرة',
    'بورتسودان',
    'مروي',
    'كريمة',
    'مدني',
    'القضارف',
    'كسلا',
    'سنار',
  ];

  final List<String> activities = [
    'نقل الركاب',
    'الليموزين بين المدن',
    'الباصات والحافلات',
    'نقل الطرود',
    'نقل الركاب والطرود',
  ];

  @override
  void dispose() {
    _companyNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _licenseController.dispose();
    _addressController.dispose();
    _managerNameController.dispose();
    _managerPhoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF121212),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'تسجيل شركة نقل',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(18, 8, 18, 30),
            children: [
              _buildHeader(),
              const SizedBox(height: 24),
              _buildSectionTitle(
                'بيانات الشركة',
                Icons.business_outlined,
              ),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _companyNameController,
                label: 'اسم الشركة',
                hint: 'أدخل اسم شركة النقل',
                icon: Icons.business_outlined,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'يرجى إدخال اسم الشركة';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _phoneController,
                label: 'رقم الهاتف',
                hint: '09XXXXXXXX',
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'يرجى إدخال رقم الهاتف';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _emailController,
                label: 'البريد الإلكتروني',
                hint: 'example@email.com',
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 12),
              _buildDropdown(
                label: 'مدينة الشركة',
                value: selectedCity,
                items: cities,
                icon: Icons.location_city_outlined,
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      selectedCity = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _addressController,
                label: 'عنوان الشركة',
                hint: 'أدخل العنوان بالتفصيل',
                icon: Icons.location_on_outlined,
                maxLines: 2,
              ),
              const SizedBox(height: 24),
              _buildSectionTitle(
                'نشاط الشركة',
                Icons.directions_bus_outlined,
              ),
              const SizedBox(height: 12),
              _buildDropdown(
                label: 'نوع النشاط',
                value: selectedActivity,
                items: activities,
                icon: Icons.category_outlined,
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      selectedActivity = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _licenseController,
                label: 'رقم ترخيص الشركة',
                hint: 'أدخل رقم الترخيص',
                icon: Icons.badge_outlined,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'يرجى إدخال رقم الترخيص';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              _buildSectionTitle(
                'بيانات المسؤول',
                Icons.person_outline,
              ),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _managerNameController,
                label: 'اسم المسؤول',
                hint: 'الاسم الكامل للمسؤول',
                icon: Icons.person_outline,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'يرجى إدخال اسم المسؤول';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _managerPhoneController,
                label: 'هاتف المسؤول',
                hint: '09XXXXXXXX',
                icon: Icons.phone_android_outlined,
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'يرجى إدخال هاتف المسؤول';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              _buildSectionTitle(
                'مستندات الشركة',
                Icons.folder_open_outlined,
              ),
              const SizedBox(height: 12),
              _buildDocumentCard(
                title: 'رخصة الشركة',
                subtitle: 'صورة واضحة وسارية المفعول',
                icon: Icons.description_outlined,
                uploaded: licenseUploaded,
                onTap: () {
                  setState(() {
                    licenseUploaded = !licenseUploaded;
                  });
                },
              ),
              const SizedBox(height: 10),
              _buildDocumentCard(
                title: 'السجل التجاري',
                subtitle: 'صورة من السجل التجاري للشركة',
                icon: Icons.article_outlined,
                uploaded: commercialDocumentUploaded,
                onTap: () {
                  setState(() {
                    commercialDocumentUploaded =
                        !commercialDocumentUploaded;
                  });
                },
              ),
              const SizedBox(height: 24),
              _buildAgreement(),
              const SizedBox(height: 24),
              SizedBox(
                height: 54,
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitRegistration,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFA3E635),
                    foregroundColor: Colors.black,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: const Text(
                    'إرسال طلب التسجيل',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'سيتم مراجعة بيانات الشركة والمستندات قبل تفعيل الحساب.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white38,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFA3E635).withValues(alpha: 0.18),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: const Color(0xFFA3E635).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(17),
            ),
            child: const Icon(
              Icons.business_center_outlined,
              color: Color(0xFFA3E635),
              size: 30,
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'انضم إلى شبكة واصل',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'سجّل شركتك لإدارة المركبات والسائقين والرحلات.',
                  style: TextStyle(
                    color: Colors.white54,
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

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          color: const Color(0xFFA3E635),
          size: 21,
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      maxLines: maxLines,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 14,
      ),
      cursorColor: const Color(0xFFA3E635),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: const TextStyle(
          color: Colors.white54,
        ),
        hintStyle: const TextStyle(
          color: Colors.white30,
          fontSize: 13,
        ),
        prefixIcon: Icon(
          icon,
          color: Colors.white54,
        ),
        filled: true,
        fillColor: const Color(0xFF1E1E1E),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: Colors.white.withValues(alpha: 0.05),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: Color(0xFFA3E635),
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: Colors.redAccent,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: Colors.redAccent,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 16,
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    required IconData icon,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      onChanged: onChanged,
      dropdownColor: const Color(0xFF252525),
      style: const TextStyle(
        color: Colors.white,
        fontSize: 14,
      ),
      icon: const Icon(
        Icons.keyboard_arrow_down_rounded,
        color: Colors.white54,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(
          color: Colors.white54,
        ),
        prefixIcon: Icon(
          icon,
          color: Colors.white54,
        ),
        filled: true,
        fillColor: const Color(0xFF1E1E1E),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: Colors.white.withValues(alpha: 0.05),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: Color(0xFFA3E635),
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 16,
        ),
      ),
      items: items
          .map(
            (item) => DropdownMenuItem<String>(
              value: item,
              child: Text(item),
            ),
          )
          .toList(),
    );
  }

  Widget _buildDocumentCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool uploaded,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: uploaded
                ? const Color(0xFFA3E635).withValues(alpha: 0.35)
                : Colors.white.withValues(alpha: 0.05),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: uploaded
                    ? const Color(0xFFA3E635).withValues(alpha: 0.12)
                    : Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(
                uploaded ? Icons.check_rounded : icon,
                color: uploaded
                    ? const Color(0xFFA3E635)
                    : Colors.white54,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    uploaded ? 'تم إرفاق المستند' : subtitle,
                    style: TextStyle(
                      color: uploaded
                          ? const Color(0xFFA3E635)
                          : Colors.white54,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              uploaded
                  ? Icons.check_circle_rounded
                  : Icons.add_circle_outline_rounded,
              color: uploaded
                  ? const Color(0xFFA3E635)
                  : Colors.white54,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAgreement() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Checkbox(
            value: agreementAccepted,
            activeColor: const Color(0xFFA3E635),
            checkColor: Colors.black,
            side: const BorderSide(
              color: Colors.white54,
            ),
            onChanged: (value) {
              setState(() {
                agreementAccepted = value ?? false;
              });
            },
          ),
          const Expanded(
            child: Padding(
              padding: EdgeInsets.only(top: 13),
              child: Text(
                'أوافق على شروط وأحكام واصل وسياسة تشغيل شركات النقل، وأقر بصحة البيانات والمستندات المقدمة.',
                style: TextStyle(
                  color: Colors.white60,
                  fontSize: 11,
                  height: 1.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _submitRegistration() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (!licenseUploaded || !commercialDocumentUploaded) {
      _showMessage(
        'يرجى إرفاق جميع مستندات الشركة المطلوبة.',
        isError: true,
      );
      return;
    }

    if (!agreementAccepted) {
      _showMessage(
        'يرجى الموافقة على الشروط والأحكام.',
        isError: true,
      );
      return;
    }

    _showSuccessDialog();
  }

  void _showMessage(
    String message, {
    bool isError = false,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          textAlign: TextAlign.right,
        ),
        backgroundColor:
            isError ? Colors.redAccent : const Color(0xFFA3E635),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSuccessDialog() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF1E1E1E),
      isDismissible: false,
      enableDrag: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(28),
        ),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 25, 24, 30),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    color: const Color(0xFFA3E635).withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    color: Color(0xFFA3E635),
                    size: 40,
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  'تم إرسال طلب التسجيل',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'تم استلام بيانات شركتك بنجاح. سيقوم فريق واصل بمراجعة الطلب والمستندات، وبعد الموافقة ستتمكن من إدارة السائقين والمركبات والرحلات.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 12,
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 22),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      context.go('/company-home');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFA3E635),
                      foregroundColor: Colors.black,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      'الانتقال إلى لوحة الشركة',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/localization/app_text.dart';

class SendParcelScreen extends StatefulWidget {
  const SendParcelScreen({super.key});

  @override
  State<SendParcelScreen> createState() => _SendParcelScreenState();
}

class _SendParcelScreenState extends State<SendParcelScreen> {
  final Color lime = const Color(0xFFA3E635);

  final TextEditingController senderController = TextEditingController();
  final TextEditingController receiverController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController descriptionController =
      TextEditingController();

  String fromCity = 'الخرطوم';
  String toCity = 'شندي';
  String parcelType = AppText.t('طرد عادي');
  String deliveryType = AppText.t('مع رحلة مسافر');

  @override
  void dispose() {
    senderController.dispose();
    receiverController.dispose();
    phoneController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: AppColors.background,
    appBar: AppBar(
      backgroundColor: AppColors.background,
      elevation: 0,
      title: Text(
        AppText.t('إرسال طرد'),
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
            _buildHeader(),
            const SizedBox(height: 22),
            _sectionTitle(AppText.t('مسار الطرد')),
            const SizedBox(height: 12),
            _buildRouteCard(),
            const SizedBox(height: 22),
            _sectionTitle(AppText.t('بيانات المستلم')),
            const SizedBox(height: 12),
            _buildReceiverCard(),
            const SizedBox(height: 22),
            _sectionTitle(AppText.t('تفاصيل الطرد')),
            const SizedBox(height: 12),
            _buildParcelDetails(),
            const SizedBox(height: 22),
            _sectionTitle(AppText.t('طريقة التوصيل')),
            const SizedBox(height: 12),
            _buildDeliveryOptions(),
            const SizedBox(height: 24),
            _buildPriceCard(),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _createParcel,
                style: ElevatedButton.styleFrom(
                  backgroundColor: lime,
                  foregroundColor: Colors.black,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(17),
                  ),
                ),
                child: Text(
                  AppText.t('متابعة وإرسال الطلب'),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
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
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: lime,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.inventory_2_outlined,
              color: Colors.black,
              size: 28,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppText.t('أرسل طردك بأمان'),
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  AppText.t('نوصله مع الرحلات المتجهة إلى مدينتك'),
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
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
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          _cityDropdown(
            label: 'من',
            value: fromCity,
            icon: Icons.my_location,
            onChanged: (value) {
              if (value == null) return;
              setState(() {
                fromCity = value;
              });
            },
          ),
          const SizedBox(height: 14),
          _cityDropdown(
            label: 'إلى',
            value: toCity,
            icon: Icons.location_on,
            onChanged: (value) {
              if (value == null) return;
              setState(() {
                toCity = value;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _cityDropdown({
    required String label,
    required String value,
    required IconData icon,
    required ValueChanged<String?> onChanged,
  }) {
    const cities = [
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
      'ربك',
      'الدويم',
    ];

    return Row(
      children: [
        Icon(
          icon,
          color: lime,
          size: 22,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: DropdownButtonFormField<String>(
            initialValue: value,
            dropdownColor: const Color(0xFF242424),
            decoration: InputDecoration(
              labelText: label,
              labelStyle: TextStyle(
                color: Colors.grey.shade500,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: const Color(0xFF242424),
            ),
            items: cities
                .map(
                  (city) => DropdownMenuItem<String>(
                    value: city,
                    child: Text(AppText.t(city)),
                  ),
                )
                .toList(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildReceiverCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          _textField(
            controller: senderController,
            label: AppText.t('اسم المرسل'),
            hint: AppText.t('اكتب اسم المرسل'),
            icon: Icons.person_outline,
          ),
          const SizedBox(height: 12),
          _textField(
            controller: receiverController,
            label: AppText.t('اسم المستلم'),
            hint: AppText.t('اكتب اسم المستلم'),
            icon: Icons.person,
          ),
          const SizedBox(height: 12),
          _textField(
            controller: phoneController,
            label: AppText.t('رقم هاتف المستلم'),
            hint: AppText.t('مثال: 09xxxxxxxx'),
            icon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
          ),
        ],
      ),
    );
  }

  Widget _textField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(
        color: Colors.white,
      ),
      decoration: InputDecoration(
        prefixIcon: Icon(
          icon,
          color: lime,
        ),
        labelText: label,
        labelStyle: TextStyle(
          color: Colors.grey.shade500,
        ),
        hintText: hint,
        hintStyle: TextStyle(
          color: Colors.grey.shade700,
        ),
        filled: true,
        fillColor: const Color(0xFF242424),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildParcelDetails() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          DropdownButtonFormField<String>(
            initialValue: parcelType,
            dropdownColor: const Color(0xFF242424),
            decoration: InputDecoration(
              prefixIcon: Icon(
                Icons.inventory_2_outlined,
                color: lime,
              ),
              labelText: AppText.t('نوع الطرد'),
              labelStyle: TextStyle(
                color: Colors.grey.shade500,
              ),
              filled: true,
              fillColor: const Color(0xFF242424),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
            ),
            items: const [
              DropdownMenuItem(
                value: 'طرد عادي',
                child: Text(AppText.t('طرد عادي')),
              ),
              DropdownMenuItem(
                value: 'مستندات',
                child: Text(AppText.t('مستندات')),
              ),
              DropdownMenuItem(
                value: 'ملابس',
                child: Text(AppText.t('ملابس')),
              ),
              DropdownMenuItem(
                value: 'مواد غذائية',
                child: Text(AppText.t('مواد غذائية')),
              ),
              DropdownMenuItem(
                value: 'أخرى',
                child: Text(AppText.t('أخرى')),
              ),
            ],
            onChanged: (value) {
              if (value == null) return;
              setState(() {
                parcelType = value;
              });
            },
          ),
          const SizedBox(height: 12),
          TextField(
            controller: descriptionController,
            maxLines: 3,
            style: const TextStyle(
              color: Colors.white,
            ),
            decoration: InputDecoration(
              prefixIcon: const Padding(
                padding: EdgeInsets.only(
                  bottom: 42,
                ),
                child: Icon(
                  Icons.notes_outlined,
                ),
              ),
              prefixIconColor: lime,
              labelText: AppText.t('وصف الطرد'),
              labelStyle: TextStyle(
                color: Colors.grey.shade500,
              ),
              hintText: AppText.t('مثلاً: صندوق ملابس صغير'),
              hintStyle: TextStyle(
                color: Colors.grey.shade700,
              ),
              filled: true,
              fillColor: const Color(0xFF242424),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryOptions() {
    final options = [
      {
        'title': 'مع رحلة مسافر',
        'subtitle': 'أوفر وأسرع عند توفر رحلة',
        'icon': Icons.directions_car_outlined,
      },
      {
        'title': 'توصيل مخصص',
        'subtitle': 'إرسال مباشر للطرد',
        'icon': Icons.local_shipping_outlined,
      },
    ];

    return Column(
      children: options.map((option) {
        final title = option['title'] as String;
        final selected = deliveryType == title;

        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: InkWell(
            onTap: () {
              setState(() {
                deliveryType = title;
              });
            },
            borderRadius: BorderRadius.circular(17),
            child: Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: selected
                    ? lime.withValues(alpha: 0.10)
                    : const Color(0xFF1B1B1B),
                borderRadius: BorderRadius.circular(17),
                border: Border.all(
                  color: selected
                      ? lime
                      : Colors.white.withValues(alpha: 0.06),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    option['icon'] as IconData,
                    color: selected
                        ? lime
                        : Colors.grey.shade500,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppText.t(title),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: selected
                                ? lime
                                : Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          AppText.t(option['subtitle'] as String),
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    selected
                        ? Icons.check_circle
                        : Icons.radio_button_unchecked,
                    color: selected
                        ? lime
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

  Widget _buildPriceCard() {
    final price = deliveryType == AppText.t('مع رحلة مسافر')
        ? 3500
        : 6500;

    return Container(
      padding: const EdgeInsets.all(19),
      decoration: BoxDecoration(
        color: lime,
        borderRadius: BorderRadius.circular(21),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.payments_outlined,
            color: Colors.black,
            size: 27,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              AppText.t('السعر التقديري'),
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Text(
            '$price جنيه',
            style: const TextStyle(
              color: Colors.black,
              fontSize: 21,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  void _createParcel() {
    if (senderController.text.trim().isEmpty ||
        receiverController.text.trim().isEmpty ||
        phoneController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppText.t('يرجى إكمال بيانات المرسل والمستلم'),
          ),
        ),
      );
      return;
    }

    final trackingId =
        'WAS-${DateTime.now().millisecondsSinceEpoch.toString().substring(6)}';

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(28),
        ),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              20,
              22,
              20,
              28,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.check_circle,
                  color: lime,
                  size: 60,
                ),
                const SizedBox(height: 14),
                Text(
                  AppText.t('تم إنشاء طلب الطرد'),
                  style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  AppText.t('احتفظ برقم التتبع لمتابعة طردك'),
                  style: TextStyle(
                    color: Colors.grey.shade500,
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: lime.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Column(
                    children: [
                      Text(
                        AppText.t('رقم التتبع'),
                        style: TextStyle(
                          color: Colors.grey.shade400,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        trackingId,
                        style: TextStyle(
                          color: lime,
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1,
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
                      Navigator.pop(sheetContext);
                      context.push('/track-parcel');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: lime,
                      foregroundColor: Colors.black,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      AppText.t('متابعة وتتبع الطرد'),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
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
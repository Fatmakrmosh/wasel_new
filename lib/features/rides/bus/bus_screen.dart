import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/localization/app_text.dart';

class BusScreen extends StatefulWidget {
  const BusScreen({super.key});

  @override
  State<BusScreen> createState() => _BusScreenState();
}

class _BusScreenState extends State<BusScreen> {
  String _fromCity = 'الخرطوم';
  String _toCity = 'بورتسودان';
  int _passengers = 1;
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 2));

  final List<String> _cities = [
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

  final List<Map<String, dynamic>> _buses = [
    {
      'company': 'شركة النيل للنقل',
      'bus': 'باص سياحي 45 راكب',
      'departure': '06:00 ص',
      'arrival': '06:00 م',
      'price': '25,000 جنيه',
      'available': 18,
      'rating': '4.7',
      'type': 'VIP',
    },
    {
      'company': 'سودان للسفر',
      'bus': 'باص حديث 50 راكب',
      'departure': '07:30 ص',
      'arrival': '07:30 م',
      'price': '22,000 جنيه',
      'available': 27,
      'rating': '4.5',
      'type': 'مريح',
    },
    {
      'company': 'الطريق السريع',
      'bus': 'باص 40 راكب',
      'departure': '09:00 م',
      'arrival': '09:00 ص',
      'price': '20,000 جنيه',
      'available': 12,
      'rating': '4.6',
      'type': 'اقتصادي',
    },
  ];

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
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
        _selectedDate = picked;
      });
    }
  }

  void _swapCities() {
    setState(() {
      final String oldFrom = _fromCity;
      _fromCity = _toCity;
      _toCity = oldFrom;
    });
  }

  void _searchBuses() {
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    enableDrag: true,
    isDismissible: true,
    useSafeArea: true,
    builder: (context) {
      return DraggableScrollableSheet(
        initialChildSize: 0.72,
        minChildSize: 0.45,
        maxChildSize: 0.94,
        expand: false,
        snap: true,
        snapSizes: const [
          0.72,
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
                18,
                12,
                18,
                30,
              ),
              children: [
                Center(
                  child: _buildSheetHandle(),
                ),
                SizedBox(height: 18),

                Text(
                  AppText.t('الباصات المتاحة'),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                SizedBox(height: 7),

                Text(
                  '$_fromCity ← $_toCity',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),

                SizedBox(height: 18),

                ..._buses.map(
                  (bus) => Padding(
                    padding: const EdgeInsets.only(
                      bottom: 12,
                    ),
                    child: _buildBusCard(bus),
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

  void _showBookingConfirmation(Map<String, dynamic> bus) {
    final int totalPrice = int.tryParse(
          bus['price']
              .toString()
              .replaceAll(',', '')
              .replaceAll(' جنيه', ''),
        ) ??
        0;

    final int totalAmount = totalPrice * _passengers;

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      enableDrag: true,
      isDismissible: true,
      useSafeArea: true,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.72,
          minChildSize: 0.45,
          maxChildSize: 0.94,
          expand: false,
          snap: true,
          snapSizes: const [0.72, 0.94],
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
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 30),
                children: [
                  _buildSheetHandle(),
                  SizedBox(height: 20),
                  Row(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: AppColors.lime.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.directions_bus_outlined,
                          color: AppColors.lime,
                          size: 28,
                        ),
                      ),
                      SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          AppText.t('تأكيد حجز الباص'),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 21,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    AppText.t('راجع تفاصيل الرحلة قبل الانتقال إلى الدفع.'),
                    style: TextStyle(
                      color: AppColors.muted,
                      fontSize: 13,
                    ),
                  ),
                  SizedBox(height: 22),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF252525),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Column(
                      children: [
                        _summaryRow(
                          'الشركة',
                          bus['company'].toString(),
                        ),
                        _summaryRow(
                          'الباص',
                          bus['bus'].toString(),
                        ),
                        _summaryRow(
                          'المسار',
                          '$_fromCity ← $_toCity',
                        ),
                        _summaryRow(
                          AppText.t('تاريخ السفر'),
                          _formattedDate(),
                        ),
                        _summaryRow(
                          'وقت الانطلاق',
                          bus['departure'].toString(),
                        ),
                        _summaryRow(
                          'وقت الوصول',
                          bus['arrival'].toString(),
                        ),
                        _summaryRow(
                          'عدد المقاعد',
                          '$_passengers',
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 18),
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: AppColors.lime.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: AppColors.lime.withValues(alpha: 0.18),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.payments_outlined,
                          color: AppColors.lime,
                          size: 27,
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            AppText.t('إجمالي المبلغ'),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Text(
                          AppText.t('$totalAmount جنيه'),
                          style: const TextStyle(
                            color: AppColors.lime,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _showPaymentMethod(
                          bus,
                          totalAmount,
                        );
                      },
                      icon: Icon(Icons.arrow_back_rounded),
                      label: Text(
                        AppText.t('المتابعة إلى الدفع'),
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.lime,
                        foregroundColor: Colors.black,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        AppText.t('إلغاء'),
                        style: TextStyle(
                          color: AppColors.muted,
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

  void _showPaymentMethod(
    Map<String, dynamic> bus,
    int totalAmount,
  ) {
    String paymentMethod = 'bankak';
    final TextEditingController referenceController =
        TextEditingController();

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      enableDrag: true,
      isDismissible: true,
      useSafeArea: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return DraggableScrollableSheet(
              initialChildSize: 0.68,
              minChildSize: 0.45,
              maxChildSize: 0.92,
              expand: false,
              snap: true,
              snapSizes: const [0.68, 0.92],
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
                      _buildSheetHandle(),
                      SizedBox(height: 20),
                      Row(
                        children: [
                          Icon(
                            Icons.payment_rounded,
                            color: AppColors.lime,
                            size: 28,
                          ),
                          SizedBox(width: 12),
                          Text(
                            AppText.t('طريقة الدفع'),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 21,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Text(
                        AppText.t('اختر الطريقة المناسبة لإتمام الحجز.'),
                        style: TextStyle(
                          color: AppColors.muted,
                          fontSize: 13,
                        ),
                      ),
                      SizedBox(height: 20),
                      _paymentOption(
                        title: AppText.t('بنكك'),
                        subtitle: AppText.t('التحويل إلى حساب WASEL'),
                        icon: Icons.account_balance_rounded,
                        selected: paymentMethod == 'bankak',
                        onTap: () {
                          setSheetState(() {
                            paymentMethod = 'bankak';
                          });
                        },
                      ),
                      SizedBox(height: 12),
                      _paymentOption(
                        title: AppText.t('الدفع نقداً'),
                        subtitle: AppText.t('الدفع في مكتب الشركة'),
                        icon: Icons.money_rounded,
                        selected: paymentMethod == 'cash',
                        onTap: () {
                          setSheetState(() {
                            paymentMethod = 'cash';
                          });
                        },
                      ),
                      SizedBox(height: 20),
                      if (paymentMethod == 'bankak') ...[
                        Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: AppColors.lime.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color:
                                  AppColors.lime.withValues(alpha: 0.18),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                AppText.t('رقم حساب بنكك'),
                                style: TextStyle(
                                  color: AppColors.muted,
                                  fontSize: 13,
                                ),
                              ),
                              SizedBox(height: 8),
                              SelectableText(
                                '9824691',
                                style: TextStyle(
                                  color: AppColors.lime,
                                  fontSize: 25,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.5,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                AppText.t('بعد التحويل أدخل رقم العملية للتأكيد.'),
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 14),
                        TextField(
                          controller: referenceController,
                          keyboardType: TextInputType.text,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            labelText: AppText.t('رقم العملية'),
                            labelStyle: const TextStyle(
                              color: AppColors.muted,
                            ),
                            prefixIcon: Icon(
                              Icons.receipt_long_outlined,
                              color: AppColors.lime,
                            ),
                            filled: true,
                            fillColor: const Color(0xFF252525),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ] else ...[
                        Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: const Color(0xFF252525),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.info_outline_rounded,
                                color: AppColors.lime,
                                size: 26,
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  AppText.t('سيتم تحصيل قيمة الحجز نقداً في مكتب الشركة قبل السفر.'),
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 13,
                                    height: 1.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF252525),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                AppText.t('إجمالي المبلغ'),
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            Text(
                              AppText.t('$totalAmount جنيه'),
                              style: const TextStyle(
                                color: AppColors.lime,
                                fontSize: 19,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 18),
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            if (paymentMethod == 'bankak' &&
                                referenceController.text
                                    .trim()
                                    .isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    AppText.t('أدخل رقم عملية بنكك أولاً'),
                                  ),
                                ),
                              );
                              return;
                            }

                            final String reference =
                                referenceController.text.trim();

                            Navigator.pop(context);

                            _showBookingTicket(
                              bus,
                              totalAmount,
                              paymentMethod,
                              reference,
                            );
                          },
                          icon: Icon(
                            Icons.check_circle_outline_rounded,
                          ),
                          label: Text(
                            AppText.t('تأكيد الدفع والحجز'),
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.lime,
                            foregroundColor: Colors.black,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(
                            AppText.t('رجوع'),
                            style: TextStyle(
                              color: AppColors.muted,
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
      },
    ).whenComplete(referenceController.dispose);
  }

  void _showBookingTicket(
    Map<String, dynamic> bus,
    int totalAmount,
    String paymentMethod,
    String paymentReference,
  ) {
    final int availableSeats =
        int.tryParse(bus['available'].toString()) ?? 1;

    final int seatNumber = 46 - availableSeats;

    final String ticketNumber =
        'WAS-B-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';

    final String bookingNumber =
        'WAS-R-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}';

    final String paymentText =
        paymentMethod == 'bankak' ? AppText.t('بنكك') : 'نقداً في المكتب';

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 24,
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 68,
                  height: 68,
                  decoration: BoxDecoration(
                    color: AppColors.lime.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.confirmation_number_rounded,
                    color: AppColors.lime,
                    size: 36,
                  ),
                ),
                SizedBox(height: 14),
                Text(
                  AppText.t('تم تأكيد الحجز'),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  AppText.t('تم إصدار تذكرتك الإلكترونية بنجاح'),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.muted,
                    fontSize: 13,
                  ),
                ),
                SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: const Color(0xFF252525),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Column(
                    children: [
                      _ticketRow(
                        'رقم التذكرة',
                        ticketNumber,
                        highlight: true,
                      ),
                      _ticketRow(
                        'رقم الحجز',
                        bookingNumber,
                        highlight: true,
                      ),
                      _ticketRow(
                        'الشركة',
                        bus['company'].toString(),
                      ),
                      _ticketRow(
                        'الباص',
                        bus['bus'].toString(),
                      ),
                      _ticketRow(
                        'المسار',
                        '$_fromCity ← $_toCity',
                      ),
                      _ticketRow(
                        AppText.t('تاريخ السفر'),
                        _formattedDate(),
                      ),
                      _ticketRow(
                        'وقت الانطلاق',
                        bus['departure'].toString(),
                      ),
                      _ticketRow(
                        'مكان الانطلاق',
                        _fromCity,
                      ),
                      _ticketRow(
                        'مكان الوصول',
                        _toCity,
                      ),
                      _ticketRow(
                        'رقم المقعد',
                        seatNumber.toString(),
                        highlight: true,
                      ),
                      _ticketRow(
                        AppText.t('طريقة الدفع'),
                        paymentText,
                      ),
                      _ticketRow(
                        'المبلغ',
                        AppText.t('$totalAmount جنيه'),
                        highlight: true,
                      ),
                    ],
                  ),
                ),
                if (paymentMethod == 'bankak' &&
                    paymentReference.isNotEmpty) ...[
                  SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      AppText.t('رقم عملية بنكك: $paymentReference'),
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
                SizedBox(height: 18),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.lime.withValues(alpha: 0.07),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.qr_code_2_rounded,
                        color: AppColors.lime,
                        size: 32,
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          AppText.t('يمكن استخدام رقم التذكرة عند الصعود ومراجعة الحجز.'),
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.lime,
                      foregroundColor: Colors.black,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: Text(
                      AppText.t('تم'),
                      style: TextStyle(
                        fontSize: 15,
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

  Widget _paymentOption({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.lime.withValues(alpha: 0.10)
              : const Color(0xFF252525),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected ? AppColors.lime : Colors.white10,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: selected ? AppColors.lime : Colors.white70,
              size: 28,
            ),
            SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: AppColors.muted,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              selected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_off,
              color: selected ? AppColors.lime : Colors.white38,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSheetHandle() {
    return Center(
      child: Container(
        width: 48,
        height: 5,
        decoration: BoxDecoration(
          color: Colors.white24,
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  String _formattedDate() {
    return '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        title: Text(
          AppText.t('الباصات والحافلات'),
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 8, 18, 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(),
              SizedBox(height: 18),
              _buildRouteCard(),
              SizedBox(height: 14),
              _buildDateCard(),
              SizedBox(height: 14),
              _buildPassengersCard(),
              SizedBox(height: 20),
              _buildSearchButton(),
              SizedBox(height: 20),
              _buildMarketplaceInfo(),
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
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: AppColors.lime.withValues(alpha: 0.18),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: AppColors.lime.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.directions_bus_outlined,
              color: AppColors.lime,
              size: 31,
            ),
          ),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppText.t('رحلات الباصات'),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  AppText.t('احجز مقعدك مع شركات النقل والحافلات المتاحة عبر واصل.'),
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

  Widget _buildRouteCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                AppText.t('مسار الرحلة'),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: _swapCities,
                icon: Icon(
                  Icons.swap_vert,
                  color: AppColors.lime,
                ),
                tooltip: 'تبديل المدن',
              ),
            ],
          ),
          SizedBox(height: 6),
          _citySelector(
            title: AppText.t('من'),
            value: _fromCity,
            icon: Icons.radio_button_checked,
            color: AppColors.lime,
            onChanged: (value) {
              if (value != null && value != _toCity) {
                setState(() {
                  _fromCity = value;
                });
              }
            },
          ),
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: Align(
              alignment: Alignment.centerRight,
              child: Container(
                width: 1,
                height: 22,
                color: Colors.white24,
              ),
            ),
          ),
          _citySelector(
            title: AppText.t('إلى'),
            value: _toCity,
            icon: Icons.location_on,
            color: Colors.white70,
            onChanged: (value) {
              if (value != null && value != _fromCity) {
                setState(() {
                  _toCity = value;
                });
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _citySelector({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required ValueChanged<String?> onChanged,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          color: color,
          size: 19,
        ),
        SizedBox(width: 12),
        SizedBox(
          width: 35,
          child: Text(
            title,
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 12,
            ),
          ),
        ),
        SizedBox(width: 8),
        Expanded(
          child: DropdownButtonFormField<String>(
            initialValue: value,
            dropdownColor: AppColors.surface,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
            iconEnabledColor: AppColors.lime,
            decoration: InputDecoration(
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.zero,
            ),
            items: _cities.map((city) {
              return DropdownMenuItem<String>(
                value: city,
                child: Text(city),
              );
            }).toList(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildDateCard() {
    return GestureDetector(
      onTap: _selectDate,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 15,
        ),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            Container(
              width: 43,
              height: 43,
              decoration: BoxDecoration(
                color: AppColors.lime.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.calendar_month_outlined,
                color: AppColors.lime,
                size: 23,
              ),
            ),
            SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppText.t('تاريخ السفر'),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    AppText.t('اختر تاريخ الرحلة'),
                    style: TextStyle(
                      color: Colors.white38,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              _formattedDate(),
              style: const TextStyle(
                color: AppColors.lime,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(width: 5),
            Icon(
              Icons.chevron_left,
              color: Colors.white38,
              size: 21,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPassengersCard() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 15,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            width: 43,
            height: 43,
            decoration: BoxDecoration(
              color: AppColors.lime.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.people_outline,
              color: AppColors.lime,
              size: 23,
            ),
          ),
          SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppText.t('عدد المسافرين'),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  AppText.t('اختر عدد المقاعد'),
                  style: TextStyle(
                    color: Colors.white38,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          _counterButton(
            icon: Icons.remove,
            enabled: _passengers > 1,
            onTap: () {
              if (_passengers > 1) {
                setState(() {
                  _passengers--;
                });
              }
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Text(
              '$_passengers',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          _counterButton(
            icon: Icons.add,
            enabled: _passengers < 10,
            onTap: () {
              if (_passengers < 10) {
                setState(() {
                  _passengers++;
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
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: enabled
              ? const Color(0xFF2A2A2A)
              : const Color(0xFF222222),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          size: 18,
          color: enabled ? Colors.white : Colors.white24,
        ),
      ),
    );
  }

  Widget _buildSearchButton() {
    return SizedBox(
      height: 54,
      child: ElevatedButton.icon(
        onPressed: _searchBuses,
        icon: Icon(Icons.search),
        label: Text(
          AppText.t('البحث عن الباصات'),
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.lime,
          foregroundColor: Colors.black,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
      ),
    );
  }

  Widget _buildMarketplaceInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.storefront_outlined,
            color: AppColors.lime,
            size: 22,
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              AppText.t('سوق الناقلين في واصل يتيح لشركات النقل عرض رحلاتها ومقاعدها. وإذا لم يكتمل الحد الأدنى للمقاعد، يمكن للنظام اقتراح ناقل أو رحلة بديلة.'),
              style: TextStyle(
                color: Colors.white54,
                fontSize: 12,
                height: 1.6,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBusCard(Map<String, dynamic> bus) {
    return GestureDetector(
      onTap: () => _showBookingConfirmation(bus),
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: const Color(0xFF252525),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.06),
          ),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 47,
                  height: 47,
                  decoration: BoxDecoration(
                    color: AppColors.lime.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Icon(
                    Icons.directions_bus_outlined,
                    color: AppColors.lime,
                    size: 25,
                  ),
                ),
                SizedBox(width: 11),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        bus['company'].toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        bus['bus'].toString(),
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.lime.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    bus['type'].toString(),
                    style: const TextStyle(
                      color: AppColors.lime,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 15),
            Row(
              children: [
                _timeColumn(
                  bus['departure'].toString(),
                  'الانطلاق',
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Row(
                      children: [
                        Expanded(
                          child: Divider(
                            color: Colors.white24,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 5),
                          child: Icon(
                            Icons.arrow_back,
                            color: AppColors.lime,
                            size: 18,
                          ),
                        ),
                        Expanded(
                          child: Divider(
                            color: Colors.white24,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                _timeColumn(
                  bus['arrival'].toString(),
                  'الوصول',
                  alignEnd: true,
                ),
              ],
            ),
            SizedBox(height: 14),
            const Divider(
              color: Colors.white10,
              height: 1,
            ),
            SizedBox(height: 13),
            Row(
              children: [
                Icon(
                  Icons.event_seat_outlined,
                  color: Colors.white54,
                  size: 17,
                ),
                SizedBox(width: 6),
                Text(
                  '${bus['available']} مقاعد متاحة',
                  style: const TextStyle(
                    color: Colors.white60,
                    fontSize: 11,
                  ),
                ),
                SizedBox(width: 12),
                Icon(
                  Icons.star,
                  color: Colors.amber,
                  size: 16,
                ),
                SizedBox(width: 4),
                Text(
                  bus['rating'].toString(),
                  style: const TextStyle(
                    color: Colors.white60,
                    fontSize: 11,
                  ),
                ),
                const Spacer(),
                Text(
                  bus['price'].toString(),
                  style: const TextStyle(
                    color: AppColors.lime,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(width: 5),
                Icon(
                  Icons.chevron_left,
                  color: Colors.white38,
                  size: 20,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _timeColumn(
    String time,
    String label, {
    bool alignEnd = false,
  }) {
    return Column(
      crossAxisAlignment:
          alignEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(
          time,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white38,
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  Widget _summaryRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 13,
            ),
          ),
          const Spacer(),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _ticketRow(
    String title,
    String value, {
    bool highlight = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: AppColors.muted,
                fontSize: 12,
              ),
            ),
          ),
          SizedBox(width: 12),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(
                color: highlight
                    ? AppColors.lime
                    : Colors.white,
                fontSize: highlight ? 13 : 12,
                fontWeight: highlight
                    ? FontWeight.bold
                    : FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
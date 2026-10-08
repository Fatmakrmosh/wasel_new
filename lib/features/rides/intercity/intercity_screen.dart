import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/localization/app_text.dart';
import '../../../core/localization/app_locale.dart';

class IntercityScreen extends StatefulWidget {
  const IntercityScreen({super.key});

  @override
  State<IntercityScreen> createState() => _IntercityScreenState();
}

class _IntercityScreenState extends State<IntercityScreen> {
  String _fromCity = 'الخرطوم';
  String _toCity = 'شندي';
  int _passengers = 1;
  String? _selectedVehicleType;

  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));

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

  final List<Map<String, dynamic>> _vehicleTypes = [
    {
      'name': 'ليموزين',
      'subtitle': 'رحلات مريحة بعدد مقاعد محدود',
      'icon': Icons.directions_car_outlined,
      'capacity': 4,
    },
    {
      'name': 'ليموزين فاخر',
      'subtitle': 'راحة وفخامة للرحلات بين المدن',
      'icon': Icons.airline_seat_recline_extra,
      'capacity': 4,
    },
    {
      'name': 'بوكسي سنقل',
      'subtitle': 'ركاب أو إيجار كامل',
      'icon': Icons.local_shipping_outlined,
      'capacity': 5,
    },
    {
      'name': 'بوكسي دبل كاب',
      'subtitle': 'رحلات ركاب أو إيجار كامل',
      'icon': Icons.fire_truck_outlined,
      'capacity': 7,
    },
    {
      'name': 'شريحة',
      'subtitle': 'رحلات جماعية ومقاعد متعددة',
      'icon': Icons.airport_shuttle_outlined,
      'capacity': 17,
    },
    {
      'name': 'باص',
      'subtitle': 'رحلات جماعية بعدد مقاعد كبير',
      'icon': Icons.directions_bus_outlined,
      'capacity': 45,
    },
    {
      'name': 'دفار',
      'subtitle': 'نقل البضائع والحمولات',
      'icon': Icons.local_shipping,
      'capacity': 0,
    },
  ];

  final List<Map<String, dynamic>> _activeTrips = [
    {
      'vehicle': 'ليموزين',
      'departure': '07:00 ص',
      'arrival': '10:30 ص',
      'capacity': 4,
      'booked': 2,
      'ticketPrice': 22000,
      'rentalPrice': 85000,
      'rating': '4.8',
    },
    {
      'vehicle': 'ليموزين فاخر',
      'departure': '09:00 ص',
      'arrival': '12:30 م',
      'capacity': 4,
      'booked': 1,
      'ticketPrice': 30000,
      'rentalPrice': 120000,
      'rating': '4.9',
    },
    {
      'vehicle': 'بوكسي سنقل',
      'departure': '08:00 ص',
      'arrival': '11:30 ص',
      'capacity': 5,
      'booked': 3,
      'ticketPrice': 18000,
      'rentalPrice': 90000,
      'rating': '4.6',
    },
    {
      'vehicle': 'بوكسي دبل كاب',
      'departure': '10:00 ص',
      'arrival': '01:30 م',
      'capacity': 7,
      'booked': 4,
      'ticketPrice': 17000,
      'rentalPrice': 95000,
      'rating': '4.7',
    },
    {
      'vehicle': 'شريحة',
      'departure': '07:30 ص',
      'arrival': '11:00 ص',
      'capacity': 17,
      'booked': 14,
      'ticketPrice': 15000,
      'rentalPrice': 210000,
      'rating': '4.8',
    },
    {
      'vehicle': 'شريحة',
      'departure': '02:00 م',
      'arrival': '05:30 م',
      'capacity': 17,
      'booked': 8,
      'ticketPrice': 15000,
      'rentalPrice': 210000,
      'rating': '4.7',
    },
    {
      'vehicle': 'باص',
      'departure': '06:30 ص',
      'arrival': '11:00 ص',
      'capacity': 45,
      'booked': 31,
      'ticketPrice': 12000,
      'rentalPrice': 450000,
      'rating': '4.8',
    },
  ];

  final TextEditingController _cargoTypeController =
      TextEditingController();
  final TextEditingController _cargoDescriptionController =
      TextEditingController();
  final TextEditingController _quantityController =
      TextEditingController();
  final TextEditingController _weightController =
      TextEditingController();
  final TextEditingController _volumeController =
      TextEditingController();
  final TextEditingController _senderController =
      TextEditingController();
  final TextEditingController _recipientController =
      TextEditingController();
  final TextEditingController _notesController =
      TextEditingController();

  bool _acceptedCargoUndertaking = false;

  @override
  void dispose() {
    _cargoTypeController.dispose();
    _cargoDescriptionController.dispose();
    _quantityController.dispose();
    _weightController.dispose();
    _volumeController.dispose();
    _senderController.dispose();
    _recipientController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(
        const Duration(days: 90),
      ),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.lime,
              onPrimary: Colors.black,
              surface: Color(0xFF1C1C1C),
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

  void _showRouteTrips() {
    if (_selectedVehicleType == 'دفار') {
      _showCargoForm();
      return;
    }

    if (_selectedVehicleType == null) {
      _showVehicleTypesSheet();
      return;
    }

    _showTripsForVehicle(_selectedVehicleType!);
  }

  void _showVehicleTypesSheet() {
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
          snapSizes: const [0.70, 0.94],
          builder: (context, scrollController) {
            return _sheetContainer(
              controller: scrollController,
              children: [
                _sheetHandle(),
                SizedBox(height: 18),
                Text(AppText.t('اختر نوع المركبة'),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  '${_localizedCityName(_fromCity)} ← ${_localizedCityName(_toCity)}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.lime,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 20),
                ..._vehicleTypes.map(
                  (vehicle) => Padding(
                    padding: const EdgeInsets.only(bottom: 11),
                    child: _vehicleTypeCard(
                      vehicle,
                      compact: false,
                      onTap: () {
                        Navigator.pop(context);
                        final String name = vehicle['name'] as String;

                        setState(() {
                          _selectedVehicleType = name;
                        });

                        if (name == 'دفار') {
                          _showCargoForm();
                        } else {
                          _showTripsForVehicle(name);
                        }
                      },
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showTripsForVehicle(String vehicleType) {
    final List<Map<String, dynamic>> trips = _activeTrips
        .where(
          (trip) => trip['vehicle'] == vehicleType,
        )
        .where(
          (trip) =>
              (trip['capacity'] as int) - (trip['booked'] as int) > 0,
        )
        .toList();

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
            return _sheetContainer(
              controller: scrollController,
              children: [
                _sheetHandle(),
                SizedBox(height: 18),
                Text(
                  _localizedVehicleName(vehicleType),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  '${_localizedCityName(_fromCity)} ← ${_localizedCityName(_toCity)}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.lime,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 8),
                Text(AppText.t('اختر رحلة قائمة للحجز، وسيتم تحديث المقاعد المتبقية تلقائياً.'),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 12,
                  ),
                ),
                SizedBox(height: 18),
                if (trips.isEmpty)
                  _emptyTripsCard()
                else
                  ...trips.map(
                    (trip) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildActiveTripCard(trip),
                    ),
                  ),
              ],
            );
          },
        );
      },
    );
  }

  void _showBookingOptions(Map<String, dynamic> trip) {
    Navigator.pop(context);

    String serviceType = 'قطع تذكرة';
    String paymentMethod = 'بنكك';

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
            final int ticketPrice = trip['ticketPrice'] as int;
            final int rentalPrice = trip['rentalPrice'] as int;
            final int amount = serviceType == 'قطع تذكرة'
                ? ticketPrice * _passengers
                : rentalPrice;

            return DraggableScrollableSheet(
              initialChildSize: 0.78,
              minChildSize: 0.50,
              maxChildSize: 0.94,
              expand: false,
              snap: true,
              snapSizes: const [0.78, 0.94],
              builder: (context, scrollController) {
                return _sheetContainer(
                  controller: scrollController,
                  children: [
                    _sheetHandle(),
                    SizedBox(height: 18),
                    Text(AppText.t('إتمام الحجز'),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 18),
                    _routeSummaryCard(trip),
                    SizedBox(height: 18),
                    _sectionTitle(AppText.t('نوع الخدمة'),
                      Icons.miscellaneous_services_outlined,
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: _choiceCard(
                            title: AppText.t('قطع تذكرة'),
                            subtitle: AppText.t('حجز مقعد'),
                            icon: Icons.airline_seat_recline_normal,
                            selected: serviceType == 'قطع تذكرة',
                            onTap: () {
                              setSheetState(() {
                                serviceType = 'قطع تذكرة';
                              });
                            },
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: _choiceCard(
                            title: AppText.t('إيجار كامل'),
                            subtitle: AppText.t('المركبة كاملة'),
                            icon: Icons.directions_car_filled_outlined,
                            selected: serviceType == 'إيجار كامل',
                            onTap: () {
                              setSheetState(() {
                                serviceType = 'إيجار كامل';
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 18),
                    if (serviceType == 'قطع تذكرة') ...[
                      _summaryRow(AppText.t('عدد المقاعد'),
                        '$_passengers',
                      ),
                      SizedBox(height: 4),
                    ],
                    _summaryRow(AppText.t('المبلغ'),
                      _formatMoney(amount),
                    ),
                    SizedBox(height: 18),
                    _sectionTitle(AppText.t('طريقة الدفع'),
                      Icons.payments_outlined,
                    ),
                    SizedBox(height: 10),
                    _paymentCard(
                      title: AppText.t('بنكك'),
                      subtitle: AppText.t('رقم الحساب: 9824691'),
                      icon: Icons.account_balance_wallet_outlined,
                      selected: paymentMethod == 'بنكك',
                      onTap: () {
                        setSheetState(() {
                          paymentMethod = 'بنكك';
                        });
                      },
                    ),
                    SizedBox(height: 10),
                    _paymentCard(
                      title: AppText.t('نقداً في المكتب'),
                      subtitle: AppText.t('الدفع نقداً لدى مكتب واصل'),
                      icon: Icons.storefront_outlined,
                      selected: paymentMethod == 'نقداً في المكتب',
                      onTap: () {
                        setSheetState(() {
                          paymentMethod = 'نقداً في المكتب';
                        });
                      },
                    ),
                    SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);

                          _showElectronicTicket(
                            trip: trip,
                            serviceType: serviceType,
                            paymentMethod: paymentMethod,
                            amount: amount,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.lime,
                          foregroundColor: Colors.black,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        child: Text(AppText.t('تأكيد وإصدار التذكرة الإلكترونية'),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  void _showElectronicTicket({
    required Map<String, dynamic> trip,
    required String serviceType,
    required String paymentMethod,
    required int amount,
  }) {
    final String ticketNumber =
        'WAS-T-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}';

    final String bookingNumber =
        'WAS-B-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          contentPadding: const EdgeInsets.fromLTRB(
            18,
            22,
            18,
            18,
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 62,
                  height: 62,
                  decoration: BoxDecoration(
                    color: AppColors.lime.withValues(
                      alpha: 0.12,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.confirmation_number_outlined,
                    color: AppColors.lime,
                    size: 32,
                  ),
                ),
                SizedBox(height: 12),
                Text(AppText.t('التذكرة الإلكترونية'),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(AppText.t('تم تأكيد الحجز وإصدار التذكرة'),
                  style: TextStyle(
                    color: AppColors.lime,
                    fontSize: 12,
                  ),
                ),
                SizedBox(height: 18),
                _ticketLogo(),
                SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: const Color(0xFF252525),
                    borderRadius: BorderRadius.circular(17),
                    border: Border.all(
                      color: Colors.white.withValues(
                        alpha: 0.06,
                      ),
                    ),
                  ),
                  child: Column(
                    children: [
                      _ticketRow(
                        AppText.t('رقم التذكرة'),
                        ticketNumber,
                      ),
                      _ticketRow(
                        AppText.t('رقم الحجز'),
                        bookingNumber,
                      ),
                      _ticketRow(
                        AppText.t('المسافر'),
                        AppText.t('مسافر واصل'),
                      ),
                      _ticketRow(
                        AppText.t('من'),
                        _localizedCityName(_fromCity),
                      ),
                      _ticketRow(
                        AppText.t('إلى'),
                        _localizedCityName(_toCity),
                      ),
                      _ticketRow(
                        AppText.t('التاريخ'),
                        '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                      ),
                      _ticketRow(
                        AppText.t('الانطلاق'),
                        _localizedTime(trip['departure'].toString()),
                      ),
                      _ticketRow(
                        AppText.t('المركبة'),
                        _localizedVehicleName(trip['vehicle'].toString()),
                      ),
                      _ticketRow(
                        AppText.t('نوع الخدمة'),
                        serviceType,
                      ),
                      if (serviceType == 'قطع تذكرة')
                        _ticketRow(
                          AppText.t('عدد المقاعد'),
                          '$_passengers',
                        ),
                      _ticketRow(
                        AppText.t('المبلغ'),
                        _formatMoney(amount),
                      ),
                      _ticketRow(
                        AppText.t('طريقة الدفع'),
                        paymentMethod,
                      ),
                      _ticketRow(
                        AppText.t('حالة الدفع'),
                        paymentMethod == 'بنكك'
                            ? AppText.t('تم اختيار الدفع عبر بنكك')
                            : AppText.t('الدفع نقداً في المكتب'),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 15),
                Container(
                  width: 105,
                  height: 105,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    Icons.qr_code_2,
                    color: Colors.black,
                    size: 78,
                  ),
                ),
                SizedBox(height: 8),
                Text(AppText.t('رمز التحقق الإلكتروني'),
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 10,
                  ),
                ),
                SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.lime,
                      foregroundColor: Colors.black,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(13),
                      ),
                    ),
                    child: Text(AppText.t('تم'),
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

  void _showCargoForm() {
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
              initialChildSize: 0.82,
              minChildSize: 0.50,
              maxChildSize: 0.96,
              expand: false,
              snap: true,
              snapSizes: const [0.82, 0.96],
              builder: (context, scrollController) {
                return _sheetContainer(
                  controller: scrollController,
                  children: [
                    _sheetHandle(),
                    SizedBox(height: 18),
                    Text(AppText.t('نقل حمولة بالدفار'),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      '${_localizedCityName(_fromCity)} ← ${_localizedCityName(_toCity)}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: AppColors.lime,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 18),
                    _formField(
                      controller: _cargoTypeController,
                      label: AppText.t('نوع الحمولة'),
                      hint: 'مثال: أثاث، مواد بناء، بضاعة',
                      icon: Icons.category_outlined,
                    ),
                    SizedBox(height: 12),
                    _formField(
                      controller: _cargoDescriptionController,
                      label: AppText.t('وصف العفش أو البضاعة'),
                      hint: 'اكتب وصفاً واضحاً للحمولة',
                      icon: Icons.description_outlined,
                      maxLines: 3,
                    ),
                    SizedBox(height: 12),
                    _formField(
                      controller: _quantityController,
                      label: AppText.t('الكمية'),
                      hint: 'عدد القطع أو الوحدات',
                      icon: Icons.numbers_outlined,
                      keyboardType: TextInputType.number,
                    ),
                    SizedBox(height: 12),
                    _formField(
                      controller: _weightController,
                      label: AppText.t('الوزن التقريبي'),
                      hint: 'بالكيلوغرام',
                      icon: Icons.scale_outlined,
                      keyboardType: TextInputType.number,
                    ),
                    SizedBox(height: 12),
                    _formField(
                      controller: _volumeController,
                      label: AppText.t('الحجم التقريبي'),
                      hint: 'متر مكعب أو وصف للحجم',
                      icon: Icons.view_in_ar_outlined,
                    ),
                    SizedBox(height: 12),
                    _formField(
                      controller: _senderController,
                      label: AppText.t('اسم المرسل'),
                      hint: 'اسم صاحب الحمولة',
                      icon: Icons.person_outline,
                    ),
                    SizedBox(height: 12),
                    _formField(
                      controller: _recipientController,
                      label: AppText.t('اسم المستلم'),
                      hint: 'اسم مستلم الحمولة',
                      icon: Icons.person_pin_outlined,
                    ),
                    SizedBox(height: 12),
                    _formField(
                      controller: _notesController,
                      label: AppText.t('ملاحظات'),
                      hint: 'أي تفاصيل إضافية',
                      icon: Icons.notes_outlined,
                      maxLines: 3,
                    ),
                    SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2A2118),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.orange.withValues(
                            alpha: 0.28,
                          ),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.warning_amber_rounded,
                                color: Colors.orange,
                                size: 22,
                              ),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(AppText.t('تعهد ومسؤولية صاحب الحمولة'),
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 10),
                          Text(AppText.t('أقر بأن جميع البيانات المتعلقة بالحمولة صحيحة، وأنني أتحمل المسؤولية الكاملة عن أي مخالفة أو مواد ممنوعة أو غير نظامية أو أضرار ناتجة عن محتويات الحمولة. كما ألتزم بتحمل جميع الرسوم والجبايات ومصاريف الطريق وأي تكاليف نظامية متعلقة بالبضاعة أو نقلها.'),
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                              height: 1.6,
                            ),
                          ),
                          SizedBox(height: 8),
                          CheckboxListTile(
                            value: _acceptedCargoUndertaking,
                            onChanged: (value) {
                              setSheetState(() {
                                _acceptedCargoUndertaking =
                                    value ?? false;
                              });
                            },
                            activeColor: AppColors.lime,
                            checkColor: Colors.black,
                            contentPadding: EdgeInsets.zero,
                            controlAffinity:
                                ListTileControlAffinity.leading,
                            title: Text(AppText.t('أوافق على التعهد والمسؤولية المذكورة أعلاه'),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: _acceptedCargoUndertaking
                            ? () {
                                Navigator.pop(context);
                                _showCargoConfirmation();
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.lime,
                          disabledBackgroundColor:
                              Colors.white12,
                          foregroundColor: Colors.black,
                          disabledForegroundColor:
                              Colors.white24,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        child: Text(AppText.t('متابعة طلب النقل'),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  void _showCargoConfirmation() {
    final String requestNumber =
        'WAS-C-${DateTime.now().millisecondsSinceEpoch.toString().substring(6)}';

    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(23),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 68,
                height: 68,
                decoration: const BoxDecoration(
                  color: AppColors.lime,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.local_shipping_outlined,
                  color: Colors.black,
                  size: 34,
                ),
              ),
              SizedBox(height: 16),
              Text(AppText.t('تم تسجيل طلب النقل'),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(AppText.t('رقم الطلب: $requestNumber'),
                style: const TextStyle(
                  color: AppColors.lime,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              SizedBox(height: 10),
              Text(AppText.t('سيتم مراجعة بيانات الحمولة وتنسيق وسيلة النقل المناسبة وإرسال تفاصيل السعر والتأكيد.'),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 12,
                  height: 1.6,
                ),
              ),
              SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.lime,
                    foregroundColor: Colors.black,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(13),
                    ),
                  ),
                  child: Text(AppText.t('تم'),
                    style: TextStyle(
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
        title: Text(AppText.t('الرحلات بين المدن'),
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
              _buildVehicleTypesSection(),
              SizedBox(height: 14),
              _buildDateCard(),
              SizedBox(height: 14),
              _buildPassengersCard(),
              SizedBox(height: 14),
              SizedBox(height: 20),
              _buildSearchButton(),
              SizedBox(height: 20),
              _buildInfoCard(),
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
              Icons.route_outlined,
              color: AppColors.lime,
              size: 31,
            ),
          ),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(AppText.t('سافر بين المدن بسهولة'),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 6),
                Text(AppText.t('اختر مسارك أولاً، ثم اختر المركبة والرحلة المناسبة لك.'),
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
              Text(AppText.t('مسار الرحلة'),
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
                tooltip: AppText.t('تبديل المدن'),
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
                  _selectedVehicleType = null;
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
                  _selectedVehicleType = null;
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
                child: Text(_localizedCityName(city)),
              );
            }).toList(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildVehicleTypesSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.directions_car_outlined,
                color: AppColors.lime,
                size: 22,
              ),
              SizedBox(width: 10),
              Text(AppText.t('اختر نوع المركبة'),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 6),
          Text(AppText.t('المركبات المتاحة لهذا المسار'),
            style: TextStyle(
              color: Colors.white38,
              fontSize: 11,
            ),
          ),
          SizedBox(height: 14),
          ..._vehicleTypes.map(
            (vehicle) => Padding(
              padding: const EdgeInsets.only(bottom: 9),
              child: _vehicleTypeCard(
                vehicle,
                compact: true,
                onTap: () {
                  final String name = vehicle['name'] as String;

                  setState(() {
                    _selectedVehicleType = name;
                  });

                  if (name == 'دفار') {
                    _showCargoForm();
                  } else {
                    _showTripsForVehicle(name);
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _vehicleTypeCard(
    Map<String, dynamic> vehicle, {
    required bool compact,
    required VoidCallback onTap,
  }) {
    final String name = vehicle['name'] as String;
    final bool selected = _selectedVehicleType == name;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: EdgeInsets.all(compact ? 12 : 15),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.lime.withValues(alpha: 0.10)
              : const Color(0xFF252525),
          borderRadius: BorderRadius.circular(
            compact ? 14 : 17,
          ),
          border: Border.all(
            color: selected
                ? AppColors.lime.withValues(alpha: 0.60)
                : Colors.white.withValues(alpha: 0.06),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: compact ? 44 : 50,
              height: compact ? 44 : 50,
              decoration: BoxDecoration(
                color: AppColors.lime.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(
                vehicle['icon'] as IconData,
                color: AppColors.lime,
                size: compact ? 23 : 26,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _localizedVehicleName(name),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: compact ? 13 : 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    AppText.t(vehicle['subtitle'] as String),
                    style: const TextStyle(
                      color: Colors.white54,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_left,
              color: selected
                  ? AppColors.lime
                  : Colors.white38,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveTripCard(Map<String, dynamic> trip) {
    final int capacity = trip['capacity'] as int;
    final int booked = trip['booked'] as int;
    final int remaining = capacity - booked;

    return GestureDetector(
      onTap: () => _showBookingOptions(trip),
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
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: AppColors.lime.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Icon(
                    Icons.directions_car_outlined,
                    color: AppColors.lime,
                    size: 24,
                  ),
                ),
                SizedBox(width: 11),
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        _localizedVehicleName(trip['vehicle'].toString()),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(AppText.t('رحلة قائمة'),
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    Icon(
                      Icons.star,
                      color: Colors.amber,
                      size: 16,
                    ),
                    SizedBox(width: 4),
                    Text(
                      trip['rating'].toString(),
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 15),
            Row(
              children: [
                _timeColumn(
                  _localizedTime(trip['departure'].toString()),
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
                          padding:
                              EdgeInsets.symmetric(horizontal: 5),
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
                  _localizedTime(trip['arrival'].toString()),
                  AppText.t('الوصول'),
                  alignEnd: true,
                ),
              ],
            ),
            SizedBox(height: 14),
            const Divider(
              color: Colors.white10,
              height: 1,
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.event_seat_outlined,
                  color: Colors.white54,
                  size: 17,
                ),
                SizedBox(width: 6),
                Text(AppText.t('$remaining مقاعد متبقية من $capacity'),
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                Text(
                  '${_formatMoney(trip['ticketPrice'] as int)} / ${AppText.t('مقعد')}',
                  style: const TextStyle(
                    color: AppColors.lime,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                vertical: 10,
              ),
              decoration: BoxDecoration(
                color: AppColors.lime.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(11),
              ),
              child: Text(AppText.t('اختيار الرحلة'),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.lime,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _emptyTripsCard() {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: const Color(0xFF252525),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Icon(
            Icons.event_busy_outlined,
            color: Colors.white38,
            size: 42,
          ),
          SizedBox(height: 12),
          Text(AppText.t('لا توجد رحلة قائمة بهذا النوع حالياً'),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 6),
          Text(AppText.t('يمكنك العودة واختيار نوع مركبة آخر أو المحاولة لاحقاً.'),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white54,
              fontSize: 12,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _routeSummaryCard(Map<String, dynamic> trip) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFF252525),
        borderRadius: BorderRadius.circular(17),
      ),
      child: Column(
        children: [
          _summaryRow(AppText.t('المسار'),
            '${_localizedCityName(_fromCity)} ← ${_localizedCityName(_toCity)}',
          ),
          _summaryRow(AppText.t('المركبة'),
            _localizedVehicleName(trip['vehicle'].toString()),
          ),
          _summaryRow(AppText.t('التاريخ'),
            '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
          ),
          _summaryRow(AppText.t('الانطلاق'),
            _localizedTime(trip['departure'].toString()),
          ),
          _summaryRow(AppText.t('الوصول'),
            _localizedTime(trip['arrival'].toString()),
          ),
        ],
      ),
    );
  }

  Widget _choiceCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.lime.withValues(alpha: 0.12)
              : const Color(0xFF252525),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected
                ? AppColors.lime
                : Colors.white.withValues(alpha: 0.07),
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: selected
                  ? AppColors.lime
                  : Colors.white54,
              size: 25,
            ),
            SizedBox(height: 7),
            Text(
              title,
              style: TextStyle(
                color: selected
                    ? AppColors.lime
                    : Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 3),
            Text(
              subtitle,
              style: const TextStyle(
                color: Colors.white38,
                fontSize: 9,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _paymentCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.lime.withValues(alpha: 0.10)
              : const Color(0xFF252525),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected
                ? AppColors.lime
                : Colors.white.withValues(alpha: 0.06),
          ),
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
                icon,
                color: AppColors.lime,
                size: 22,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Colors.white54,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              selected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_off,
              color: selected
                  ? AppColors.lime
                  : Colors.white30,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }

  Widget _formField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 13,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: const TextStyle(
          color: Colors.white54,
          fontSize: 12,
        ),
        hintStyle: const TextStyle(
          color: Colors.white24,
          fontSize: 11,
        ),
        prefixIcon: Icon(
          icon,
          color: AppColors.lime,
          size: 20,
        ),
        filled: true,
        fillColor: const Color(0xFF252525),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: AppColors.lime,
          ),
        ),
      ),
    );
  }

  Widget _ticketLogo() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(
          'assets/images/wasel-logo.png',
          width: 44,
          height: 44,
          errorBuilder: (_, _, _) {
            return Icon(
              Icons.route,
              color: AppColors.lime,
              size: 38,
            );
          },
        ),
        SizedBox(width: 9),
        Text(
          'WASEL',
          style: TextStyle(
            color: AppColors.lime,
            fontSize: 22,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _ticketRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 11,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sheetContainer({
    required ScrollController controller,
    required List<Widget> children,
  }) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(28),
        ),
      ),
      child: ListView(
        controller: controller,
        padding: const EdgeInsets.fromLTRB(
          20,
          12,
          20,
          30,
        ),
        children: children,
      ),
    );
  }

  Widget _sheetHandle() {
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

  Widget _sectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          color: AppColors.lime,
          size: 21,
        ),
        SizedBox(width: 9),
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildDateCard() {
    final String date =
        '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}';

    return _settingsCard(
      icon: Icons.calendar_month_outlined,
      title: AppText.t('تاريخ السفر'),
      value: date,
      onTap: _selectDate,
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
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(AppText.t('عدد المسافرين'),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 4),
                Text(AppText.t('اختر عدد المقاعد'),
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
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
            ),
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
            enabled: _passengers < 8,
            onTap: () {
              if (_passengers < 8) {
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
          color: enabled
              ? Colors.white
              : Colors.white24,
        ),
      ),
    );
  }
  Widget _buildSearchButton() {
    return SizedBox(
      height: 54,
      child: ElevatedButton.icon(
        onPressed: _showRouteTrips,
        icon: Icon(Icons.search),
        label: Text(
          _selectedVehicleType == null
              ? AppText.t('عرض أنواع المركبات')
              : _selectedVehicleType == 'دفار'
                  ? AppText.t('متابعة طلب نقل الحمولة')
                  : AppText.t('عرض الرحلات المتاحة'),
          style: const TextStyle(
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

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline,
            color: AppColors.lime,
            size: 21,
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(AppText.t('اختر المسار أولاً. بعد ذلك تظهر أنواع المركبات المتاحة، ثم الرحلات القائمة والمقاعد المتبقية. لا يتم عرض شركات النقل للمسافر؛ إدارة واصل تتولى تنسيق الناقل عند الحاجة.'),
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

  Widget _settingsCard({
    required IconData icon,
    required String title,
    required String value,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
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
                color: AppColors.lime.withValues(
                  alpha: 0.10,
                ),
                borderRadius:
                    BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: AppColors.lime,
                size: 23,
              ),
            ),
            SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    _localizedCityName(value),
                    style: const TextStyle(
                      color: AppColors.lime,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_left,
              color: Colors.white38,
              size: 22,
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
      crossAxisAlignment: alignEnd
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
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

  Widget _summaryRow(
    String title,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 5,
      ),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 12,
            ),
          ),
          const Spacer(),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _localizedCityName(String city) {
    if (!AppLocale.isEnglish) return city;
    const names = {
      'الخرطوم': 'Khartoum',
      'بحري': 'Bahri',
      'أم درمان': 'Omdurman',
      'شندي': 'Shendi',
      'عطبرة': 'Atbara',
      'بورتسودان': 'Port Sudan',
      'مروي': 'Merowe',
      'كريمة': 'Karima',
      'مدني': 'Wad Madani',
      'القضارف': 'Gedaref',
      'كسلا': 'Kassala',
      'سنار': 'Sennar',
      'ربك': 'Rabak',
      'الدويم': 'Ed Dueim',
    };
    return names[city] ?? city;
  }

  String _localizedVehicleName(String vehicle) {
    if (!AppLocale.isEnglish) return vehicle;
    const names = {
      'ليموزين': 'Limousine',
      'ليموزين فاخر': 'Luxury limousine',
      'بوكسي سنقل': 'Single-cab pickup',
      'بوكسي دبل كاب': 'Double-cab pickup',
      'شريحة': 'Minibus',
      'باص': 'Bus',
      'دفار': 'Cargo truck',
    };
    return names[vehicle] ?? vehicle;
  }

  String _localizedTime(String time) {
    if (!AppLocale.isEnglish) return time;
    return time.replaceAll(' ص', ' AM').replaceAll(' م', ' PM');
  }

  String _formatMoney(int amount) {
    final String value = amount.toString();
    final StringBuffer result = StringBuffer();

    for (int i = 0; i < value.length; i++) {
      if (i > 0 &&
          (value.length - i) % 3 == 0) {
        result.write(',');
      }
      result.write(value[i]);
    }

    return AppLocale.isEnglish ? '${result.toString()} SDG' : '${result.toString()} جنيه';
  }
}
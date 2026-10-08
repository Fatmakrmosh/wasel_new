import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/network/supabase_service.dart';
import '../../core/theme/app_theme.dart';
import '../../core/localization/app_strings.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  bool notificationsEnabled = true;
  bool darkModeEnabled = true;
  String? _role;

  @override
  void initState() {
    super.initState();
    _loadRole();
  }

  Future<void> _loadRole() async {
    final client = SupabaseService.client;
    final user = client?.auth.currentUser;
    if (client == null || user == null) return;
    try {
      final row = await client
          .from('profiles')
          .select('role,is_active')
          .eq('id', user.id)
          .maybeSingle();
      if (!mounted) return;
      final active = row?['is_active'] == true;
      final role = row?['role']?.toString();
      setState(() => _role = active ? role : null);
    } catch (_) {}
  }

  bool get _isAdminAccount => _role == 'admin' || _role == 'supervisor';

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

  void _showLanguageDialog() {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          title: Text(
            AppStrings.language,
            textAlign: TextAlign.right,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _languageOption(AppStrings.arabic, true),
              _languageOption('English', false),
            ],
          ),
        );
      },
    );
  }

  Widget _languageOption(String title, bool selected) {
    return ListTile(
      onTap: () {
        Navigator.pop(context);
        if (!selected) {
          _showMessage(AppStrings.englishLater);
        }
      },
      title: Text(
        title,
        textAlign: TextAlign.right,
        style: const TextStyle(
          color: Colors.white,
        ),
      ),
      trailing: Icon(
        selected
            ? Icons.radio_button_checked_rounded
            : Icons.radio_button_off_rounded,
        color: selected ? AppColors.lime : Colors.white38,
      ),
    );
  }

  Future<void> _logout() async {
    final client = SupabaseService.client;

    if (client == null) {
      if (mounted) context.go('/login');
      return;
    }

    try {
      // Logout locally first so the browser session is definitely cleared
      // even if the network/Supabase request fails.
      await client.auth.signOut(scope: SignOutScope.local);
    } catch (_) {
      if (mounted) {
        _showMessage('تعذر تسجيل الخروج. حاول مرة أخرى.');
      }
      return;
    }

    // Make sure the router no longer sees an active session.
    if (client.auth.currentSession != null) {
      if (mounted) {
        _showMessage('لم يتم إنهاء الجلسة. حاول مرة أخرى.');
      }
      return;
    }

    if (mounted) {
      context.go('/login');
    }
  }

  void _showLogoutDialog() {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          title: Text(
            AppStrings.logout,
            textAlign: TextAlign.right,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            AppStrings.logoutConfirm,
            textAlign: TextAlign.right,
            style: TextStyle(
              color: Colors.white70,
              height: 1.5,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                AppStrings.cancel,
                style: TextStyle(
                  color: Colors.white70,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                await _logout();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.lime,
                foregroundColor: Colors.black,
              ),
              child: Text(
                AppStrings.logout,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showEditProfile() {
    final nameController = TextEditingController(
      text: 'Ahmed Mohamed',
    );

    final phoneController = TextEditingController(
      text: '09XXXXXXXX',
    );

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 30),
            decoration: const BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(28),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 45,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 22),
                Text(
                  AppStrings.editProfile,
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                _buildTextField(
                  controller: nameController,
                  label: AppStrings.name,
                  icon: Icons.person_outline_rounded,
                ),
                const SizedBox(height: 14),
                _buildTextField(
                  controller: phoneController,
                  label: AppStrings.phoneNumber,
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 22),
                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _showMessage(AppStrings.profileSaved);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.lime,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      AppStrings.saveChanges,
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
        );
      },
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(
        color: Colors.white,
      ),
      textAlign: TextAlign.right,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(
          color: Colors.white54,
        ),
        prefixIcon: Icon(
          icon,
          color: AppColors.lime,
        ),
        filled: true,
        fillColor: const Color(0xFF252525),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  void _showChangePassword() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 30),
            decoration: const BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(28),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 45,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 22),
                Text(
                  AppStrings.changePasswordTitle,
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                _buildPasswordField(AppStrings.currentPassword),
                const SizedBox(height: 14),
                _buildPasswordField(AppStrings.newPassword),
                const SizedBox(height: 14),
                _buildPasswordField(AppStrings.confirmNewPassword),
                const SizedBox(height: 22),
                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _showMessage(AppStrings.passwordUpdated);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.lime,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      AppStrings.updatePassword,
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

  Widget _buildPasswordField(String label) {
    return TextField(
      obscureText: true,
      style: const TextStyle(
        color: Colors.white,
      ),
      textAlign: TextAlign.right,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(
          color: Colors.white54,
        ),
        prefixIcon: const Icon(
          Icons.lock_outline_rounded,
          color: AppColors.lime,
        ),
        filled: true,
        fillColor: const Color(0xFF252525),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  void _showHelpDialog() {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          title: const Text(
            'مركز المساعدة',
            textAlign: TextAlign.right,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: const Text(
            'يمكنك التواصل مع دعم واصل للحصول على المساعدة في الرحلات والطرود والحسابات.\n\nسيتم ربط مركز الدعم بخدمة العملاء لاحقًا.',
            textAlign: TextAlign.right,
            style: TextStyle(
              color: Colors.white70,
              height: 1.7,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'إغلاق',
                style: TextStyle(
                  color: AppColors.lime,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showInfoDialog(String title, String message) {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          title: Text(
            title,
            textAlign: TextAlign.right,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            message,
            textAlign: TextAlign.right,
            style: const TextStyle(
              color: Colors.white70,
              height: 1.7,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'إغلاق',
                style: TextStyle(
                  color: AppColors.lime,
                ),
              ),
            ),
          ],
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
        title: Text(
          AppStrings.account,
          style: TextStyle(
            color: Colors.white,
            fontSize: 21,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
            size: 20,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 30),
        children: [
          _buildProfileHeader(),
          const SizedBox(height: 22),
          _buildSectionTitle(AppStrings.account),
          const SizedBox(height: 8),
          _buildAccountItem(
            icon: Icons.person_outline_rounded,
            title: AppStrings.profile,
            subtitle: AppStrings.editNamePhone,
            onTap: _showEditProfile,
          ),
          _buildAccountItem(
            icon: Icons.lock_outline_rounded,
            title: AppStrings.passwordSettings,
            subtitle: AppStrings.changePassword,
            onTap: _showChangePassword,
          ),
          _buildAccountItem(
            icon: Icons.language_rounded,
            title: AppStrings.language,
            subtitle: AppStrings.arabic,
            onTap: _showLanguageDialog,
          ),
          const SizedBox(height: 20),
          _buildSectionTitle(AppStrings.settings),
          const SizedBox(height: 8),
          _buildSwitchItem(
            icon: Icons.notifications_none_rounded,
            title: AppStrings.notifications,
            subtitle: AppStrings.tripParcelAlerts,
            value: notificationsEnabled,
            onChanged: (value) {
              setState(() {
                notificationsEnabled = value;
              });
            },
          ),
          _buildSwitchItem(
            icon: Icons.dark_mode_outlined,
            title: AppStrings.darkMode,
            subtitle: AppStrings.appAppearance,
            value: darkModeEnabled,
            onChanged: (value) {
              setState(() {
                darkModeEnabled = value;
              });
              _showMessage(
                value
                    ? AppStrings.darkModeEnabled
                    : AppStrings.lightModeLater,
              );
            },
          ),
          if (_isAdminAccount) ...[
            const SizedBox(height: 20),
            _buildSectionTitle(AppStrings.admin),
            const SizedBox(height: 8),
            _buildAccountItem(
              icon: Icons.admin_panel_settings_outlined,
              title: _role == 'admin' ? AppStrings.systemManagement : AppStrings.supervisorPanel,
              subtitle: _role == 'admin'
                  ? AppStrings.manageUsersTripsPermissions
                  : AppStrings.manageTasksPermissions,
              onTap: () => context.push('/admin'),
            ),
          ],
          const SizedBox(height: 20),
          _buildSectionTitle(AppStrings.waselServices),
          const SizedBox(height: 8),
          _buildAccountItem(
            icon: Icons.drive_eta_outlined,
            title: AppStrings.driverRegistration,
            subtitle: AppStrings.joinWaselDrivers,
            onTap: () => context.push('/driver-register'),
          ),
          _buildAccountItem(
            icon: Icons.business_outlined,
            title: AppStrings.transportCompanyRegistration,
            subtitle: AppStrings.addCompanyServices,
            onTap: () => context.push('/company-register'),
          ),
          const SizedBox(height: 20),
          _buildSectionTitle(AppStrings.helpInfo),
          const SizedBox(height: 8),
          _buildAccountItem(
            icon: Icons.help_outline_rounded,
            title: AppStrings.helpCenter,
            subtitle: AppStrings.questionsSupport,
            onTap: _showHelpDialog,
          ),
          _buildAccountItem(
            icon: Icons.privacy_tip_outlined,
            title: AppStrings.privacy,
            subtitle: AppStrings.privacyDataPolicy,
            onTap: () => _showInfoDialog(
              AppStrings.privacy,
              'تحرص واصل على حماية بيانات المستخدمين وعدم استخدامها إلا لتقديم الخدمات وتحسين تجربة الاستخدام.\n\nسيتم إضافة سياسة الخصوصية الكاملة قبل الإطلاق النهائي.',
            ),
          ),
          _buildAccountItem(
            icon: Icons.description_outlined,
            title: AppStrings.termsConditions,
            subtitle: AppStrings.termsServices,
            onTap: () => _showInfoDialog(
              AppStrings.termsConditions,
              'تخضع جميع خدمات واصل لشروط الاستخدام وسياسات السلامة والدفع المعتمدة من إدارة المنصة.\n\nسيتم إضافة الشروط النهائية قبل الإطلاق.',
            ),
          ),
          _buildAccountItem(
            icon: Icons.info_outline_rounded,
            title: AppStrings.aboutWasel,
            subtitle: AppStrings.appVersion,
            onTap: () => _showInfoDialog(
              AppStrings.aboutWasel,
              'واصل WASEL\n\nمنصة سودانية للنقل والرحلات وإرسال الطرود، تهدف إلى تسهيل التنقل وربط الركاب بالسائقين وشركات النقل.',
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 52,
            child: OutlinedButton.icon(
              onPressed: _showLogoutDialog,
              icon: const Icon(
                Icons.logout_rounded,
                color: Colors.redAccent,
              ),
              label: const Text(
                'تسجيل الخروج',
                style: TextStyle(
                  color: Colors.redAccent,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: BorderSide(
                  color: Colors.redAccent.withValues(alpha: 0.35),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
          ),
          const SizedBox(height: 15),
          const Text(
            'WASEL • واصل',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white24,
              fontSize: 12,
              letterSpacing: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
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
            width: 64,
            height: 64,
            decoration: const BoxDecoration(
              color: AppColors.lime,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person_rounded,
              color: Colors.black,
              size: 34,
            ),
          ),
          const SizedBox(width: 15),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'أحمد محمد',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  '09XXXXXXXX',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 13,
                  ),
                ),
                SizedBox(height: 7),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Icon(
                      Icons.verified_rounded,
                      color: AppColors.lime,
                      size: 16,
                    ),
                    SizedBox(width: 5),
                    Text(
                      'حساب موثوق',
                      style: TextStyle(
                        color: AppColors.lime,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Text(
        title,
        textAlign: TextAlign.right,
        style: const TextStyle(
          color: AppColors.lime,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildAccountItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white10,
        ),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 3,
        ),
        leading: const Icon(
          Icons.arrow_back_ios_new_rounded,
          color: Colors.white30,
          size: 15,
        ),
        trailing: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: AppColors.lime.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.person_outline_rounded,
            color: AppColors.lime,
            size: 22,
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
          subtitle,
          textAlign: TextAlign.right,
          style: const TextStyle(
            color: Colors.white54,
            fontSize: 11,
          ),
        ),
      ),
    );
  }

  Widget _buildSwitchItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white10,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 3,
        ),
        leading: Switch(
          value: value,
          onChanged: onChanged,
          activeThumbColor: AppColors.lime,
          activeTrackColor: AppColors.lime.withValues(alpha: 0.35),
        ),
        trailing: Container(
          width: 42,
          height: 42,
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
          subtitle,
          textAlign: TextAlign.right,
          style: const TextStyle(
            color: Colors.white54,
            fontSize: 11,
          ),
        ),
      ),
    );
  }
}
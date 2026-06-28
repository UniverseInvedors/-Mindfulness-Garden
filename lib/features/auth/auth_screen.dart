import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:pranaverse/core/localization/app_copy.dart';
import 'package:pranaverse/presentation/providers/auth_provider.dart'
    as app_auth;
import 'package:pranaverse/core/config.dart';

class _Country {
  final String name;
  final String dialCode;
  final String code;

  const _Country(this.name, this.dialCode, this.code);

  String get flag {
    const base = 0x1F1E6 - 0x41;
    final chars = code.toUpperCase().codeUnits;
    return String.fromCharCode(base + chars[0]) +
        String.fromCharCode(base + chars[1]);
  }
}

const List<_Country> _kCountries = [
  _Country('Afghanistan', '+93', 'AF'),
  _Country('Albania', '+355', 'AL'),
  _Country('Algeria', '+213', 'DZ'),
  _Country('Argentina', '+54', 'AR'),
  _Country('Armenia', '+374', 'AM'),
  _Country('Australia', '+61', 'AU'),
  _Country('Austria', '+43', 'AT'),
  _Country('Azerbaijan', '+994', 'AZ'),
  _Country('Bahrain', '+973', 'BH'),
  _Country('Bangladesh', '+880', 'BD'),
  _Country('Belarus', '+375', 'BY'),
  _Country('Belgium', '+32', 'BE'),
  _Country('Bolivia', '+591', 'BO'),
  _Country('Bosnia & Herzegovina', '+387', 'BA'),
  _Country('Brazil', '+55', 'BR'),
  _Country('Bulgaria', '+359', 'BG'),
  _Country('Cambodia', '+855', 'KH'),
  _Country('Cameroon', '+237', 'CM'),
  _Country('Canada', '+1', 'CA'),
  _Country('Chile', '+56', 'CL'),
  _Country('China', '+86', 'CN'),
  _Country('Colombia', '+57', 'CO'),
  _Country('Croatia', '+385', 'HR'),
  _Country('Cuba', '+53', 'CU'),
  _Country('Cyprus', '+357', 'CY'),
  _Country('Czech Republic', '+420', 'CZ'),
  _Country('Denmark', '+45', 'DK'),
  _Country('Ecuador', '+593', 'EC'),
  _Country('Egypt', '+20', 'EG'),
  _Country('Ethiopia', '+251', 'ET'),
  _Country('Finland', '+358', 'FI'),
  _Country('France', '+33', 'FR'),
  _Country('Georgia', '+995', 'GE'),
  _Country('Germany', '+49', 'DE'),
  _Country('Ghana', '+233', 'GH'),
  _Country('Greece', '+30', 'GR'),
  _Country('Guatemala', '+502', 'GT'),
  _Country('Hungary', '+36', 'HU'),
  _Country('India', '+91', 'IN'),
  _Country('Indonesia', '+62', 'ID'),
  _Country('Iran', '+98', 'IR'),
  _Country('Iraq', '+964', 'IQ'),
  _Country('Ireland', '+353', 'IE'),
  _Country('Israel', '+972', 'IL'),
  _Country('Italy', '+39', 'IT'),
  _Country('Japan', '+81', 'JP'),
  _Country('Jordan', '+962', 'JO'),
  _Country('Kazakhstan', '+7', 'KZ'),
  _Country('Kenya', '+254', 'KE'),
  _Country('Kuwait', '+965', 'KW'),
  _Country('Kyrgyzstan', '+996', 'KG'),
  _Country('Lebanon', '+961', 'LB'),
  _Country('Libya', '+218', 'LY'),
  _Country('Malaysia', '+60', 'MY'),
  _Country('Mexico', '+52', 'MX'),
  _Country('Morocco', '+212', 'MA'),
  _Country('Myanmar', '+95', 'MM'),
  _Country('Nepal', '+977', 'NP'),
  _Country('Netherlands', '+31', 'NL'),
  _Country('New Zealand', '+64', 'NZ'),
  _Country('Nigeria', '+234', 'NG'),
  _Country('Norway', '+47', 'NO'),
  _Country('Oman', '+968', 'OM'),
  _Country('Pakistan', '+92', 'PK'),
  _Country('Palestine', '+970', 'PS'),
  _Country('Panama', '+507', 'PA'),
  _Country('Peru', '+51', 'PE'),
  _Country('Philippines', '+63', 'PH'),
  _Country('Poland', '+48', 'PL'),
  _Country('Portugal', '+351', 'PT'),
  _Country('Qatar', '+974', 'QA'),
  _Country('Romania', '+40', 'RO'),
  _Country('Russia', '+7', 'RU'),
  _Country('Saudi Arabia', '+966', 'SA'),
  _Country('Serbia', '+381', 'RS'),
  _Country('Singapore', '+65', 'SG'),
  _Country('Slovakia', '+421', 'SK'),
  _Country('South Africa', '+27', 'ZA'),
  _Country('South Korea', '+82', 'KR'),
  _Country('Spain', '+34', 'ES'),
  _Country('Sri Lanka', '+94', 'LK'),
  _Country('Sudan', '+249', 'SD'),
  _Country('Sweden', '+46', 'SE'),
  _Country('Switzerland', '+41', 'CH'),
  _Country('Syria', '+963', 'SY'),
  _Country('Taiwan', '+886', 'TW'),
  _Country('Tajikistan', '+992', 'TJ'),
  _Country('Tanzania', '+255', 'TZ'),
  _Country('Thailand', '+66', 'TH'),
  _Country('Tunisia', '+216', 'TN'),
  _Country('Turkey', '+90', 'TR'),
  _Country('Turkmenistan', '+993', 'TM'),
  _Country('UAE', '+971', 'AE'),
  _Country('Uganda', '+256', 'UG'),
  _Country('Ukraine', '+380', 'UA'),
  _Country('United Kingdom', '+44', 'GB'),
  _Country('United States', '+1', 'US'),
  _Country('Uzbekistan', '+998', 'UZ'),
  _Country('Venezuela', '+58', 'VE'),
  _Country('Vietnam', '+84', 'VN'),
  _Country('Yemen', '+967', 'YE'),
  _Country('Zimbabwe', '+263', 'ZW'),
];

enum _AuthMode { emailPassword, phoneOtp }

// Temporary flag: when `kDevelopmentAuthMode` is true, hide advanced
// authentication methods (Google, Phone OTP) from the UI to simplify
// development testing. Production behavior remains unchanged.

bool get _kPhoneAuthEnabled => !kDevelopmentAuthMode;

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with SingleTickerProviderStateMixin {
  bool _signUpMode = false;
  bool _showPassword = false;
  _AuthMode _authMode = _AuthMode.emailPassword;
  _Country _selectedCountry = _kCountries.firstWhere((c) => c.code == 'BD');

  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _otpCtrl = TextEditingController();
  final _searchCtrl = TextEditingController();

  late final AnimationController _animCtrl;
  late final Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    )..forward();
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeIn);
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _phoneCtrl.dispose();
    _otpCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  void _showError(String msg) => _showSnack(msg, isError: true);

  void _showSnack(String msg, {bool isError = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppCopy.of(context, msg)),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _navigateAfterAuth() {
    // Grab the display name to personalise the welcome screen
    final auth = context.read<app_auth.AuthProvider>();
    final name = auth.user?.name;
    final encoded = name != null && name.isNotEmpty
        ? Uri.encodeComponent(name.split(' ').first)
        : null;
    final route = encoded != null ? '/welcome?name=$encoded' : '/welcome';

    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
    context.go(route);
  }

  void _showCountryPicker() {
    _searchCtrl.clear();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _CountryPickerSheet(
        searchCtrl: _searchCtrl,
        selectedCountry: _selectedCountry,
        onSelected: (country) {
          HapticFeedback.selectionClick();
          setState(() => _selectedCountry = country);
          Navigator.pop(context);
        },
      ),
    );
  }

  Future<void> _submitEmailPassword() async {
    final auth = context.read<app_auth.AuthProvider>();
    final email = _emailCtrl.text.trim();
    final pass = _passCtrl.text;
    final name = _nameCtrl.text.trim();

    if (email.isEmpty || pass.isEmpty) {
      _showError('Please fill in all fields');
      return;
    }
    if (_signUpMode && name.isEmpty) {
      _showError('Please enter a display name');
      return;
    }
    if (!email.contains('@')) {
      _showError('Please enter a valid email');
      return;
    }
    if (pass.length < 6) {
      _showError('Password must be at least 6 characters');
      return;
    }

    if (_signUpMode) {
      await auth.signUp(email: email, password: pass, displayName: name);
    } else {
      await auth.signIn(email: email, password: pass);
    }

    if (!mounted) return;
    if (auth.error == null) {
      if (_signUpMode && !auth.isEmailVerified && !kDevelopmentAuthMode) {
        _showEmailVerificationDialog();
      } else {
        _navigateAfterAuth();
      }
    }
  }

  Future<void> _signInWithGoogle() async {
    final auth = context.read<app_auth.AuthProvider>();
    if (kDevelopmentAuthMode) return; // disabled in dev mode
    await auth.signInWithGoogle();
    if (!mounted) return;
    if (auth.error == null && auth.isAuthenticated) _navigateAfterAuth();
  }

  Future<void> _sendOtp() async {
    final phone = _phoneCtrl.text.trim();
    if (phone.isEmpty) {
      _showError('Enter your phone number');
      return;
    }

    await context.read<app_auth.AuthProvider>().sendPhoneOtp(
          phoneNumber: '${_selectedCountry.dialCode}$phone',
        );
  }

  Future<void> _verifyOtp() async {
    final otp = _otpCtrl.text.trim();
    if (otp.length != 6) {
      _showError('Enter the 6-digit code');
      return;
    }

    final auth = context.read<app_auth.AuthProvider>();
    await auth.verifyOtp(otp: otp);
    if (!mounted) return;
    if (auth.error == null && auth.isAuthenticated) _navigateAfterAuth();
  }

  void _showEmailVerificationDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1a1a2e),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          AppCopy.of(context, 'Verify Your Email'),
          style:
              const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: Text(
          AppCopy.of(
            context,
            'A verification link has been sent. Check your inbox and spam folder.',
          ),
          style: const TextStyle(color: Color(0xBBFFFFFF), height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              await context
                  .read<app_auth.AuthProvider>()
                  .sendEmailVerification();
              if (!mounted) return;
              Navigator.pop(context);
              _showSnack('Verification email resent', isError: false);
            },
            child: Text(
              AppCopy.of(context, 'Resend'),
              style: const TextStyle(color: Color(0xFF9d4edd)),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF9d4edd),
            ),
            onPressed: () {
              Navigator.pop(context);
              _navigateAfterAuth();
            },
            child: Text(
              AppCopy.of(context, 'Continue'),
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _showForgotPasswordDialog() {
    final ctrl = TextEditingController(text: _emailCtrl.text);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1a1a2e),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          AppCopy.of(context, 'Reset Password'),
          style:
              const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: TextField(
          controller: ctrl,
          keyboardType: TextInputType.emailAddress,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: AppCopy.of(context, 'Enter your email'),
            hintStyle: const TextStyle(color: Color(0x66FFFFFF)),
            enabledBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF9d4edd)),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              AppCopy.of(context, 'Cancel'),
              style: const TextStyle(color: Color(0xFF9d4edd)),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF9d4edd),
            ),
            onPressed: () async {
              await context
                  .read<app_auth.AuthProvider>()
                  .sendPasswordResetEmail(email: ctrl.text.trim());
              if (!mounted) return;
              Navigator.pop(context);
              _showSnack('Password reset email sent', isError: false);
            },
            child: Text(
              AppCopy.of(context, 'Send'),
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    ).whenComplete(ctrl.dispose);
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<app_auth.AuthProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(AppCopy.of(context, 'Account')),
        backgroundColor: const Color(0xFF0a0a1a),
        elevation: 0,
        leading: IconButton(
          tooltip: AppCopy.of(context, 'Back'),
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              context.go('/main');
            }
          },
        ),
      ),
      backgroundColor: const Color(0xFF0a0a1a),
      body: FadeTransition(
        opacity: _fadeAnim,
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            20,
            20,
            20,
            20 + MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: _buildSignModeToggle()),
              if (_kPhoneAuthEnabled) ...[
                const SizedBox(height: 24),
                _buildAuthModeToggle(),
              ],
              const SizedBox(height: 28),
              Text(
                _signUpMode
                    ? AppCopy.of(context, 'Create Account')
                    : AppCopy.of(context, 'Welcome Back'),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _signUpMode
                    ? AppCopy.of(context, 'Join your mindfulness journey')
                    : AppCopy.of(context, 'Continue your practice'),
                style: const TextStyle(
                  color: Color(0x99FFFFFF),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 28),
              if (_authMode == _AuthMode.emailPassword)
                _buildEmailPasswordFields()
              else
                _buildPhoneFields(auth),
              const SizedBox(height: 20),
              if (auth.error != null) ...[
                _ErrorPanel(message: auth.error!),
                const SizedBox(height: 16),
              ],
              _buildSubmitButton(auth),
              if (_authMode == _AuthMode.emailPassword) ...[
                const SizedBox(height: 14),
                if (!kDevelopmentAuthMode) _buildGoogleButton(auth),
                if (!_signUpMode)
                  Center(
                    child: TextButton(
                      onPressed:
                          auth.isLoading ? null : _showForgotPasswordDialog,
                      child: Text(
                        AppCopy.of(context, 'Forgot password?'),
                        style: const TextStyle(
                          color: Color(0xFF9d4edd),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
              ],
              const SizedBox(height: 24),
              _buildOfflineOption(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSignModeToggle() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1a1a2e),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0x339d4edd)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ModeButton(
            label: AppCopy.of(context, 'Sign Up'),
            isSelected: _signUpMode,
            onTap: () => setState(() => _signUpMode = true),
          ),
          _ModeButton(
            label: AppCopy.of(context, 'Sign In'),
            isSelected: !_signUpMode,
            onTap: () => setState(() => _signUpMode = false),
          ),
        ],
      ),
    );
  }

  Widget _buildAuthModeToggle() {
    return Row(
      children: [
        Expanded(
          child: _AuthChoiceButton(
            icon: Icons.email_outlined,
            label: AppCopy.of(context, 'Email'),
            selected: _authMode == _AuthMode.emailPassword,
            onPressed: () =>
                setState(() => _authMode = _AuthMode.emailPassword),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _kPhoneAuthEnabled
              ? _AuthChoiceButton(
                  icon: Icons.phone_iphone,
                  label: AppCopy.of(context, 'Phone'),
                  selected: _authMode == _AuthMode.phoneOtp,
                  onPressed: () =>
                      setState(() => _authMode = _AuthMode.phoneOtp),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget _buildEmailPasswordFields() {
    return Column(
      children: [
        if (_signUpMode) ...[
          _TextField(
            controller: _nameCtrl,
            hint: AppCopy.of(context, 'Display name'),
            icon: Icons.person_outline,
          ),
          const SizedBox(height: 16),
        ],
        _TextField(
          controller: _emailCtrl,
          hint: AppCopy.of(context, 'Email'),
          icon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 16),
        _TextField(
          controller: _passCtrl,
          hint: AppCopy.of(context, 'Password'),
          icon: Icons.lock_outline,
          obscureText: !_showPassword,
          onToggleVisibility: () =>
              setState(() => _showPassword = !_showPassword),
        ),
        if (_signUpMode) ...[
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              AppCopy.of(context, 'At least 6 characters'),
              style: const TextStyle(
                color: Color(0x80FFFFFF),
                fontSize: 12,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildPhoneFields(app_auth.AuthProvider auth) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        OutlinedButton(
          onPressed: auth.isLoading ? null : _showCountryPicker,
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.white,
            side: const BorderSide(color: Color(0x339d4edd)),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            backgroundColor: const Color(0xFF0D0D1F),
          ),
          child: Row(
            children: [
              Text(_selectedCountry.flag, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '${_selectedCountry.name} (${_selectedCountry.dialCode})',
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              const Icon(Icons.keyboard_arrow_down),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _TextField(
          controller: _phoneCtrl,
          hint: AppCopy.of(context, 'Phone number'),
          icon: Icons.phone_iphone,
          keyboardType: TextInputType.phone,
          prefixText: '${_selectedCountry.dialCode} ',
        ),
        if (auth.awaitingOtp) ...[
          const SizedBox(height: 16),
          _TextField(
            controller: _otpCtrl,
            hint: AppCopy.of(context, '6-digit code'),
            icon: Icons.pin_outlined,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(6),
            ],
          ),
          if (auth.pendingPhone != null) ...[
            const SizedBox(height: 8),
            Text(
              AppCopy.of(
                context,
                'Code sent to {phone}',
                vars: {'phone': auth.pendingPhone},
              ),
              style: const TextStyle(color: Color(0x99FFFFFF), fontSize: 12),
            ),
          ],
        ],
      ],
    );
  }

  Widget _buildSubmitButton(app_auth.AuthProvider auth) {
    final label = _authMode == _AuthMode.emailPassword
        ? (_signUpMode ? 'Create Account' : 'Sign In')
        : (auth.awaitingOtp ? 'Verify Code' : 'Send Code');

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: auth.isLoading
            ? null
            : (_authMode == _AuthMode.emailPassword
                ? _submitEmailPassword
                : (auth.awaitingOtp ? _verifyOtp : _sendOtp)),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF9d4edd),
          disabledBackgroundColor: const Color(0x669d4edd),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: auth.isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Text(
                AppCopy.of(context, label),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
      ),
    );
  }

  Widget _buildGoogleButton(app_auth.AuthProvider auth) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: auth.isLoading ? null : _signInWithGoogle,
        icon: const Icon(Icons.g_mobiledata, size: 28),
        label: Text(AppCopy.of(context, 'Continue with Google')),
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.white,
          side: const BorderSide(color: Color(0x339d4edd)),
          padding: const EdgeInsets.symmetric(vertical: 13),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  Widget _buildOfflineOption() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0x1a9d4edd),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0x339d4edd)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppCopy.of(context, 'Offline Play Available'),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            AppCopy.of(
              context,
              'You can practice meditation offline. Sign in to sync progress across devices.',
            ),
            style: const TextStyle(
              color: Color(0xB3FFFFFF),
              fontSize: 12,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => context.go('/dashboard'),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFF9d4edd)),
              ),
              child: Text(
                AppCopy.of(context, 'Continue Offline'),
                style: const TextStyle(
                  color: Color(0xFF9d4edd),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ModeButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _ModeButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF9d4edd) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: Colors.white,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

class _AuthChoiceButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onPressed;

  const _AuthChoiceButton({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: selected ? Colors.white : const Color(0xFF9d4edd),
        backgroundColor:
            selected ? const Color(0xFF9d4edd) : const Color(0xFF0D0D1F),
        side: BorderSide(
          color: selected ? const Color(0xFF9d4edd) : const Color(0x339d4edd),
        ),
        padding: const EdgeInsets.symmetric(vertical: 13),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

class _TextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final TextInputType keyboardType;
  final bool obscureText;
  final VoidCallback? onToggleVisibility;
  final String? prefixText;
  final List<TextInputFormatter>? inputFormatters;

  const _TextField({
    required this.controller,
    required this.hint,
    required this.icon,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.onToggleVisibility,
    this.prefixText,
    this.inputFormatters,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      inputFormatters: inputFormatters,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0x80FFFFFF)),
        prefixIcon: Icon(icon, color: const Color(0xFF9d4edd)),
        prefixText: prefixText,
        prefixStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
        suffixIcon: onToggleVisibility != null
            ? IconButton(
                onPressed: onToggleVisibility,
                icon: Icon(
                  obscureText ? Icons.visibility_off : Icons.visibility,
                  color: const Color(0xFF9d4edd),
                ),
              )
            : null,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0x339d4edd)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF9d4edd), width: 2),
        ),
        filled: true,
        fillColor: const Color(0xFF0D0D1F),
      ),
    );
  }
}

class _ErrorPanel extends StatelessWidget {
  final String message;

  const _ErrorPanel({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.withValues(alpha: 0.5)),
      ),
      child: Text(
        message,
        style: const TextStyle(color: Colors.red, fontSize: 12),
      ),
    );
  }
}

class _CountryPickerSheet extends StatefulWidget {
  final TextEditingController searchCtrl;
  final _Country selectedCountry;
  final ValueChanged<_Country> onSelected;

  const _CountryPickerSheet({
    required this.searchCtrl,
    required this.selectedCountry,
    required this.onSelected,
  });

  @override
  State<_CountryPickerSheet> createState() => _CountryPickerSheetState();
}

class _CountryPickerSheetState extends State<_CountryPickerSheet> {
  @override
  void initState() {
    super.initState();
    widget.searchCtrl.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    widget.searchCtrl.removeListener(_onSearchChanged);
    super.dispose();
  }

  void _onSearchChanged() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final query = widget.searchCtrl.text.trim().toLowerCase();
    final countries = query.isEmpty
        ? _kCountries
        : _kCountries
            .where(
              (country) =>
                  country.name.toLowerCase().contains(query) ||
                  country.dialCode.contains(query) ||
                  country.code.toLowerCase().contains(query),
            )
            .toList();

    return DraggableScrollableSheet(
      initialChildSize: 0.78,
      minChildSize: 0.45,
      maxChildSize: 0.94,
      builder: (context, scrollController) => Container(
        decoration: const BoxDecoration(
          color: Color(0xFF121224),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 42,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0x66FFFFFF),
                borderRadius: BorderRadius.circular(99),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
              child: TextField(
                controller: widget.searchCtrl,
                autofocus: true,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: AppCopy.of(context, 'Search country'),
                  hintStyle: const TextStyle(color: Color(0x80FFFFFF)),
                  prefixIcon:
                      const Icon(Icons.search, color: Color(0xFF9d4edd)),
                  filled: true,
                  fillColor: const Color(0xFF0D0D1F),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            Expanded(
              child: ListView.separated(
                controller: scrollController,
                itemCount: countries.length,
                separatorBuilder: (_, __) =>
                    const Divider(height: 1, color: Color(0x1AFFFFFF)),
                itemBuilder: (context, index) {
                  final country = countries[index];
                  final selected = country.code == widget.selectedCountry.code;
                  return ListTile(
                    onTap: () => widget.onSelected(country),
                    leading: Text(
                      country.flag,
                      style: const TextStyle(fontSize: 22),
                    ),
                    title: Text(
                      country.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          country.dialCode,
                          style: const TextStyle(color: Color(0x99FFFFFF)),
                        ),
                        if (selected) ...[
                          const SizedBox(width: 10),
                          const Icon(
                            Icons.check_circle,
                            color: Color(0xFF9d4edd),
                          ),
                        ],
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

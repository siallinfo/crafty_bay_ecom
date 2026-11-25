import 'package:crafty_bay_ecom/core/app_assets.dart';
import 'package:crafty_bay_ecom/core/app_colors.dart';
import 'package:crafty_bay_ecom/core/app_strings.dart';
import 'package:crafty_bay_ecom/data/model/user_profile_model.dart';
import 'package:crafty_bay_ecom/data/service/auth_service.dart';
import 'package:crafty_bay_ecom/data/service/cache/cache_service.dart';
import 'package:crafty_bay_ecom/presentation/features/home/view/home_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CompleteProfileView extends StatefulWidget {
  const CompleteProfileView({super.key, this.authService, this.homeDataLoader});

  final AuthService? authService;
  final Future<HomeData> Function()? homeDataLoader;

  @override
  State<CompleteProfileView> createState() => _CompleteProfileViewState();
}

class _CompleteProfileViewState extends State<CompleteProfileView> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _mobileController = TextEditingController();
  final _cityController = TextEditingController();
  final _addressController = TextEditingController();
  late final AuthService _authService;
  bool _isSubmitting = false;
  bool _isLoadingProfile = true;
  Object? _profileLoadError;

  @override
  void initState() {
    super.initState();
    _authService = widget.authService ?? AuthService();
    _loadProfile(initial: true);
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _mobileController.dispose();
    _cityController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile({bool initial = false}) async {
    if (!initial) {
      setState(() {
        _isLoadingProfile = true;
        _profileLoadError = null;
      });
    }
    try {
      final profile = UserProfileModel.fromJson(
        await _authService.getProfile(),
      );
      if (!mounted) return;
      _firstNameController.text = profile.firstName;
      _lastNameController.text = profile.lastName;
      _mobileController.text = profile.phone;
      _cityController.text = profile.city;
      _addressController.text = profile.address;
      setState(() {
        _isLoadingProfile = false;
        _profileLoadError = null;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isLoadingProfile = false;
        _profileLoadError = error;
      });
    }
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (!CacheService.isLoggedIn) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text(AppStrings.loginRequired)));
      return;
    }
    FocusScope.of(context).unfocus();
    setState(() => _isSubmitting = true);
    try {
      await _authService.updateProfile({
        'first_name': _firstNameController.text.trim(),
        'last_name': _lastNameController.text.trim(),
        'phone': _mobileController.text.trim(),
        'city': _cityController.text.trim(),
        'address': _addressController.text.trim(),
      });
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute<void>(
          builder: (_) => HomeView(loadData: widget.homeDataLoader),
        ),
        (_) => false,
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString().replaceFirst('Exception: ', '')),
        ),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Widget _buildField({
    required TextEditingController controller,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      enabled: !_isLoadingProfile,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: const TextStyle(color: AppColors.textPrimary, fontSize: 18),
      decoration: InputDecoration(
        hintText: hint,
        contentPadding: EdgeInsets.symmetric(
          horizontal: 12,
          vertical: maxLines > 1 ? 14 : 15,
        ),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return AppStrings.fieldRequired;
        }
        return null;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 28),
                Align(
                  alignment: Alignment.topCenter,
                  child: SvgPicture.asset(
                    AppAssets.logo,
                    width: 118,
                    height: 124,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  AppStrings.completeProfile,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 25,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  AppStrings.completeProfileSubtitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 20),
                if (_isLoadingProfile) ...[
                  const LinearProgressIndicator(),
                  const SizedBox(height: 12),
                ],
                if (_profileLoadError != null) ...[
                  Text(
                    _profileLoadError!.toString().replaceFirst(
                      'Exception: ',
                      '',
                    ),
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppColors.error),
                  ),
                  TextButton(
                    onPressed: _loadProfile,
                    child: const Text(AppStrings.retry),
                  ),
                  const SizedBox(height: 12),
                ],
                _buildField(
                  controller: _firstNameController,
                  hint: AppStrings.firstName,
                ),
                const SizedBox(height: 12),
                _buildField(
                  controller: _lastNameController,
                  hint: AppStrings.lastName,
                ),
                const SizedBox(height: 12),
                _buildField(
                  controller: _mobileController,
                  hint: AppStrings.mobile,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 12),
                _buildField(controller: _cityController, hint: AppStrings.city),
                const SizedBox(height: 12),
                _buildField(
                  controller: _addressController,
                  hint: AppStrings.shippingAddress,
                  maxLines: 3,
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _isSubmitting || _isLoadingProfile
                        ? null
                        : _submit,
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.textOnPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.textOnPrimary,
                            ),
                          )
                        : const Text(
                            AppStrings.complete,
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

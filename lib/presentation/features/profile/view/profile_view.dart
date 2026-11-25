import 'package:crafty_bay_ecom/core/app_colors.dart';
import 'package:crafty_bay_ecom/core/app_strings.dart';
import 'package:crafty_bay_ecom/data/model/user_profile_model.dart';
import 'package:crafty_bay_ecom/data/service/auth_service.dart';
import 'package:crafty_bay_ecom/data/service/cache/cache_service.dart';
import 'package:crafty_bay_ecom/domain/entities/user_profile.dart';
import 'package:crafty_bay_ecom/presentation/features/auth/login/view/login_view.dart';
import 'package:flutter/material.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key, this.authService});

  final AuthService? authService;

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _cityController = TextEditingController();
  final _addressController = TextEditingController();

  late final AuthService _authService;
  UserProfile? _profile;
  Object? _loadError;
  bool _isLoading = true;
  bool _isEditing = false;
  bool _isSaving = false;
  bool _isLoggingOut = false;

  @override
  void initState() {
    super.initState();
    _authService = widget.authService ?? AuthService();
    if (CacheService.isLoggedIn) {
      _loadProfile(initial: true);
    } else {
      _isLoading = false;
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _cityController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile({bool initial = false}) async {
    if (!initial) {
      setState(() {
        _isLoading = true;
        _loadError = null;
      });
    }
    try {
      final profile = UserProfileModel.fromJson(
        await _authService.getProfile(),
      );
      if (!mounted) return;
      _setControllers(profile);
      setState(() {
        _profile = profile;
        _isLoading = false;
        _loadError = null;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _loadError = error;
      });
    }
  }

  void _setControllers(UserProfile profile) {
    _firstNameController.text = profile.firstName;
    _lastNameController.text = profile.lastName;
    _phoneController.text = profile.phone;
    _cityController.text = profile.city;
    _addressController.text = profile.address;
  }

  void _cancelEditing() {
    final profile = _profile;
    if (profile != null) _setControllers(profile);
    setState(() => _isEditing = false);
  }

  Future<void> _saveProfile() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    FocusScope.of(context).unfocus();
    setState(() => _isSaving = true);
    final updatedFields = {
      'first_name': _firstNameController.text.trim(),
      'last_name': _lastNameController.text.trim(),
      'phone': _phoneController.text.trim(),
      'city': _cityController.text.trim(),
      'address': _addressController.text.trim(),
    };
    try {
      await _authService.updateProfile(updatedFields);
      if (!mounted) return;
      final current = _profile;
      if (current != null) {
        setState(() {
          _profile = current.copyWith(
            firstName: updatedFields['first_name']!,
            lastName: updatedFields['last_name']!,
            phone: updatedFields['phone']!,
            city: updatedFields['city']!,
            address: updatedFields['address']!,
          );
          _isEditing = false;
        });
      }
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text(AppStrings.profileSaved)));
    } catch (error) {
      if (!mounted) return;
      _showError(error);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _logout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(AppStrings.logoutConfirmTitle),
        content: const Text(AppStrings.logoutConfirmMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text(AppStrings.logout),
          ),
        ],
      ),
    );
    if (shouldLogout != true || !mounted) return;

    setState(() => _isLoggingOut = true);
    try {
      await CacheService.clearAccessToken();
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute<void>(builder: (_) => const LoginView()),
        (_) => false,
      );
    } catch (error) {
      if (!mounted) return;
      _showError(error);
    } finally {
      if (mounted) setState(() => _isLoggingOut = false);
    }
  }

  void _openLogin() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => const LoginView()),
      (_) => false,
    );
  }

  void _showError(Object error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(error.toString().replaceFirst('Exception: ', ''))),
    );
  }

  Widget _buildField({
    required String label,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      readOnly: !_isEditing,
      keyboardType: keyboardType,
      maxLines: maxLines,
      textCapitalization: TextCapitalization.words,
      style: const TextStyle(fontSize: 16, color: AppColors.textPrimary),
      decoration: InputDecoration(
        labelText: label,
        contentPadding: EdgeInsets.symmetric(
          horizontal: 12,
          vertical: maxLines > 1 ? 14 : 15,
        ),
      ),
      validator: (value) => value == null || value.trim().isEmpty
          ? AppStrings.fieldRequired
          : null,
    );
  }

  Widget _buildProfileForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildField(
            label: AppStrings.firstName,
            controller: _firstNameController,
          ),
          const SizedBox(height: 14),
          _buildField(
            label: AppStrings.lastName,
            controller: _lastNameController,
          ),
          const SizedBox(height: 14),
          _buildField(
            label: AppStrings.mobile,
            controller: _phoneController,
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 14),
          _buildField(label: AppStrings.city, controller: _cityController),
          const SizedBox(height: 14),
          _buildField(
            label: AppStrings.shippingAddress,
            controller: _addressController,
            maxLines: 2,
          ),
          if (_isEditing) ...[
            const SizedBox(height: 22),
            SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _saveProfile,
                child: _isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.textOnPrimary,
                        ),
                      )
                    : const Text(AppStrings.saveChanges),
              ),
            ),
          ],
          const SizedBox(height: 24),
          const Divider(color: AppColors.divider),
          const SizedBox(height: 8),
          SizedBox(
            height: 48,
            child: ElevatedButton.icon(
              onPressed: _isLoggingOut ? null : _logout,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.errorDark,
                foregroundColor: AppColors.textOnPrimary,
              ),
              icon: _isLoggingOut
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.textOnPrimary,
                      ),
                    )
                  : const Icon(Icons.logout),
              label: const Text(AppStrings.logout),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(UserProfile profile) {
    final initials = profile.initials;
    final displayName = profile.displayName.isEmpty
        ? AppStrings.myProfile
        : profile.displayName;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          _buildAvatar(profile.avatarUrl, initials),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (profile.email.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    profile.email,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar(String? avatarUrl, String initials) {
    final url = avatarUrl?.trim();
    return Container(
      width: 56,
      height: 56,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        color: AppColors.background,
        shape: BoxShape.circle,
      ),
      child: url == null || url.isEmpty
          ? Text(
              initials,
              style: const TextStyle(
                color: AppColors.primaryDark,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            )
          : ClipOval(
              child: Image.network(
                url,
                width: 56,
                height: 56,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Center(
                  child: Text(
                    initials,
                    style: const TextStyle(
                      color: AppColors.primaryDark,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildUnauthenticatedState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.person_outline,
              size: 48,
              color: AppColors.iconInactive,
            ),
            const SizedBox(height: 12),
            const Text(
              AppStrings.profileSignInPrompt,
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 15),
            ),
            const SizedBox(height: 18),
            ElevatedButton(
              onPressed: _openLogin,
              child: const Text(AppStrings.login),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    final errorMessage =
        _loadError?.toString().replaceFirst('Exception: ', '') ?? '';
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              errorMessage.isEmpty
                  ? AppStrings.profileLoadFailed
                  : errorMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => _loadProfile(),
              child: const Text(AppStrings.retry),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isAuthenticated = CacheService.isLoggedIn;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(AppStrings.myProfile),
        actions: [
          if (_profile != null)
            IconButton(
              tooltip: _isEditing ? AppStrings.cancel : AppStrings.editProfile,
              onPressed: _isSaving
                  ? null
                  : () {
                      if (_isEditing) {
                        _cancelEditing();
                      } else {
                        setState(() => _isEditing = true);
                      }
                    },
              icon: Icon(_isEditing ? Icons.close : Icons.edit_outlined),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : !isAuthenticated
          ? _buildUnauthenticatedState()
          : _loadError != null
          ? _buildErrorState()
          : _profile == null
          ? const SizedBox.shrink()
          : SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildProfileHeader(_profile!),
                  const SizedBox(height: 24),
                  _buildProfileForm(),
                ],
              ),
            ),
    );
  }
}

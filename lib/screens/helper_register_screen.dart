import 'package:flutter/material.dart';
import '../widgets/forms/custom_text_field.dart';
import '../widgets/forms/phone_text_field.dart';
import '../widgets/forms/skills_dropdown.dart';
import '../widgets/forms/experience_dropdown.dart';
import '../widgets/forms/barangay_dropdown.dart';
import '../widgets/forms/file_upload_field.dart';
import '../widgets/forms/terms_agreement_checkbox.dart';
import '../widgets/common/section_header.dart';
import '../utils/constants/helper_constants.dart';
import '../utils/constants/barangay_constants.dart';
import '../utils/validators/form_validators.dart';
import '../services/file_picker_service.dart';
import '../services/helper_auth_service.dart';
import '../services/supabase_service.dart';
import 'login_screen.dart';

class HelperRegisterScreen extends StatefulWidget {
  const HelperRegisterScreen({super.key});

  @override
  State<HelperRegisterScreen> createState() => _HelperRegisterScreenState();
}

class _HelperRegisterScreenState extends State<HelperRegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  String? _selectedSkill;
  String? _selectedExperience;
  String? _selectedBarangay;
  String? _barangayClearanceFileName;
  String? _barangayClearanceBase64;
  bool _agreeToTerms = false;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;
  bool _isPickingFile = false;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _pickBarangayClearance() async {
    // Prevent multiple concurrent file picks
    if (_isPickingFile) {
      _showErrorMessage('File picker is already open. Please wait for the current operation to complete.');
      return;
    }

    // Check if file picker is already active globally
    if (FilePickerService.isPickerActive) {
      _showErrorMessage('Another file picker operation is in progress. Please wait and try again.');
      return;
    }

    setState(() => _isPickingFile = true);

    try {
      debugPrint('DEBUG: Starting file picker...');
      // Get both filename and base64 data in single call
      final result = await FilePickerService.pickImageWithBase64();
      debugPrint('DEBUG: File picker result: ${result != null ? 'Success' : 'Cancelled'}');
      
      if (result != null && mounted) {
        debugPrint('DEBUG: File selected - Name: ${result.fileName}, Base64 length: ${result.base64Data.length}');
        setState(() {
          _barangayClearanceFileName = result.fileName;
          _barangayClearanceBase64 = result.base64Data;
        });
        
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('File "${result.fileName}" uploaded successfully!'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
        debugPrint('DEBUG: File upload state updated successfully');
      } else if (result == null) {
        debugPrint('DEBUG: File selection was cancelled by user');
      }
    } catch (e) {
      debugPrint('DEBUG: File picker error: $e');
      if (!mounted) return;
      
      String errorMessage = e.toString();
      // Remove "Exception: " prefix if present
      if (errorMessage.startsWith('Exception: ')) {
        errorMessage = errorMessage.substring(11);
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isPickingFile = false);
      }
    }
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedSkill == null) {
      _showErrorMessage('Please select your primary skill');
      return;
    }

    if (_selectedExperience == null) {
      _showErrorMessage('Please select your years of experience');
      return;
    }

    if (_selectedBarangay == null) {
      _showErrorMessage('Please select your barangay');
      return;
    }

    if (_barangayClearanceBase64 == null) {
      _showErrorMessage('Please upload your barangay clearance image');
      return;
    }

    if (!_agreeToTerms) {
      _showErrorMessage('Please agree to the terms of service and privacy policy');
      return;
    }

    // Check if Supabase is initialized
    if (!SupabaseService.isInitialized) {
      _showErrorMessage('Database connection not available. Please check your configuration.');
      return;
    }

    debugPrint('DEBUG: Starting registration process...');
    debugPrint('DEBUG: Base64 data length: ${_barangayClearanceBase64?.length ?? 0}');
    debugPrint('DEBUG: File name: $_barangayClearanceFileName');

    setState(() => _isLoading = true);

    try {
      // Format phone number to include +63 prefix
      String phoneNumber = _phoneController.text.trim();
      if (!phoneNumber.startsWith('+63')) {
        phoneNumber = '+63$phoneNumber';
      }

      debugPrint('DEBUG: Calling HelperAuthService.registerHelper...');
      final result = await HelperAuthService.registerHelper(
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        email: _emailController.text.trim(),
        phone: phoneNumber,
        password: _passwordController.text,
        skill: _selectedSkill!,
        experience: _selectedExperience!,
        barangay: _selectedBarangay!,
        barangayClearanceBase64: _barangayClearanceBase64,
      );

      debugPrint('DEBUG: Registration result: ${result['success']}');
      debugPrint('DEBUG: Registration message: ${result['message']}');

      if (!mounted) return;

      if (result['success']) {
        // Registration successful
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${result['message']} Please log in to continue.'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 4),
          ),
        );

        // Navigate to login screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const LoginScreen(userType: 'Helper'),
          ),
        );
      } else {
        // Registration failed
        _showErrorMessage(result['message']);
      }
    } catch (e) {
      debugPrint('DEBUG: Registration exception: $e');
      if (!mounted) return;
      _showErrorMessage('Registration failed: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.only(top: 8, left: 8),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(24),
              onTap: () => Navigator.pop(context),
              child: const Padding(
                padding: EdgeInsets.all(12),
                child: Icon(Icons.arrow_back, color: Color(0xFFFF8A50)),
              ),
            ),
          ),
        ),
        title: const Text(
          'Helper Registration',
          style: TextStyle(
            color: Color(0xFFFF8A50),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Personal Information Section
              const SectionHeader(title: 'Personal Information'),

              CustomTextField(
                controller: _firstNameController,
                label: 'First Name',
                hint: 'Enter your first name',
                validator: (value) => FormValidators.validateRequired(value, 'first name'),
              ),

              CustomTextField(
                controller: _lastNameController,
                label: 'Last Name',
                hint: 'Enter your last name',
                validator: (value) => FormValidators.validateRequired(value, 'last name'),
              ),

              CustomTextField(
                controller: _emailController,
                label: 'Email',
                hint: 'Enter your email address',
                keyboardType: TextInputType.emailAddress,
                validator: FormValidators.validateEmail,
              ),

              PhoneTextField(
                controller: _phoneController,
                validator: FormValidators.validatePhoneNumber,
              ),

              // Skills & Experience Section
              const SectionHeader(title: 'Skills & Experience'),

              SkillsDropdown(
                selectedSkill: _selectedSkill,
                skillsList: HelperConstants.skills,
                onChanged: (String? value) {
                  setState(() {
                    _selectedSkill = value;
                  });
                },
              ),

              ExperienceDropdown(
                selectedExperience: _selectedExperience,
                experienceList: HelperConstants.experienceLevels,
                onChanged: (String? value) {
                  setState(() {
                    _selectedExperience = value;
                  });
                },
              ),

              // Location Section
              const SectionHeader(title: 'Location'),

              BarangayDropdown(
                selectedBarangay: _selectedBarangay,
                barangayList: LocationConstants.boholMunicipalities,
                label: 'Municipality in Bohol',
                hint: 'Select Municipality',
                onChanged: (String? value) {
                  setState(() {
                    _selectedBarangay = value;
                  });
                },
              ),

              // Document Upload Section
              const SectionHeader(title: 'Required Documents'),

              FileUploadField(
                label: 'Barangay Clearance Image',
                fileName: _barangayClearanceFileName,
                onTap: _isPickingFile ? null : _pickBarangayClearance,
                placeholder: _isPickingFile 
                    ? 'Selecting file...' 
                    : 'Upload Barangay Clearance Image (JPG, PNG)',
                isLoading: _isPickingFile,
              ),

              // Security Section
              const SectionHeader(title: 'Security'),

              CustomTextField(
                controller: _passwordController,
                label: 'Password',
                hint: 'Create a strong password',
                isPassword: true,
                isPasswordVisible: _isPasswordVisible,
                onPasswordToggle: () {
                  setState(() {
                    _isPasswordVisible = !_isPasswordVisible;
                  });
                },
                validator: FormValidators.validatePassword,
              ),

              CustomTextField(
                controller: _confirmPasswordController,
                label: 'Verify Password',
                hint: 'Re-enter your password',
                isPassword: true,
                isPasswordVisible: _isConfirmPasswordVisible,
                onPasswordToggle: () {
                  setState(() {
                    _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                  });
                },
                validator: (value) => FormValidators.validateConfirmPassword(
                  value, 
                  _passwordController.text
                ),
              ),

              // Terms and Conditions
              TermsAgreementCheckbox(
                isAgreed: _agreeToTerms,
                onChanged: (bool value) {
                  setState(() {
                    _agreeToTerms = value;
                  });
                },
              ),
              const SizedBox(height: 32),

              // Register Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _register,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF8A50),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'Register as Helper',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
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

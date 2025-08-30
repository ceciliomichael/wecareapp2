import 'package:flutter/material.dart';
import '../../models/employer.dart';
import '../../services/session_service.dart';
import '../../services/employer_auth_service.dart';
import '../../widgets/forms/custom_text_field.dart';
import '../../widgets/forms/barangay_dropdown.dart';
import '../../widgets/forms/file_upload_field.dart';
import '../../services/file_picker_service.dart';
import '../../utils/constants/barangay_constants.dart';
import '../../utils/validators/form_validators.dart';

class EditEmployerProfileScreen extends StatefulWidget {
  final Employer employer;

  const EditEmployerProfileScreen({
    super.key,
    required this.employer,
  });

  @override
  State<EditEmployerProfileScreen> createState() => _EditEmployerProfileScreenState();
}

class _EditEmployerProfileScreenState extends State<EditEmployerProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  
  String? _selectedBarangay;
  String? _barangayClearanceFileName;
  String? _barangayClearanceBase64;
  bool _isLoading = false;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _initializeFields();
  }

  void _initializeFields() {
    _firstNameController.text = widget.employer.firstName;
    _lastNameController.text = widget.employer.lastName;
    _selectedBarangay = widget.employer.barangay;
    _barangayClearanceBase64 = widget.employer.barangayClearanceBase64;
    
    // Add listeners to detect changes
    _firstNameController.addListener(_onFieldChanged);
    _lastNameController.addListener(_onFieldChanged);
  }

  void _onFieldChanged() {
    if (!_hasChanges) {
      setState(() {
        _hasChanges = true;
      });
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  Future<void> _pickBarangayClearance() async {
    try {
      final result = await FilePickerService.pickImageWithBase64();
      
      if (result != null && mounted) {
        setState(() {
          _barangayClearanceFileName = result.fileName;
          _barangayClearanceBase64 = result.base64Data;
          _hasChanges = true;
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error picking image: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_hasChanges) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No changes to save'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final result = await EmployerAuthService.updateEmployerProfile(
        id: widget.employer.id,
        firstName: _firstNameController.text.trim() != widget.employer.firstName 
            ? _firstNameController.text.trim() 
            : null,
        lastName: _lastNameController.text.trim() != widget.employer.lastName 
            ? _lastNameController.text.trim() 
            : null,
        barangay: _selectedBarangay != widget.employer.barangay 
            ? _selectedBarangay 
            : null,
        barangayClearanceBase64: _barangayClearanceBase64 != widget.employer.barangayClearanceBase64 
            ? _barangayClearanceBase64 
            : null,
      );

      if (!mounted) return;

      if (result['success']) {
        // Update session with new data
        await SessionService.updateCurrentUser(result['employer'].toMap());
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message']),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pop(context, true); // Return true to indicate changes were saved
      } else {
        _showErrorMessage(result['message']);
      }
    } catch (e) {
      if (!mounted) return;
      _showErrorMessage('Update failed: $e');
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
    return Scaffold(
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
                child: Icon(Icons.arrow_back, color: Color(0xFF1565C0)),
              ),
            ),
          ),
        ),
        title: const Text(
          'Edit Profile',
          style: TextStyle(
            color: Color(0xFF1565C0),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          if (_hasChanges)
            Container(
              margin: const EdgeInsets.only(right: 16),
              child: TextButton(
                onPressed: _isLoading ? null : _saveProfile,
                child: const Text(
                  'Save',
                  style: TextStyle(
                    color: Color(0xFF1565C0),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF1565C0).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1565C0),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: const Icon(
                        Icons.person,
                        size: 30,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      widget.employer.fullName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1565C0),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Employer Profile',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Personal Information Section
              _buildSectionHeader('Personal Information'),
              const SizedBox(height: 16),

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

              const SizedBox(height: 24),

              // Contact Information Section
              _buildSectionHeader('Contact Information'),
              const SizedBox(height: 16),

              _buildReadOnlyField('Email', widget.employer.email),
              _buildReadOnlyField('Phone', widget.employer.phone),

              const SizedBox(height: 24),

              // Location Section
              _buildSectionHeader('Location'),
              const SizedBox(height: 16),

              BarangayDropdown(
                selectedBarangay: _selectedBarangay,
                barangayList: BarangayConstants.tagbilaranBarangays,
                onChanged: (String? value) {
                  setState(() {
                    _selectedBarangay = value;
                    _hasChanges = true;
                  });
                },
              ),

              const SizedBox(height: 24),

              // Documents Section
              _buildSectionHeader('Documents'),
              const SizedBox(height: 16),

              FileUploadField(
                label: 'Barangay Clearance Image',
                fileName: _barangayClearanceFileName ?? 
                    (widget.employer.barangayClearanceBase64 != null ? 'Current document' : null),
                onTap: _pickBarangayClearance,
                placeholder: 'Upload Barangay Clearance Image (JPG, PNG)',
              ),

              const SizedBox(height: 32),

              // Save Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading || !_hasChanges ? null : _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1565C0),
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.grey[300],
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
                      : Text(
                          _hasChanges ? 'Save Changes' : 'No Changes',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Color(0xFF1565C0),
      ),
    );
  }

  Widget _buildReadOnlyField(String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1565C0),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Text(
              value,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

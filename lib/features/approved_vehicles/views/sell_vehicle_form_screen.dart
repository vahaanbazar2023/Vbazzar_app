import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/design_system/templates/app_layout.dart';
import '../../../core/design_system/tokens/app_spacing.dart';
import '../../../theme/app_fonts.dart';
import '../controllers/approved_vehicle_controller.dart';

class SellVehicleFormScreen extends StatefulWidget {
  const SellVehicleFormScreen({super.key});

  @override
  State<SellVehicleFormScreen> createState() => _SellVehicleFormScreenState();
}

class _SellVehicleFormScreenState extends State<SellVehicleFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _ctrl = Get.find<ApprovedVehicleController>();

  // Form fields
  String? _selectedCategory;
  final _regNoController = TextEditingController();
  final _chassisController = TextEditingController();
  final _brandController = TextEditingController();
  final _yearController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();
  String? _selectedState;
  String? _selectedCity;
  bool _fitnessAvailable = false;
  bool _invoiceAvailable = false;
  bool _gstApplicable = false;
  final _insuranceDateController = TextEditingController();

  // File names (placeholder - integrate with file_picker when package is added)
  final List<String> _images = [];
  final List<String> _rcDocuments = [];
  final List<String> _insuranceDocs = [];

  final _categories = [
    'Truck', 'Bus', 'Tipper', 'Excavator',
    'Trailer', 'Crane', 'JCB', 'Other'
  ];

  final _states = [
    'Maharashtra', 'Delhi', 'Karnataka', 'Tamil Nadu',
    'Gujarat', 'Rajasthan', 'Uttar Pradesh', 'West Bengal',
    'Telangana', 'Andhra Pradesh', 'Madhya Pradesh', 'Punjab',
    'Haryana', 'Bihar', 'Kerala', 'Odisha', 'Other'
  ];

  @override
  void dispose() {
    _regNoController.dispose();
    _chassisController.dispose();
    _brandController.dispose();
    _yearController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    _insuranceDateController.dispose();
    super.dispose();
  }

  Future<void> _pickFiles(List<String> target, {bool imageOnly = false}) async {
    // TODO: Add file_picker package to pubspec.yaml and uncomment below
    // final result = await FilePicker.platform.pickFiles(
    //   allowMultiple: true,
    //   type: imageOnly ? FileType.image : FileType.any,
    // );
    // if (result != null) {
    //   setState(() {
    //     target.addAll(result.names.whereType<String>());
    //   });
    // }
    
    // Placeholder: simulate file selection
    setState(() {
      target.add('sample_file_${target.length + 1}.jpg');
    });
    Get.snackbar(
      'Info',
      'File picker integration pending. Add file_picker package to enable uploads.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.grey100,
      colorText: AppColors.black,
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    // Populate controller fields from local form state
    if (_selectedCategory != null) {
      _ctrl.sellCategoryCodeC.text = _selectedCategory!;
      _ctrl.sellCategoryNameC.text = _selectedCategory!;
    }
    _ctrl.sellRegNumberC.text = _regNoController.text;
    _ctrl.sellChassisC.text = _chassisController.text;
    _ctrl.sellBrandC.text = _brandController.text;
    _ctrl.sellAssetDescC.text = _descriptionController.text;
    _ctrl.sellPriceC.text = _priceController.text;
    _ctrl.sellMfgYear.value = _yearController.text;
    _ctrl.sellStateC.text = _selectedState ?? '';
    _ctrl.sellCityC.text = _selectedCity ?? '';
    _ctrl.sellFitness.value = _fitnessAvailable ? 'Yes' : 'No';
    _ctrl.sellOriginalInvoice.value = _invoiceAvailable ? 'Yes' : 'No';
    _ctrl.sellGSTApplicability.value = _gstApplicable ? 'Yes' : 'No';
    _ctrl.sellVehicleImages.assignAll(_images);
    _ctrl.sellRCFiles.assignAll(_rcDocuments);
    _ctrl.sellInsuranceFiles.assignAll(_insuranceDocs);

    _ctrl.submitSellFormData();
  }

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      title: 'Sell Your Vehicle',
      subtitle: 'Submit your vehicle for approval',
      body: SingleChildScrollView(
        padding: EdgeInsets.all(AppSpacing.md),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader('Vehicle Details'),
              SizedBox(height: AppSpacing.sm),
              _buildDropdown('Category *', _selectedCategory, _categories,
                  (v) => setState(() => _selectedCategory = v)),
              SizedBox(height: AppSpacing.md),
              _buildTextField(_regNoController, 'Registration Number *',
                  hint: 'e.g., MH01AB1234'),
              _buildTextField(_chassisController, 'Chassis Number *'),
              _buildTextField(_brandController, 'Brand *',
                  hint: 'e.g., Tata, Ashok Leyland'),
              _buildTextField(_yearController, 'Year of Manufacturing *',
                  keyboardType: TextInputType.number),
              _buildTextField(_priceController, 'Expected Price (₹) *',
                  keyboardType: TextInputType.number),
              _buildTextField(_descriptionController, 'Asset Description',
                  hint: 'e.g., Tata Signa 2823.T 6x4', maxLines: 2),

              SizedBox(height: AppSpacing.lg),
              _buildSectionHeader('Location'),
              SizedBox(height: AppSpacing.sm),
              _buildDropdown('State *', _selectedState, _states,
                  (v) => setState(() => _selectedState = v)),
              SizedBox(height: AppSpacing.md),
              _buildTextField(
                TextEditingController(text: _selectedCity ?? ''),
                'City *',
                onChanged: (v) => _selectedCity = v,
              ),

              SizedBox(height: AppSpacing.lg),
              _buildSectionHeader('Additional Info'),
              SizedBox(height: AppSpacing.sm),
              _buildSwitchTile('Fitness Certificate Available', _fitnessAvailable,
                  (v) => setState(() => _fitnessAvailable = v)),
              _buildSwitchTile('Original Invoice Available', _invoiceAvailable,
                  (v) => setState(() => _invoiceAvailable = v)),
              _buildSwitchTile('GST Applicable', _gstApplicable,
                  (v) => setState(() => _gstApplicable = v)),
              _buildTextField(_insuranceDateController, 'Insurance Valid Until',
                  hint: 'DD/MM/YYYY', readOnly: true,
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now().add(const Duration(days: 365)),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 3650)),
                    );
                    if (date != null) {
                      _insuranceDateController.text =
                          '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
                    }
                  }),

              SizedBox(height: AppSpacing.lg),
              _buildSectionHeader('Documents & Photos'),
              SizedBox(height: AppSpacing.sm),
              _buildFilePicker('Vehicle Photos *', _images, imageOnly: true),
              _buildFilePicker('RC Documents', _rcDocuments),
              _buildFilePicker('Insurance Documents', _insuranceDocs),

              SizedBox(height: AppSpacing.xxl),
              Obx(() => SizedBox(
                    width: double.infinity,
                    height: 48.h,
                    child: ElevatedButton(
                      onPressed: _ctrl.isSubmittingSellForm.value
                          ? null
                          : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        elevation: 0,
                      ),
                      child: _ctrl.isSubmittingSellForm.value
                          ? SizedBox(
                              height: 20.h,
                              width: 20.w,
                              child: const CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              'Submit Vehicle',
                              style: TextStyle(
                                fontFamily: 'Montserrat',
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                    ),
                  )),
              SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: TextStyle(
        fontFamily: 'Montserrat',
        fontSize: 15.sp,
        fontWeight: FontWeight.w700,
        color: AppColors.black,
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    String? hint,
    TextInputType? keyboardType,
    int maxLines = 1,
    bool readOnly = false,
    VoidCallback? onTap,
    ValueChanged<String>? onChanged,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: AppFonts.bodySmall.copyWith(
                color: AppColors.grey700,
                fontWeight: FontWeight.w500,
              )),
          SizedBox(height: 4.h),
          TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            maxLines: maxLines,
            readOnly: readOnly,
            onTap: onTap,
            onChanged: onChanged,
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 13.sp,
              color: AppColors.black,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                color: AppColors.grey400,
                fontSize: 13.sp,
                fontFamily: 'Montserrat',
              ),
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
                borderSide: BorderSide(color: AppColors.grey300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
                borderSide: BorderSide(color: AppColors.grey300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
                borderSide: BorderSide(color: AppColors.primary, width: 1.5),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
                borderSide: BorderSide(color: AppColors.error),
              ),
            ),
            validator: label.contains('*')
                ? (v) => (v == null || v.isEmpty) ? 'Required' : null
                : null,
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown(String label, String? value, List<String> items,
      ValueChanged<String?> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: AppFonts.bodySmall.copyWith(
              color: AppColors.grey700,
              fontWeight: FontWeight.w500,
            )),
        SizedBox(height: 4.h),
        DropdownButtonFormField<String>(
          value: value,
          items: items
              .map((e) => DropdownMenuItem(
                    value: e,
                    child: Text(e,
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 13.sp,
                          color: AppColors.black,
                        )),
                  ))
              .toList(),
          onChanged: onChanged,
          decoration: InputDecoration(
            contentPadding:
                EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: BorderSide(color: AppColors.grey300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: BorderSide(color: AppColors.grey300),
            ),
          ),
          validator: label.contains('*')
              ? (v) => v == null ? 'Required' : null
              : null,
          icon: Icon(Icons.keyboard_arrow_down_rounded,
              color: AppColors.grey500),
          isExpanded: true,
        ),
      ],
    );
  }

  Widget _buildSwitchTile(String label, bool value, ValueChanged<bool> onChanged) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(label,
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.black,
                )),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildFilePicker(String label, List<String> files, {bool imageOnly = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: AppFonts.bodySmall.copyWith(
                color: AppColors.grey700,
                fontWeight: FontWeight.w500,
              )),
          SizedBox(height: 4.h),
          GestureDetector(
            onTap: () => _pickFiles(files, imageOnly: imageOnly),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 20.h),
              decoration: BoxDecoration(
                color: AppColors.grey100.withOpacity(0.5),
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(color: AppColors.grey300, style: BorderStyle.solid),
              ),
              child: Column(
                children: [
                  Icon(Icons.cloud_upload_outlined,
                      size: 32.w, color: AppColors.grey500),
                  SizedBox(height: 6.h),
                  Text(
                    'Tap to upload',
                    style: AppFonts.bodySmall.copyWith(color: AppColors.grey500),
                  ),
                ],
              ),
            ),
          ),
          if (files.isNotEmpty) ...[
            SizedBox(height: 8.h),
            Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: files.asMap().entries.map((entry) {
                      final name = entry.value;
                return Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.attach_file, size: 14.w, color: AppColors.primary),
                      SizedBox(width: 4.w),
                      ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: 120.w),
                        child: Text(name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppFonts.bodySmall
                                .copyWith(color: AppColors.primary)),
                      ),
                      SizedBox(width: 4.w),
                      GestureDetector(
                        onTap: () => setState(() => files.removeAt(entry.key)),
                        child: Icon(Icons.close,
                            size: 14.w, color: AppColors.error),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/design_system/molecules/custom_autocomplete_field.dart';
import '../../../core/design_system/molecules/inline_dropdown_field.dart';
import '../controllers/vehicle_detail_controller.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Entry point — call this to open the filter sheet
// ─────────────────────────────────────────────────────────────────────────────

void showBuyFilterSheet(BuildContext context, BuyVehicleController controller) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => BuyFilterSheet(controller: controller),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// BuyFilterSheet — dynamic height, wraps content exactly
// ─────────────────────────────────────────────────────────────────────────────

class BuyFilterSheet extends StatefulWidget {
  final BuyVehicleController controller;
  const BuyFilterSheet({super.key, required this.controller});

  @override
  State<BuyFilterSheet> createState() => _BuyFilterSheetState();
}

class _BuyFilterSheetState extends State<BuyFilterSheet> {
  late Map<String, String> _labels; // display labels
  late Map<String, String> _values; // API values

  @override
  void initState() {
    super.initState();
    _labels = {};
    _values = {};
    for (final e in widget.controller.appliedFilters.entries) {
      _values[e.key] = e.value.toString();
      _labels[e.key] = e.value.toString();
    }
  }

  void _select(String key, String label, String value) => setState(() {
    _labels[key] = label;
    _values[key] = value;
  });

  void _clear(String key) => setState(() {
    _labels.remove(key);
    _values.remove(key);
  });

  void _apply() {
    final toRemove = widget.controller.appliedFilters.keys
        .where((k) => !_values.containsKey(k))
        .toList();
    for (final k in toRemove) widget.controller.applyFilter(k, null);
    for (final e in _values.entries)
      widget.controller.applyFilter(e.key, e.value);
    widget.controller.applyFiltersAndFetch();
    Navigator.pop(context);
  }

  void _reset() => setState(() {
    _labels.clear();
    _values.clear();
  });

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      // Let SafeArea + Column determine height — no fixed height
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Drag handle ────────────────────────────────────────────────
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 12, bottom: 4),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.grey300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            // ── Header ────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 8, 0),
              child: Row(
                children: [
                  Text(
                    'Filters',
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 17.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: _reset,
                    child: Text(
                      'Reset',
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                        fontSize: 14.sp,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),

            // ── Filter fields — shrink-wrapped, no fixed height ────────────
            Flexible(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(20, 14, 20, bottomPad + 8),
                child: Obx(() {
                  if (widget.controller.isLoadingFilters.value) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 32),
                      child: Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                        ),
                      ),
                    );
                  }
                  final opts = widget.controller.dynamicFilterOptions;
                  if (opts.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: Center(
                        child: Text(
                          'No filters available',
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            color: AppColors.grey500,
                          ),
                        ),
                      ),
                    );
                  }
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ...opts.entries.map((entry) {
                        final key = entry.key;
                        final def = entry.value as Map<String, dynamic>? ?? {};
                        final source = def['source']?.toString();
                        final staticOptions = def['options'] as List<dynamic>?;

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 20),
                          child: _FilterField(
                            filterKey: key,
                            source: source,
                            staticOptions: staticOptions,
                            selectedLabel: _labels[key],
                            selectedValue: _values[key],
                            controller: widget.controller,
                            onSelected: _select,
                            onCleared: _clear,
                          ),
                        );
                      }),
                      // ── Apply button ───────────────────────────────────
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _apply,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            'Apply Filters',
                            style: TextStyle(
                              fontFamily: 'Montserrat',
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Individual filter field widget
// ─────────────────────────────────────────────────────────────────────────────

class _FilterField extends StatelessWidget {
  final String filterKey;
  final String? source;
  final List<dynamic>? staticOptions;
  final String? selectedLabel;
  final String? selectedValue;
  final BuyVehicleController controller;
  final void Function(String key, String label, String value) onSelected;
  final void Function(String key) onCleared;

  const _FilterField({
    required this.filterKey,
    required this.source,
    required this.staticOptions,
    required this.selectedLabel,
    required this.selectedValue,
    required this.controller,
    required this.onSelected,
    required this.onCleared,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── Label row ────────────────────────────────────────────────────
        Row(
          children: [
            Text(
              filterKey,
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            if (selectedValue != null) ...[
              const Spacer(),
              GestureDetector(
                onTap: () => onCleared(filterKey),
                child: const Icon(
                  Icons.close_rounded,
                  size: 16,
                  color: AppColors.primary,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        // ── Field ────────────────────────────────────────────────────────
        if (filterKey == 'Brand' && source == 'master')
          _BrandField(
            controller: controller,
            selected: selectedLabel,
            onSelected: (l, v) => onSelected(filterKey, l, v),
          )
        else if (filterKey == 'State' && source == 'master')
          _StateField(
            controller: controller,
            selected: selectedLabel,
            onSelected: (l, v) => onSelected(filterKey, l, v),
          )
        else if (staticOptions != null && staticOptions!.isNotEmpty)
          _StaticField(
            hint: 'Select $filterKey',
            selected: selectedValue,
            options: staticOptions!.map((o) {
              if (o is Map<String, dynamic>) {
                return _Opt(
                  o['value']?.toString() ?? '',
                  o['label']?.toString() ?? o['value']?.toString() ?? '',
                );
              }
              return _Opt(o.toString(), o.toString());
            }).toList(),
            onSelected: (opt) => onSelected(filterKey, opt.label, opt.value),
          )
        else
          TextField(
            onChanged: (v) => onSelected(filterKey, v, v),
            style: TextStyle(fontFamily: 'Montserrat', fontSize: 14.sp),
            decoration: InputDecoration(
              hintText: 'Enter $filterKey',
              hintStyle: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 14.sp,
                color: AppColors.grey400,
              ),
              filled: true,
              fillColor: AppColors.grey50,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 12,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.grey300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.grey300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(
                  color: AppColors.primary,
                  width: 1.5,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Brand autocomplete (master source)
// ─────────────────────────────────────────────────────────────────────────────

class _BrandField extends StatefulWidget {
  final BuyVehicleController controller;
  final String? selected;
  final void Function(String label, String value) onSelected;
  const _BrandField({
    required this.controller,
    required this.selected,
    required this.onSelected,
  });

  @override
  State<_BrandField> createState() => _BrandFieldState();
}

class _BrandFieldState extends State<_BrandField> {
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.selected ?? '');
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => CustomAutocompleteField<_Opt>(
        controller: _ctrl,
        options: widget.controller.brands
            .map((b) => _Opt(b.brandCode, b.brandName))
            .toList(),
        placeholder: widget.controller.isLoadingFilters.value
            ? 'Loading...'
            : 'Search brand',
        prefixIcon: Icons.branding_watermark_outlined,
        isLoading: widget.controller.isLoadingFilters.value,
        displayStringForOption: (o) => o.label,
        forceSelection: true,
        maxDropdownHeight: 200,
        onSelected: (o) {
          if (o != null) widget.onSelected(o.label, o.value);
        },
        onChanged: (_) {},
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// State autocomplete (master source)
// ─────────────────────────────────────────────────────────────────────────────

class _StateField extends StatefulWidget {
  final BuyVehicleController controller;
  final String? selected;
  final void Function(String label, String value) onSelected;
  const _StateField({
    required this.controller,
    required this.selected,
    required this.onSelected,
  });

  @override
  State<_StateField> createState() => _StateFieldState();
}

class _StateFieldState extends State<_StateField> {
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.selected ?? '');
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => CustomAutocompleteField<_Opt>(
        controller: _ctrl,
        options: widget.controller.filterStates
            .map((s) => _Opt(s['state_id'] ?? '', s['state_name'] ?? ''))
            .toList(),
        placeholder: widget.controller.isLoadingFilterStates.value
            ? 'Loading...'
            : 'Search state',
        prefixIcon: Icons.location_on_outlined,
        isLoading: widget.controller.isLoadingFilterStates.value,
        displayStringForOption: (o) => o.label,
        forceSelection: true,
        maxDropdownHeight: 200,
        onSelected: (o) {
          if (o != null) widget.onSelected(o.label, o.value);
        },
        onChanged: (_) {},
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Static dropdown using InlineDropdownField
// ─────────────────────────────────────────────────────────────────────────────

class _StaticField extends StatelessWidget {
  final String hint;
  final String? selected;
  final List<_Opt> options;
  final void Function(_Opt) onSelected;
  const _StaticField({
    required this.hint,
    required this.selected,
    required this.options,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final sel = selected == null
        ? null
        : options.firstWhereOrNull((o) => o.value == selected);
    return InlineDropdownField<_Opt>(
      value: sel,
      items: options,
      placeholder: hint,
      itemLabel: (o) => o.label,
      height: 46,
      onChanged: (o) {
        if (o != null) onSelected(o);
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Simple option model
// ─────────────────────────────────────────────────────────────────────────────

class _Opt {
  final String value;
  final String label;
  const _Opt(this.value, this.label);
}

import 'package:customer_app/src/core/layout/app_responsive.dart';
import 'package:customer_app/src/core/widgets/app_notice.dart';
import 'package:customer_app/src/features/checkout/data/models/checkout_draft.dart';
import 'package:customer_app/src/features/checkout/presentation/pages/payment_method_page.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class DeliveryAddressPage extends StatefulWidget {
  const DeliveryAddressPage({super.key});

  static const String routeName = '/delivery-address';

  @override
  State<DeliveryAddressPage> createState() => _DeliveryAddressPageState();
}

class _DeliveryAddressPageState extends State<DeliveryAddressPage> {
  final TextEditingController _streetController = TextEditingController();
  final TextEditingController _houseController = TextEditingController();
  final TextEditingController _apartmentController = TextEditingController();
  final TextEditingController _floorController = TextEditingController();
  final TextEditingController _zipController = TextEditingController();
  final TextEditingController _commentController = TextEditingController();
  bool _isLocating = false;
  double? _latitude;
  double? _longitude;
  String? _gpsSummary;

  String _selectedCity = 'القاهرة';
  String _selectedDate = 'Today';
  String _selectedTime = '09:00 AM';

  static const List<String> _cities = [
    'القاهرة',
    'الجيزة',
    'الإسكندرية',
    'المنصورة',
    'طنطا',
  ];

  static const List<String> _dates = [
    'Today',
    'Tomorrow',
    'This weekend',
  ];

  static const List<String> _times = [
    '09:00 AM',
    '11:00 AM',
    '01:00 PM',
    '03:00 PM',
    '06:00 PM',
  ];

  @override
  void dispose() {
    _streetController.dispose();
    _houseController.dispose();
    _apartmentController.dispose();
    _floorController.dispose();
    _zipController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isSmallPhone = context.isSmallPhone;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      body: SafeArea(
        child: Column(
          children: [
            _AddressTopBar(onBack: () => Navigator.of(context).pop()),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(14, 14, 14, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          color: Color(0xFFFF8B6A),
                          size: 20,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Delivery address',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF4A4E61),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _GpsLocationCard(
                      isLocating: _isLocating,
                      gpsSummary: _gpsSummary,
                      onUseLocation: _captureCurrentLocation,
                    ),
                    const SizedBox(height: 16),
                    const _FieldLabel('City'),
                    const SizedBox(height: 6),
                    _SelectField(
                      value: _selectedCity,
                      items: _cities,
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _selectedCity = value);
                        }
                      },
                    ),
                    const SizedBox(height: 14),
                    const _FieldLabel('Street'),
                    const SizedBox(height: 6),
                    _TextFieldCard(
                      controller: _streetController,
                      hintText: 'Street',
                    ),
                    const SizedBox(height: 14),
                    _ResponsiveTwoColumn(
                      compact: isSmallPhone,
                      first: _LabeledTextField(
                        label: 'House',
                        controller: _houseController,
                        hintText: 'House #',
                      ),
                      second: _LabeledTextField(
                        label: 'Apartment',
                        controller: _apartmentController,
                        hintText: 'Apartment #',
                      ),
                    ),
                    const SizedBox(height: 14),
                    _ResponsiveTwoColumn(
                      compact: isSmallPhone,
                      first: _LabeledTextField(
                        label: 'Floor',
                        controller: _floorController,
                        hintText: 'Floor',
                      ),
                      second: _LabeledTextField(
                        label: 'ZIP Code',
                        controller: _zipController,
                        hintText: 'ZIP Code',
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(height: 14),
                    _ResponsiveTwoColumn(
                      compact: isSmallPhone,
                      first: _SelectFieldBlock(
                        label: 'Delivery Date',
                        value: _selectedDate,
                        items: _dates,
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _selectedDate = value);
                          }
                        },
                      ),
                      second: _SelectFieldBlock(
                        label: 'Delivery Time',
                        value: _selectedTime,
                        items: _times,
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _selectedTime = value);
                          }
                        },
                      ),
                    ),
                    const SizedBox(height: 14),
                    const _FieldLabel('Comment'),
                    const SizedBox(height: 6),
                    _TextFieldCard(
                      controller: _commentController,
                      hintText: 'Street, landmark, or delivery note',
                      maxLines: 3,
                    ),
                    const SizedBox(height: 22),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: () {
                          final street = _streetController.text.trim();
                          if (street.isEmpty) {
                            context.showAppNotice(
                              title: 'Address missing',
                              message: 'Please enter the street before continuing.',
                              type: AppNoticeType.warning,
                            );
                            return;
                          }
                          if (_latitude == null || _longitude == null) {
                            context.showAppNotice(
                              title: 'Location required',
                              message:
                                  'Please use your current GPS location so the driver can reach you.',
                              type: AppNoticeType.warning,
                            );
                            return;
                          }

                          final segments = <String>[
                            _selectedCity,
                            street,
                            if (_houseController.text.trim().isNotEmpty)
                              'House ${_houseController.text.trim()}',
                            if (_apartmentController.text.trim().isNotEmpty)
                              'Apartment ${_apartmentController.text.trim()}',
                            if (_floorController.text.trim().isNotEmpty)
                              'Floor ${_floorController.text.trim()}',
                            if (_zipController.text.trim().isNotEmpty)
                              'ZIP ${_zipController.text.trim()}',
                            if (_commentController.text.trim().isNotEmpty)
                              'Note: ${_commentController.text.trim()}',
                          ];

                          final checkout = CheckoutDraft(
                            addressText: segments.join(', '),
                            lat: _latitude,
                            lng: _longitude,
                            deliveryDate: _selectedDate,
                            deliveryTime: _selectedTime,
                            comment: _commentController.text.trim(),
                          );
                          Navigator.of(context).pushNamed(
                            PaymentMethodPage.routeName,
                            arguments: checkout,
                          );
                        },
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFFF7A998),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text(
                          'SAVE CHANGES',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _captureCurrentLocation() async {
    if (_isLocating) {
      return;
    }

    setState(() {
      _isLocating = true;
    });

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw _LocationMessageException(
          'Please turn on GPS on your phone, then try again.',
        );
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied) {
        throw _LocationMessageException(
          'Location permission is needed to send the driver to your address.',
        );
      }

      if (permission == LocationPermission.deniedForever) {
        throw _LocationMessageException(
          'Location permission is blocked. Please allow it from phone settings.',
        );
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _latitude = position.latitude;
        _longitude = position.longitude;
        _gpsSummary =
            'GPS pinned: ${position.latitude.toStringAsFixed(5)}, ${position.longitude.toStringAsFixed(5)}';
      });

      context.showAppNotice(
        title: 'Location saved',
        message: 'Your current GPS location is ready for the driver.',
        type: AppNoticeType.success,
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      final message = error is _LocationMessageException
          ? error.message
          : 'We could not get your current location. Please try again.';

      context.showAppNotice(
        title: 'Location failed',
        message: message,
        type: AppNoticeType.warning,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLocating = false;
        });
      }
    }
  }
}

class _LocationMessageException implements Exception {
  const _LocationMessageException(this.message);

  final String message;
}

class _ResponsiveTwoColumn extends StatelessWidget {
  const _ResponsiveTwoColumn({
    required this.compact,
    required this.first,
    required this.second,
  });

  final bool compact;
  final Widget first;
  final Widget second;

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return Column(
        children: [
          first,
          const SizedBox(height: 14),
          second,
        ],
      );
    }

    return Row(
      children: [
        Expanded(child: first),
        const SizedBox(width: 12),
        Expanded(child: second),
      ],
    );
  }
}

class _GpsLocationCard extends StatelessWidget {
  const _GpsLocationCard({
    required this.isLocating,
    required this.gpsSummary,
    required this.onUseLocation,
  });

  final bool isLocating;
  final String? gpsSummary;
  final VoidCallback onUseLocation;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.my_location_rounded,
                color: Color(0xFFFF8B6A),
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                'GPS delivery point',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF4A4E61),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            gpsSummary ??
                'Use your current location so the driver can open the map and come directly to you.',
            style: const TextStyle(
              fontSize: 13,
              height: 1.4,
              color: Color(0xFF8E96AA),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: isLocating ? null : onUseLocation,
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFFF8B6A),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              icon: isLocating
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.gps_fixed_rounded),
              label: Text(isLocating ? 'Getting location...' : 'Use current location'),
            ),
          ),
        ],
      ),
    );
  }
}

class _AddressTopBar extends StatelessWidget {
  const _AddressTopBar({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(14, 10, 14, 0),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          InkWell(
            onTap: onBack,
            borderRadius: BorderRadius.circular(12),
            child: const Padding(
              padding: EdgeInsets.all(4),
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 16,
                color: Color(0xFF9BA2B6),
              ),
            ),
          ),
          const Expanded(
            child: Text(
              'Delivery address',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Color(0xFF6A7187),
              ),
            ),
          ),
          const SizedBox(width: 24),
        ],
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: Color(0xFFA0A7BA),
      ),
    );
  }
}

class _LabeledTextField extends StatelessWidget {
  const _LabeledTextField({
    required this.label,
    required this.controller,
    required this.hintText,
    this.keyboardType,
  });

  final String label;
  final TextEditingController controller;
  final String hintText;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FieldLabel(label),
        const SizedBox(height: 6),
        _TextFieldCard(
          controller: controller,
          hintText: hintText,
          keyboardType: keyboardType,
        ),
      ],
    );
  }
}

class _TextFieldCard extends StatelessWidget {
  const _TextFieldCard({
    required this.controller,
    required this.hintText,
    this.keyboardType,
    this.maxLines = 1,
  });

  final TextEditingController controller;
  final String hintText;
  final TextInputType? keyboardType;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(
          color: Color(0xFFC3C8D6),
          fontWeight: FontWeight.w600,
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

class _SelectFieldBlock extends StatelessWidget {
  const _SelectFieldBlock({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final String label;
  final String value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FieldLabel(label),
        const SizedBox(height: 6),
        _SelectField(
          value: value,
          items: items,
          onChanged: onChanged,
        ),
      ],
    );
  }
}

class _SelectField extends StatelessWidget {
  const _SelectField({
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final String value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      onChanged: onChanged,
      icon: const Icon(
        Icons.keyboard_arrow_down_rounded,
        color: Color(0xFFB0B6C6),
      ),
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
      items: items
          .map(
            (item) => DropdownMenuItem<String>(
              value: item,
              child: Text(
                item,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF6A7187),
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

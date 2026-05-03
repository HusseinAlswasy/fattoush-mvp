import 'package:customer_app/src/core/errors/app_error_presenter.dart';
import 'package:customer_app/src/core/state/app_scope.dart';
import 'package:customer_app/src/core/widgets/app_notice.dart';
import 'package:customer_app/src/features/admin/data/services/admin_api_service.dart';
import 'package:customer_app/src/features/admin/presentation/pages/admin_orders_page.dart';
import 'package:customer_app/src/features/auth/presentation/pages/auth_page.dart';
import 'package:customer_app/src/features/home/data/models/product.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  static const String routeName = '/admin-dashboard';

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  static const List<String> _productCategories = [
    'البقالة',
    'المخبوزات',
    'الألبان',
    'الخضار',
    'الفواكه',
    'اللحوم',
    'الفراخ',
    'المجمدات',
    'المشروبات',
    'الحلويات',
    'المنظفات',
    'العناية الشخصية',
    'أخرى',
  ];

  final AdminApiService _adminApiService = AdminApiService();
  final ImagePicker _imagePicker = ImagePicker();
  late Future<_AdminDashboardData> _future;
  bool _didBootstrap = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didBootstrap) {
      return;
    }

    _didBootstrap = true;
    _future = _load();
  }

  Future<_AdminDashboardData> _load() async {
    final session = AppScope.sessionOf(context);
    final token = session.accessToken!;
    late List<dynamic> results;
    try {
      results = await Future.wait([
        _adminApiService.getProducts(token),
        _adminApiService.getDailyReport(token),
        _adminApiService.getMonthlyReport(token),
      ]);
    } catch (_) {
      await Future<void>.delayed(const Duration(milliseconds: 700));
      results = await Future.wait([
        _adminApiService.getProducts(token),
        _adminApiService.getDailyReport(token),
        _adminApiService.getMonthlyReport(token),
      ]);
    }

    return _AdminDashboardData(
      products: results[0] as List<Product>,
      dailyReport: results[1] as Map<String, dynamic>,
      monthlyReport: results[2] as Map<String, dynamic>,
    );
  }

  Future<void> _refresh() async {
    setState(() {
      _future = _load();
    });
    try {
      await _future;
    } catch (_) {
      if (!mounted) {
        return;
      }
      context.showAppNotice(
        title: 'Saved successfully',
        message: 'The change was saved. Pull down or tap retry if the dashboard needs a moment.',
        type: AppNoticeType.info,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = AppScope.sessionOf(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      body: SafeArea(
        child: FutureBuilder<_AdminDashboardData>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Failed to load admin dashboard'),
                      const SizedBox(height: 12),
                      FilledButton(
                        onPressed: _refresh,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              );
            }

            final data = snapshot.data!;
            return RefreshIndicator(
              onRefresh: _refresh,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 24),
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Admin Dashboard',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF4A4E61),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              session.user?.email ?? 'admin@fattoush.app',
                              style: const TextStyle(color: Color(0xFF98A0B4)),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          session.logout();
                          Navigator.of(context).pushNamedAndRemoveUntil(
                            AuthPage.routeName,
                            (route) => false,
                          );
                        },
                        icon: const Icon(Icons.logout_rounded),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          title: 'Today Sales',
                          value: '${data.dailyReport['totalRevenue'] ?? 0}',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatCard(
                          title: 'Orders',
                          value: '${data.dailyReport['totalOrders'] ?? 0}',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          title: 'Monthly Sales',
                          value: '${data.monthlyReport['totalRevenue'] ?? 0}',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatCard(
                          title: 'Items Sold',
                          value: '${data.monthlyReport['totalItemsSold'] ?? 0}',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.of(context).pushNamed(
                              AdminOrdersPage.routeName,
                            );
                          },
                          icon: const Icon(Icons.receipt_long_rounded),
                          label: const Text('Open Orders Page'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Products',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF4A4E61),
                          ),
                        ),
                      ),
                      FilledButton.icon(
                        onPressed: () => _showProductDialog(),
                        icon: const Icon(Icons.add),
                        label: const Text('Add'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ...data.products.map(
                    (product) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _ProductAdminCard(
                        product: product,
                        onEdit: () => _showProductDialog(product: product),
                        onToggleActive: () => _toggleProductActive(product),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _toggleProductActive(Product product) async {
    final session = AppScope.sessionOf(context);
    try {
      await _adminApiService.updateProduct(
        token: session.accessToken!,
        productId: product.id,
        isActive: !product.isActive,
      );
      if (!mounted) {
        return;
      }
      context.showAppNotice(
        title: product.isActive ? 'Product hidden' : 'Product activated',
        message: product.isActive
            ? 'The product will disappear from the customer app after refresh.'
            : 'The product is available for customers again.',
        type: AppNoticeType.success,
      );
      await _refresh();
    } catch (error) {
      if (!mounted) {
        return;
      }
      context.showHandledError(error, fallbackTitle: 'Update failed');
    }
  }

  Future<void> _showProductDialog({Product? product}) async {
    final session = AppScope.sessionOf(context);
    final isEditing = product != null;
    final result = await showDialog<_ProductDialogResult>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _ProductDialog(
        adminApiService: _adminApiService,
        imagePicker: _imagePicker,
        accessToken: session.accessToken!,
        categories: _productCategories,
        product: product,
        normalizedCategory: _normalizeCategory(product?.category),
      ),
    );

    if (!mounted) {
      return;
    }

    if (result?.saved == true) {
      await _refresh();
      if (!mounted) {
        return;
      }
      context.showAppNotice(
        title: isEditing ? 'Product updated' : 'Product added',
        message: isEditing
            ? 'The product changes are live now.'
            : 'The new product has been added successfully.',
        type: AppNoticeType.success,
      );
    }
  }

  String _normalizeCategory(String? category) {
    final value = category?.trim();
    if (value == null || value.isEmpty) {
      return _productCategories.first;
    }

    if (_productCategories.contains(value)) {
      return value;
    }

    return _productCategories.last;
  }
}

class _ProductDialogResult {
  const _ProductDialogResult({required this.saved});

  final bool saved;
}

class _ProductDialog extends StatefulWidget {
  const _ProductDialog({
    required this.adminApiService,
    required this.imagePicker,
    required this.accessToken,
    required this.categories,
    required this.normalizedCategory,
    this.product,
  });

  final AdminApiService adminApiService;
  final ImagePicker imagePicker;
  final String accessToken;
  final List<String> categories;
  final String normalizedCategory;
  final Product? product;

  @override
  State<_ProductDialog> createState() => _ProductDialogState();
}

class _ProductDialogState extends State<_ProductDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _priceController;
  late final TextEditingController _descriptionController;

  late String _selectedCategory;
  late bool _isActive;
  String? _imageUrl;
  XFile? _selectedImage;
  bool _isSaving = false;

  bool get _isEditing => widget.product != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product?.name ?? '');
    _priceController = TextEditingController(
      text: widget.product == null ? '' : widget.product!.price.toStringAsFixed(2),
    );
    _descriptionController = TextEditingController(
      text: widget.product?.description ?? '',
    );
    _selectedCategory = widget.normalizedCategory;
    _isActive = widget.product?.isActive ?? true;
    _imageUrl = widget.product?.imageUrl;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final picked = await widget.imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (picked == null || !mounted) {
        return;
      }

      setState(() {
        _selectedImage = picked;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not open gallery right now. Please try again.'),
        ),
      );
    }
  }

  Future<void> _submit() async {
    setState(() {
      _isSaving = true;
    });

    try {
      var finalImageUrl = _imageUrl;
      if (_selectedImage != null) {
        finalImageUrl = await widget.adminApiService.uploadProductImage(
          token: widget.accessToken,
          imagePath: _selectedImage!.path,
        );
      }

      if (_isEditing) {
        await widget.adminApiService.updateProduct(
          token: widget.accessToken,
          productId: widget.product!.id,
          name: _nameController.text.trim(),
          category: _selectedCategory,
          price: double.tryParse(_priceController.text.trim()) ?? 0,
          description: _descriptionController.text.trim(),
          imageUrl: finalImageUrl,
          isActive: _isActive,
        );
      } else {
        await widget.adminApiService.createProduct(
          token: widget.accessToken,
          name: _nameController.text.trim(),
          category: _selectedCategory,
          price: double.tryParse(_priceController.text.trim()) ?? 0,
          description: _descriptionController.text.trim(),
          imageUrl: finalImageUrl,
          isActive: _isActive,
        );
      }

      if (!mounted) {
        return;
      }
      Navigator.of(context).pop(const _ProductDialogResult(saved: true));
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _isSaving = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppErrorPresenter.present(
              error,
              fallbackTitle: _isEditing ? 'Save failed' : 'Create failed',
            ).message,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(_isEditing ? 'Edit product' : 'Add product'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _DialogField(controller: _nameController, label: 'Name'),
            _DialogDropdownField(
              label: 'Category',
              value: _selectedCategory,
              items: widget.categories,
              onChanged: _isSaving
                  ? null
                  : (value) {
                      if (value == null) {
                        return;
                      }
                      setState(() {
                        _selectedCategory = value;
                      });
                    },
            ),
            _DialogField(
              controller: _priceController,
              label: 'Price',
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
            _DialogField(
              controller: _descriptionController,
              label: 'Description',
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Text(
                    _selectedImage != null
                        ? 'Selected image: ${_selectedImage!.name}'
                        : _imageUrl?.isNotEmpty == true
                            ? 'Current image ready'
                            : 'No image selected',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF7D859A),
                    ),
                  ),
                ),
                TextButton.icon(
                  onPressed: _isSaving ? null : _pickImage,
                  icon: const Icon(Icons.photo_library_outlined),
                  label: const Text('From phone'),
                ),
              ],
            ),
            if (_imageUrl?.isNotEmpty == true && _selectedImage == null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Image.network(
                    _imageUrl!,
                    height: 120,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => Container(
                      height: 120,
                      color: const Color(0xFFF3F5FA),
                      alignment: Alignment.center,
                      child: const Icon(Icons.broken_image_outlined),
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 8),
            SwitchListTile(
              value: _isActive,
              onChanged: _isSaving
                  ? null
                  : (value) {
                      setState(() {
                        _isActive = value;
                      });
                    },
              contentPadding: EdgeInsets.zero,
              title: const Text('Visible for customers'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSaving
              ? null
              : () => Navigator.of(context).pop(const _ProductDialogResult(saved: false)),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _isSaving ? null : _submit,
          child: _isSaving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Text(_isEditing ? 'Save' : 'Create'),
        ),
      ],
    );
  }
}

class _AdminDashboardData {
  const _AdminDashboardData({
    required this.products,
    required this.dailyReport,
    required this.monthlyReport,
  });

  final List<Product> products;
  final Map<String, dynamic> dailyReport;
  final Map<String, dynamic> monthlyReport;
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.title, required this.value});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Color(0xFF98A0B4))),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Color(0xFF4A4E61),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductAdminCard extends StatelessWidget {
  const _ProductAdminCard({
    required this.product,
    required this.onEdit,
    required this.onToggleActive,
  });

  final Product product;
  final VoidCallback onEdit;
  final VoidCallback onToggleActive;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Container(
              width: 64,
              height: 64,
              color: const Color(0xFFF3F5FA),
              child: product.imageUrl?.isNotEmpty == true
                  ? Image.network(
                      product.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) =>
                          const Icon(Icons.broken_image_outlined),
                    )
                  : const Icon(Icons.image_outlined),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF4A4E61),
                  ),
                ),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _Tag(
                      label: product.category ?? 'Other',
                      color: const Color(0xFFFF8B6A),
                    ),
                    _Tag(
                      label: product.isActive ? 'Live' : 'Hidden',
                      color: product.isActive
                          ? const Color(0xFF3BAA64)
                          : const Color(0xFF9CA3B7),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'AED ${product.price.toStringAsFixed(2)}',
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: onEdit,
                    icon: const Icon(Icons.edit_outlined),
                  ),
                  IconButton(
                    onPressed: onToggleActive,
                    icon: Icon(
                      product.isActive
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({
    required this.label,
    required this.color,
  });

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _DialogField extends StatelessWidget {
  const _DialogField({
    required this.controller,
    required this.label,
    this.keyboardType,
  });

  final TextEditingController controller;
  final String label;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }
}

class _DialogDropdownField extends StatelessWidget {
  const _DialogDropdownField({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final String label;
  final String value;
  final List<String> items;
  final ValueChanged<String?>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: DropdownButtonFormField<String>(
        initialValue: value,
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        items: items
            .map(
              (item) => DropdownMenuItem<String>(
                value: item,
                child: Text(item),
              ),
            )
            .toList(growable: false),
      ),
    );
  }
}

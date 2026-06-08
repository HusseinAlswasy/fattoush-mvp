import 'package:customer_app/src/core/errors/app_error_presenter.dart';
import 'package:customer_app/src/core/localization/app_text.dart';
import 'package:customer_app/src/core/state/app_scope.dart';
import 'package:customer_app/src/core/widgets/app_notice.dart';
import 'package:customer_app/src/features/admin/data/services/admin_api_service.dart';
import 'package:customer_app/src/features/admin/presentation/widgets/admin_bottom_nav.dart';
import 'package:customer_app/src/features/home/data/models/product.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AdminProductsPage extends StatefulWidget {
  const AdminProductsPage({super.key});

  static const routeName = '/admin-products';

  @override
  State<AdminProductsPage> createState() => _AdminProductsPageState();
}

class _AdminProductsPageState extends State<AdminProductsPage> {
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
  late Future<List<Product>> _future;
  bool _didBootstrap = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didBootstrap) return;
    _didBootstrap = true;
    _future = _load();
  }

  Future<List<Product>> _load() {
    final session = AppScope.sessionOf(context);
    return _adminApiService.getProducts(session.accessToken!);
  }

  Future<void> _refresh() async {
    setState(() {
      _future = _load();
    });
    await _future;
  }

  Future<void> _showPreviewDialog(Product product) async {
    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          title: Text(product.name),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Container(
                  height: 160,
                  width: double.infinity,
                  color: const Color(0xFFF3F5FA),
                  child: product.imageUrl?.isNotEmpty == true
                      ? Image.network(
                          product.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) =>
                              const Icon(Icons.broken_image_outlined),
                        )
                      : const Icon(Icons.image_outlined, size: 42),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                product.category ?? context.tr('Other', 'أخرى'),
                style: const TextStyle(
                  color: Color(0xFF6B7280),
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                product.description?.trim().isNotEmpty == true
                    ? product.description!
                    : context.tr('No description', 'لا يوجد وصف'),
              ),
              const SizedBox(height: 10),
              Text('AED ${product.price.toStringAsFixed(2)}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(context.tr('Close', 'إغلاق')),
            ),
          ],
        );
      },
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
      if (!mounted) return;
      await _refresh();
      if (!mounted) return;
      context.showAppNotice(
        title: product.isActive
            ? context.tr('Product hidden', 'تم إخفاء المنتج')
            : context.tr('Product activated', 'تم تفعيل المنتج'),
        message: product.isActive
            ? context.tr(
                'The product is now hidden from customers.',
                'المنتج الآن مخفي عن العملاء.',
              )
            : context.tr(
                'The product is available for customers again.',
                'المنتج متاح للعملاء مرة أخرى.',
              ),
        type: AppNoticeType.success,
      );
    } catch (error) {
      if (!mounted) return;
      context.showHandledError(
        error,
        fallbackTitle: context.tr('Update failed', 'فشل التحديث'),
      );
    }
  }

  Future<void> _confirmDeleteProduct(Product product) async {
    final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text(context.tr('Delete product', 'حذف المنتج')),
              content: Text(
                context.tr(
                  'Do you want to permanently delete ${product.name}?',
                  'هل تريد حذف ${product.name} نهائيًا؟',
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text(context.tr('Cancel', 'إلغاء')),
                ),
                FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFFDC2626),
                  ),
                  onPressed: () => Navigator.of(context).pop(true),
                  child: Text(context.tr('Delete', 'حذف')),
                ),
              ],
            );
          },
        ) ??
        false;

    if (!confirmed || !mounted) return;

    final session = AppScope.sessionOf(context);
    try {
      await _adminApiService.deleteProduct(
        token: session.accessToken!,
        productId: product.id,
      );
      if (!mounted) return;
      await _refresh();
      if (!mounted) return;
      context.showAppNotice(
        title: context.tr('Product deleted', 'تم حذف المنتج'),
        message: context.tr(
          '${product.name} was removed permanently.',
          'تم حذف ${product.name} نهائيًا.',
        ),
        type: AppNoticeType.success,
      );
    } catch (error) {
      if (!mounted) return;
      context.showHandledError(
        error,
        fallbackTitle: context.tr('Delete failed', 'فشل الحذف'),
      );
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

    if (!mounted) return;
    if (result?.saved == true) {
      await _refresh();
      if (!mounted) return;
      context.showAppNotice(
        title: isEditing
            ? context.tr('Product updated', 'تم تحديث المنتج')
            : context.tr('Product added', 'تمت إضافة المنتج'),
        message: isEditing
            ? context.tr(
                'The product changes are live now.',
                'تغييرات المنتج أصبحت ظاهرة الآن.',
              )
            : context.tr(
                'The new product has been added successfully.',
                'تمت إضافة المنتج الجديد بنجاح.',
              ),
        type: AppNoticeType.success,
      );
    }
  }

  String _normalizeCategory(String? category) {
    final value = category?.trim();
    if (value == null || value.isEmpty) return _productCategories.first;
    if (_productCategories.contains(value)) return value;
    return _productCategories.last;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      bottomNavigationBar: const AdminBottomNav(
        currentTab: AdminBottomNavTab.products,
      ),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF6F7FB),
        surfaceTintColor: const Color(0xFFF6F7FB),
        title: Text(
          context.tr('Products', 'المنتجات'),
          style: const TextStyle(
            color: Color(0xFF111827),
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showProductDialog(),
        backgroundColor: const Color(0xFF1F8A39),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: Text(context.tr('Add product', 'إضافة منتج')),
      ),
      body: SafeArea(
        child: FutureBuilder<List<Product>>(
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
                      Text(
                        AppErrorPresenter.present(
                          snapshot.error ?? Exception('Unknown error'),
                          fallbackTitle:
                              context.tr('Products failed', 'فشل تحميل المنتجات'),
                        ).message,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      FilledButton(
                        onPressed: _refresh,
                        child: Text(context.tr('Retry', 'إعادة المحاولة')),
                      ),
                    ],
                  ),
                ),
              );
            }

            final products = snapshot.data ?? const <Product>[];
            return RefreshIndicator(
              onRefresh: _refresh,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(18, 14, 18, 100),
                children: [
                  if (products.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(26),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.inventory_2_outlined,
                            size: 42,
                            color: Color(0xFFB8BFCC),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            context.tr(
                              'No products yet',
                              'لا توجد منتجات حتى الآن',
                            ),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF4A4E61),
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    ...products.map(
                      (product) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _ProductAdminCard(
                          product: product,
                          onPreview: () => _showPreviewDialog(product),
                          onEdit: () => _showProductDialog(product: product),
                          onHide: () => _toggleProductActive(product),
                          onDelete: () => _confirmDeleteProduct(product),
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
}

class _ProductDialogResult {
  const _ProductDialogResult({required this.saved});

  final bool saved;
}

class _ProductAdminCard extends StatelessWidget {
  const _ProductAdminCard({
    required this.product,
    required this.onPreview,
    required this.onEdit,
    required this.onHide,
    required this.onDelete,
  });

  final Product product;
  final VoidCallback onPreview;
  final VoidCallback onEdit;
  final VoidCallback onHide;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final statusLabel =
        product.isActive ? context.tr('Live', 'مفعل') : context.tr('Hidden', 'مخفي');
    final statusColor =
        product.isActive ? const Color(0xFF16A34A) : const Color(0xFF94A3B8);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Column(
            children: [
              _MiniActionButton(
                icon: Icons.visibility_outlined,
                onTap: onPreview,
              ),
              const SizedBox(height: 8),
              _MiniActionButton(
                icon: Icons.edit_outlined,
                onTap: onEdit,
              ),
              const SizedBox(height: 8),
              _MiniActionButton(
                icon: product.isActive
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                onTap: onHide,
              ),
              const SizedBox(height: 8),
              _MiniActionButton(
                icon: Icons.delete_outline_rounded,
                onTap: onDelete,
              ),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'AED ${product.price.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 18,
                    color: Color(0xFF4B5563),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _StatusPill(
                      label: statusLabel,
                      color: statusColor,
                    ),
                    _StatusPill(
                      label: product.category ?? context.tr('Other', 'أخرى'),
                      color: const Color(0xFFEF4444),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Container(
              width: 108,
              height: 108,
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
        ],
      ),
    );
  }
}

class _MiniActionButton extends StatelessWidget {
  const _MiniActionButton({
    required this.icon,
    required this.onTap,
  });

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE8EDF3)),
        ),
        child: Icon(icon, size: 18, color: const Color(0xFF374151)),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({
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
          fontSize: 13,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
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
    _descriptionController =
        TextEditingController(text: widget.product?.description ?? '');
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
      if (picked == null || !mounted) return;
      setState(() => _selectedImage = picked);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.tr(
              'Could not open gallery right now. Please try again.',
              'تعذر فتح المعرض الآن. حاول مرة أخرى.',
            ),
          ),
        ),
      );
    }
  }

  Future<void> _submit() async {
    setState(() => _isSaving = true);

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

      if (!mounted) return;
      Navigator.of(context).pop(const _ProductDialogResult(saved: true));
    } catch (error) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppErrorPresenter.present(
              error,
              fallbackTitle: context.tr('Save failed', 'فشل الحفظ'),
            ).message,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      title: Text(
        _isEditing
            ? context.tr('Edit product', 'تعديل المنتج')
            : context.tr('Add product', 'إضافة منتج'),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _DialogField(controller: _nameController, label: context.tr('Name', 'الاسم')),
            _DialogDropdownField(
              label: context.tr('Category', 'التصنيف'),
              value: _selectedCategory,
              items: widget.categories,
              onChanged: _isSaving
                  ? null
                  : (value) {
                      if (value == null) return;
                      setState(() => _selectedCategory = value);
                    },
            ),
            _DialogField(
              controller: _priceController,
              label: context.tr('Price', 'السعر'),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
            _DialogField(
              controller: _descriptionController,
              label: context.tr('Description', 'الوصف'),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Text(
                    _selectedImage != null
                        ? context.tr(
                            'Selected image: ${_selectedImage!.name}',
                            'الصورة المختارة: ${_selectedImage!.name}',
                          )
                        : _imageUrl?.isNotEmpty == true
                            ? context.tr('Current image ready', 'الصورة الحالية جاهزة')
                            : context.tr('No image selected', 'لم يتم اختيار صورة'),
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF7D859A),
                    ),
                  ),
                ),
                TextButton.icon(
                  onPressed: _isSaving ? null : _pickImage,
                  icon: const Icon(Icons.photo_library_outlined),
                  label: Text(context.tr('From phone', 'من الهاتف')),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              value: _isActive,
              onChanged: _isSaving ? null : (value) => setState(() => _isActive = value),
              contentPadding: EdgeInsets.zero,
              title: Text(context.tr('Visible for customers', 'ظاهر للعملاء')),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSaving
              ? null
              : () => Navigator.of(context).pop(
                    const _ProductDialogResult(saved: false),
                  ),
          child: Text(context.tr('Cancel', 'إلغاء')),
        ),
        FilledButton(
          onPressed: _isSaving ? null : _submit,
          child: _isSaving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : Text(_isEditing ? context.tr('Save', 'حفظ') : context.tr('Create', 'إنشاء')),
        ),
      ],
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
          filled: true,
          fillColor: const Color(0xFFF8FAFC),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(color: Color(0xFFE8EDF3)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(color: Color(0xFF1E7B34), width: 1.3),
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
          filled: true,
          fillColor: const Color(0xFFF8FAFC),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(color: Color(0xFFE8EDF3)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(color: Color(0xFF1E7B34), width: 1.3),
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

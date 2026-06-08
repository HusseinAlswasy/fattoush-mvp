import 'package:customer_app/src/core/errors/app_error_presenter.dart';
import 'package:customer_app/src/core/localization/app_text.dart';
import 'package:customer_app/src/core/state/app_scope.dart';
import 'package:customer_app/src/core/widgets/app_notice.dart';
import 'package:customer_app/src/core/widgets/product_image_view.dart';
import 'package:customer_app/src/features/admin/data/services/admin_api_service.dart';
import 'package:customer_app/src/features/admin/presentation/pages/admin_orders_page.dart';
import 'package:customer_app/src/features/admin/presentation/pages/admin_settings_page.dart';
import 'package:customer_app/src/features/admin/presentation/widgets/admin_bottom_nav.dart';
import 'package:customer_app/src/features/admin/utils/product_image_data_url.dart';
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
    if (_didBootstrap) return;
    _didBootstrap = true;
    _future = _load();
  }

  Future<_AdminDashboardData> _load() async {
    final session = AppScope.sessionOf(context);
    final token = session.accessToken!;
    final results = await Future.wait([
      _adminApiService.getProducts(token),
      _adminApiService.getDailyReport(token),
      _adminApiService.getMonthlyReport(token),
    ]);

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
    await _future;
  }

  @override
  Widget build(BuildContext context) {
    final session = AppScope.sessionOf(context);
    final preferences = AppScope.preferencesOf(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      bottomNavigationBar: const AdminBottomNav(
        currentTab: AdminBottomNavTab.home,
      ),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: preferences,
          builder: (context, _) {
            return FutureBuilder<_AdminDashboardData>(
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
                            context.tr(
                              'Failed to load admin dashboard',
                              'فشل تحميل لوحة الأدمن',
                            ),
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

                final data = snapshot.data!;
                final totalOrders = (data.dailyReport['totalOrders'] ?? 0) as num;
                final totalRevenue = (data.dailyReport['totalRevenue'] ?? 0) as num;
                final hiddenCount = data.products.where((p) => !p.isActive).length;

                return RefreshIndicator(
                  onRefresh: _refresh,
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
                    children: [
                      Row(
                        children: [
                          _TopIconButton(
                            icon: Icons.menu_rounded,
                            onTap: () => Navigator.of(context).pushNamed(
                              AdminSettingsPage.routeName,
                            ),
                          ),
                          const SizedBox(width: 10),
                          _TopIconButton(
                            icon: Icons.notifications_none_rounded,
                            onTap: () => Navigator.of(context).pushNamed(
                              AdminOrdersPage.routeName,
                            ),
                            badge: '$totalOrders',
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              children: [
                                const Text(
                                  'Fattoush Admin',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w900,
                                    color: Color(0xFF111827),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  session.user?.name ??
                                      context.tr('Administrator', 'المدير'),
                                  style: const TextStyle(
                                    color: Color(0xFF8A94A6),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          _ProfileAvatarButton(
                            onTap: () => Navigator.of(context).pushNamed(
                              AdminSettingsPage.routeName,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 22),
                      _RevenueCard(revenue: totalRevenue.toDouble()),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _SmallStatCard(
                              icon: Icons.shopping_bag_outlined,
                              count: '$totalOrders',
                              title: context.tr('Orders today', 'الطلبات اليوم'),
                              accent: const Color(0xFF16A34A),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _SmallStatCard(
                              icon: Icons.inventory_2_outlined,
                              count: '${data.products.length}',
                              title: context.tr('Products', 'المنتجات'),
                              accent: const Color(0xFF8B5CF6),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _SmallStatCard(
                              icon: Icons.local_offer_outlined,
                              count: '$hiddenCount',
                              title: context.tr('Hidden', 'المخفية'),
                              accent: const Color(0xFFF97316),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      InkWell(
                        onTap: () => Navigator.of(context).pushNamed(
                          AdminOrdersPage.routeName,
                        ),
                        borderRadius: BorderRadius.circular(24),
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24),
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFF1E7B34),
                                Color(0xFF2C9C47),
                              ],
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 58,
                                height: 58,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.16),
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                child: const Icon(
                                  Icons.shopping_bag_rounded,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      context.tr(
                                        '$totalOrders orders need attention',
                                        '$totalOrders طلبات قيد الانتظار',
                                      ),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 22,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      context.tr(
                                        'View all orders',
                                        'عرض جميع الطلبات',
                                      ),
                                      style: TextStyle(
                                        color: Colors.white.withValues(alpha: 0.92),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(
                                Icons.chevron_right_rounded,
                                color: Colors.white,
                                size: 30,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              context.tr('Products', 'المنتجات'),
                              style: const TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF111827),
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () {},
                            child: Text(
                              context.tr('View all', 'عرض الكل'),
                              style: const TextStyle(
                                color: Color(0xFF1E7B34),
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      if (data.products.isEmpty)
                        Container(
                          padding: const EdgeInsets.all(28),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Column(
                            children: [
                              const Icon(
                                Icons.inventory_2_outlined,
                                size: 42,
                                color: Color(0xFFB8BFCC),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                context.tr('No products yet', 'لا توجد منتجات الآن'),
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF4B5563),
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        ...data.products.map(
                          (product) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _ProductAdminCard(
                              product: product,
                              onPreview: () => _showPreviewDialog(product),
                              onEdit: () => _showProductDialog(product: product),
                              onDelete: () => _confirmDeleteProduct(product),
                              onMore: () => _showProductActionSheet(product),
                            ),
                          ),
                        ),
                      const SizedBox(height: 4),
                      OutlinedButton.icon(
                        onPressed: () => _showProductDialog(),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(22),
                          ),
                        ),
                        icon: const Icon(Icons.add_rounded),
                        label: Text(
                          context.tr('Add new product', 'إضافة منتج جديد'),
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Future<void> _showProductActionSheet(Product product) async {
    await showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _SheetAction(
                  icon: Icons.visibility_outlined,
                  label: context.tr('Preview product', 'معاينة المنتج'),
                  onTap: () {
                    Navigator.of(context).pop();
                    _showPreviewDialog(product);
                  },
                ),
                _SheetAction(
                  icon: Icons.edit_outlined,
                  label: context.tr('Edit product', 'تعديل المنتج'),
                  onTap: () {
                    Navigator.of(context).pop();
                    _showProductDialog(product: product);
                  },
                ),
                _SheetAction(
                  icon: product.isActive
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  label: product.isActive
                      ? context.tr('Hide product', 'إخفاء المنتج')
                      : context.tr('Activate product', 'تفعيل المنتج'),
                  onTap: () {
                    Navigator.of(context).pop();
                    _toggleProductActive(product);
                  },
                ),
                _SheetAction(
                  icon: Icons.delete_outline_rounded,
                  label: context.tr('Delete product', 'حذف المنتج'),
                  onTap: () {
                    Navigator.of(context).pop();
                    _confirmDeleteProduct(product);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
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
                      ? ProductImageView(imageUrl: product.imageUrl!)
                      : const Icon(Icons.image_outlined, size: 42),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                product.description?.isNotEmpty == true
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
      context.showAppNotice(
        title: product.isActive
            ? context.tr('Product hidden', 'تم إخفاء المنتج')
            : context.tr('Product activated', 'تم تفعيل المنتج'),
        message: product.isActive
            ? context.tr(
                'The product will disappear from the customer app after refresh.',
                'سيختفي المنتج من تطبيق العميل بعد التحديث.',
              )
            : context.tr(
                'The product is available for customers again.',
                'المنتج متاح للعملاء مرة أخرى.',
              ),
        type: AppNoticeType.success,
      );
      await _refresh();
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
              title: Text(
                context.tr('Delete product', 'حذف المنتج'),
              ),
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

    if (!confirmed) return;
    if (!mounted) return;

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

class _ProductDialogResult {
  const _ProductDialogResult({required this.saved});

  final bool saved;
}

class _TopIconButton extends StatelessWidget {
  const _TopIconButton({
    required this.icon,
    required this.onTap,
    this.badge,
  });

  final IconData icon;
  final VoidCallback onTap;
  final String? badge;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Icon(icon, color: const Color(0xFF111827)),
          ),
        ),
        if (badge != null)
          Positioned(
            top: -4,
            right: -4,
            child: Container(
              width: 20,
              height: 20,
              decoration: const BoxDecoration(
                color: Color(0xFFFF5C5C),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                badge!,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _ProfileAvatarButton extends StatelessWidget {
  const _ProfileAvatarButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 54,
        height: 54,
        decoration: BoxDecoration(
          color: const Color(0xFFF0F7EF),
          borderRadius: BorderRadius.circular(18),
        ),
        child: const Icon(
          Icons.person,
          color: Color(0xFF1E7B34),
          size: 30,
        ),
      ),
    );
  }
}

class _RevenueCard extends StatelessWidget {
  const _RevenueCard({required this.revenue});

  final double revenue;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          colors: [
            Color(0xFF1E7B34),
            Color(0xFF2C9C47),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.account_balance_wallet_outlined,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            context.tr('Today total sales', 'إجمالي المبيعات اليوم'),
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.92),
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'AED ${revenue.toStringAsFixed(0)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 40,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            context.tr('↑ 12% vs yesterday', '↑ 12% عن أمس'),
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.92),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _SmallStatCard extends StatelessWidget {
  const _SmallStatCard({
    required this.icon,
    required this.count,
    required this.title,
    required this.accent,
  });

  final IconData icon;
  final String count;
  final String title;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: accent),
          ),
          const SizedBox(height: 14),
          Text(
            count,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w900,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF6B7280),
              fontWeight: FontWeight.w600,
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
    required this.onPreview,
    required this.onEdit,
    required this.onDelete,
    required this.onMore,
  });

  final Product product;
  final VoidCallback onPreview;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onMore;

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
              InkWell(
                onTap: onMore,
                child: const Icon(Icons.more_vert_rounded, color: Color(0xFF6B7280)),
              ),
              const SizedBox(height: 22),
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
                  ? ProductImageView(imageUrl: product.imageUrl!)
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

class _SheetAction extends StatelessWidget {
  const _SheetAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF1E7B34)),
            const SizedBox(width: 12),
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
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
        maxWidth: 760,
        maxHeight: 760,
        imageQuality: 55,
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
        finalImageUrl = await ProductImageDataUrl.fromXFile(_selectedImage!);
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

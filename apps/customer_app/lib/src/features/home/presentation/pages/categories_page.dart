import 'package:customer_app/src/features/home/data/services/home_api_service.dart';
import 'package:customer_app/src/features/home/presentation/pages/category_products_page.dart';
import 'package:flutter/material.dart';

class CategoriesPage extends StatefulWidget {
  const CategoriesPage({super.key});

  static const String routeName = '/categories';

  @override
  State<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  final HomeApiService _homeApiService = HomeApiService();
  late Future<List<_CategoryListItem>> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<List<_CategoryListItem>> _load() async {
    final homeData = await _homeApiService.fetchHomeData();
    final grouped = <String, int>{};

    for (final product in homeData.products) {
      final category = (product.category ?? 'Other').trim();
      grouped[category] = (grouped[category] ?? 0) + 1;
    }

    final categories = grouped.entries
        .map(
          (entry) => _CategoryListItem(
            title: entry.key,
            subtitle: '${entry.value} products',
            emoji: _emojiFor(entry.key),
            color: _colorFor(entry.key),
          ),
        )
        .toList()
      ..sort((a, b) => a.title.compareTo(b.title));

    return categories;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF4F6FB),
        surfaceTintColor: const Color(0xFFF4F6FB),
        title: const Text(
          'All Categories',
          style: TextStyle(
            color: Color(0xFF4C5063),
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 18),
          child: FutureBuilder<List<_CategoryListItem>>(
            future: _future,
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return const Center(child: Text('Failed to load categories'));
              }

              final items = snapshot.data ?? <_CategoryListItem>[];
              return ListView.separated(
                itemCount: items.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final item = items[index];
                  return InkWell(
                    onTap: () {
                      Navigator.of(context).pushNamed(
                        CategoryProductsPage.routeName,
                        arguments: item.title,
                      );
                    },
                    borderRadius: BorderRadius.circular(18),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.title,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF4C5063),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  item.subtitle,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFFACB1BF),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            width: 62,
                            height: 62,
                            decoration: BoxDecoration(
                              color: item.color,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Center(
                              child: Text(
                                item.emoji,
                                style: const TextStyle(fontSize: 28),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  String _emojiFor(String category) {
    switch (category) {
      case 'البقالة':
        return '🛒';
      case 'المخبوزات':
        return '🥖';
      case 'الألبان':
        return '🥛';
      case 'الخضار':
        return '🥬';
      case 'الفواكه':
        return '🍎';
      case 'اللحوم':
        return '🥩';
      case 'الفراخ':
        return '🍗';
      case 'المجمدات':
        return '🧊';
      case 'المشروبات':
        return '🥤';
      case 'الحلويات':
        return '🧁';
      case 'المنظفات':
        return '🧴';
      case 'العناية الشخصية':
        return '🧼';
      default:
        return '🛍️';
    }
  }

  Color _colorFor(String category) {
    switch (category) {
      case 'البقالة':
        return const Color(0xFFE3EDFF);
      case 'المخبوزات':
        return const Color(0xFFEEDFCB);
      case 'الألبان':
        return const Color(0xFFE4F5FF);
      case 'الخضار':
        return const Color(0xFFE7F6E9);
      case 'الفواكه':
        return const Color(0xFFFFECE4);
      case 'اللحوم':
        return const Color(0xFFFFE3E3);
      case 'الفراخ':
        return const Color(0xFFFFE9D9);
      case 'المجمدات':
        return const Color(0xFFE6F0FF);
      case 'المشروبات':
        return const Color(0xFFE8F6FF);
      case 'الحلويات':
        return const Color(0xFFFFE3EF);
      case 'المنظفات':
        return const Color(0xFFE8F8F1);
      case 'العناية الشخصية':
        return const Color(0xFFF2EAFF);
      default:
        return const Color(0xFFFFEDD7);
    }
  }
}

class _CategoryListItem {
  const _CategoryListItem({
    required this.title,
    required this.subtitle,
    required this.emoji,
    required this.color,
  });

  final String title;
  final String subtitle;
  final String emoji;
  final Color color;
}

import 'package:flutter/material.dart';
import '../data/product_data.dart';
import '../models/product.dart';
import '../widgets/product_card.dart';
import 'detail_screen.dart';
import 'splash_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Sepet: productId → adet
  final Map<int, int> _cart = {};
  final Set<int> _favorites = {};
  List<Product> _filtered = products;
  final _searchController = TextEditingController();
  int _navIndex = 0;

  // ── Sepet yardımcıları ─────────────────────────────────────────────
  void _addToCart(int id) =>
      setState(() => _cart[id] = (_cart[id] ?? 0) + 1);

  void _decrement(int id) => setState(() {
        if ((_cart[id] ?? 0) <= 1) {
          _cart.remove(id);
        } else {
          _cart[id] = _cart[id]! - 1;
        }
      });

  void _removeItem(int id) => setState(() => _cart.remove(id));

  int get _totalItems => _cart.values.fold(0, (s, q) => s + q);

  double get _totalPrice => _cart.entries.fold(0.0, (s, e) {
        final p = products.firstWhere((p) => p.id == e.key);
        return s + p.price * e.value;
      });

  List<MapEntry<Product, int>> get _cartItems => _cart.entries
      .map((e) =>
          MapEntry(products.firstWhere((p) => p.id == e.key), e.value))
      .toList();

  // ── Favoriler ──────────────────────────────────────────────────────
  void _toggleFav(int id) => setState(() {
        _favorites.contains(id)
            ? _favorites.remove(id)
            : _favorites.add(id);
      });

  // ── Navigasyon ─────────────────────────────────────────────────────
  static PageRoute<T> _slideRoute<T>(Widget page) => PageRouteBuilder<T>(
        pageBuilder: (_, __, ___) => page,
        transitionDuration: const Duration(milliseconds: 280),
        transitionsBuilder: (_, anim, __, child) => SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).animate(
              CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
          child: child,
        ),
      );

  Future<void> _openDetail(Product product) async {
    final added = await Navigator.push<bool>(
      context,
      _slideRoute(DetailScreen(
        product: product,
        isFavorite: _favorites.contains(product.id),
        onToggleFavorite: _toggleFav,
      )),
    );
    if (!mounted) return;
    if (added == true) _addToCart(product.id);
  }

  // ── Arama ──────────────────────────────────────────────────────────
  void _onSearch(String q) => setState(() {
        _filtered = q.isEmpty
            ? products
            : products
                .where((p) =>
                    p.name.toLowerCase().contains(q.toLowerCase()))
                .toList();
      });

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ── AppBar ─────────────────────────────────────────────────────────
  AppBar _appBar() {
    const divider = PreferredSize(
      preferredSize: Size.fromHeight(1),
      child: Divider(height: 1, color: Color(0xFFE5E5EA)),
    );
    switch (_navIndex) {
      case 0:
        return AppBar(
          title: const Column(children: [
            Text('Mini Katalog'),
            Text('Teknoloji dünyası',
                style: TextStyle(
                    fontSize: 11,
                    color: Color(0xFF6E6E73),
                    fontWeight: FontWeight.w400)),
          ]),
          actions: [
            IconButton(
                icon: const Icon(Icons.notifications_outlined),
                onPressed: () {}),
          ],
          bottom: divider,
        );
      case 1:
        return AppBar(title: const Text('Keşfet'), bottom: divider);
      case 2:
        return AppBar(
          title: Text(
              'Sepetim${_totalItems > 0 ? ' ($_totalItems)' : ''}'),
          actions: [
            if (_cart.isNotEmpty)
              TextButton(
                onPressed: () => setState(() => _cart.clear()),
                child: const Text('Temizle',
                    style: TextStyle(color: Color(0xFFFF3B30))),
              ),
          ],
          bottom: divider,
        );
      default:
        return AppBar(title: const Text('Profil'), bottom: divider);
    }
  }

  // ── HOME TAB ───────────────────────────────────────────────────────
  Widget _homeTab() {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearch,
              style: const TextStyle(fontSize: 15),
              decoration: InputDecoration(
                hintText: 'Ürün, marka veya kategori ara...',
                hintStyle: const TextStyle(
                    fontSize: 14, color: Color(0xFFAEAEB2)),
                prefixIcon: const Icon(Icons.search,
                    color: Color(0xFFAEAEB2), size: 20),
                filled: true,
                fillColor: const Color(0xFFEFEFF4),
                contentPadding: EdgeInsets.zero,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 8, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Popüler Ürünler',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1D1D1F),
                        letterSpacing: -0.3)),
                TextButton(
                  onPressed: () {},
                  child: const Row(children: [
                    Text('Tümü',
                        style: TextStyle(
                            color: Color(0xFF0071E3), fontSize: 14)),
                    SizedBox(width: 2),
                    Icon(Icons.arrow_forward_ios,
                        size: 12, color: Color(0xFF0071E3)),
                  ]),
                ),
              ],
            ),
          ),
        ),
        if (_filtered.isEmpty)
          const SliverFillRemaining(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.search_off_outlined,
                      size: 56, color: Color(0xFFAEAEB2)),
                  SizedBox(height: 12),
                  Text('Ürün bulunamadı.',
                      style: TextStyle(
                          color: Color(0xFF6E6E73), fontSize: 15)),
                ],
              ),
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            sliver: SliverGrid(
              delegate: SliverChildBuilderDelegate(
                (_, i) => ProductCard(
                  product: _filtered[i],
                  isFavorite: _favorites.contains(_filtered[i].id),
                  onTap: () => _openDetail(_filtered[i]),
                  onFavorite: () => _toggleFav(_filtered[i].id),
                ),
                childCount: _filtered.length,
              ),
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.75,
              ),
            ),
          ),
      ],
    );
  }

  // ── EXPLORE TAB ────────────────────────────────────────────────────
  Widget _exploreTab() {
    const names = ['Telefon', 'Laptop', 'Kulaklık', 'Saat', 'Tablet'];
    const icons = [
      Icons.smartphone_outlined,
      Icons.laptop_outlined,
      Icons.headphones_outlined,
      Icons.watch_outlined,
      Icons.tablet_outlined,
    ];
    const bgs = [
      Color(0xFFE8F3FF),
      Color(0xFFF0EAFF),
      Color(0xFFE8F8F0),
      Color(0xFFFFF5E8),
      Color(0xFFF0EAFF),
    ];
    const iconColors = [
      Color(0xFF0071E3),
      Color(0xFF7B5EA7),
      Color(0xFF34C759),
      Color(0xFFFF9500),
      Color(0xFF5856D6),
    ];
    const keys = ['phone', 'laptop', 'audio', 'watch', 'tablet'];

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: [
        for (int i = 0; i < names.length; i++) _catTile(
          label: names[i],
          icon: icons[i],
          bg: bgs[i],
          iconColor: iconColors[i],
          catKey: keys[i],
        ),
      ],
    );
  }

  Widget _catTile({
    required String label,
    required IconData icon,
    required Color bg,
    required Color iconColor,
    required String catKey,
  }) {
    final count = products.where((p) => p.category == catKey).length;
    final items = products.where((p) => p.category == catKey).toList();
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withAlpha(8),
              blurRadius: 12,
              offset: const Offset(0, 2)),
        ],
      ),
      child: ListTile(
        onTap: () => Navigator.push(
          context,
          _slideRoute(_CategoryScreen(
            title: label,
            items: items,
            favorites: _favorites,
            onToggleFav: _toggleFav,
            onOpenDetail: _openDetail,
          )),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: iconColor, size: 24),
        ),
        title: Text(label,
            style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 15,
                color: Color(0xFF1D1D1F))),
        subtitle: Text('$count ürün',
            style: const TextStyle(
                fontSize: 12, color: Color(0xFF6E6E73))),
        trailing: const Icon(Icons.arrow_forward_ios,
            size: 14, color: Color(0xFFAEAEB2)),
      ),
    );
  }

  // ── CART TAB ───────────────────────────────────────────────────────
  Widget _cartTab() {
    if (_cart.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                color: const Color(0xFFEFEFF4),
                borderRadius: BorderRadius.circular(30),
              ),
              child: const Icon(Icons.shopping_cart_outlined,
                  size: 58, color: Color(0xFFAEAEB2)),
            ),
            const SizedBox(height: 20),
            const Text('Sepetiniz boş',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1D1D1F))),
            const SizedBox(height: 8),
            const Text('Beğendiğiniz ürünleri sepetinize ekleyin.',
                style:
                    TextStyle(fontSize: 14, color: Color(0xFF6E6E73))),
            const SizedBox(height: 28),
            ElevatedButton(
              onPressed: () => setState(() => _navIndex = 0),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0071E3),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                    horizontal: 32, vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text('Alışverişe Başla',
                  style: TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            itemCount: _cartItems.length,
            itemBuilder: (_, i) {
              final p = _cartItems[i].key;
              final qty = _cartItems[i].value;
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withAlpha(8),
                        blurRadius: 12,
                        offset: const Offset(0, 2)),
                  ],
                ),
                child: Row(
                  children: [
                    // Görsel
                    ClipRRect(
                      borderRadius: const BorderRadius.horizontal(
                          left: Radius.circular(16)),
                      child: Container(
                        width: 88,
                        height: 88,
                        color: const Color(0xFFF5F5F7),
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: Image.network(p.imageUrl,
                              fit: BoxFit.contain,
                              errorBuilder: (_, __, ___) => const Icon(
                                  Icons.image_not_supported_outlined,
                                  color: Color(0xFFAEAEB2))),
                        ),
                      ),
                    ),
                    // Bilgi
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(p.name,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
                                    color: Color(0xFF1D1D1F)),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis),
                            const SizedBox(height: 4),
                            Text(
                                '₺${(p.price * qty).toStringAsFixed(0)}',
                                style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF0071E3))),
                          ],
                        ),
                      ),
                    ),
                    // Kontroller
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.delete_outline,
                              color: Color(0xFFFF3B30), size: 18),
                          onPressed: () => _removeItem(p.id),
                        ),
                        Row(
                          children: [
                            _qtyBtn(Icons.remove, () => _decrement(p.id)),
                            SizedBox(
                              width: 28,
                              child: Text('$qty',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 15)),
                            ),
                            _qtyBtn(Icons.add, () => _addToCart(p.id)),
                          ],
                        ),
                        const SizedBox(height: 4),
                      ],
                    ),
                    const SizedBox(width: 4),
                  ],
                ),
              );
            },
          ),
        ),
        // Özet paneli
        Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius:
                BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [
              BoxShadow(
                  color: Color(0x14000000),
                  blurRadius: 20,
                  offset: Offset(0, -4)),
            ],
          ),
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('$_totalItems ürün',
                      style: const TextStyle(
                          fontSize: 14, color: Color(0xFF6E6E73))),
                  Text('₺${_totalPrice.toStringAsFixed(0)}',
                      style: const TextStyle(
                          fontSize: 14, color: Color(0xFF6E6E73))),
                ],
              ),
              const SizedBox(height: 8),
              const Divider(color: Color(0xFFE5E5EA)),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Toplam',
                      style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1D1D1F))),
                  Text('₺${_totalPrice.toStringAsFixed(2)}',
                      style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0071E3),
                          letterSpacing: -0.5)),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0071E3),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text('Ödemeye Geç',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _qtyBtn(IconData icon, VoidCallback onPressed) => SizedBox(
        width: 30,
        height: 30,
        child: Material(
          color: const Color(0xFFEFEFF4),
          borderRadius: BorderRadius.circular(8),
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(8),
            child: Icon(icon, size: 16, color: const Color(0xFF0071E3)),
          ),
        ),
      );

  // ── PROFILE TAB ────────────────────────────────────────────────────
  Widget _profileTab() {
    const menuIcons = [
      Icons.receipt_long_outlined,
      Icons.favorite_border_outlined,
      Icons.location_on_outlined,
      Icons.settings_outlined,
      Icons.help_outline,
      Icons.logout,
    ];
    const menuLabels = [
      'Siparişlerim',
      'Favorilerim',
      'Adreslerim',
      'Ayarlar',
      'Yardım & Destek',
      'Çıkış Yap',
    ];

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: [
        // Avatar + Giriş kartı
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withAlpha(8),
                  blurRadius: 12,
                  offset: const Offset(0, 2)),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: const Color(0xFFEFEFF4),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Icon(Icons.person_outline,
                    size: 34, color: Color(0xFF6E6E73)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Merhaba!',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1D1D1F))),
                    const SizedBox(height: 4),
                    const Text(
                      'Giriş yaparak siparişlerinizi\ngörebilirsiniz.',
                      style: TextStyle(
                          fontSize: 12, color: Color(0xFF6E6E73)),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: 100,
                      height: 34,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pushReplacement(
                          context,
                          PageRouteBuilder(
                            pageBuilder: (_, __, ___) =>
                                const SplashScreen(),
                            transitionDuration:
                                const Duration(milliseconds: 300),
                            transitionsBuilder: (_, anim, __, child) =>
                                FadeTransition(
                                    opacity: anim, child: child),
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.zero,
                          backgroundColor: const Color(0xFF0071E3),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text('Giriş Yap',
                            style: TextStyle(fontSize: 13)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        // Menü
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withAlpha(8),
                  blurRadius: 12,
                  offset: const Offset(0, 2)),
            ],
          ),
          child: Column(
            children: [
              for (int i = 0; i < menuLabels.length; i++) ...[
                ListTile(
                  onTap: () {},
                  leading: Icon(menuIcons[i],
                      color: menuIcons[i] == Icons.logout
                          ? const Color(0xFFFF3B30)
                          : const Color(0xFF0071E3),
                      size: 22),
                  title: Text(menuLabels[i],
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: menuIcons[i] == Icons.logout
                              ? const Color(0xFFFF3B30)
                              : const Color(0xFF1D1D1F))),
                  trailing: menuIcons[i] != Icons.logout
                      ? const Icon(Icons.arrow_forward_ios,
                          size: 14, color: Color(0xFFAEAEB2))
                      : null,
                ),
                if (i < menuLabels.length - 1)
                  const Divider(
                      height: 1,
                      indent: 56,
                      color: Color(0xFFE5E5EA)),
              ],
            ],
          ),
        ),
      ],
    );
  }

  // ── Bottom Navigation ──────────────────────────────────────────────
  Widget _bottomNav() => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Color(0xFFE5E5EA))),
        ),
        child: BottomNavigationBar(
          currentIndex: _navIndex,
          onTap: (i) => setState(() => _navIndex = i),
          items: [
            const BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Ana Sayfa',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.grid_view_outlined),
              activeIcon: Icon(Icons.grid_view_rounded),
              label: 'Keşfet',
            ),
            BottomNavigationBarItem(
              icon: Badge(
                isLabelVisible: _totalItems > 0,
                label: Text('$_totalItems'),
                child: const Icon(Icons.shopping_bag_outlined),
              ),
              activeIcon: Badge(
                isLabelVisible: _totalItems > 0,
                label: Text('$_totalItems'),
                child: const Icon(Icons.shopping_bag),
              ),
              label: 'Sepetim',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Profil',
            ),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      appBar: _appBar(),
      body: [
        _homeTab(),
        _exploreTab(),
        _cartTab(),
        _profileTab(),
      ][_navIndex],
      bottomNavigationBar: _bottomNav(),
    );
  }
}

// ── Kategori Ürün Sayfası ─────────────────────────────────────────────
class _CategoryScreen extends StatelessWidget {
  final String title;
  final List<Product> items;
  final Set<int> favorites;
  final Function(int) onToggleFav;
  final Future<void> Function(Product) onOpenDetail;

  const _CategoryScreen({
    required this.title,
    required this.items,
    required this.favorites,
    required this.onToggleFav,
    required this.onOpenDetail,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      appBar: AppBar(
        title: Text(title),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: () {},
            child: const Text('Filtrele',
                style: TextStyle(color: Color(0xFF0071E3))),
          ),
        ],
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: Color(0xFFE5E5EA)),
        ),
      ),
      body: items.isEmpty
          ? const Center(
              child: Text('Bu kategoride ürün yok.',
                  style: TextStyle(color: Color(0xFF6E6E73))))
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: Text('${items.length} ürün',
                      style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF6E6E73),
                          fontWeight: FontWeight.w500)),
                ),
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.75,
                    ),
                    itemCount: items.length,
                    itemBuilder: (_, i) => ProductCard(
                      product: items[i],
                      isFavorite: favorites.contains(items[i].id),
                      onTap: () => onOpenDetail(items[i]),
                      onFavorite: () => onToggleFav(items[i].id),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

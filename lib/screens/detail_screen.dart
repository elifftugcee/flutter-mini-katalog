import 'package:flutter/material.dart';
import '../models/product.dart';

class DetailScreen extends StatefulWidget {
  final Product product;
  final bool isFavorite;
  final ValueChanged<int> onToggleFavorite;

  const DetailScreen({
    super.key,
    required this.product,
    required this.isFavorite,
    required this.onToggleFavorite,
  });

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  late bool _isFav;
  int _colorIdx = 0;
  int _storageIdx = 0;

  @override
  void initState() {
    super.initState();
    _isFav = widget.isFavorite;
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.product;
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      appBar: AppBar(
        title: Text(p.name, maxLines: 1, overflow: TextOverflow.ellipsis),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isFav ? Icons.favorite : Icons.favorite_border,
              color: _isFav ? const Color(0xFFFF3B30) : null,
            ),
            onPressed: () {
              setState(() => _isFav = !_isFav);
              widget.onToggleFavorite(p.id);
            },
          ),
        ],
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: Color(0xFFE5E5EA)),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero görsel
            Container(
              width: double.infinity,
              height: 280,
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Hero(
                  tag: 'product-img-${p.id}',
                  child: Image.network(
                    p.imageUrl,
                    fit: BoxFit.contain,
                    loadingBuilder: (_, child, progress) => progress == null
                        ? child
                        : const Center(child: CircularProgressIndicator()),
                    errorBuilder: (_, __, ___) => const Center(
                      child: Icon(Icons.image_not_supported_outlined,
                          size: 72, color: Color(0xFFAEAEB2)),
                    ),
                  ),
                ),
              ),
            ),
            // Bilgi paneli
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(p.name,
                            style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF1D1D1F),
                                letterSpacing: -0.5)),
                      ),
                      const SizedBox(width: 12),
                      Text('₺${p.price.toStringAsFixed(0)}',
                          style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF0071E3),
                              letterSpacing: -0.5)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // Stok badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F8F0),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text('Stokta var',
                        style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF34C759),
                            fontWeight: FontWeight.w600)),
                  ),
                  const SizedBox(height: 14),
                  Text(p.description,
                      style: const TextStyle(
                          fontSize: 15,
                          color: Color(0xFF3A3A3C),
                          height: 1.6)),
                ],
              ),
            ),
            // Renk seçimi
            if (p.colors.isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                color: Colors.white,
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Renk Seçimi',
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1D1D1F))),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        for (int i = 0; i < p.colors.length; i++)
                          GestureDetector(
                            onTap: () => setState(() => _colorIdx = i),
                            child: Container(
                              margin: const EdgeInsets.only(right: 10),
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: p.colors[i],
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: _colorIdx == i
                                      ? const Color(0xFF0071E3)
                                      : Colors.transparent,
                                  width: 2.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                      color: Colors.black.withAlpha(20),
                                      blurRadius: 4),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
            // Depolama seçimi
            if (p.storage.isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                color: Colors.white,
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Depolama',
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1D1D1F))),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (int i = 0; i < p.storage.length; i++)
                          GestureDetector(
                            onTap: () => setState(() => _storageIdx = i),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: _storageIdx == i
                                    ? const Color(0xFF0071E3)
                                    : const Color(0xFFF5F5F7),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: _storageIdx == i
                                      ? const Color(0xFF0071E3)
                                      : const Color(0xFFE5E5EA),
                                ),
                              ),
                              child: Text(p.storage[i],
                                  style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: _storageIdx == i
                                          ? Colors.white
                                          : const Color(0xFF1D1D1F))),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
            // Sepete Ekle
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.shopping_bag_outlined, size: 20),
                  label: const Text('Sepete Ekle',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w600)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0071E3),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Row(
                          children: [
                            const Icon(Icons.check_circle_outline,
                                color: Colors.white, size: 18),
                            const SizedBox(width: 8),
                            Expanded(
                                child:
                                    Text('${p.name} sepete eklendi')),
                          ],
                        ),
                        duration: const Duration(seconds: 2),
                        behavior: SnackBarBehavior.floating,
                        backgroundColor: const Color(0xFF34C759),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        margin: const EdgeInsets.all(12),
                      ),
                    );
                    Navigator.pop(context, true);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

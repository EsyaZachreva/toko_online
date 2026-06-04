import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:toko_online/controllers/cartProvide.dart';
import 'package:toko_online/models/toko_model.dart';
import 'package:toko_online/services/toko.dart';
import 'package:toko_online/services/DBHelper.dart';
import 'package:toko_online/models/cart.dart';
import 'package:badges/badges.dart' as badges;
import 'package:toko_online/views/gambar_barang.dart';
import 'package:toko_online/widgets/bottom_nav.dart';
import 'package:toko_online/widgets/alert.dart';

class PesanView extends StatefulWidget {
  const PesanView({super.key});

  @override
  State<PesanView> createState() => PesanViewState();
}

class PesanViewState extends State<PesanView>
    with SingleTickerProviderStateMixin {
  TokoService tokoService = TokoService();
  CartProvider cartProvider = CartProvider();
  DBHelper dBHelper = DBHelper();
  List<TokoModel> barangList = [];
  bool _isLoading = true;
  String _searchQuery = '';
  late AnimationController _animController;

  // ── Warna Ungu (sama persis dengan barang_view.dart) ────────────────────────
  static const Color _primary = Color(0xFF5E35B1);
  static const Color _primaryDark = Color(0xFF4527A0);
  static const Color _primaryLight = Color(0xFF7E57C2);
  static const Color _primarySurface = Color(0xFFEDE7F6);
  static const Color _bg = Color(0xFFF5F3FB);
  // ─────────────────────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    getBarang();
    updateCount();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> getBarang() async {
    setState(() => _isLoading = true);
    var response = await tokoService.getBarangUser();
    setState(() {
      barangList = response.data != null
          ? List<TokoModel>.from(response.data!)
          : [];
      _isLoading = false;
    });
    _animController.forward(from: 0);
  }

  void updateCount() async {
    await cartProvider.getData();
    if (mounted) {
      setState(() {
        cartProvider.counter = cartProvider.cart.length;
      });
    }
  }

  // Cek dulu apakah sudah ada di cart → DBHelper.insert sudah handle auto update qty
  void saveData(TokoModel barang) async {
    if (barang.id == null) {
      if (mounted)
        AlertMessage().showAlert(context, "Barang tidak valid", false);
      return;
    }

    try {
      await dBHelper.insert(
        Cart(
          id: 0,
          id_barang: barang.id.toString(),
          nama_barang: barang.nama_barang ?? '',
          harga: barang.harga ?? 0.0,
          deskripsi: barang.deskripsi ?? '',
          gambar_url: barang.gambar_url ?? '',
          quantity: 1,
        ),
      );

      updateCount();
      if (mounted) {
        AlertMessage().showAlert(context, "Berhasil masuk keranjang", true);
      }
    } catch (error) {
      debugPrint('saveData error: $error');
      if (mounted) {
        AlertMessage().showAlert(
          context,
          "Gagal menambahkan ke keranjang",
          false,
        );
      }
    }
  }

  List<TokoModel> get _filtered {
    if (_searchQuery.isEmpty) return barangList;
    return barangList
        .where(
          (b) => (b.nama_barang ?? '').toLowerCase().contains(
            _searchQuery.toLowerCase(),
          ),
        )
        .toList();
  }

  String _formatHarga(double? harga) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return formatter.format(harga ?? 0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _primarySurface,
        elevation: 0,
        // Di bagian title AppBar (sekitar line 127-148)
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: _primary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.storefront_rounded,
                color: Colors.white,
                size: 18,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              // ✅ tambah Expanded di sini
              child: Text(
                'Produk Toko Online',
                style: TextStyle(
                  color: _primaryDark,
                  fontWeight: FontWeight.w800,
                  fontSize: 20,
                  letterSpacing: 0.3,
                ),
                overflow: TextOverflow.ellipsis, // ✅ tambah ini juga
              ),
            ),
          ],
        ),
        actions: [
          // Cart badge
          Padding(
            padding: const EdgeInsets.only(right: 4),
            child: badges.Badge(
              badgeStyle: const badges.BadgeStyle(
                badgeColor: Color(0xFFE53935),
                padding: EdgeInsets.all(5),
              ),
              badgeContent: ListenableBuilder(
                listenable: cartProvider,
                builder: (context, child) {
                  final count = cartProvider.cart.isEmpty
                      ? 0
                      : cartProvider.counter;
                  return Text(
                    '$count',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                },
              ),
              position: badges.BadgePosition.topEnd(top: -4, end: -4),
              child: IconButton(
                style: IconButton.styleFrom(
                  backgroundColor: _primary.withOpacity(0.12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    '/cartScreen',
                  ).then((_) => updateCount());
                },
                icon: const Icon(Icons.shopping_cart_outlined, color: _primary),
                tooltip: 'Keranjang',
              ),
            ),
          ),
          // Refresh
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: IconButton(
              style: IconButton.styleFrom(
                backgroundColor: _primary.withOpacity(0.12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: getBarang,
              icon: const Icon(Icons.refresh_rounded, color: _primary),
              tooltip: 'Refresh',
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: _primary.withOpacity(0.08)),
        ),
      ),
      body: Column(
        children: [
          // ── Search bar (sama persis dengan barang_view.dart) ──
          Container(
            color: _primarySurface,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: TextField(
              onChanged: (v) => setState(() => _searchQuery = v),
              decoration: InputDecoration(
                hintText: 'Cari nama barang...',
                hintStyle: TextStyle(
                  color: _primaryLight.withOpacity(0.6),
                  fontSize: 14,
                ),
                prefixIcon: Icon(Icons.search_rounded, color: _primaryLight),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: Icon(
                          Icons.close_rounded,
                          color: _primaryLight,
                          size: 18,
                        ),
                        onPressed: () => setState(() => _searchQuery = ''),
                      )
                    : null,
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(
                    color: _primary.withOpacity(0.2),
                    width: 1.5,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: _primary, width: 1.8),
                ),
              ),
            ),
          ),

          // ── Info jumlah item ──
          if (!_isLoading && _filtered.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 4),
              child: Row(
                children: [
                  Text(
                    '${_filtered.length} barang ditemukan',
                    style: TextStyle(
                      fontSize: 12,
                      color: _primaryLight,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

          // ── List ──
          Expanded(
            child: _isLoading
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(color: _primary),
                        const SizedBox(height: 12),
                        Text(
                          'Memuat data...',
                          style: TextStyle(color: _primaryLight, fontSize: 13),
                        ),
                      ],
                    ),
                  )
                : _filtered.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: _primarySurface,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.inventory_2_outlined,
                            size: 48,
                            color: _primaryLight,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Barang tidak ditemukan',
                          style: TextStyle(
                            color: _primaryDark,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _searchQuery.isNotEmpty
                              ? 'Coba kata kunci lain'
                              : 'Belum ada produk tersedia',
                          style: TextStyle(
                            color: Colors.grey.shade400,
                            fontSize: 13,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                    itemCount: _filtered.length,
                    itemBuilder: (context, index) {
                      final item = _filtered[index];
                      return _PesanCard(
                        item: item,
                        formatHarga: _formatHarga,
                        onTambah: () => saveData(item),
                        animController: _animController,
                        index: index,
                      );
                    },
                  ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNav(1),
    );
  }
}

// ─── Card Pesan (clone struktur _BarangCard, aksi diganti tombol keranjang) ───
class _PesanCard extends StatelessWidget {
  final TokoModel item;
  final String Function(double?) formatHarga;
  final VoidCallback onTambah;
  final AnimationController animController;
  final int index;

  const _PesanCard({
    required this.item,
    required this.formatHarga,
    required this.onTambah,
    required this.animController,
    required this.index,
  });

  static const Color _primary = Color(0xFF5E35B1);
  static const Color _primaryDark = Color(0xFF4527A0);
  static const Color _primaryLight = Color(0xFF7E57C2);
  static const Color _primarySurface = Color(0xFFEDE7F6);

  @override
  Widget build(BuildContext context) {
    final delay = (index * 0.07).clamp(0.0, 0.7);
    final anim = CurvedAnimation(
      parent: animController,
      curve: Interval(
        delay,
        (delay + 0.4).clamp(0.0, 1.0),
        curve: Curves.easeOut,
      ),
    );

    return FadeTransition(
      opacity: anim,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.12),
          end: Offset.zero,
        ).animate(anim),
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: _primary.withOpacity(0.08), width: 1),
            boxShadow: [
              BoxShadow(
                color: _primary.withOpacity(0.08),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              // ── Gambar ──
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(18),
                  bottomLeft: Radius.circular(18),
                ),
                child: GambarBarang(url: item.gambar_url),
              ),

              // ── Info ──
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.nama_barang ?? '-',
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          color: Color(0xFF1A1035),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        formatHarga(double.tryParse(item.harga.toString())),
                        style: const TextStyle(
                          color: _primary,
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _StokBadge(stok: item.stok ?? 0),
                    ],
                  ),
                ),
              ),

              // ── Aksi: Tombol Tambah Keranjang ──
              Padding(
                padding: const EdgeInsets.only(right: 10),
                child: _ActionBtn(
                  icon: Icons.add_shopping_cart_rounded,
                  color: _primaryLight,
                  bg: _primarySurface,
                  onPressed: onTambah,
                  tooltip: 'Tambah ke keranjang',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Gambar dengan fallback ───────────────────────────────────────────────────
class _GambarPesan extends StatelessWidget {
  final String? url;
  const _GambarPesan({this.url});

  static const Color _primaryLight = Color(0xFF7E57C2);
  static const Color _primarySurface = Color(0xFFEDE7F6);

  @override
  Widget build(BuildContext context) {
    final hasUrl = url != null && url!.trim().isNotEmpty;
    if (!hasUrl) return _placeholder();

    return Image.network(
      url!,
      width: 95,
      height: 95,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          width: 95,
          height: 95,
          color: _primarySurface,
          child: Center(
            child: SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: _primaryLight,
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                    : null,
              ),
            ),
          ),
        );
      },
      errorBuilder: (_, error, __) {
        debugPrint("DEBUG FOTO: Gagal load gambar -> $url");
        return _placeholder(hasError: true);
      },
    );
  }

  Widget _placeholder({bool hasError = false}) => Container(
    width: 95,
    height: 95,
    decoration: const BoxDecoration(color: _primarySurface),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          hasError ? Icons.broken_image_rounded : Icons.image_rounded,
          color: _primaryLight.withOpacity(0.5),
          size: 30,
        ),
        if (hasError) ...[
          const SizedBox(height: 4),
          Text(
            'Gagal',
            style: TextStyle(
              fontSize: 10,
              color: _primaryLight.withOpacity(0.5),
            ),
          ),
        ],
      ],
    ),
  );
}

// ─── Action Button (sama persis dengan barang_view.dart) ─────────────────────
class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final Color bg;
  final VoidCallback onPressed;
  final String tooltip;

  const _ActionBtn({
    required this.icon,
    required this.color,
    required this.bg,
    required this.onPressed,
    required this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(10),
        child: Tooltip(
          message: tooltip,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Icon(icon, size: 20, color: color),
          ),
        ),
      ),
    );
  }
}

// ─── Stok Badge (sama persis dengan barang_view.dart) ────────────────────────
class _StokBadge extends StatelessWidget {
  final int stok;
  const _StokBadge({required this.stok});

  static const Color _primary = Color(0xFF5E35B1);
  static const Color _primarySurface = Color(0xFFEDE7F6);

  @override
  Widget build(BuildContext context) {
    final isEmpty = stok == 0;
    final isLow = stok > 0 && stok <= 5;

    final Color color = isEmpty
        ? Colors.red.shade700
        : isLow
        ? Colors.orange.shade700
        : _primary;

    final Color bg = isEmpty
        ? Colors.red.shade50
        : isLow
        ? Colors.orange.shade50
        : _primarySurface;

    final IconData icon = isEmpty
        ? Icons.remove_circle_outline_rounded
        : isLow
        ? Icons.warning_amber_rounded
        : Icons.inventory_2_rounded;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.2), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            isEmpty ? 'Habis' : 'Stok: $stok',
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

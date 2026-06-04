import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:toko_online/services/pesan.dart';
import 'package:toko_online/widgets/bottom_nav.dart';

class HistoryView extends StatefulWidget {
  const HistoryView({super.key});

  @override
  State<HistoryView> createState() => _HistoryViewState();
}

class _HistoryViewState extends State<HistoryView> {
  static const Color _primary = Color(0xFF5E35B1);
  static const Color _primaryDark = Color(0xFF4527A0);
  static const Color _primaryLight = Color(0xFF7E57C2);
  static const Color _primarySurface = Color(0xFFEDE7F6);
  static const Color _bg = Color(0xFFF5F3FB);

  List<dynamic> _historyList = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      var result = await Pesan().getHistory();
      if (result.status == true) {
        setState(() {
          _historyList = result.data is List
              ? List<dynamic>.from(result.data as List)
              : [];
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = result.message;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  String _formatHarga(dynamic harga) {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(double.tryParse(harga.toString()) ?? 0);
  }

  String _formatTanggal(String? raw) {
    if (raw == null) return '-';
    try {
      final dt = DateTime.parse(raw).toLocal();
      return DateFormat('dd MMM yyyy', 'id_ID').format(dt);
    } catch (_) {
      return raw;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _primarySurface,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: _primary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.receipt_long_rounded,
                color: Colors.white,
                size: 18,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'Riwayat Pesanan',
              style: TextStyle(
                color: _primaryDark,
                fontWeight: FontWeight.w800,
                fontSize: 20,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: IconButton(
              style: IconButton.styleFrom(
                backgroundColor: _primary.withOpacity(0.12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: _loadHistory,
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
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(color: _primary),
                  const SizedBox(height: 12),
                  Text(
                    'Memuat riwayat...',
                    style: TextStyle(color: _primaryLight, fontSize: 13),
                  ),
                ],
              ),
            )
          : _errorMessage != null
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.wifi_off_rounded, size: 48, color: _primaryLight),
                  const SizedBox(height: 12),
                  Text(
                    _errorMessage!,
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: _primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: _loadHistory,
                    icon: const Icon(Icons.refresh_rounded, size: 18),
                    label: const Text('Coba Lagi'),
                  ),
                ],
              ),
            )
          : _historyList.isEmpty
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
                      Icons.receipt_long_outlined,
                      size: 48,
                      color: _primaryLight,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Belum ada pesanan',
                    style: TextStyle(
                      color: _primaryDark,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Pesanan yang sudah checkout muncul di sini',
                    style: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
              itemCount: _historyList.length,
              itemBuilder: (context, index) {
                final transaksi = _historyList[index];

                // ✅ Key disesuaikan dengan response API
                final details = (transaksi['detail'] as List?) ?? [];
                final noTransaksi = transaksi['id_transaksi'];
                final tanggal = transaksi['tgl_transaksi'];

                // ✅ Total dihitung dari detail karena tidak ada di response
                final totalHarga = details.fold<double>(0, (sum, d) {
                  final harga =
                      double.tryParse(d['harga_beli']?.toString() ?? '0') ?? 0;
                  final qty =
                      int.tryParse(d['quantity']?.toString() ?? '0') ?? 0;
                  return sum + (harga * qty);
                });

                return Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: _primary.withOpacity(0.08),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: _primary.withOpacity(0.08),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header transaksi
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: _primarySurface,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(18),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.receipt_rounded,
                              size: 16,
                              color: _primaryLight,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Order #$noTransaksi',
                                style: TextStyle(
                                  color: _primaryDark,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            Text(
                              _formatTanggal(tanggal?.toString()),
                              style: TextStyle(
                                color: _primaryLight,
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // List detail item
                      if (details.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          child: Text(
                            'Tidak ada detail produk',
                            style: TextStyle(
                              color: Colors.grey.shade400,
                              fontSize: 12,
                            ),
                          ),
                        )
                      else
                        ...details.map((detail) {
                          // ✅ Key disesuaikan dengan response API
                          final nama = detail['nama_barang'] ?? '-';
                          final qty = detail['quantity'] ?? 0;
                          final harga = detail['harga_beli'] ?? 0;
                          final gambar = detail['gambar_url'];

                          return Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 10,
                            ),
                            child: Row(
                              children: [
                                // Gambar kecil
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: gambar != null
                                      ? Image.network(
                                          gambar.toString(),
                                          width: 50,
                                          height: 50,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) =>
                                              _imgPlaceholder(),
                                        )
                                      : _imgPlaceholder(),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        nama.toString(),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 13,
                                          color: Color(0xFF1A1035),
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 3),
                                      Text(
                                        '${_formatHarga(harga)} × $qty',
                                        style: TextStyle(
                                          color: _primaryLight,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  _formatHarga(
                                    (double.tryParse(harga.toString()) ?? 0) *
                                        (int.tryParse(qty.toString()) ?? 0),
                                  ),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: _primary,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),

                      // Divider + Total
                      Divider(color: _primary.withOpacity(0.08), height: 1),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Total',
                              style: TextStyle(
                                color: Colors.grey.shade500,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                            Text(
                              _formatHarga(totalHarga),
                              style: const TextStyle(
                                color: _primaryDark,
                                fontWeight: FontWeight.w800,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
      bottomNavigationBar: BottomNav(2),
    );
  }

  Widget _imgPlaceholder() => Container(
    width: 50,
    height: 50,
    color: _primarySurface,
    child: Icon(
      Icons.image_rounded,
      size: 22,
      color: _primaryLight.withOpacity(0.5),
    ),
  );
}
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart'; // kIsWeb
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:toko_online/models/response_data_map.dart';
import 'package:toko_online/models/toko_model.dart';
import 'package:toko_online/services/toko.dart';

class FormBarangView extends StatefulWidget {
  final TokoModel? barang;
  const FormBarangView({super.key, this.barang});

  @override
  State<FormBarangView> createState() => _FormBarangViewState();
}

class _FormBarangViewState extends State<FormBarangView> {
  final _formKey = GlobalKey<FormState>();
  final TokoService tokoService = TokoService();
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;

  XFile? _pickedFile;       // file mentah dari picker
  Uint8List? _imageBytes;   // untuk preview di web

  static const Color _primary = Color(0xFF5E35B1);
  static const Color _primaryDark = Color(0xFF4527A0);
  static const Color _bg = Color(0xFFF5F3FB);

  late TextEditingController _namaCtrl;
  late TextEditingController _deskripsiCtrl;
  late TextEditingController _stokCtrl;
  late TextEditingController _hargaCtrl;

  bool get isEdit => widget.barang != null;

  @override
  void initState() {
    super.initState();
    final b = widget.barang;
    _namaCtrl = TextEditingController(text: b?.nama_barang ?? '');
    _deskripsiCtrl = TextEditingController(text: b?.deskripsi ?? '');
    _stokCtrl = TextEditingController(text: b?.stok?.toString() ?? '');
    _hargaCtrl =
        TextEditingController(text: b?.harga?.toStringAsFixed(0) ?? '');
  }

  @override
  void dispose() {
    _namaCtrl.dispose();
    _deskripsiCtrl.dispose();
    _stokCtrl.dispose();
    _hargaCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? picked =
        await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (picked != null) {
      final bytes = await picked.readAsBytes();
      setState(() {
        _pickedFile = picked;
        _imageBytes = bytes;
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (!isEdit && _pickedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text('Pilih gambar terlebih dahulu'),
        backgroundColor: Colors.orange.shade700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ));
      return;
    }

    setState(() => _isLoading = true);

    final model = TokoModel(
      id: widget.barang?.id,
      nama_barang: _namaCtrl.text.trim(),
      deskripsi: _deskripsiCtrl.text.trim(),
      stok: int.parse(_stokCtrl.text.trim()),
      harga: double.parse(_hargaCtrl.text.trim()),
    );

    ResponseDataMap res = isEdit
        ? await tokoService.updateBarang(model, pickedFile: _pickedFile)
        : await tokoService.insertBarang(model, _pickedFile!);

    setState(() => _isLoading = false);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(res.status
          ? isEdit
              ? 'Barang berhasil diperbarui!'
              : 'Barang berhasil ditambahkan!'
          : res.message.isNotEmpty
              ? res.message
              : 'Terjadi kesalahan, coba lagi'),
      backgroundColor: res.status ? _primary : Colors.red.shade600,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
    if (res.status) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: _primaryDark, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          isEdit ? 'Edit Barang' : 'Tambah Barang',
          style: const TextStyle(
            color: _primaryDark,
            fontWeight: FontWeight.w800,
            fontSize: 20,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Image Picker ─────────────────────────────────────────────
              _ImagePickerWidget(
                imageBytes: _imageBytes,
                existingUrl: widget.barang?.gambar_url,
                onTap: _pickImage,
              ),
              const SizedBox(height: 20),

              _SectionLabel('Informasi Barang'),
              const SizedBox(height: 12),
              _Field(
                ctrl: _namaCtrl,
                label: 'Nama Barang',
                hint: 'Contoh: Sepatu Lari Nike',
                icon: Icons.inventory_2_rounded,
                validator: (v) => (v == null || v.isEmpty)
                    ? 'Nama barang wajib diisi'
                    : null,
              ),
              const SizedBox(height: 14),
              _Field(
                ctrl: _deskripsiCtrl,
                label: 'Deskripsi',
                hint: 'Deskripsi singkat barang...',
                icon: Icons.description_rounded,
                maxLines: 3,
                validator: (v) => (v == null || v.isEmpty)
                    ? 'Deskripsi wajib diisi'
                    : null,
              ),
              const SizedBox(height: 20),

              _SectionLabel('Harga & Stok'),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _Field(
                      ctrl: _hargaCtrl,
                      label: 'Harga (Rp)',
                      hint: '50000',
                      icon: Icons.payments_rounded,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly
                      ],
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Wajib diisi';
                        if (double.tryParse(v) == null)
                          return 'Angka tidak valid';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _Field(
                      ctrl: _stokCtrl,
                      label: 'Stok',
                      hint: '10',
                      icon: Icons.warehouse_rounded,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly
                      ],
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Wajib diisi';
                        if (int.tryParse(v) == null)
                          return 'Angka tidak valid';
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  onPressed: _isLoading ? null : _submit,
                  style: FilledButton.styleFrom(
                    backgroundColor: _primary,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2.5),
                        )
                      : Text(
                          isEdit ? 'Simpan Perubahan' : 'Tambah Barang',
                          style: const TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 15),
                        ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.grey.shade600,
                    side:
                        BorderSide(color: Colors.grey.shade300, width: 1.5),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('Batal',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Image Picker Widget ──────────────────────────────────────────────────────
class _ImagePickerWidget extends StatelessWidget {
  final Uint8List? imageBytes;
  final String? existingUrl;
  final VoidCallback onTap;

  const _ImagePickerWidget({
    required this.imageBytes,
    required this.existingUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Container(
          width: double.infinity,
          height: 180,
          color: const Color(0xFFEDE7F6),
          child: imageBytes != null
              // Gambar baru dipilih — pakai bytes (works di web & mobile)
              ? Image.memory(imageBytes!, fit: BoxFit.cover)
              : existingUrl != null && existingUrl!.isNotEmpty
                  // Gambar lama dari server (mode edit)
                  ? Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.network(existingUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => _empty()),
                        Container(color: Colors.black26),
                        const Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.edit_rounded,
                                  color: Colors.white, size: 28),
                              SizedBox(height: 6),
                              Text('Ganti gambar',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 13)),
                            ],
                          ),
                        ),
                      ],
                    )
                  : _empty(),
        ),
      ),
    );
  }

  Widget _empty() => const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.add_photo_alternate_rounded,
                size: 40, color: Color(0xFF7E57C2)),
            SizedBox(height: 8),
            Text('Pilih gambar dari galeri',
                style: TextStyle(color: Color(0xFF7E57C2), fontSize: 13)),
          ],
        ),
      );
}

// ─── Section Label ────────────────────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);
  @override
  Widget build(BuildContext context) => Text(text,
      style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: Color(0xFF00574B),
          letterSpacing: 0.3));
}

// ─── Field ────────────────────────────────────────────────────────────────────
class _Field extends StatelessWidget {
  final TextEditingController ctrl;
  final String label;
  final String hint;
  final IconData icon;
  final int maxLines;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;

  const _Field({
    required this.ctrl,
    required this.label,
    required this.hint,
    required this.icon,
    this.maxLines = 1,
    this.keyboardType,
    this.inputFormatters,
    this.validator,
    this.onChanged,
  });

  static const Color _primary = Color(0xFF5E35B1);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: ctrl,
      maxLines: maxLines,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      onChanged: onChanged,
      validator: validator,
      style: const TextStyle(fontSize: 14, color: Color(0xFF1A2E2A)),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
        labelStyle: const TextStyle(color: _primary, fontSize: 13),
        prefixIcon: Icon(icon, color: Colors.grey.shade400, size: 20),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey.shade200, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.red.shade400, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.red.shade400, width: 1.5),
        ),
      ),
    );
  }
}
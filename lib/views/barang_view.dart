
import 'package:flutter/material.dart';
import 'package:toko_online/models/response_data_list.dart';
import 'package:toko_online/services/toko.dart';
import 'package:toko_online/widgets/bottom_nav.dart';

class MovieView extends StatefulWidget {
  const MovieView({super.key});
  @override
  State<MovieView> createState() => _MovieViewState();
}

class _MovieViewState extends State<MovieView> {
  TokoService tokoService = TokoService();
  List? barang;
  getBarang() async {
    ResponseDataList getBarang = await tokoService.getBarang();
    setState(() {
      barang = getBarang.data;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getBarang();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Movie"),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: barang != null
          ? ListView.builder(
              itemCount: barang!.length,
              itemBuilder: (context, index) {
                return Card(
                  child: ListTile(
                    leading: Image(
                      image: NetworkImage(barang![index].posterPath),
                    ),
                    title: Text(barang![index].name),
                  ),
                );
              },
            )
          : Center(child: CircularProgressIndicator()),
      bottomNavigationBar: BottomNav(1),
    );
  }
}

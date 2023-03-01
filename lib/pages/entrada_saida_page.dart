import 'package:cached_network_image/cached_network_image.dart';
import 'package:estoque/product_entrada_saida.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../product.dart';
import '../services/product_service.dart';

class EntradaSaidaPage extends StatefulWidget {
  @override
  _EntradaSaidaPage createState() => _EntradaSaidaPage();
}

class _EntradaSaidaPage extends State<EntradaSaidaPage> {
  ProductService productService = ProductService();
  List<Product>? products;

  @override
  void initState() {
    super.initState();
    _getProducts();
  }

  _getProducts() async {
    List<Product> productsData = await productService.getAllProducts();
    setState(() {
      products = productsData;
    });
  }

  void ue() {
    // Recarregue a lista de produtos aqui
    setState(() {
      products = []; // Limpe a lista de produtos atual
      _getProducts(); // Carregue a lista de produtos novamente
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Entrada/Saída'),
      ),
      body: ListView.builder(
        itemCount: products?.length ?? 0,
        itemBuilder: (BuildContext context, int index) {
          Product product = products![index];
          return ListTile(
              leading: Container(
                height: 170,
                width: 80,
                child: CachedNetworkImage(
                  imageUrl: product.imageUrl,
                  width: 150,
                  height: 80,
                ),
              ),
              title: Text(product.name),
              subtitle: Text(product.description),
              onTap: () {
                Get.to(ProductEntradaSaida(
                  product: product,
                  onSave: ue,
                ));
              },
              trailing: Text("Qtd.  ${product.quantity}"));
        },
      ),
    );
  }
}

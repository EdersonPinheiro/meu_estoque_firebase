import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:estoque/edit_product_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../create_product_page.dart';
import '../product.dart';
import '../services/product_service.dart';

class ProductsPage extends StatefulWidget {
  @override
  _ProductPageState createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductsPage> {
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

  void _updateProductsList() {
    // Recarregue a lista de produtos aqui
    setState(() {
      products = []; // Limpe a lista de produtos atual
      _getProducts(); // Carregue a lista de produtos novamente
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
        title: const Text('Produtos'),
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
              ),
            ),
            title: Text(product.name),
            subtitle: Text(product.description),
            onTap: () {},
            trailing: IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () async {
                // Abre a página de edição de produtos quando o botão é pressionado
                Get.to(EditProductPage(
                    product: product, onSave: _updateProductsList));
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.to(CreateProductPage(
            onSave: ue,
          ));
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

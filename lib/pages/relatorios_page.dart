import 'dart:io';

import 'package:estoque/product.dart';
import 'package:estoque/services/product_service.dart';
import 'package:estoque/relatorios/pdf_movimentacoes_api.dart';
import 'package:flutter/material.dart';
import '../relatorios/pdf_api.dart';
import '../relatorios/pdf_paragraph_api.dart';

class RelatoriosPage extends StatefulWidget {
  const RelatoriosPage({super.key, this.restorationId});

  final String? restorationId;
  @override
  State<RelatoriosPage> createState() => _RelatoriosPageState();
}

class _RelatoriosPageState extends State<RelatoriosPage> {
  ProductService productService = ProductService();
  List<Product>? _products;
  DateTime dateSelected = DateTime.now();

  List<Product>? get products => _products;

  @override
  void initState() {
    super.initState();
    updateProducts();
    updateProductsEstoque();
  }

  void updateProductsEstoque() async {
    final updatedProducts = await productService.getAllProducts();
    _products = updatedProducts;
  }

  void updateProducts() async {
    final updatedProducts =
        await productService.getAllProductsRelatorio(dateSelected.toString());
    _products = updatedProducts;
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2015, 8),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        dateSelected = picked;
      });
    }
  }

  String dataFormatada(DateTime data) {
    return "${data.day.toString().padLeft(2, '0')}/${data.month.toString().padLeft(2, '0')}/${data.year.toString()}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Relatórios")),
      body: Center(
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () async {
                final api = PdfParagraphApi(products!);
                setState(() {
                  api.updateProducts();
                });
                final pdfFile = await PdfParagraphApi.generate(api);
                PdfApi.openFile(pdfFile);
              },
              child: Text("Relatório de Estoque"),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () async {
                _selectDate(context);
                final api = PdfMovimentacoes(
                  _products!,
                  dataFormatada(dateSelected),
                );
                setState(() {
                  api.updateProducts();
                });
                final pdfFile = await PdfMovimentacoes.generate(api);
                PdfApi.openFile(pdfFile);
              },
              child: Text("Relatório de Movimentações"),
            ),
          ],
        ),
      ),
    );
  }
}

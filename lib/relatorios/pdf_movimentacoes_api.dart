import 'dart:io';

import 'package:estoque/product.dart';
import 'package:estoque/services/product_service.dart';
import 'package:estoque/relatorios/pdf_api.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/widgets.dart';

class PdfMovimentacoes {
  ProductService productService = ProductService();
  late List<Product> _movimentacoes;
  late String selectedDate;
  PdfMovimentacoes(this._movimentacoes, this.selectedDate);

  void updateProducts() async {
    final updatedProducts =
        await productService.getAllProductsRelatorio(selectedDate);
    _movimentacoes = updatedProducts;
  }

  List<Product> get movimentacoes => _movimentacoes;

  static Future<File> generate(PdfMovimentacoes api) async {
    final movimentacoes = api.movimentacoes;
    final pdf = pw.Document();

    final customFont =
        Font.ttf(await rootBundle.load('assets/OpenSans-Regular.ttf'));

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            children: <pw.Widget>[
              pw.Text('Relatório de Movimentacoes',
                  style: pw.Theme.of(context).defaultTextStyle.copyWith(
                        fontSize: 20,
                        fontWeight: pw.FontWeight.bold,
                      )),
              pw.SizedBox(height: 20),
              pw.Table(
                children: [
                  pw.TableRow(children: [
                    pw.Text('Usuário'),
                    pw.Text('Nome'),
                    pw.Text('Movimentação'),
                    pw.Text('Quantidade'),
                    pw.Text('Data'),
                  ]),
                  ...movimentacoes.map((movimentacao) {
                    return pw.TableRow(children: [
                      pw.Text(movimentacao.userName.substring(0, 18)),
                      pw.Text(movimentacao.name),
                      pw.Text(movimentacao.movimentacao),
                      pw.Text(movimentacao.lastQuantity),
                      pw.Text(movimentacao.dataMov),
                      pw.Text(movimentacao.horaMov)
                    ]);
                  }).toList(),
                ],
              ),
            ],
          );
        },
      ),
    );
    return PdfApi.saveDocument(
      name: 'relatorio_movimentacoes',
      pdf: pdf,
    );
  }
}

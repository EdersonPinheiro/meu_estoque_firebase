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
  PdfMovimentacoes(this._movimentacoes);

  List<Product> get products => _movimentacoes;

  static Future<File> generate(PdfMovimentacoes api) async {
    var movimentacoes = api.products;
    final pdf = Document();
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
                      pw.Text(movimentacao.userName.length > 18
                          ? movimentacao.userName.substring(0, 18)
                          : movimentacao.userName),
                      pw.Text(movimentacao.name.length > 18
                          ? movimentacao.name.substring(0, 18)
                          : movimentacao.name),
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
    final now = DateTime.now();
    final name =
        'relatorio_movimentacoes_atual_${now.year}_${now.month}_${now.day}_${now.millisecondsSinceEpoch}.pdf';
    return PdfApi.saveDocument(name: name, pdf: pdf);
  }
}

String dataFormatada(DateTime data) {
  return "${data.day.toString().padLeft(2, '0')}/${data.month.toString().padLeft(2, '0')}/${data.year.toString()}";
}

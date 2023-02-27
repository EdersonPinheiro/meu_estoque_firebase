import 'package:estoque/product.dart';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class EntradaSaidaRelatorio extends StatelessWidget {
  final List<Product> products;

  EntradaSaidaRelatorio({required this.products});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Relatório de Entrada e Saída'),
      ),
      body: Container(
        child: _buildReport(),
      ),
    );
  }

  Widget _buildReport() {
    final pw.Document pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            children: <pw.Widget>[
              pw.Text('Relatório de Entrada e Saída',
                  style: pw.Theme.of(context).defaultTextStyle.copyWith(
                        fontSize: 20,
                        fontWeight: pw.FontWeight.bold,
                      )),
              pw.SizedBox(height: 20),
              pw.Table(
                children: [
                  pw.TableRow(children: [
                    pw.Text('Nome'),
                    pw.Text('Descrição'),
                    pw.Text('Quantidade'),
                  ]),
                  ...products.map((product) {
                    return pw.TableRow(children: [
                      pw.Text(product.name),
                      pw.Text(product.description),
                      pw.Text("${product.quantity}"),
                    ]);
                  }).toList(),
                ],
              ),
            ],
          );
        },
      ),
    );

    return Container(
      
    );
  }
}

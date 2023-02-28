import 'package:estoque/product.dart';
import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import '../services/product_service.dart';

class MovimentacoesPage extends StatefulWidget {
  const MovimentacoesPage({
    super.key,
  });

  @override
  State<MovimentacoesPage> createState() => _MovimentacoesPageState();
}

class _MovimentacoesPageState extends State<MovimentacoesPage> {
  ProductService productService = ProductService();
  List<Product>? products;
  String lastData = '';
  var currentDate = DateTime.now();
  String dataFormatada(DateTime data) {
    return "${data.day.toString().padLeft(2, '0')}/${data.month.toString().padLeft(2, '0')}/${data.year.toString()}";
  }

  @override
  void initState() {
    super.initState();
    _getProducts();
  }

  _getProducts() async {
    List<Product> productsData = await productService.getAllMovimentacao();
    setState(() {
      products = productsData;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (products == null)
      return const Center(child: CircularProgressIndicator());
    Map<String, List<Product>> movimentacoesGroup =
        groupBy(products!, (product) => product.dataMov);

    return Scaffold(
      appBar: AppBar(centerTitle: true, title: const Text("Movimentações")),
      body: SingleChildScrollView(
        child: Column(
          children: [
            for (var entry in movimentacoesGroup.entries)
              Column(
                children: [
                  if (entry.key != dataFormatada(currentDate).toString())
                    Text(entry.key),
                  const Divider(),
                  for (var movimentacao in entry.value)
                    ListTile(
                      leading: Image.network(
                        movimentacao.imageUrl,
                        height: 150,
                        width: 80,
                      ),
                      title: Text(movimentacao.name),
                      subtitle: Text(movimentacao.lastQuantity),
                      trailing: movimentacao.movimentacao == "Entrada"
                          ? const Icon(
                              Icons.arrow_upward,
                              color: Colors.green,
                            )
                          : const Icon(
                              Icons.arrow_downward,
                              color: Colors.red,
                            ),
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text('Última movimentação'),
                              content: Text(
                                  '${movimentacao.movimentacao}: ${movimentacao.dataMov} ${movimentacao.horaMov}\n'
                                  '${movimentacao.name}\n'
                                  'Usuário: ${movimentacao.userName}'),
                              actions: [
                                ElevatedButton(
                                  child: Text('Fechar'),
                                  onPressed: () {
                                    Navigator.of(context)
                                        .pop(); // Close the window
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      },
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

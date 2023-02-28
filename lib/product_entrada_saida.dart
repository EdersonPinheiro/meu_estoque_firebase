import 'package:estoque/pages/userInformacoes.dart';
import 'package:estoque/product.dart';
import 'package:estoque/services/product_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'constants/constants.dart';

class ProductEntradaSaida extends StatefulWidget {
  final Product product;
  final Function onSave;
  const ProductEntradaSaida(
      {super.key, required this.product, required this.onSave});

  @override
  State<ProductEntradaSaida> createState() => _ProductEntradaSaidaState();
}

class _ProductEntradaSaidaState extends State<ProductEntradaSaida> {
  final _formKey = GlobalKey<FormState>();
  ProductService productService = ProductService();
  final _descriptionController = TextEditingController();
  final _quantityController = TextEditingController();
  final _lastQuantityController = TextEditingController();
  List<UserInformacoes>? userInformacoesList;
  bool _isLoading = false;
  late Rx<User?> firebaseUser;
  String? userId;
  String? userName;
  late UserInformacoes userInformacoes;

  void onReady() {
    firebaseUser = Rx<User?>(auth.currentUser);
    userId = firebaseUser
        .toString(); //atribui o usuário atual da autenticação firebase a ela.
    userName = auth.currentUser?.displayName.toString();
  }

  _getInfoUser() async {
    userInformacoesList = await productService.getInfoUser();
    userInformacoesList?.forEach((element) {
      setState(() {
        userName = element.userName;
      });
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getInfoUser();
  }

  setInitialScreen(User? user) {
    if (user != null) {
      // user is logged in
      return "Usuario nulo";
    } else {
      // user is null as in user is not available or not logged in
      return "Usuário logado";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(centerTitle: true, title: Text(widget.product.name)),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            TextFormField(
              controller: _descriptionController,
              decoration: InputDecoration(labelText: 'Descrição'),
            ),
            TextFormField(
              controller: _quantityController,
              decoration: InputDecoration(labelText: 'Quantidade'),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value!.isEmpty) {
                  return "Insira a quantidade";
                }
              },
            ),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                      child: Text('Entrada'),
                      onPressed: () {
                        _entrada();
                      }),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                      style:
                          ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      child: Text('Saída'),
                      onPressed: () {
                        _saida();
                      }),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String horaFormatada(DateTime data) {
    return "${data.hour.toString().padLeft(2, '0')}:${data.minute.toString().padLeft(2, '0')}";
  }

  String dataFormatada(DateTime data) {
    return "${data.day.toString().padLeft(2, '0')}/${data.month.toString().padLeft(2, '0')}/${data.year.toString()}";
  }

  void _entrada() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
// Atualiza o produto no banco de dados
      int currentQuantity = widget.product.quantity;
      int quantityToSum = int.parse(_quantityController.text);
      _lastQuantityController.text = _quantityController.text.toString();
      _quantityController.text = (currentQuantity + quantityToSum).toString();
      final data = DateTime.now();

      Product updateESProduct = Product(
          id: widget.product.id,
          name: widget.product.name,
          description: _descriptionController.text,
          quantity: int.parse(_quantityController.text),
          imageUrl: widget.product.imageUrl,
          price: widget.product.price,
          movimentacao: 'Entrada',
          lastQuantity: _lastQuantityController.text,
          dataMov: dataFormatada(data),
          horaMov: horaFormatada(data),
          userId: userId.toString(),
          userName: userName.toString());
      await productService.updateProduct(updateESProduct);
      try {
        await productService.createMovimentacao(updateESProduct).then((_) {
          setState(() {
            _isLoading = false;
          });
          // Chame o callback após salvar o produto
          widget.onSave();
          Navigator.of(context).pop();
        });

        // Atualiza a lista de produtos
        Get.offNamed('/products', arguments: true);
      } catch (e) {
        print(e);
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _saida() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
// Atualiza o produto no banco de dados
      int currentQuantity = widget.product.quantity;
      int quantityToSum = int.parse(_quantityController.text);
      _lastQuantityController.text = _quantityController.text.toString();
      _quantityController.text = (currentQuantity - quantityToSum).toString();
      final data = DateTime.now();

      Product updateESProduct = Product(
        id: widget.product.id,
        name: widget.product.name,
        description: _descriptionController.text,
        quantity: int.parse(_quantityController.text),
        imageUrl: widget.product.imageUrl,
        price: widget.product.price,
        movimentacao: 'Saída',
        lastQuantity: _lastQuantityController.text,
        dataMov: dataFormatada(data),
        horaMov: horaFormatada(data),
        userId: userId.toString(),
        userName: userName.toString(),
      );
      if (quantityToSum > currentQuantity) {
        Get.snackbar("Erro",
            "Você tentou realizar uma operação, porém esse produto possui: ${currentQuantity} no estoque.",
            snackPosition: SnackPosition.BOTTOM);
        setState(() {
          Navigator.of(context).pop();
        });
        return;
      }

      await productService.updateProduct(updateESProduct);

      try {
        await productService.createMovimentacao(updateESProduct).then((_) {
          setState(() {
            _isLoading = false;
          });
          // Chame o callback após salvar o produto
          widget.onSave();
          Navigator.of(context).pop();
        });

        // Atualiza a lista de produtos
        Get.offNamed('/products', arguments: true);
      } catch (e) {
        print(e);
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}

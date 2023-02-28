import 'package:estoque/constants/constants.dart';
import 'package:estoque/controllers/auth_controller.dart';
import 'package:estoque/pages/entrada_saida_page.dart';
import 'package:estoque/pages/grupos_page.dart';
import 'package:estoque/pages/movimentacoes_page.dart';
import 'package:estoque/pages/payment.dart';
import 'package:estoque/pages/userInformacoes.dart';
import 'package:estoque/pages/products_page.dart';
import 'package:firebase_dart/auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'relatorios_page.dart';
import '../product.dart';
import '../services/product_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  ProductService productService = ProductService();
  List<Product>? products;
  List<UserInformacoes>? userInformacoesList;
  AuthController authController = AuthController();
  GoogleSignIn googleSignIn = GoogleSignIn();
  String userName = '';

  @override
  void initState() {
    super.initState();
    _getInfoUser();
    _getProducts();
  }

  _getInfoUser() async {
    List<UserInformacoes>? userInformacoesData =
        await productService.getInfoUser();
    setState(() {
      userInformacoesList = userInformacoesData;
    });
  }

  _getProducts() async {
    List<Product> productsData = await productService.getAllProducts();
    setState(() {
      products = productsData;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 170, 200, 252),
      appBar: AppBar(
        title: const Text("Meu Estoque"),
        centerTitle: true,
      ),
      drawer: Drawer(
        child: ListView.builder(
          itemCount: userInformacoesList?.length ?? 0,
          itemBuilder: (BuildContext context, int index) {
            UserInformacoes userInformacoes = userInformacoesList![index];
            return Column(
              children: [
                UserAccountsDrawerHeader(
                  decoration: BoxDecoration(color: Colors.blue),
                  accountName: Text(
                    userInformacoes.userName,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  accountEmail: Text(
                    userInformacoes.email,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  currentAccountPicture: Container(
                    width: 100.0,
                    height: 100.0,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        fit: BoxFit.cover,
                        image: NetworkImage(userInformacoes.image),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                ListTile(
                  title: Text('Sair'),
                  onTap: () {
                    authController.signOut();
                  },
                ),
                const Divider(
                  height: 60,
                ),
                ListTile(
                  title: Text('Apagar minha conta'),
                  onTap: () {
                    authController.deleteAccount();
                  },
                ),
              ],
            );
          },
        ),
      ),
      body: Center(
        child: GridView.count(
          crossAxisCount: 2, // number of columns
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(23),
              child: ElevatedButton(
                onPressed: () {
                  // action for entrada/saida button
                  Get.to(EntradaSaidaPage());
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const <Widget>[
                    Icon(Icons.swap_horiz),
                    Text("Entrada/Saida"),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(23),
              child: ElevatedButton(
                onPressed: () {
                  Get.to(ProductsPage());
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const <Widget>[
                    Icon(Icons.shopping_basket),
                    Text("Produto"),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(23),
              child: ElevatedButton(
                onPressed: () {
                  // action for entrada/saida button
                  Get.to(() => MovimentacoesPage());
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const <Widget>[
                    Icon(Icons.move_to_inbox),
                    Text("Movimentações"),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(23),
              child: ElevatedButton(
                onPressed: () async {
                  bool isPremium = await productService.getUserPremium();
                  if (isPremium) {
                    Get.to(const RelatoriosPage());
                  } else {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: new Text("Você não é um usuário prime"),
                          content: new Text(
                              "Portanto não possui acesso a essa página"),
                          actions: <Widget>[
                            new ElevatedButton(
                              child: new Text("Assinar Prime"),
                              onPressed: () {
                                Get.to(Payment());
                              },
                            ),
                          ],
                        );
                      },
                    );
                  }
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const <Widget>[
                    Icon(Icons.assessment),
                    Text("Relatórios"),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(23),
              child: ElevatedButton(
                onPressed: () async {
                  bool isPremium = await productService.getUserPremium();
                  if (isPremium) {
                    Get.to(const GruposPage());
                  } else {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: new Text("Você não é um usuário prime"),
                          content: new Text(
                              "Portanto não possui acesso a essa página"),
                          actions: <Widget>[
                            new ElevatedButton(
                              child: new Text("Assinar Prime"),
                              onPressed: () {
                                Get.to(Payment());
                              },
                            ),
                          ],
                        );
                      },
                    );
                  }
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const <Widget>[
                    Icon(Icons.add_box),
                    Text("Grupos"),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

logout() async {
  try {
    final credential = await FirebaseAuth.instance.signOut();
    Get.to(HomePage());
  } on FirebaseAuthException catch (e) {
    if (e.code == 'weak-password') {
      print('The password provided is too weak.');
    } else if (e.code == 'email-already-in-use') {
      print('The account already exists for that email.');
    }
  } catch (e) {
    print(e);
  }
}

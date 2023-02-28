import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:estoque/constants/constants.dart';
import 'package:estoque/pages/login_page.dart';
import 'package:estoque/pages/userInformacoes.dart';
import 'package:firebase_dart/auth.dart';
import 'package:get/get.dart';

import '../grupo.dart';
import '../product.dart';

class ProductService {
  // Cria uma instância do Firestore
  final db = FirebaseFirestore.instance;
  UserInformacoes? user;
  var id = auth.currentUser?.uid;

  // Cria um novo produto
  // Cria um novo produto
  Future<void> createProduct(Product product) async {
    // Adiciona o produto ao banco de dados e obtém o ID gerado pelo Firebase
    var docRef = await db.collection('products').add(product.toMap());
    var idDoProduto = docRef.id;
    var idDoUsuario = auth.currentUser?.uid;

    // Atualiza a instância de Product com o ID gerado pelo Firebase
    product.id = idDoProduto;
    product.userId = idDoUsuario.toString();
    // Atualiza o documento no banco de dados com o ID
    docRef.update({'id': idDoProduto, 'userId': idDoUsuario});
  }

  Future<void> createOperador(UserInformacoes userInformacoes) async {
    // Adiciona o produto ao banco de dados e obtém o ID gerado pelo Firebase
    var docRef = await db.collection('operadores').add(userInformacoes.toMap());
    var idDoUsuario = auth.currentUser!.uid;

    // Atualiza a instância de Product com o ID gerado pelo Firebase
    userInformacoes.userId = idDoUsuario.toString();
    // Atualiza o documento no banco de dados com o ID
    docRef.update({'userId': idDoUsuario});
  }

  Future<void> createGrupo(Grupo grupo) async {
    // Adiciona o produto ao banco de dados e obtém o ID gerado pelo Firebase
    var docRef = await db.collection('grupo').add(grupo.toMap());
    var idDoGrupo = docRef.id;
    var idDoUsuario = auth.currentUser?.uid;

    // Atualiza a instância de Product com o ID gerado pelo Firebase
    grupo.userId = idDoUsuario.toString();
    grupo.id = idDoGrupo;
    // Atualiza o documento no banco de dados com o ID
    docRef.update({'id': idDoGrupo, 'userId': idDoUsuario});
  }

  Future<String> getOperadorByEmail(String email, String senha) async {
    var operador = await db
        .collection('operadores')
        .where("email", isEqualTo: email)
        .get();
    return operador.toString();
  }

  Future<void> createMovimentacao(Product product) async {
    // Adiciona o produto ao banco de dados e obtém o ID gerado pelo Firebase
    var docRef = await db.collection('movimentacao').add(product.toMap());
    var idDoProduto = docRef.id;
    var idDoUsuario = auth.currentUser?.uid;

    // Atualiza a instância de Product com o ID gerado pelo Firebase
    product.id = idDoProduto;
    product.userId = idDoUsuario.toString();

    // Atualiza o documento no banco de dados com o ID
    docRef.update({'id': idDoProduto, 'userId': idDoUsuario});
  }

  Future<List<Product>> getAllMovimentacao() async {
    // Obtém todos os documentos da coleção 'products'
    var querySnapshot = await db
        .collection("movimentacao")
        .where("userId", isEqualTo: id)
        .orderBy("dataMov", descending: true)
        .get();

    // Transforma cada documento em um objeto do modelo de produto e adiciona à lista
    return querySnapshot.docs
        .map((doc) => Product.fromMap({...doc.data()}))
        .toList();
  }

  Future<String> getLastMovimentacao() async {
// Obtém o primeiro documento da coleção 'movimentacao' ordenado pela dataMov em ordem decrescente
    var querySnapshot = await db
        .collection("movimentacao")
        .where("userId", isEqualTo: id)
        .orderBy("dataMov", descending: true)
        .limit(1)
        .get();
    if (querySnapshot.docs.isNotEmpty) {
      var doc = querySnapshot.docs.first;
      var dataMov = doc.data()['dataMov'];
      return dataMov;
    } else
      return "";
  }

  Future<List<UserInformacoes>?> getInfoUser() async {
    var querySnapshot =
        await db.collection("users").where("uid", isEqualTo: id).get();
    //var userName = querySnapshot.docs.first.data()["user_name"];

    return querySnapshot.docs
        .map((doc) => UserInformacoes.fromMap({...doc.data()}))
        .toList();
  }

  Future<bool> getUserPremium() async {
    var querySnapshot =
        await db.collection("users").where("prime", isEqualTo: true).get();
    return querySnapshot.docs.isNotEmpty;
  }

  Future<List<Grupo>> getProductWithId(String id) async {
    var querySnapshot = await db.collection('products').where("grupo").get();
    // Transforma cada documento em um objeto do modelo de produto e adiciona à lista
    return querySnapshot.docs
        .map((doc) => Grupo.fromMap({...doc.data()}))
        .toList();
  }

  // Lê todos os produtos
  Future<List<Product>> getAllProducts() async {
    // Obtém todos os documentos da coleção 'products'
    var querySnapshot =
        await db.collection('products').where('userId', isEqualTo: id).get();
    // Transforma cada documento em um objeto do modelo de produto e adiciona à lista
    
    return querySnapshot.docs
        .map((doc) => Product.fromMap({...doc.data()}))
        .toList();
  }

  Future<List<Product>> getAllProductsRelatorio(String selected) async {
    // Obtém todos os documentos da coleção 'products'
    var querySnapshot = await db
        .collection('movimentacao')
        .where("dataMov", isEqualTo: selected).where("userId", isEqualTo: id)
        .get();
    return querySnapshot.docs
        .map((doc) => Product.fromMap({...doc.data()}))
        .toList();
  }

  Future<List<UserInformacoes>> getAllOperador() async {
    // Obtém todos os documentos da coleção 'products'
    var querySnapshot =
        await db.collection('operadores').where("userId", isEqualTo: id).get();
    // Transforma cada documento em um objeto do modelo de produto e adiciona à lista
    return querySnapshot.docs
        .map((doc) => UserInformacoes.fromMap({...doc.data()}))
        .toList();
  }

  Future<List<Grupo>> getAllGroups() async {
    // Obtém todos os documentos da coleção 'products'
    var querySnapshot =
        await db.collection('grupo').where("userId", isEqualTo: id).get();
    // Transforma cada documento em um objeto do modelo de produto e adiciona à lista
    return querySnapshot.docs
        .map((doc) => Grupo.fromMap({...doc.data()}))
        .toList();
  }

  Future<Product?> getProductById(String id) async {
    //Caso for fazer uma pesquisa
    // Obtém o documento do banco de dados pelo ID
    var doc = await db.collection('products').doc(id).get();
    // Transforma o documento em um objeto do modelo de produto, se os dados existirem
    return doc.data() != null ? Product.fromMap({...?doc.data()}) : null;
  }

  // Atualiza um produto pelo ID
  Future<void> updateProduct(Product product) async {
    if (product.id == null || product.id.isEmpty) {
      print("ID inválido");
    }
    // Atualiza o documento no banco de dados pelo ID
    await db.collection('products').doc(product.id).update(product.toMap());
  }

  // Exclui um produto pelo ID
  Future<void> deleteProduct(String id) async {
    if (id == null || id.isEmpty) {
      print("ID inválido");
      return;
    }
    // Exclui o documento do banco de dados pelo ID
    await db.collection('products').doc(id).delete();
    print("deletado");
  }

  Future<void> updateGroup(Grupo grupo) async {
    if (grupo.id == null || grupo.id.isEmpty) {
      print("ID inválido");
    }
    // Atualiza o documento no banco de dados pelo ID
    await db.collection('grupo').doc(grupo.id).update(grupo.toMap());
  }

  Future<void> deleteGrupo(String id) async {
    if (id == null || id.isEmpty) {
      print("ID inválido");
      return;
    }
    // Exclui o documento do banco de dados pelo ID
    await db.collection('grupo').doc(id).delete();
    print("deletado");
  }
}

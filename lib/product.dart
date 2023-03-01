import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'grupo.dart';

class Product {
  late String id;
  late String imageUrl;
  late String userName;
  late String name;
  late String price;
  late int quantity;
  late String description;
  late String movimentacao;
  late String lastQuantity;
  late String dataMov;
  late String horaMov;
  late String userId;
  late String grupo;

  Product(
      {required this.id,
      this.imageUrl = '',
      required this.name,
      required this.price,
      required this.quantity,
      required this.description,
      this.movimentacao = '',
      this.lastQuantity = '',
      this.dataMov = '',
      this.horaMov = '',
      this.userId = '',
      this.userName = '',
      this.grupo = ''});

  Product.empty() {
    id = '';
    imageUrl = '';
    name = '';
    price = '';
    quantity = 0;
    description = '';
    dataMov = '';
    horaMov = '';
    userName = '';
    grupo = '';
  }

  //Busca os dados
  Product.fromMap(Map<String, dynamic> data) {
    id = data['id'];
    imageUrl = data['imageUrl'] ?? '';
    name = data['name'];
    price = data['price'].toString();
    quantity = int.parse(data['quantity'].toString());
    description = data['description'];
    movimentacao = data['movimentacao'];
    lastQuantity = data['lastQuantity'];
    dataMov = data['dataMov'];
    horaMov = data['horaMov'];
    userName = data['userName'];
    grupo = data['grupo'];
  }

  //Envia os dados
  Map<String, dynamic> toMap() {
    Map<String, dynamic> data = {
      'id': id,
      'name': name,
      'price': price,
      'quantity': quantity,
      'description': description,
      'movimentacao': movimentacao,
      'lastQuantity': lastQuantity,
      'dataMov': dataMov,
      'horaMov': horaMov,
      'userName': userName,
      'grupo': grupo
    };

    if (imageUrl != null && imageUrl.isNotEmpty) {
      print(imageUrl);
      data['imageUrl'] = imageUrl;
    } else {
      data['imageUrl'] =
          'https://cdn.awsli.com.br/production/static/img/produto-sem-imagem.gif';
    }
    return data;
  }
}

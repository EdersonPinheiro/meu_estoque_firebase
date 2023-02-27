import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:estoque/constants/constants.dart';
import 'package:firebase_dart/auth.dart';

class UserInformacoes {
  late String userId;
  late String userName;
  late String email;
  late String senha;
  late String image;
  late String empresa;

  UserInformacoes({
    this.senha = '',
    this.email = '',
    required this.userName,
    this.empresa = '',
  });

  UserInformacoes.fromMap(Map<String, dynamic> data) {
    userName = data['user_name'];
    email = data['email'];
    image = data['image'] ?? '';
  }

  Map<String, dynamic> toMap() {
    return {
      'user_name': userName,
      'email': email,
      'senha': senha,
    };
  }
}

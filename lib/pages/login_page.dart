import 'package:estoque/controllers/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  AuthController authController = AuthController();
  final _userNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                controller: _userNameController,
                decoration: const InputDecoration(
                  labelText: 'Nome',
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Insira um nome';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Insira um email';
                  }
                  return null;
                },
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Senha',
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Insira uma senha';
                  }
                  return null;
                },
                obscureText: true,
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () {
                  authController.login(
                      _emailController.text, _passwordController.text);
                },
                child: const Text('Entrar'),
              ),
              const SizedBox(height: 16.0),
              TextButton(
                onPressed: () {
                  authController.register(_emailController.text,
                      _passwordController.text, _userNameController.text);
                },
                child: const Text('Criar conta'),
              ),
              ElevatedButton(
                onPressed: () {
                  authController.signInWithGoogle();
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Image.asset("assets/googlelogo.png", height: 35.0),
                    Text("oogle")
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

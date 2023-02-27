import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';

import '../constants/constants.dart';
import '../grupo.dart';
import '../services/product_service.dart';

class CreateGrupoPage extends StatefulWidget {
  final Function onSave;
  const CreateGrupoPage({super.key, required this.onSave});

  @override
  State<CreateGrupoPage> createState() => _CreateGrupoPageState();
}

class _CreateGrupoPageState extends State<CreateGrupoPage> {
  ProductService productService = ProductService();
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isLoading = false;
  String id = '';

  @override
  void initState() {
    super.initState();
    _getGrupos();
    _nameController.text = '';
    _descriptionController.text = '';
  }

  Future<void> _getGrupos() async {
    id = auth.currentUser!.uid.toString();

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Criar Grupo'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Nome',
                ),
                validator: (value) {
                  if (value == null) {
                    return 'Insira o nome';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Descrição',
                ),
                validator: (value) {
                  if (value == null) {
                    return 'Insira a descrição';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              _isLoading
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _createProduct,
                      child: Text('Criar'),
                    ),
            ],
          ),
        ),
      ),
    );
  }

// Chama o método de criação de produtos e,
//se a criação for bem-sucedida, atualiza a lista de produtos

  void _createProduct() async {
    var userId = auth.currentUser?.uid.toString();
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
// Atualiza o produto no banco de dados
      try {
        Grupo createGroup = Grupo(
          nome: _nameController.text,
          descricao: _descriptionController.text,
          userId: userId.toString(),
          id: '',
        );
        await productService.createGrupo(createGroup).then((_) {
          setState(() {
            _isLoading = false;
          });
          // Chame o callback após salvar o produto
          widget.onSave();
          Navigator.of(context).pop();
        });
        // Atualiza a lista de produtos

      } catch (error) {
        print('error $error');
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}

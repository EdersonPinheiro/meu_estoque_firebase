import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';

import '../grupo.dart';
import '../product.dart';
import '../services/product_service.dart';

class EditGroupPage extends StatefulWidget {
  final Grupo grupo;
  final Function onSave;
  const EditGroupPage({super.key, required this.grupo, required this.onSave});

  @override
  State<EditGroupPage> createState() => _EditGroupPageState();
}

class _EditGroupPageState extends State<EditGroupPage> {
  ProductService productService = ProductService();
  final _formKey = GlobalKey<FormState>();
  final _imageController = TextEditingController();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.grupo.nome;
    _descriptionController.text = widget.grupo.descricao;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Editar Grupo'),
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(labelText: 'Nome'),
                      validator: (value) {
                        if (value == null) {
                          return 'Por favor, insira o nome do produto';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: InputDecoration(labelText: 'Descrição'),
                      maxLines: 3,
                      validator: (value) {
                        if (value == null) {
                          return 'Por favor, insira a descrição do produto';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                setState(() {
                                  _isLoading = true;
                                });
                                // Atualiza o produto no banco de dados
                                Grupo updatedGroup = Grupo(
                                  id: widget.grupo.id,
                                  nome: _nameController.text,
                                  descricao: _descriptionController.text,
                                  userId: widget.grupo.userId,
                                );
                                productService
                                    .updateGroup(updatedGroup)
                                    .then((_) {
                                  setState(() {
                                    _isLoading = false;
                                  });
                                  // Chame o callback após salvar o produto
                                  widget.onSave();
                                  Navigator.of(context).pop();
                                });
                              }
                            },
                            child: Text('Salvar'),
                          ),
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _isLoading = true;
                              });
                              // Exclui o produto do banco de dados
                              productService
                                  .deleteGrupo(widget.grupo.id)
                                  .then((_) {
                                setState(() {
                                  _isLoading = false;
                                });
                                // Chame o callback após excluir o produto
                                widget.onSave();
                                Navigator.of(context).pop();
                              });
                            },
                            child: Text('Excluir'),
                            style: ButtonStyle(
                              backgroundColor:
                                  MaterialStateProperty.resolveWith<Color>(
                                      (Set<MaterialState> states) {
                                return Colors.red;
                              }),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

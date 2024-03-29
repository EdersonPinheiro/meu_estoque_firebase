import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:estoque/constants/constants.dart';
import 'package:estoque/grupo.dart';
import 'package:estoque/services/product_service.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

import 'product.dart';

class EditProductPage extends StatefulWidget {
  final Product product;
  final Function onSave; // Adicione o callback aqui

  EditProductPage({required this.product, required this.onSave});

  @override
  _EditProductPageState createState() => _EditProductPageState();
}

class _EditProductPageState extends State<EditProductPage> {
  ProductService productService = ProductService();
  final _formKey = GlobalKey<FormState>();
  final _imageController = TextEditingController();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _grupoController = TextEditingController();
  final _quantityController = TextEditingController();
  bool _isLoading = false;
  List<Grupo> _grupos = [];
  Grupo? _selectedGrupo;
  String id = '';

  @override
  void initState() {
    super.initState();
    _getGrupos();
    _grupoController.text = widget.product.grupo;
    _imageController.text = widget.product.imageUrl;
    _nameController.text = widget.product.name;
    _priceController.text = widget.product.price.toString();
    _descriptionController.text = widget.product.description;
    _quantityController.text = widget.product.quantity.toString();
  }

  Future<void> _getGrupos() async {
    id = auth.currentUser!.uid.toString();
    _grupos = await productService.getAllGroups();
    setState(() {});
  }

  File? _imageFile;
  String? _imageUrl;
  String? _selectedImage;

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source);

    setState(() {
      if (pickedFile != null) {
        _imageFile = File(pickedFile.path);
        _selectedImage = _imageFile!.path;
      } else {
        setState(() {});
      }
    });
  }

  late String downloadUrl;
  Future<void> _uploadImage() async {
    final storage = firebase_storage.FirebaseStorage.instance;
    final ref = storage
        .ref()
        .child('${id = auth.currentUser!.uid.toString()}')
        .child('${DateTime.now()}');
    final metadata = firebase_storage.SettableMetadata(
      contentType: 'image/jpeg',
      customMetadata: {'picked-file-path': _selectedImage!},
    );
    final uploadTask = ref.putFile(_imageFile!, metadata);
    final snapshot = await uploadTask.whenComplete(() {});
    downloadUrl = await snapshot.ref.getDownloadURL();
    print("Download URL: ${downloadUrl}");
    setState(() {
      _imageUrl = downloadUrl;
      print("image URL: ${_imageUrl}");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.product.name), actions: [
        IconButton(
            onPressed: () async {
              await _pickImage(ImageSource.gallery);
            },
            icon: Icon(Icons.image))
      ]),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    _selectedImage != null
                        ? Container(
                            width: 120,
                            height: 120,
                            child: Image.file(File(_selectedImage!),
                                fit: BoxFit.fitHeight),
                          )
                        : CachedNetworkImage(
                            imageUrl: widget.product.imageUrl,
                            width: 150,
                            height: 80,
                          ),
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(labelText: 'Nome'),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Por favor, insira o nome do produto';
                        }
                        return null;
                      },
                    ),
                    Container(
                      width: 400,
                      child: DropdownButton<Grupo>(
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.black,
                        ),
                        hint: Text(_grupoController.text),
                        value: _selectedGrupo,
                        items: _grupos.map((grupo) {
                          return DropdownMenuItem<Grupo>(
                            value: grupo,
                            child: Text(grupo.nome),
                          );
                        }).toList(),
                        onChanged: (Grupo? value) {
                          setState(() {
                            _selectedGrupo = value;
                          });
                        },
                      ),
                    ),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(labelText: 'Descrição'),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () async {
                              await _uploadImage();
                              if (_formKey.currentState!.validate()) {
                                setState(() {
                                  _isLoading = true;
                                });
                                // Atualiza o produto no banco de dados
                                Product updatedProduct = Product(
                                  id: widget.product.id,
                                  name: _nameController.text,
                                  price: _priceController.text,
                                  description: _descriptionController.text,
                                  imageUrl: _imageUrl!,
                                  quantity: int.parse(
                                    _quantityController.text,
                                  ),
                                  grupo: _selectedGrupo!.nome.toString(),
                                );

                                productService
                                    .updateProduct(updatedProduct)
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
                            child: const Text('Salvar'),
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _isLoading = true;
                              });
                              // Exclui o produto do banco de dados
                              productService
                                  .deleteProduct(widget.product.id)
                                  .then((_) {
                                setState(() {
                                  _isLoading = false;
                                });
                                // Chame o callback após excluir o produto
                                widget.onSave();
                                Navigator.of(context).pop();
                              });
                            },
                            child: const Text('Excluir'),
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

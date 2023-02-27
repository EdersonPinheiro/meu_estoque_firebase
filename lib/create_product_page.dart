import 'dart:io';
import 'dart:typed_data';
import 'package:estoque/constants/constants.dart';
import 'package:estoque/product.dart';
import 'package:estoque/services/product_service.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'grupo.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class CreateProductPage extends StatefulWidget {
  final Function onSave;

  const CreateProductPage({super.key, required this.onSave});
  @override
  _CreateProductPageState createState() => _CreateProductPageState();
}

class _CreateProductPageState extends State<CreateProductPage> {
  ProductService productService = ProductService();
  final _formKey = GlobalKey<FormState>();
  final _imageController = TextEditingController();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _quantityController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isLoading = false;
  List<Grupo> _grupos = [];
  Grupo? _selectedGrupo;
  String id = '';

  @override
  void initState() {
    super.initState();
    _getGrupos();
    _imageController.text =
        'https://dermogral.com.br/wp-content/uploads/2022/08/Sem-nome-600-%C3%97-600-px1.png';
    _nameController.text = '';
    _priceController.text = '';
    _descriptionController.text = '';
  }

  Future<void> _getGrupos() async {
    id = auth.currentUser!.uid.toString();
    _grupos = await productService.getAllGroups();
    setState(() {});
  }

  bool uploading = false;
  double total = 0;
  bool loading = false;

  File? _imageFile;
  String? _imageUrl;
  String? _selectedImage;

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source);
    setState(() {
      _imageFile = File(pickedFile!.path);
      _selectedImage = _imageFile!.path;
    });
  }

  late String downloadUrl;
  Future<void> _uploadImage() async {
    final storage = firebase_storage.FirebaseStorage.instance;
    final ref = storage.ref().child('images').child('image.jpg');
    final metadata = firebase_storage.SettableMetadata(
      contentType: 'image/jpeg',
      customMetadata: {'picked-file-path': _imageFile!.path},
    );
    final uploadTask = ref.putFile(_imageFile!, metadata);
    uploading = true;
    final snapshot = await uploadTask.whenComplete(() {
      uploading = false;
    });
    downloadUrl = await snapshot.ref.getDownloadURL();
    setState(() {
      _imageUrl = downloadUrl;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title:
              uploading ? Text('${total.round()}% enviado') : Text('Produto'),
          actions: [
            uploading
                ? Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: Center(
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  )
                : IconButton(
                    onPressed: () async {
                      await _pickImage(ImageSource.gallery);
                    },
                    icon: Icon(Icons.image))
          ]),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              _selectedImage != null
                  ? Container(
                      width: 120,
                      height: 120,
                      child: Image.file(File(_selectedImage!),
                          fit: BoxFit.fitHeight),
                    )
                  : Container(
                      child: Text("Nenhuma imagem selecionada"),
                    ),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nome',
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Insira o nome';
                  }
                  return null;
                },
              ),
              TextFormField(
                keyboardType: TextInputType.number,
                controller: _quantityController,
                decoration: const InputDecoration(
                  labelText: 'Quantidade',
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Insira a quantidade';
                  }
                  return null;
                },
              ),
              Container(
                width: 400,
                child: DropdownButton<Grupo>(
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.black,
                  ),
                  hint: Text('Grupo'),
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
                decoration: const InputDecoration(
                  labelText: 'Descrição',
                ),
              ),
              const SizedBox(height: 16),
              _isLoading
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: () {
                        _createProduct();
                      },
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
    await _uploadImage();
    var userId = auth.currentUser!.uid.toString();
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
    }

    try {
      Product createProduct = Product(
        name: _nameController.text,
        price: _priceController.text,
        description: _descriptionController.text,
        imageUrl: downloadUrl,
        id: '',
        quantity: int.parse(_quantityController.text),
        userId: userId.toString(),
        grupo: _selectedGrupo!.nome.toString(),
      );
      await productService.createProduct(createProduct).then((_) {
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

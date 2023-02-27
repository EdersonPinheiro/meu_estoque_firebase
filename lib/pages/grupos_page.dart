import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:get/get.dart';

import '../grupo.dart';
import '../services/product_service.dart';
import 'create_grupo_page.dart';
import 'edit_group_page.dart';

class GruposPage extends StatefulWidget {
  const GruposPage({super.key});

  @override
  State<GruposPage> createState() => _GruposPageState();
}

class _GruposPageState extends State<GruposPage> {
  ProductService productService = ProductService();
  List<Grupo>? groups;

  @override
  void initState() {
    super.initState();
    _getGroups();
  }

  _getGroups() async {
    List<Grupo> groupsData = await productService.getAllGroups();
    setState(() {
      groups = groupsData;
    });
  }

  void _updateGroupsList() {
    // Recarregue a lista de produtos aqui
    setState(() {
      groups = []; // Limpe a lista de produtos atual
      _getGroups(); // Carregue a lista de produtos novamente
    });
  }

  void ue() {
    // Recarregue a lista de produtos aqui
    setState(() {
      groups = []; // Limpe a lista de produtos atual
      _getGroups(); // Carregue a lista de produtos novamente
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Grupos'),
      ),
      body: ListView.builder(
        itemCount: groups?.length ?? 0,
        itemBuilder: (BuildContext context, int index) {
          Grupo grupo = groups![index];
          return ListTile(
            title: Text(grupo.nome),
            subtitle: Text(grupo.descricao),
            onTap: () {},
            trailing: IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () async {
                // Abre a página de edição de produtos quando o botão é pressionado
                Get.to(EditGroupPage(
                  onSave: _updateGroupsList,
                  grupo: grupo,
                ));
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.to(CreateGrupoPage(
            onSave: ue,
          ));
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

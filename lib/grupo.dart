class Grupo {
  String id;
  String userId;
  String nome;
  String descricao;

  Grupo(
      {required this.nome,
      required this.descricao,
      this.userId = '',
      this.id = ''});

  Map<String, dynamic> toMap() {
    Map<String, dynamic> data = {
      'id': id,
      'userId': userId,
      'nome': nome,
      'descricao': descricao,
    };
    return data;
  }

  static Grupo fromMap(Map<String, dynamic> date) {
    return Grupo(
      id: date['id'],
      userId: date['userId'],
      nome: date['nome'],
      descricao: date['descricao'],
    );
  }
}

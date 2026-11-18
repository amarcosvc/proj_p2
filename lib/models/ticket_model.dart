// Modelo de dados da entidade Ticket (Chamado)
class TicketModel {
  final String? id;
  final String userId;
  final String title;
  final String description;
  final String category;
  final String priority;
  final String status;

  TicketModel({
    this.id,
    required this.userId,
    required this.title,
    required this.description,
    this.category = 'Suporte Técnico',
    this.priority = 'Média',
    this.status = 'Aberto',
  });

  // Converte o objeto Dart para Map (envio ao Supabase)
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'user_id': userId,
      'title': title,
      'description': description,
      'category': category,
      'priority': priority,
      'status': status,
    };
  }

  // Constrói o objeto Dart a partir do JSON retornado pelo Supabase
  factory TicketModel.fromMap(Map<String, dynamic> map) {
    return TicketModel(
      id: map['id']?.toString(),
      userId: map['user_id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      category: map['category'] ?? 'Suporte Técnico',
      priority: map['priority'] ?? 'Média',
      status: map['status'] ?? 'Aberto',
    );
  }
}

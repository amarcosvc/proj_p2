import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/ticket_model.dart';

// Serviço responsável pelas operações CRUD na tabela 'tickets' do Supabase
class DatabaseService {
  static final _supabase = Supabase.instance.client;

  // CREATE: Abre um novo ticket
  static Future<void> createTicket(TicketModel ticket) async {
    await _supabase.from('tickets').insert(ticket.toMap());
  }

  // READ: Lista todos os tickets do usuário autenticado
  static Future<List<TicketModel>> getTicketsByUser(String userId) async {
    final response = await _supabase
        .from('tickets')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return (response as List)
        .map((item) => TicketModel.fromMap(item))
        .toList();
  }

  // UPDATE: Atualiza os dados, prioridade ou status de um ticket
  static Future<void> updateTicket(TicketModel ticket) async {
    await _supabase
        .from('tickets')
        .update(ticket.toMap())
        .eq('id', ticket.id!);
  }

  // DELETE: Exclui um ticket pelo ID
  static Future<void> deleteTicket(String id) async {
    await _supabase.from('tickets').delete().eq('id', id);
  }
}

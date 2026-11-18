import 'package:flutter/material.dart';
import '../models/ticket_model.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../widgets/ticket_form_dialog.dart';

// Painel principal protegido com listagem e ações do CRUD de Tickets
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<TicketModel> _tickets = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Proteção de rota: redireciona se não houver sessão ativa
    if (!AuthService.isAuthenticated) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, '/login');
      });
      return;
    }
    _loadTickets();
  }

  Future<void> _loadTickets() async {
    try {
      final userId = AuthService.currentUser!.id;
      final data = await DatabaseService.getTicketsByUser(userId);
      if (!mounted) return;
      setState(() {
        _tickets = data;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erro ao carregar tickets do servidor.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _openForm({TicketModel? ticket}) {
    showDialog(
      context: context,
      builder: (_) => TicketFormDialog(
        ticket: ticket,
        userId: AuthService.currentUser!.id,
        onSave: (savedTicket) async {
          if (ticket == null) {
            await DatabaseService.createTicket(savedTicket);
          } else {
            await DatabaseService.updateTicket(savedTicket);
          }
          await _loadTickets();
        },
      ),
    );
  }

  Future<void> _deleteTicket(String id) async {
    await DatabaseService.deleteTicket(id);
    await _loadTickets();
  }

  Future<void> _logout() async {
    await AuthService.logout();
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/login');
  }

  Color _priorityColor(String priority) {
    switch (priority) {
      case 'Urgente':
        return Colors.red;
      case 'Alta':
        return Colors.orange;
      case 'Média':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Resolvido':
        return Colors.green;
      case 'Em Andamento':
        return Colors.amber.shade800;
      default:
        return Colors.teal;
    }
  }

  @override
  Widget build(BuildContext context) {
    final userName = AuthService.currentUser?.userMetadata?['name'] ??
        AuthService.currentUser?.email ??
        'Usuário';

    return Scaffold(
      appBar: AppBar(
        title: Text('Chamados — $userName'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Atualizar lista',
            onPressed: _loadTickets,
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: TextButton.icon(
              onPressed: _logout,
              icon: const Icon(Icons.logout),
              label: const Text('Sair'),
            ),
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 850),
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _tickets.isEmpty
                  ? const Center(
                      child: Text(
                        'Nenhum chamado aberto.\nClique em "Novo Ticket" para registrar uma solicitação.',
                        textAlign: TextAlign.center,
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _tickets.length,
                      itemBuilder: (context, index) {
                        final ticket = _tickets[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        ticket.title,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium
                                            ?.copyWith(fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    Chip(
                                      label: Text(
                                        ticket.status,
                                        style: const TextStyle(color: Colors.white, fontSize: 12),
                                      ),
                                      backgroundColor: _statusColor(ticket.status),
                                      padding: EdgeInsets.zero,
                                    ),
                                    const SizedBox(width: 8),
                                    IconButton(
                                      icon: const Icon(Icons.edit, color: Colors.blue),
                                      tooltip: 'Editar ticket',
                                      onPressed: () => _openForm(ticket: ticket),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete, color: Colors.red),
                                      tooltip: 'Excluir ticket',
                                      onPressed: () => _deleteTicket(ticket.id!),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(ticket.description),
                                const SizedBox(height: 12),
                                Wrap(
                                  spacing: 8,
                                  children: [
                                    Chip(
                                      avatar: const Icon(Icons.category, size: 16),
                                      label: Text(ticket.category),
                                    ),
                                    Chip(
                                      label: Text(
                                        'Prioridade: ${ticket.priority}',
                                        style: TextStyle(
                                          color: _priorityColor(ticket.priority),
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(),
        icon: const Icon(Icons.add),
        label: const Text('Novo Ticket'),
      ),
    );
  }
}

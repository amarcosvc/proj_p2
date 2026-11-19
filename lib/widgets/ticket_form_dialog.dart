import 'package:material_ui/material_ui.dart';

import '../models/ticket_model.dart';

// Modal reutilizável para abertura e edição de tickets
class TicketFormDialog extends StatefulWidget {
  final TicketModel? ticket;
  final String userId;
  final Future<void> Function(TicketModel) onSave;

  const TicketFormDialog({
    super.key,
    this.ticket,
    required this.userId,
    required this.onSave,
  });

  @override
  State<TicketFormDialog> createState() => _TicketFormDialogState();
}

class _TicketFormDialogState extends State<TicketFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descController;
  late String _category;
  late String _priority;
  late String _status;
  bool _isSaving = false;

  final List<String> _categories = [
    'Suporte Técnico',
    'Infraestrutura / Rede',
    'Acesso / Senha',
    'Bug no Sistema',
    'Outros',
  ];

  final List<String> _priorities = ['Baixa', 'Média', 'Alta', 'Urgente'];
  final List<String> _statuses = ['Aberto', 'Em Andamento', 'Resolvido'];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.ticket?.title ?? '');
    _descController = TextEditingController(
      text: widget.ticket?.description ?? '',
    );
    _category = widget.ticket?.category ?? 'Suporte Técnico';
    _priority = widget.ticket?.priority ?? 'Média';
    _status = widget.ticket?.status ?? 'Aberto';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    final ticketData = TicketModel(
      id: widget.ticket?.id,
      userId: widget.userId,
      title: _titleController.text.trim(),
      description: _descController.text.trim(),
      category: _category,
      priority: _priority,
      status: _status,
    );

    await widget.onSave(ticketData);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.ticket != null;

    return AlertDialog(
      title: Text(isEditing ? 'Editar Ticket' : 'Abrir Novo Ticket'),
      content: SizedBox(
        width: 440,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Assunto / Título *',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Informe o assunto do ticket'
                      : null,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: _category,
                  decoration: const InputDecoration(
                    labelText: 'Categoria',
                    border: OutlineInputBorder(),
                  ),
                  items: _categories
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: (val) => setState(() => _category = val!),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: _priority,
                  decoration: const InputDecoration(
                    labelText: 'Prioridade',
                    border: OutlineInputBorder(),
                  ),
                  items: _priorities
                      .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                      .toList(),
                  onChanged: (val) => setState(() => _priority = val!),
                ),
                if (isEditing) ...[
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: _status,
                    decoration: const InputDecoration(
                      labelText: 'Situação',
                      border: OutlineInputBorder(),
                    ),
                    items: _statuses
                        .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                        .toList(),
                    onChanged: (val) => setState(() => _status = val!),
                  ),
                ],
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descController,
                  decoration: const InputDecoration(
                    labelText: 'Descrição do Problema *',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Descreva o problema'
                      : null,
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _isSaving ? null : _submit,
          child: _isSaving
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text('Salvar Ticket'),
        ),
      ],
    );
  }
}

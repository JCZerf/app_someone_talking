import 'package:flutter/material.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:provider/provider.dart';
import 'package:someone_talking/viewmodels/auth/ProfileViewModel.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final phoneMask = MaskTextInputFormatter(
      mask: '(##) #####-####',
      filter: {"#": RegExp(r'[0-9]')},
      type: MaskAutoCompletionType.lazy,
    );

    return ChangeNotifierProvider(
      create: (_) => ProfileViewModel()..fetchUserProfile(),
      child: Consumer<ProfileViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          if (viewModel.errorMessage != null) {
            return Scaffold(
              appBar: AppBar(
                title: const Text('Perfil'),
                backgroundColor: Colors.cyan,
              ),
              body: Center(
                child: Text(
                  viewModel.errorMessage!,
                  style: const TextStyle(color: Colors.red, fontSize: 18),
                ),
              ),
            );
          }
          return Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.cyan,
              elevation: 0,
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Meu Perfil',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
            ),
            body: SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    color: Colors.cyan,
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 32),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 48,
                          backgroundColor: Colors.white,
                          child: Text(
                            viewModel.nome.isNotEmpty ? viewModel.nome[0].toUpperCase() : '?',
                            style: const TextStyle(
                              fontSize: 40,
                              color: Colors.cyan,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          viewModel.nome,
                          style: const TextStyle(
                            fontSize: 22,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          viewModel.email,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      children: [
                        _buildProfileField(
                          label: 'Nome',
                          value: viewModel.nome,
                          onChanged: viewModel.setNome,
                        ),
                        const SizedBox(height: 16),
                        _buildProfileField(
                          label: 'Email',
                          value: viewModel.email,
                          onChanged: viewModel.setEmail,
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          decoration: InputDecoration(
                            labelText: 'Telefone',
                            prefixIcon: const Icon(Icons.phone),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          inputFormatters: [phoneMask],
                          keyboardType: TextInputType.phone,
                          controller:
                              TextEditingController(text: phoneMask.maskText(viewModel.telefone)),
                          onChanged: (value) {
                            viewModel.setTelefone(phoneMask.getUnmaskedText());
                          },
                        ),
                        const SizedBox(height: 16),
                        GestureDetector(
                          onTap: () async {
                            DateTime? picked = await showDatePicker(
                              context: context,
                              initialDate: viewModel.dataNascimento ?? DateTime(2000, 1, 1),
                              firstDate: DateTime(1900),
                              lastDate: DateTime.now(),
                            );
                            if (picked != null) {
                              viewModel.setDataNascimento(picked);
                            }
                          },
                          child: AbsorbPointer(
                            child: TextField(
                              decoration: InputDecoration(
                                labelText: 'Data de Nascimento',
                                prefixIcon: const Icon(Icons.cake),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              controller: TextEditingController(
                                text: viewModel.dataNascimento != null
                                    ? '${viewModel.dataNascimento!.day.toString().padLeft(2, '0')}/${viewModel.dataNascimento!.month.toString().padLeft(2, '0')}/${viewModel.dataNascimento!.year}'
                                    : '',
                              ),
                              readOnly: true,
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.cyan,
                            foregroundColor: Colors.white,
                            minimumSize: const Size(double.infinity, 48),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          icon: const Icon(Icons.save),
                          label: viewModel.isLoading
                              ? const CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                )
                              : const Text(
                                  'Salvar',
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                          onPressed: viewModel.isLoading
                              ? null
                              : () async {
                                  bool success = await viewModel.updateProfile();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(success
                                          ? 'Perfil atualizado com sucesso!'
                                          : viewModel.errorMessage ?? 'Erro ao atualizar perfil'),
                                      backgroundColor: success ? Colors.cyan : Colors.red,
                                    ),
                                  );
                                },
                        ),
                        const SizedBox(height: 24),
                        OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.cyan,
                            minimumSize: const Size(double.infinity, 48),
                            side: const BorderSide(color: Colors.cyan, width: 2),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          icon: const Icon(Icons.logout),
                          label: const Text(
                            'Sair',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          onPressed: () async {
                            await Provider.of<ProfileViewModel>(context, listen: false)
                                .logout(context);
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileField({
    required String label,
    required String value,
    required Function(String) onChanged,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: _getIcon(label),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      controller: TextEditingController(text: value),
      onChanged: onChanged,
      keyboardType: keyboardType,
    );
  }

  Icon _getIcon(String label) {
    switch (label) {
      case 'Nome':
        return const Icon(Icons.person);
      case 'Email':
        return const Icon(Icons.email);
      case 'Telefone':
        return const Icon(Icons.phone);
      default:
        return const Icon(Icons.info);
    }
  }
}

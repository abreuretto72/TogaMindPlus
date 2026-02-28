import 'package:flutter/material.dart';
import 'package:toga_mind_plus/core/services/toga_auth_service.dart';
import 'package:toga_mind_plus/core/toga_colors.dart';

class TogaRegisterView extends StatefulWidget {
  const TogaRegisterView({super.key});

  @override
  State<TogaRegisterView> createState() => _TogaRegisterViewState();
}

class _TogaRegisterViewState extends State<TogaRegisterView> {
  final TextEditingController _userController = TextEditingController();
  final TextEditingController _passController = TextEditingController();
  final TextEditingController _passConfirmController = TextEditingController();
  bool _isLoading = false;

  void _handleRegister() async {
    final user = _userController.text.trim();
    final pass = _passController.text.trim();
    final passConfirm = _passConfirmController.text.trim();

    if (user.isEmpty || pass.isEmpty || passConfirm.isEmpty) return;

    if (pass != passConfirm) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("As senhas não coincidem. Tente novamente."),
          backgroundColor: Color(0xFFFC2D7C),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    
    final Map<String, dynamic> result = await TogaAuthService.registerLocal(user, pass);
    
    if (result['success'] == true) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? "Gabinete local criado com sucesso! Faça login."),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context); // Volta para a tela de login
      }
    } else {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? "Falha ao registrar."),
            backgroundColor: const Color(0xFFFC2D7C),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Criar Novo Gabinete"),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: TogaColors.azulPetroleo,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.security, size: 64, color: TogaColors.azulPetroleo),
                const SizedBox(height: 24),
                const Text(
                  "Novo Gabinete",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: TogaColors.azulPetroleo,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Sua IA exclusiva e personalizada.",
                  style: TextStyle(fontSize: 16, color: Colors.black54),
                ),
                const SizedBox(height: 48),
                TextField(
                  controller: _userController,
                  decoration: const InputDecoration(
                    labelText: "Novo Judge ID (Ex: juiz_marcos)",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person_add),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _passController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: "Criar Senha Segura",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock_outline),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _passConfirmController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: "Confirmar Senha Segura",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock),
                  ),
                  onSubmitted: (_) => _handleRegister(),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: TogaColors.azulPetroleo,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: _isLoading ? null : _handleRegister,
                    child: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : const Text("Criar Gabinete", style: TextStyle(fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

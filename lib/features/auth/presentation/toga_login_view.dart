import 'package:flutter/material.dart';
import 'package:toga_mind_plus/core/services/toga_auth_service.dart';
import 'package:toga_mind_plus/core/toga_colors.dart';
import 'package:toga_mind_plus/l10n/app_localizations.dart';

class TogaLoginView extends StatefulWidget {
  const TogaLoginView({super.key});

  @override
  State<TogaLoginView> createState() => _TogaLoginViewState();
}

class _TogaLoginViewState extends State<TogaLoginView> {
  final TextEditingController _userController = TextEditingController();
  final TextEditingController _passController = TextEditingController();
  bool _isLoading = false;

  void _handleLogin() async {
    final user = _userController.text.trim();
    final pass = _passController.text.trim();

    if (user.isEmpty || pass.isEmpty) return;

    setState(() => _isLoading = true);
    
    // Autenticação Real Local através do Backend Python
    final Map<String, dynamic> result = await TogaAuthService.loginLocal(user, pass);
    
    if (result['success'] == true) {
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } else {
      if (mounted) {
        setState(() => _isLoading = false);
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? l10n?.error_access_denied ?? "Credenciais Inválidas"),
            backgroundColor: const Color(0xFFFC2D7C), // Magenta de Erro
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Branco Absoluto
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.account_balance, size: 80, color: TogaColors.azulPetroleo),
                const SizedBox(height: 24),
                const Text(
                  "TogaMind+ Gabinete",
                  style: TextStyle(
                    fontSize: 28,
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
                    labelText: "Identificação do Magistrado (Judge ID)",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _passController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: "Senha de Acesso",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock),
                  ),
                  onSubmitted: (_) => _handleLogin(),
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
                    onPressed: _isLoading ? null : _handleLogin,
                    child: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : const Text("Entrar no Gabinete", style: TextStyle(fontSize: 16)),
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => Navigator.pushNamed(context, '/register'),
                  child: const Text(
                    'Primeiro acesso? Cadastre-se no Gabinete',
                    style: TextStyle(color: TogaColors.azulPetroleo),
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

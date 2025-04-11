import 'package:bluesky_video_feed/core/services/service_locator.dart';
import 'package:bluesky_video_feed/features/feed/feed_controller.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController(text: 'luizzlcs@gmail.com');
  final _passwordController = TextEditingController(text: '88180706');
  bool _obscurePassword = true;

  // Obtém o controller via GetIt
  final _controller = getIt<FeedController>();

  @override
  void initState() {
    super.initState();
    // Adiciona um listener ao controller para reconstruir a UI quando o estado mudar
    _controller.addListener(_updateUI);
  }

  void _updateUI() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _controller.removeListener(_updateUI);
    super.dispose();
  }

  void _login() {
    if (_formKey.currentState?.validate() ?? false) {
      _controller.login(_emailController.text.trim(), _passwordController.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = _controller.state == FeedState.loading;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo ou título
                  const Icon(Icons.video_library, size: 70, color: Colors.blue),
                  const SizedBox(height: 20),
                  const Text(
                    'Bluesky Video Feed',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 40),

                  // Campo de email
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email do Bluesky',
                      prefixIcon: Icon(Icons.email),
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, insira seu email';
                      }
                      return null;
                    },
                    enabled: !isLoading,
                  ),
                  const SizedBox(height: 20),

                  // Campo de senha
                  TextFormField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      labelText: 'App Password',
                      prefixIcon: const Icon(Icons.lock),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                      border: const OutlineInputBorder(),
                    ),
                    obscureText: _obscurePassword,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, insira sua senha';
                      }
                      return null;
                    },
                    enabled: !isLoading,
                  ),
                  const SizedBox(height: 30),

                  // Botão de login
                  ElevatedButton(
                    onPressed: isLoading ? null : _login,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                    child:
                        isLoading
                            ? const CircularProgressIndicator()
                            : const Text(
                              'Entrar',
                              style: TextStyle(fontSize: 16),
                            ),
                  ),

                  // Mensagem de erro
                  if (_controller.state == FeedState.error)
                    Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: Text(
                        _controller.errorMessage,
                        style: const TextStyle(color: Colors.red, fontSize: 14),
                        textAlign: TextAlign.center,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

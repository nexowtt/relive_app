import 'package:flutter/material.dart';
import 'home_screen.dart';

class SignupScreen extends StatelessWidget {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Кнопка назад
              IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.arrow_back_ios, color: Colors.black54),
              ),
              
              const SizedBox(height: 40),
              
              // Заголовок
              const Text(
                'Sign up',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              
              const SizedBox(height: 8),
              
              const Text(
                'Create your account to get started!',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                ),
              ),
              
              const SizedBox(height: 40),
              
              // Поля ввода для регистрации
              _buildInputField('Full Name', Icons.person_outline),
              const SizedBox(height: 20),
              _buildInputField('Email', Icons.email_outlined),
              const SizedBox(height: 20),
              _buildInputField('Password', Icons.lock_outline, isPassword: true),
              const SizedBox(height: 20),
              _buildInputField('Confirm Password', Icons.lock_outline, isPassword: true),
              
              const SizedBox(height: 20),
              
              // Checkbox согласия с условиями
              Row(
                children: [
                  Checkbox(
                    value: true,
                    onChanged: (value) {},
                    activeColor: const Color(0xFF9D84FF),
                  ),
                  const Expanded(
                    child: Text(
                      'I agree to the Terms of Service and Privacy Policy',
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 20),
              
              // Кнопка регистрации
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    // Переход на главный экран
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const HomeScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF9D84FF),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 2,
                  ),
                  child: const Text(
                    'Create Account',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              
              const Spacer(),
              
              // Уже есть аккаунт?
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Already have an account? ',
                      style: TextStyle(
                        color: Colors.black54,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: const Text(
                        'Log in',
                        style: TextStyle(
                          color: Color(0xFF9D84FF),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField(String label, IconData icon, {bool isPassword = false}) {
    return TextField(
      obscureText: isPassword,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.black54),
        prefixIcon: Icon(icon, color: Colors.grey),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Color(0xFF9D84FF)),
        ),
        filled: true,
        fillColor: Colors.grey[50],
      ),
    );
  }
}
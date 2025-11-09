import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/login_controller.dart';

final controller = Get.put(LoginController());

class LoginView extends GetView<LoginController> {
  const LoginView({super.key});
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/login-2.png'),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  Colors.black.withOpacity(0.5),
                  BlendMode.darken,
                ),
              ),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 450),
                child: Container(
                  clipBehavior: Clip.antiAlias,
                  padding: const EdgeInsets.all(30),
                  decoration: BoxDecoration(
                    color: Color(0xFF121212).withOpacity(0.9),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor:
                            theme.colorScheme.primary.withOpacity(0.1),
                        child: Image.asset("assets/images/logo-mahardika.png"),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Selamat Datang di Absensi Smahardhika',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Silahkan masuk ke akun Anda!',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(height: 32),
                      Obx(
                        () => TextField(
                          focusNode: controller.emailF,
                          controller: controller.emailC,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            labelText: 'NISN',
                            errorText: controller.emailError.isEmpty
                                ? null
                                : controller.emailError.value,
                            labelStyle: const TextStyle(color: Colors.white70),
                            prefixIcon: const Icon(Icons.email_outlined,
                                color: Colors.white70),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide:
                                  const BorderSide(color: Colors.white24),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Colors.red),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide:
                                  const BorderSide(color: Colors.white70),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Colors.red),
                            ),
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.05),
                          ),
                          onSubmitted: (value) {
                            if (controller.emailC.text.isNotEmpty &&
                                controller.passwordC.text.isNotEmpty) {
                              controller.login();
                            }
                          },
                          keyboardType: TextInputType.visiblePassword,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Obx(
                        () => TextField(
                          controller: controller.passwordC,
                          focusNode: controller.passwordF,
                          obscureText: !controller.showPassword.value,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            errorText: controller.passwordError.isEmpty
                                ? null
                                : controller.passwordError.value,
                            labelText: 'Password',
                            labelStyle: const TextStyle(color: Colors.white70),
                            prefixIcon: const Icon(Icons.lock_outline,
                                color: Colors.white70),
                            suffixIcon: IconButton(
                              icon: Icon(
                                controller.showPassword.value
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: Colors.white70,
                              ),
                              onPressed: controller.togglePasswordVisibility,
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Colors.red),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide:
                                  const BorderSide(color: Colors.white24),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Colors.red),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide:
                                  const BorderSide(color: Colors.white70),
                            ),
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.05),
                          ),
                          onSubmitted: (value) {
                            if (controller.emailC.text.isNotEmpty &&
                                controller.passwordC.text.isNotEmpty) {
                              controller.login();
                            }
                          },
                        ),
                      ),
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: controller.forgotPassword,
                          child: const Text(
                            'Lupa Password?',
                            style: TextStyle(
                              color: Colors.white70,
                              decoration: TextDecoration.underline,
                              decorationColor: Colors.white70,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Obx(
                        () => (controller.allError.isEmpty)
                            ? SizedBox.shrink()
                            : Text(
                                controller.allError.value,
                                style: TextStyle(color: Colors.red),
                              ),
                      ),
                      const SizedBox(height: 12),
                      Obx(
                        () => SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            icon: controller.isLoading.value
                                ? SizedBox.shrink()
                                : const Icon(Icons.login, color: Colors.white),
                            label: controller.isLoading.value
                                ? SizedBox(
                                    height: 24,
                                    width: 24,
                                    child: CircularProgressIndicator(),
                                  )
                                : Text(
                                    'Login',
                                    style: TextStyle(color: Colors.white),
                                  ),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: controller.isLoading.value
                                ? null
                                : controller.login,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

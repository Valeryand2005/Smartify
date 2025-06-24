import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:smartify/pages/authorization/authorization_page.dart';
import 'package:smartify/pages/api_server/api_server.dart';

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({super.key});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final emailController = TextEditingController();
  final codeController = TextEditingController();
  final passwordController = TextEditingController();
  bool isPasswordVisible = false;

  bool get hasMinLength => passwordController.text.length >= 8;
  bool get hasNumber => RegExp(r'[0-9]').hasMatch(passwordController.text);
  bool get hasSymbol => RegExp(r'[!@#\$%^&*(),.?":{}|<>]').hasMatch(passwordController.text);

  double get passwordStrength {
    int metCriteria = [hasMinLength, hasNumber, hasSymbol].where((c) => c).length;
    return metCriteria / 3;
  }

  Color get strengthColor {
    if (passwordStrength < 0.34) return const Color.fromRGBO(214, 44, 1, 1);
    if (passwordStrength < 0.67) return const Color.fromRGBO(250, 174, 22, 1);
    return const Color.fromRGBO(73, 130, 0, 1);
  }

  int currentStep = 0;
  
  void _nextStep() {
    setState(() {
      currentStep++;
    });
  }

  void _resetFlow() {
    setState(() {
      currentStep = 0;
      emailController.clear();
      codeController.clear();
      passwordController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget content;

    switch (currentStep) {
      case 0:
        content = _buildEmailStep();
        break;
      case 1:
        content = _buildCodeStep();
        break;
      case 2:
        content = _buildPasswordStep();
        break;
      case 3:
        content = _buildSuccessStep();
        break;
      default:
        content = const SizedBox();
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: currentStep != 3,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Сбросить пароль',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
        child: Column(
          children: [
            Expanded(child: content),
            _buildFooterDisclaimer(),
          ],
        ),
      ),
    );
  }

    Widget _buildProgressIndicator(int activeStep) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: 24,
          height: 4,
          decoration: BoxDecoration(
            color: index <= activeStep ? Colors.tealAccent[100] : Colors.grey[300],
            borderRadius: BorderRadius.circular(2),
          ),
        );
      }),
    );
  }

  Widget _buildEmailStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        Center(
          child: Column(
            children: [
              const Text(
                "Введите вашу почту 1 / 3",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              _buildProgressIndicator(0),
            ],
          ),
        ),
        const SizedBox(height: 40),
        const Text("Почта", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        TextField(
          controller: emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            hintText: "example@example",
            hintStyle: const TextStyle(color: Colors.grey),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.grey),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () async {
              final success = await ApiService.forgot_password(
                emailController.text
              );
              if (success) {
                _nextStep();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Ошибка с почтой!")),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF54D0C0),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text("Отправить", style: TextStyle(color: Colors.white)),
          ),
        ),
      ],
    );
  }

  Widget _buildCodeStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Center(
          child: Image.asset('email.png', height: 140, width: 200, fit: BoxFit.contain),
        ),
        const SizedBox(height: 16),
        const SizedBox(height: 10),
        const Text(
          "Подтвердите вашу почту 2 / 3",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildStepIndicator(active: true),
            const SizedBox(width: 4),
            _buildStepIndicator(active: true),
            const SizedBox(width: 4),
            _buildStepIndicator(active: false),
          ],
        ),
        const SizedBox(height: 30),
        Text(
          "Мы отправили пятизначный код на\n${emailController.text}, введите его ниже:",
          style: const TextStyle(fontSize: 15),
          textAlign: TextAlign.center,
        ),
        
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 350),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, // aligns everything to the left
              children: [
                const Text(
                  "Код",
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8), // spacing between label and pin field
                PinCodeTextField(
                  length: 5,
                  obscureText: false,
                  animationType: AnimationType.fade,
                  keyboardType: TextInputType.number,
                  pinTheme: PinTheme(
                    shape: PinCodeFieldShape.box,
                    borderRadius: BorderRadius.circular(10),
                    fieldHeight: 48,
                    fieldWidth: 65.4,
                    activeColor: Colors.grey.shade300,
                    selectedColor: Colors.teal,
                    inactiveColor: Colors.grey.shade300,
                  ),
                  animationDuration: const Duration(milliseconds: 300),
                  enableActiveFill: false,
                  controller: codeController,
                  onChanged: (value) {},
                  appContext: context,
                ),
              ],
            ),
          ),
        ),


        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF54D0C0),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () async {
              final success = await ApiService.resetPassword_codeValidation(
                emailController.text,
                codeController.text,
              );
              if (success) {
                _nextStep();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Неверный код или ошибка подключения")),
                );
              }
            },
            child: const Text("Подтвердить почту", style: TextStyle(color: Colors.white)),
          ),
        ),
        const SizedBox(height: 20),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ResetPasswordPage(),
              ),
            );
          },
          child: const Text.rich(
            TextSpan(
              text: "Указали не ту почту? ",
              children: [
                TextSpan(
                  text: "Отправить на другой адрес",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }


  Widget _buildStepIndicator({required bool active}) {
    return Container(
      width: 20,
      height: 4,
      decoration: BoxDecoration(
        color: active ? const Color(0xFFADE2DF) : const Color(0xFFE5E7EB),
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }

  Widget _buildPasswordStep() {
   return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SizedBox(height: 10),
      Center(
        child: Column(
          children: [
            const Text(
              "Придумайте новый пароль 3 / 3",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildProgressIndicator(2),
          ],
        ),
      ),
      const SizedBox(height: 30),
      const Text("Пароль", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
      const SizedBox(height: 8),
      TextField(
        controller: passwordController,
        obscureText: !isPasswordVisible,
        onChanged: (_) => setState(() {}),
        decoration: InputDecoration(
          suffixIcon: IconButton(
            icon: Icon(isPasswordVisible ? Icons.visibility_outlined : Icons.visibility_off_outlined),
            onPressed: () => setState(() => isPasswordVisible = !isPasswordVisible),
          ),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        ),
      ),
      const SizedBox(height: 10),
      ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: LinearProgressIndicator(
          value: passwordStrength,
          backgroundColor: Colors.grey[300],
          valueColor: AlwaysStoppedAnimation<Color>(strengthColor),
          minHeight: 8,
        ),
      ),
      const SizedBox(height: 16),
      _buildCriteria("Минимум 8 символов", hasMinLength),
      _buildCriteria("Хотя бы одна цифра (0-9)", hasNumber),
      _buildCriteria("Хотя бы один специальный символ (например: ! @ # % ^ & * ( ) - _ + = )", hasSymbol),
      const Spacer(),
      SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: passwordStrength == 1.0
          ? () async {
              final success = await ApiService.resetPassword_resetPassword(emailController.text, passwordController.text);
              if (success) {
                _nextStep();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Ошибка регистрации")),
                );
              }
            }
          : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: passwordStrength == 1.0 ? const Color(0xFF54D0C0) : const Color(0xFFB2DFDB),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            disabledBackgroundColor: const Color(0xFFB2DFDB),
          ),
          child: const Text("Продолжить"),
        ),
      ),
    ],
  );
  }

    Widget _buildCriteria(String label, bool met) {
    return Row(
      children: [
        Icon(met ? Icons.check_circle_rounded : Icons.radio_button_unchecked, color: met ? const Color.fromRGBO(73, 130, 0, 1) : Colors.grey),
        const SizedBox(width: 8),
        Text(label, style: TextStyle(fontWeight: FontWeight.w500, color: met ? Colors.black : Colors.grey)),
      ],
    );
  }

  Widget _buildSuccessStep() {
return Column(
    children: [
      Expanded(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check, size: 40, color: Color.fromRGBO(21, 203, 189, 1)),
            const SizedBox(height: 24),
            const Text(
              "Ваш пароль был успешно обновлён!",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text(
              "Исследуйте мир образования одним кликом.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AuthorizationPage(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF54D0C0),
                padding: const EdgeInsets.symmetric(vertical: 16),
                minimumSize: const Size.fromHeight(48),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text("Войти", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    ],
  );
  }

  ButtonStyle _buttonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFF54D0C0),
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  Widget _buildFooterDisclaimer() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text.rich(
        TextSpan(
          text: 'Используя Smartify, вы соглашаетесь с\n',
          style: const TextStyle(fontSize: 12),
          children: [
            TextSpan(
              text: 'Условиями пользования и Политикой конфиденциальности.',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

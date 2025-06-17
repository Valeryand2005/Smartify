import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:smartify/pages/authorization/authorization_page.dart';
import 'package:smartify/pages/welcome/welcome_page.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  int currentStep = 0;
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
    if (passwordStrength < 0.34) return Colors.red;
    if (passwordStrength < 0.67) return Colors.orange;
    return Colors.green;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: [
            _buildEmailStep(),
            _buildVerifyStep(),
            _buildPasswordStep(),
            _buildSuccessStep(),
          ][currentStep],
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
        const SizedBox(height: 20),
        IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const WelcomePage(),
              ),
            );
          },
        ),
        const SizedBox(height: 10),
        Center(
          child: Column(
            children: [
              const Text(
                "Add your email 1 / 3",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              _buildProgressIndicator(0),
            ],
          ),
        ),
        const SizedBox(height: 40),
        const Text("Email", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
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
            onPressed: () => setState(() => currentStep = 1),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF54D0C0),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text("Create an account", style: TextStyle(color: Colors.white)),
          ),
        ),
      ],
    );
  }

  Widget _buildVerifyStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 20),
        const Align(
          alignment: Alignment.centerLeft,
          child: Icon(Icons.arrow_back, size: 24),
        ),
        const SizedBox(height: 10),
        const Text(
          "Verify your email 2 / 3",
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
          "We just sent 5-digit code to\n${emailController.text}, enter it below:",
          style: const TextStyle(fontSize: 15),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 30),
        const Align(
          alignment: Alignment.centerLeft,
          child: Text("Code", style: TextStyle(fontWeight: FontWeight.w500)),
        ),
        const SizedBox(height: 10),
        PinCodeTextField(
          length: 5,
          obscureText: false,
          animationType: AnimationType.fade,
          keyboardType: TextInputType.number,
          pinTheme: PinTheme(
            shape: PinCodeFieldShape.box,
            borderRadius: BorderRadius.circular(10),
            fieldHeight: 50,
            fieldWidth: 50,
            activeColor: Colors.teal,
            selectedColor: Colors.teal,
            inactiveColor: Colors.grey.shade300,
          ),
          animationDuration: const Duration(milliseconds: 300),
          enableActiveFill: false,
          controller: codeController,
          onChanged: (value) {},
          appContext: context,
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
            onPressed: () {
              setState(() => currentStep = 2);
            },
            child: const Text("Verify email", style: TextStyle(color: Colors.white)),
          ),
        ),
        const SizedBox(height: 20),
        GestureDetector(
          onTap: () {
            setState(() => currentStep = 0);
          },
          child: const Text.rich(
            TextSpan(
              text: "Wrong email? ",
              children: [
                TextSpan(
                  text: "Send to different email",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
        const Spacer(),
        _termsText(),
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
      const SizedBox(height: 20),
      Align(
        alignment: Alignment.centerLeft,
        child: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => setState(() => currentStep = 1),
        ),
      ),
      const SizedBox(height: 10),
      Center(
        child: Column(
          children: [
            const Text(
              "Create your password 3 / 3",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildProgressIndicator(2),
          ],
        ),
      ),
      const SizedBox(height: 30),
      const Text("Password", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
      const SizedBox(height: 8),
      TextField(
        controller: passwordController,
        obscureText: !isPasswordVisible,
        onChanged: (_) => setState(() {}),
        decoration: InputDecoration(
          suffixIcon: IconButton(
            icon: Icon(isPasswordVisible ? Icons.visibility : Icons.visibility_off),
            onPressed: () => setState(() => isPasswordVisible = !isPasswordVisible),
          ),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        ),
      ),
      const SizedBox(height: 10),
      LinearProgressIndicator(
        value: passwordStrength,
        backgroundColor: Colors.grey[300],
        valueColor: AlwaysStoppedAnimation<Color>(strengthColor),
        minHeight: 6,
      ),
      const SizedBox(height: 16),
      _buildCriteria("8 characters minimum", hasMinLength),
      _buildCriteria("a number", hasNumber),
      _buildCriteria("a symbol", hasSymbol),
      const Spacer(),
      SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: passwordStrength == 1.0 ? () => setState(() => currentStep = 3) : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: passwordStrength == 1.0 ? const Color(0xFF54D0C0) : const Color(0xFFB2DFDB),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            disabledBackgroundColor: const Color(0xFFB2DFDB),
          ),
          child: const Text("Continue"),
        ),
      ),
      const SizedBox(height: 20),
      _termsText(),
    ],
  );
}

  Widget _buildCriteria(String label, bool met) {
    return Row(
      children: [
        Icon(met ? Icons.check_circle : Icons.radio_button_unchecked, color: met ? Colors.green : Colors.grey),
        const SizedBox(width: 8),
        Text(label, style: TextStyle(fontWeight: FontWeight.w500, color: met ? Colors.black : Colors.grey)),
      ],
    );
  }

  Widget _buildSuccessStep() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.check_circle, size: 64, color: Colors.teal),
        const SizedBox(height: 24),
        const Text(
          "Your account was successfully created!",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        const Text(
          "Only one click to explore education.",
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
          child: const Text("Log in", style: TextStyle(color: Colors.white)),
        ),
        const SizedBox(height: 20),
        _termsText(),
      ],
    );
  }

  Widget _termsText() {
    return const Text.rich(
      TextSpan(
        text: "By using Smartify, you agree to the ",
        children: [
          TextSpan(
              text: "Terms and Privacy Policy.",
              style: TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
      textAlign: TextAlign.center,
      style: TextStyle(fontSize: 12),
    );
  }
}

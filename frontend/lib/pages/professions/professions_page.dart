import 'package:flutter/material.dart';
import 'package:smartify/pages/tests/prof_test_page.dart';

class ProfessionsPage extends StatelessWidget {
  const ProfessionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    const highlightColor = Color(0xFF54D0C0);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Image.asset('logo.png', height: 50),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: highlightColor,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        const QuestionnairePage(),
                  ),
                );
              },
              child: const Text(
                'Пройти анкетирование',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

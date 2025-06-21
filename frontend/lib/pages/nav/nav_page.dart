import 'package:flutter/material.dart';
import 'package:smartify/pages/universities/main_university_page.dart';

void main() {
  runApp(const SmartifyApp());
}

class SmartifyApp extends StatelessWidget {
  const SmartifyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: DashboardPage(),
    );
  }
}

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
        automaticallyImplyLeading: true,
        backgroundColor: Colors.white,
        elevation: 0,
        title: Center(
          child: Image.asset(
            'logo.png',
            height: 50,
          ),
        ),
      ),

      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF54D0C0),
        unselectedItemColor: Colors.grey,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        currentIndex: 0,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_rounded),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book_rounded),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: '',
          ),
        ],
      ),
body: SafeArea(
  child: LayoutBuilder(
    builder: (context, constraints) {
      return SingleChildScrollView(
        physics: const ClampingScrollPhysics(), // отключает "подпрыгивание"
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Добро пожаловать!',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Выберите тему',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: _TopicCard(
                        title: 'Университеты',
                        subtitle: 'Более ста разных университетов',
                        assetImage: 'university.png',
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const UniversityPage(),
                            ),
                          );
                        },
                        isDarkButton: false,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _TopicCard(
                        title: 'Карьерные\nПредложения',
                        subtitle: 'Выбери то, что подходит тебе',
                        assetImage: 'career.png',
                        onPressed: () {},
                        isDarkButton: true,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _WideButton(
                  title: 'Подготовка к ЕГЭ',
                  subtitle: 'Более ста заданий · 10–60 мин.',
                  onPressed: () {},
                ),
                const SizedBox(height: 12),
                _WideButton(
                  title: 'Репетиторы',
                  subtitle: 'Более ста репетиторов',
                  onPressed: () {},
                ),
                const SizedBox(height: 20), // чтобы не было прилипания к нижнему nav
              ],
            ),
          ),
        ),
      );
    },
  ),
),

    );
  }
}

class _TopicCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String assetImage;
  final VoidCallback onPressed;
  final bool isDarkButton;

  const _TopicCard({
    required this.title,
    required this.subtitle,
    required this.assetImage,
    required this.onPressed,
    this.isDarkButton = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 230,
      decoration: BoxDecoration(
        color: const Color(0xFF54D0C0),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.topRight,
            child: Image.asset(
              assetImage,
              width: 100,
              height: 80,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.white70,
            ),
          ),
          const Spacer(),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    isDarkButton ? const Color(0xFF0E736B) : Colors.white,
                foregroundColor:
                    isDarkButton ? Colors.white : const Color(0xFF1C7D75),
                minimumSize: const Size(80, 36),
                padding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              onPressed: onPressed,
              child: const Text('Перейти'),
            ),
          ),
        ],
      ),
    );
  }
}

class _WideButton extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onPressed;

  const _WideButton({
    required this.title,
    required this.subtitle,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0E736B),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.play_circle_filled_rounded,
                color: Colors.white, size: 30),
            onPressed: onPressed,
          )
        ],
      ),
    );
  }
}

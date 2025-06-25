import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:smartify/pages/universities/filter.dart';
import 'package:smartify/pages/universities/filter_page.dart';
import 'package:smartify/pages/universities/uniDetPAge.dart';
import 'package:smartify/pages/universities/universityCard.dart';

class UniversityPage extends StatefulWidget {
  const UniversityPage({super.key});

  @override
  State<UniversityPage> createState() => _UniversityPageState();
}

class _UniversityPageState extends State<UniversityPage> {
  List universities = [];
  List filteredUniversities = [];
  UniversityFilter activeFilter = UniversityFilter(); // хранение активных фильтров

  @override
  void initState() {
    super.initState();
    loadUniversityData();
  }

  Future<void> loadUniversityData() async {
    final String jsonString = await rootBundle.loadString('assets/universities.json');
    final List data = json.decode(jsonString);
    setState(() {
      universities = data;
      filteredUniversities = data;
    });
  }

  void filterSearch(String query) {
    final filtered = universities.where((uni) {
      final name = uni['название'].toString().toLowerCase();
      return name.contains(query.toLowerCase());
    }).toList();

    setState(() {
      filteredUniversities = filtered;
    });
  }

  void applyFilters(UniversityFilter filter) {
    final filtered = universities.where((uni) {
      // РЕГИОН
      if (filter.regions.isNotEmpty && !filter.regions.contains(uni['город'])) {
        return false;
      }

      // РЕЙТИНГ
      double rating = double.tryParse(uni['рейтинг'].toString()) ?? 0.0;
      if (rating < filter.minRating) {
        return false;
      }

      // ОБЩЕЖИТИЕ
      if (filter.hasDorm && uni['общежитие'] != 'Да') {
        return false;
      }

      // ВОЕННЫЙ УЧ. ЦЕНТР
      if (filter.hasMilitary && uni['воен. уч. центр'] != 'Да') {
        return false;
      }

      return true;
    }).toList();

    setState(() {
      activeFilter = filter;
      filteredUniversities = filtered;
    });
  }

  Future<void> openFilterPage() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => UniversityFilterPage(currentFilter: activeFilter),
      ),
    );

    if (result is UniversityFilter) {
      applyFilters(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black,), 
          onPressed: () {
            Navigator.pop(context);
          },),
        centerTitle: true,
        title: const Text('Университеты', style: TextStyle(color: Colors.black)),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: CircleAvatar(
              backgroundColor: Colors.blue[100],
              child: const Icon(Icons.pets, color: Colors.white),
            ),
          )
        ],
      ),
      body: universities.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Search and Filter
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          onChanged: filterSearch,
                          decoration: InputDecoration(
                            hintText: 'Поиск...',
                            prefixIcon: const Icon(Icons.search),
                            contentPadding: const EdgeInsets.symmetric(vertical: 12),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(32),
                              borderSide: const BorderSide(color: Colors.teal),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(32),
                              borderSide: const BorderSide(color: Colors.teal),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      CircleAvatar(
                        backgroundColor: Colors.teal[300],
                        child: IconButton(
                          icon: const Icon(Icons.tune, color: Colors.white, size: 20),
                          onPressed: openFilterPage,
                        ),
                      ),
                    ],
                  ),
                ),
                // GridView
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final itemWidth = (constraints.maxWidth - 48) / 2;
                      final itemHeight = itemWidth;

                      return GridView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: filteredUniversities.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: itemWidth / itemHeight,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                        itemBuilder: (context, index) {
                          final uni = filteredUniversities[index];
                          return UniversityCard(
                            image: uni['фото'],
                            title: uni['название'],
                            rating: double.tryParse(uni['рейтинг'].toString()) ?? 4.0,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => UniversityDetailPage(university: uni),
                                ),
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}

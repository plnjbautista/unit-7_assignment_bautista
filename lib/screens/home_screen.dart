// importing libraries/packages
import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_expanded_tile/flutter_expanded_tile.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<Map<String, dynamic>> future;

  @override
  void initState() {
    super.initState();
    future = getDisneyData();
  }

  // Function to get data from the Disney API
  Future<Map<String, dynamic>> getDisneyData() async {
    String url = 'https://api.disneyapi.dev/character';
    Response response = await http.get(Uri.parse(url));
    print(response.statusCode);
    Map<String, dynamic> data = json.decode(response.body);
    return data;
  }

  /// This is to show a brief description about the character, specifically I chose
  /// to put which film or show they are from. I only included these 2 categories because
  /// these are the most frequent data in the API when I scanned it
  String getBriefDescription(dynamic character) {
    List<String> tvShows = List<String>.from(character['tvShows'] ?? []);
    List<String> films = List<String>.from(character['films'] ?? []);

    if (tvShows.isNotEmpty) {
      return "A character from the TV Show: ${tvShows.first}";
    } else if (films.isNotEmpty) {
      return "A character from the Film: ${films.first}";
    }
    return "Disney Character";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white, // Added to make the background white
        title: const Text("Unit 7 - API Calls"),
      ),
      body: FutureBuilder(
        future: future,
        builder: (context, snapshot) {
          // Consider 3 cases here
          // when the process is ongoing
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          // when the process is completed:
          // successful
          // Use the library here
          if (snapshot.hasData) {
            final characters = snapshot.data!['data'] as List;
            return ExpandedTileList.builder(
              itemCount: characters.length,
              itemBuilder: (BuildContext context, int index,
                  ExpandedTileController controller) {
                final character = characters[index];
                return ExpandedTile(
                  controller: ExpandedTileController(isExpanded: false),
                  title: Row(
                    children: [
                      // Image Section
                      if (character['imageUrl'] != null)
                        Container(
                          width: 100,
                          height: 100,
                          margin: const EdgeInsets.only(right: 15),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: Image.network(character['imageUrl'],
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Icon(
                                      Icons.favorite,
                                    ) // If there is no cover, this will make it display a heart icon instead <3
                                ),
                          ),
                        ),

                      // Name, Title, and Description Section
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              character['name'] ?? 'Unknown',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              getBriefDescription(character),
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  content: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (character['films'].isNotEmpty) ...[
                        const Text(
                          'Films:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(character['films'].join(', ')),
                        const SizedBox(height: 8),
                      ],
                      if (character['tvShows'].isNotEmpty) ...[
                        const Text(
                          'TV Shows:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(character['tvShows'].join(', ')),
                      ],
                    ],
                  ),
                );
              },
            );
          }

          // error
          // If there is an error, this will display what type of error occured
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          // Displays a "There is no data" message when there is no data available
          return const Center(
            child: Text('There is no data.'),
          );
        },
      ),
    );
  }
}

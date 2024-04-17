import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: GalleryScreen(),
    );
  }
}

class GalleryScreen extends StatefulWidget {
  @override
  _GalleryScreenState createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  List<Photo> _photos = [];
  int _columns = 2;

  @override
  void initState() {
    super.initState();
    _fetchPhotos();
  }

  void _fetchPhotos() async {
    final response = await http.get(Uri.parse(
        'https://pixabay.com/api/?key=43431676-c083725278dc58f36ce03ea25&per_page=50'));
    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      setState(() {
        _photos = (jsonData['hits'] as List)
            .map((photo) => Photo.fromJson(photo))
            .toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gallery App'),
        centerTitle: true,
      ),
      body: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: _columns,
        ),
        itemCount: _photos.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.all(8.0), // Adjust the spacing as needed
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FullScreenImage(_photos[index]),
                  ),
                );
              },
              child: GridTile(
                child: Image.network(
                  _photos[index].imageUrl,
                  fit: BoxFit.cover,
                ),
                footer: GridTileBar(
                  backgroundColor: Colors.black54,
                  title: Text(
                    'Likes: ${_photos[index].likes}',
                    textAlign: TextAlign.center,
                  ),
                  subtitle: Text(
                    'Views: ${_photos[index].views}',
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class FullScreenImage extends StatelessWidget {
  final Photo photo;

  FullScreenImage(this.photo);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () {
          Navigator.pop(context);
        },
        child: Stack(
          children: [
            Center(
              child: Hero(
                tag: photo.imageUrl,
                child: Image.network(
                  photo.imageUrl,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Positioned(
              top: 40,
              left: 10,
              child: IconButton(
                icon: Icon(Icons.cancel),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Photo {
  final String imageUrl;
  final int likes;
  final int views;

  Photo({
    required this.imageUrl,
    required this.likes,
    required this.views,
  });

  factory Photo.fromJson(Map<String, dynamic> json) {
    return Photo(
      imageUrl: json['webformatURL'],
      likes: json['likes'],
      views: json['views'],
    );
  }
}

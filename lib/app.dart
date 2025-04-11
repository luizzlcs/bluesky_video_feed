import 'package:bluesky_video_feed/features/feed/data/presentation/screens/feed_screen.dart';
import 'package:flutter/material.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bluesky Video Feed',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.dark,
        useMaterial3: true,
      ),
      home: const FeedScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
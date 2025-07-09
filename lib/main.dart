import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'api_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dio Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiProvider provider = ApiProvider();
  final List<String> responses = [];

  void logResponse(String msg) {
    setState(() {
      responses.add(msg);
      if (responses.length > 20) responses.removeAt(0);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.black, Color.fromARGB(255, 23, 21, 21)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                floating: true,
                snap: true,
                backgroundColor: Colors.black.withOpacity(0.8),
                flexibleSpace: const FlexibleSpaceBar(
                  title: Text('Dio API Playground',
                      style: TextStyle(color: Colors.redAccent)),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildListDelegate(
                    [
                      _glassButton(
                          'GET /get',
                          Icons.download,
                          () => provider.fetchData().then(
                              (res) => logResponse("GET: ${res.toString()}"))),
                      _glassButton(
                          'POST /post',
                          Icons.send,
                          () => provider.postData().then(
                              (res) => logResponse("POST: ${res.toString()}"))),
                      _glassButton('Upload File', Icons.file_upload, () async {
                        const path = '/path/to/local/test.txt';
                        if (await File(path).exists()) {
                          await provider.uploadFile(path);
                          logResponse("File uploaded: $path");
                        } else {
                          logResponse("❌ File not found at $path");
                        }
                      }),
                      _glassButton(
                          'Delayed call',
                          Icons.timer,
                          () => provider.delayedCall(cancel: false).then(
                              (_) => logResponse("Delayed call complete"))),
                      _glassButton(
                          'Delayed call + cancel',
                          Icons.cancel,
                          () => provider.delayedCall(cancel: true).then(
                              (_) => logResponse("Canceled delayed call"))),
                      _glassButton(
                          'Timeout test',
                          Icons.timelapse,
                          () => provider.timeoutTest().then(
                              (_) => logResponse("Timeout test completed"))),
                      const SizedBox(height: 20),
                      _glassResponseBoard(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _glassButton(String text, IconData icon, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: InkWell(
            onTap: onTap,
            child: Container(
              height: 60,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.redAccent.withOpacity(0.3)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(icon, color: Colors.redAccent),
                  Text(
                    text,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1,
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios_rounded,
                      color: Colors.grey),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _glassResponseBoard() {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.redAccent.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '📋 Responses:',
            style: TextStyle(
              color: Colors.redAccent,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 200,
            child: ListView.builder(
              itemCount: responses.length,
              itemBuilder: (context, index) {
                return Text(
                  responses[index],
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

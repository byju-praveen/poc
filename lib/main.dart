import 'dart:io';
import 'dart:isolate';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:path_provider/path_provider.dart';
import 'package:archive/archive.dart';
import 'package:poc/webview.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Plugin must be initialized before using
  await FlutterDownloader.initialize(
    debug: true,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'FlutterDownloader'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int progress = 0;
  int folderCounter = 0; // New variable to keep track of folder count
  int status = 9;
  // ...

  void _downloadFiles() async {
    final baseDir = (await getTemporaryDirectory()).path;
    print(baseDir);
    const folderName = 'folder'; // Increment folder count
    final savedDir = '$baseDir/$folderName';
    const fileName = 'filename.zip';
    final filePath = '$savedDir/$fileName';
    print(filePath);
    // Create the directory if it doesn't exist
    if (!Directory(savedDir).existsSync()) {
      Directory(savedDir).createSync(recursive: true);
    }
    print("savedDir - $savedDir");

    // Check if the file already exists
    final file = File(filePath);
    if (file.existsSync()) {
      print('File already downloaded');
      return;
    }

    final taskId = await FlutterDownloader.enqueue(
      url:
          'https://s3-ap-southeast-1.amazonaws.com/tnl-public/interactions/sanitized_assets/staging/1577.zip?1626696053',
      savedDir: savedDir,
      openFileFromNotification: false,
      fileName: fileName,
    );
    print(savedDir);
    print('Download task ID: $taskId');

    // Wait for the file to finish downloading

    // ...
  }

  ReceivePort receivePort = ReceivePort();

  @override
  void initState() {
    IsolateNameServer.registerPortWithName(
        receivePort.sendPort, 'downloadingId');
    receivePort.listen((message) {
      setState(() {
        progress = message;
      });
    });
    FlutterDownloader.registerCallback(downloadCallback);
    super.initState();
  }

  static downloadCallback(id, status, progress) async {
    SendPort? sendPort = IsolateNameServer.lookupPortByName('downloadingId');
    sendPort?.send(progress);
    print('$status -----  ${DownloadTaskStatus.complete.value}');
    if (status == DownloadTaskStatus.complete.value) {
      print("1");
      // final savedDir = (await getTemporaryDirectory()).path;
      print("2");
      const zipFilePath =
          '/data/user/0/com.example.poc/cache/folder/filename.zip';
      print("3");
      const unzipDirectory =
          '/data/user/0/com.example.poc/cache/folder/unzipfile';

      print("4");

      try {
        print("5");
        final bytes = File(zipFilePath).readAsBytesSync();
        print("6");
        final archive = ZipDecoder().decodeBytes(bytes);
        print("7");
        for (final file in archive) {
          final fileName = file.name;
          if (file.isFile) {
            final filePath = '$unzipDirectory/$fileName';
            final outputFile = File(filePath);
            if (fileName.endsWith('.html')) {
              // Check if the file has .html extension
              print('HTML path: $filePath');
            }
            outputFile.createSync(recursive: true);
            outputFile.writeAsBytesSync(file.content as List<int>);
          } else {
            final directoryPath = '$unzipDirectory/$fileName';
            Directory(directoryPath).createSync(recursive: true);
          }
          print("8");
        }
        print('File unzipped successfully');
        print("9");
        // Remove the zip file
        File(zipFilePath).deleteSync();
        print("10");
        // Rename the unzipped directory to the desired name
        // const newDirectoryName =
        //     '/data/user/0/com.example.poc/cache/folder/unzipfile';
        // print("11");
        // await unzipDirectory.rename(unzipDirectory);
        // print('Unzipped directory renamed');
      } catch (e) {
        print("12");
        print('Error during unzipping: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Download Percentage',
            ),
            Text(
              '$progress',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ExtractArgumentsScreen()),
                  );
                },
                icon: const Icon(
                    Icons.account_box)) // Changed headlineMedium to headline6
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _downloadFiles,
        child: const Icon(Icons.download),
      ),
    );
  }
}

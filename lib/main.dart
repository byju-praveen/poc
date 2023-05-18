import 'dart:io';
import 'dart:isolate';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:path_provider/path_provider.dart';
import 'package:archive/archive.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Plugin must be initialized before using
  await FlutterDownloader.initialize(
    debug: true,
    ignoreSsl: true,
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

  void _downloadFiles() async {
    final savedDir = (await getTemporaryDirectory()).path;
    const fileName = 'filename.zip';
    final filePath = '$savedDir/$fileName';

    // Check if the file already exists
    final file = File(filePath);
    if (file.existsSync()) {
      print('File already downloaded');
      return;
    }

    final id = await FlutterDownloader.enqueue(
      url:
          'https://s3-ap-southeast-1.amazonaws.com/tnl-public/interactions/sanitized_assets/staging/1576.zip?1626696053',
      savedDir: savedDir,
      fileName: fileName,
    );
    print(savedDir);
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
    sendPort!.send(progress);

    if (status == DownloadTaskStatus.complete) {
      final savedDir = (await getTemporaryDirectory()).path;
      final zipFilePath = '$savedDir/filename.zip';
      final unzipDirectory = Directory('$savedDir/unzipfile');

      try {
        final bytes = File(zipFilePath).readAsBytesSync();
        final archive = ZipDecoder().decodeBytes(bytes);

        for (final file in archive) {
          final fileName = file.name;
          if (file.isFile) {
            final filePath = '$unzipDirectory/$fileName';
            final outputFile = File(filePath);
            outputFile.createSync(recursive: true);
            outputFile.writeAsBytesSync(file.content as List<int>);
          } else {
            final directoryPath = '$unzipDirectory/$fileName';
            Directory(directoryPath).create(recursive: true);
          }
        }
        print('File unzipped successfully');

        // Remove the zip file
        File(zipFilePath).delete();

        // Rename the unzipped directory to the desired name
        final newDirectoryName = '$savedDir/unzipfile';
        await unzipDirectory.rename(newDirectoryName);
        print('Unzipped directory renamed');
      } catch (e) {
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
              style: Theme.of(context).textTheme.headlineMedium,
            ),
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

import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:url_launcher/url_launcher.dart';

class FirebaseImageViewer extends StatelessWidget {
  final String imageUrl;

  const FirebaseImageViewer({
    Key? key,
    required this.imageUrl,
  }) : super(key: key);

  Future<String> _getDownloadUrl() async {
    final ref = FirebaseStorage.instance.refFromURL(imageUrl);
    return await ref.getDownloadURL();
  }

  Future<void> _downloadImage() async {
    try {
      final url = await _getDownloadUrl();
      if (await canLaunch(url)) {
        await launch(url); // Launch the URL in the browser for downloading
      } else {
        print('Could not launch URL');
      }
    } catch (e) {
      print('Error downloading image: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _getDownloadUrl(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 8),
              Text('Error loading image: ${snapshot.error}'),
            ],
          );
        }

        if (!snapshot.hasData) {
          return const Text('No image available');
        }

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.network(
              snapshot.data!,
              height: 200,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Center(
                  child: CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded / (loadingProgress.expectedTotalBytes ?? 1)
                        : null,
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return Column(
                  children: [
                    const Icon(Icons.broken_image, size: 48),
                    const SizedBox(height: 8),
                    Text('Error loading image: $error'),
                  ],
                );
              },
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: _downloadImage,
              icon: const Icon(Icons.download),
              label: const Text('Download Image'),
            ),
          ],
        );
      },
    );
  }
}

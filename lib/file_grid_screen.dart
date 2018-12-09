import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:synology_image_viewer/image_viewer_screen.dart';
import 'package:synology_image_viewer/synology_api.dart';

class FileGridScreen extends StatefulWidget {
  final String directory;

  const FileGridScreen(this.directory);

  @override
  State createState() => FileGridState(directory);
}

class FileGridState extends State<FileGridScreen> {
  final synologyApi = SynologyApi();
  final String directory;
  List<Widget> _thumbnails = [];
  List<String> _imagePaths = [];

  FileGridState(this.directory);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Files"),
      ),
      body: getBody(),
    );
  }

  @override
  void initState() {
    super.initState();
    _queryGridItems();
  }

  getBody() {
    if (_thumbnails.length == 0) {
      return Center(child: CircularProgressIndicator());
    } else {
      return GridView.count(
        crossAxisCount: 3,
        children: _thumbnails,
      );
    }
  }

  _queryGridItems() {
    synologyApi.getResultsForPath(directory).then((contents) {
      List<String> newPaths = [];
      List<Widget> newThumbnails = [];
      createThumbnails(contents, newPaths, newThumbnails);

      setState(() {
        _imagePaths = newPaths;
        _thumbnails = newThumbnails;
      });
    });
  }

  void createThumbnails(List results, List<String> newPaths, List<Widget> newThumbnails) {
    for (var i = 0; i < results.length; ++i) {
      final file = results[i];
      final String path = file["path"];
      if (_isImageFile(file, path)) {
        newPaths.add(path);
        newThumbnails.add(
          Ink.image(
            image: CachedNetworkImageProvider(
              synologyApi.getThumbnailUrl(path),
              headers: synologyApi.getAuthHeaders(),
            ),
            fit: BoxFit.cover,
            child: InkWell(
              onTap: () => Navigator.push(
                  context, MaterialPageRoute(builder: (context) => ImageViewerScreen(path, _imagePaths))),
            ),
          ),
        );
      } else if (file["isdir"]) {
        newThumbnails.add(GestureDetector(
          child: Padding(
              padding: EdgeInsets.all(8),
              child: Column(
                children: <Widget>[
                  Expanded(
                      child: Image.asset(
                    "assets/directory_icon.png",
                    fit: BoxFit.contain,
                  )),
                  Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: Text(
                      path.substring(path.lastIndexOf('/') + 1),
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      overflow: TextOverflow.fade,
                    ),
                  ),
                ],
              )),
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (buildContext) => FileGridScreen(path))),
        ));
      }
    }
  }

  bool _isImageFile(file, String path) =>
      file["isdir"] == false &&
      (path.toLowerCase().endsWith("jpeg") || path.toLowerCase().endsWith("png") || path.toLowerCase().endsWith("jpg"));
}

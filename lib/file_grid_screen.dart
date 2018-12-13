import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:synology_image_viewer/Assets.dart';
import 'package:synology_image_viewer/image_viewer_screen.dart';
import 'package:synology_image_viewer/synology_api.dart';
import 'package:synology_image_viewer/video_viewer_screen.dart';

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
  bool _hasLoaded = false;

  FileGridState(this.directory);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(directory.substring(directory.lastIndexOf('/') + 1)),
      ),
      body: getBody(),
      backgroundColor: (_hasLoaded && _thumbnails.length > 0) ? Colors.black : Colors.white,
    );
  }

  @override
  void initState() {
    super.initState();
    _queryGridItems();
  }

  getBody() {
    if (_thumbnails.length == 0 && !_hasLoaded) {
      return Center(child: CircularProgressIndicator());
    } else if (_thumbnails.length == 0 && _hasLoaded) {
      return Center(
        child: Text(
          "Nothing here..",
          style: TextStyle(fontSize: 20, color: Colors.black.withOpacity(0.6)),
        ),
      );
    } else {
      return GridView.extent(
        maxCrossAxisExtent: 200,
        children: _thumbnails,
        mainAxisSpacing: 1,
        crossAxisSpacing: 1,
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
        _hasLoaded = true;
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
          GestureDetector(
            child: Hero(
              tag: path,
              child: FadeInImage(
                image: CachedNetworkImageProvider(
                  synologyApi.getThumbnailUrl(path),
                  headers: synologyApi.getAuthHeaders(),
                ),
                fit: BoxFit.cover,
                placeholder: AssetImage(Assets.videoIcon),
                fadeInDuration: Duration(milliseconds: 100),
                fadeOutDuration: Duration(milliseconds: 100),
              ),
            ),
            onTap: () =>
                Navigator.push(context, MaterialPageRoute(builder: (context) => ImageViewerScreen(path, _imagePaths))),
          ),
        );
      } else if (file["isdir"]) {
        newThumbnails.add(GestureDetector(
          child: Container(
            color: Colors.white,
            child: Padding(
                padding: EdgeInsets.all(8),
                child: Column(
                  children: <Widget>[
                    Expanded(
                        child: Image.asset(
                      Assets.directoryIcon,
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
          ),
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (buildContext) => FileGridScreen(path))),
        ));
      }
    }
  }

  bool _isImageFile(file, String path) =>
      file["isdir"] == false &&
      (path.toLowerCase().endsWith("jpeg") || path.toLowerCase().endsWith("png") || path.toLowerCase().endsWith("jpg"));
}

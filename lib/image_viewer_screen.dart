import 'package:flutter/widgets.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:synology_image_viewer/synology_api.dart';

class ImageViewerScreen extends StatefulWidget {
  final String _path;
  final List<String> _imagePaths;

  ImageViewerScreen(this._path, this._imagePaths);

  @override
  State createState() => ImageViewerState(this._path, this._imagePaths);
}

class ImageViewerState extends State<ImageViewerScreen> {
  final _synologyApi = SynologyApi();
  final String _initialPath;
  final List<String> _paths;

  ImageViewerState(this._initialPath, this._paths);

  @override
  Widget build(BuildContext context) {
    final List<PhotoViewGalleryPageOptions> images = _paths.map((path) {
      return PhotoViewGalleryPageOptions(
          imageProvider: NetworkImage(
        _synologyApi.getImageUrl(path),
        headers: _synologyApi.getAuthHeaders(),
      ));
    }).toList();
    return GestureDetector(
      child: PhotoViewGallery(
        pageOptions: images,
        pageController: PageController(initialPage: _paths.indexOf(_initialPath)),
      ),
      onTap: () => Navigator.pop(context),
    );
  }
}

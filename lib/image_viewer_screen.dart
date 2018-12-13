import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:synology_image_viewer/synology_api.dart';

class ImageViewerScreen extends StatelessWidget {
  final String _path;
  final List<String> _imagePaths;

  ImageViewerScreen(this._path, this._imagePaths);

  @override
  Widget build(BuildContext context) {
    return SynologyPhotoGallery(_path, _imagePaths);
  }
}

class SynologyPhotoGallery extends StatefulWidget {
  final String _initialPath;
  final List<String> _paths;

  const SynologyPhotoGallery(this._initialPath, this._paths);

  @override
  State createState() => SynologyPhotoGalleryState(_initialPath, _paths);
}

class SynologyPhotoGalleryState extends State<SynologyPhotoGallery> {
  final String _initialPath;
  final List<String> _paths;

  SynologyPhotoGalleryState(this._initialPath, this._paths);

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays([]);

    return GestureDetector(
      child: PhotoViewGallery(
        pageOptions: getImages(),
        pageController: PageController(initialPage: _paths.indexOf(_initialPath)),
      ),
      onTap: () {
        Navigator.pop(context);
      },
    );
  }

  List<PhotoViewGalleryPageOptions> getImages() {
    final synologyApi = SynologyApi();

    return _paths.map(
      (path) {
        return PhotoViewGalleryPageOptions(
            heroTag: (_initialPath == path) ? path : "",
            imageProvider: CachedNetworkImageProvider(
              synologyApi.getImageUrl(path),
              headers: synologyApi.getAuthHeaders(),
            ));
      },
    ).toList();
  }


  @override
  void dispose() {
    super.dispose();
    SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
  }
}

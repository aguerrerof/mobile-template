import 'package:flutter/material.dart';
import 'package:mobile_app_template/components/youtube_player_widget.dart';
import 'package:mobile_app_template/models/response_models.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class ImageGalery extends StatefulWidget {
  final List<MediaItem> medias;
  const ImageGalery({super.key, required this.medias});

  @override
  ImageGaleryState createState() => ImageGaleryState();
}

class ImageGaleryState extends State<ImageGalery> {
  MediaItem? mediaSelected;

  @override
  void initState() {
    super.initState();
    mediaSelected = widget.medias.isNotEmpty ? widget.medias.first : null;
  }

  @override
  void didUpdateWidget(covariant ImageGalery oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.medias != oldWidget.medias && widget.medias.isNotEmpty) {
      setState(() {
        mediaSelected = widget.medias.first;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (mediaSelected != null) {
      return Row(
        spacing: 20,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child:
                  widget.medias.isNotEmpty
                      ? Container(
                        color: Colors.grey.shade100,
                        padding: EdgeInsets.all(10),
                        child:
                            mediaSelected!.isImage()
                                ? Image.network(
                                  mediaSelected!.image!.url,
                                  height: 250,
                                  fit: BoxFit.contain,
                                  errorBuilder:
                                      (context, error, stackTrace) =>
                                          const Icon(Icons.error),
                                )
                                : mediaSelected!.isYoutubeVideo()
                                ? YouTubePlayer(
                                  youtubeUrl: mediaSelected!.embeddedUrl!,
                                )
                                : Icon(Icons.image_not_supported),
                      )
                      : const Icon(Icons.image_not_supported),
            ),
          ),
          if (widget.medias.length > 1)
            SizedBox(
              width: 60,
              child: ListView.builder(
                scrollDirection: Axis.vertical,
                itemCount: widget.medias.length,
                itemBuilder: (_, i) {
                  final item = widget.medias[i];

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            mediaSelected = widget.medias[i];
                          });
                        },
                        child: Container(
                          color: Colors.grey.shade100,
                          padding: EdgeInsets.all(5),
                          child:
                              item.isImage()
                                  ? Image.network(
                                    item.image!.url,
                                    width: 50,
                                    height: 50,
                                    fit: BoxFit.contain,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            const Icon(Icons.error),
                                  )
                                  : item.isYoutubeVideo()
                                  ? Icon(Icons.play_circle_outline, size: 50)
                                  : Icon(Icons.image_not_supported),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      );
    } else {
      return Container();
    }
  }
}


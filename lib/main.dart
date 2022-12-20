import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';


import 'package:flutter/foundation.dart';
import 'package:video_player/video_player.dart';

void main() => runApp(const VideoPlayerApp());



class VideoPlayerApp extends StatelessWidget {
  const VideoPlayerApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Video Player Demo',
      home: VideoPlayerScreen(),
    );
  }
}

class VideoPlayerScreen extends StatefulWidget {
  const VideoPlayerScreen({Key? key}) : super(key: key);

  @override
  _VideoPlayerScreenState createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
    VideoPlayerController? _controller;
  VideoPlayerController? _toBeDisposed;
  
 bool muted=false;
 bool isPlaying =false;
 bool loop = false;
 double vol=0.5;
 var kamado = 16/9;
bool sc = false;
double _currentopacity =1;

 final ImagePicker _picker = ImagePicker();
 bool isVideo =false;
_up(){
    setState(() {
             
            // If the video is playing, pause it.
              vol=vol+0.1;
              _controller!.setVolume(vol);


          });
}
_down(){
setState(() {
             
            // If the video is playing, pause it.
              vol=vol-0.1;
              _controller!.setVolume(vol);


          });

}
fullsc(){
  setState(() {
    
     if(sc == false){
       sc= true;
     }
     else{
       sc=false;
     }
     if(kamado ==16/9){
        kamado =  _controller!.value.aspectRatio;
     }
     else{
       kamado =16/9;
     }
   

  });
}
_edio(){
  
 setState(() {
           
            // If the video is playing, pause it.
            if (_controller!.value.isPlaying) {
              _controller!.pause();
              isPlaying =false;
            } else {
              // If the video is paused, play it.
              _controller!.play();
              isPlaying =true;
            }
          });

}
_mu(){
   setState(() {
             
            // If the video is playing, pause it.
            if (muted == false){
               muted= true;
             }
             else{
               muted=false;
             }
            if (muted== true) {
             _controller!.setVolume(0.0);
             
            }
            else{
              
              _controller!.setVolume(1.0);
            } 
          });
}
_loo(){
  setState(() {
             
            // If the video is playing, pause it.
            if (loop == false){
               loop= true;
             }
             else{
               loop=false;
             }
            if (loop== true) {
              _controller!.setLooping(true);
             
            }
            else{
              
               _controller!.setLooping(false);
            } 
          });
}
 _playVideo(XFile? file) async {
    if (file != null ) {
      await _disposeVideoController();
      late VideoPlayerController controller;
        if (kIsWeb) {
        controller = VideoPlayerController.network(file.path);
      } else {
        controller = VideoPlayerController.file(File(file.path));
      }
      
      _controller = controller;
      // In web, most browsers won't honor a programmatic call to .play
      // if the video has a sound track (and is not muted).
      // Mute the video so it auto-plays in web!
      // This is not needed if the call to .play is the result of user
      // interaction (clicking on a "play" button, for example).
    

      await controller.initialize();
      await controller.setLooping(true);
      await controller.play();
      setState(() {
      });
    }
  }
  void _onImageButtonPressed(ImageSource source, {BuildContext? context, bool isMultiImage = false}) async {

    if (isVideo) {
      final XFile? file = await _picker.pickVideo(
          source: source, maxDuration: const Duration(seconds: 10));
      await _playVideo(file);
    }
      }

  
 @override
  void deactivate() {
    if (_controller != null) {
      _controller!.setVolume(0.0);
      _controller!.pause();
    }
    super.deactivate();
  }

  @override
  void dispose() {
    _disposeVideoController();
    super.dispose();
  }
  Future<void> _disposeVideoController() async {
    if (_toBeDisposed != null) {
      await _toBeDisposed!.dispose();
    }
    _toBeDisposed = _controller;
    _controller = null;
  }

    Widget _previewVideo() {
    
    if (_controller == null) {
      return const Text(
        'You have not yet picked a video',
        textAlign: TextAlign.center,
      );
    }
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: AspectRatioVideo(_controller,kamado,_currentopacity),
    );
  }
  
    Future<void> retrieveLostData() async {
    final LostDataResponse response = await _picker.retrieveLostData();
    if (response.isEmpty) {
      return;
    }
    if (response.file != null) {
      if (response.type == RetrieveType.video) {
        isVideo = true;
        await _playVideo(response.file);
      } 
    } 
  }
  
 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      body: Stack(
        
           children:<Widget>[
             GestureDetector(
      onTap: () {
        setState(() {
          _currentopacity = _currentopacity == 0.0 ? 1 : 0.0;

        });
      },
    ),
              !kIsWeb && defaultTargetPlatform == TargetPlatform.android ?
             FutureBuilder<void>(
               
           future: retrieveLostData(),
                builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.none:
                    case ConnectionState.waiting:
                      return const Text(
                        'You have not yet picked an image.',
                        textAlign: TextAlign.center,
                      );
                    case ConnectionState.done:
                      return _previewVideo();
                    default:
                      if (snapshot.hasError) {
                        return Text(
                          'Pick image/video error: ${snapshot.error}}',
                          textAlign: TextAlign.center,
                        );
                      } else {
                        return const Text(
                          'You have not yet picked an image.',
                          textAlign: TextAlign.center,
                        );
                      }
                  }
                },
              ): _previewVideo()
           ],
      ),
      // Use a FutureBuilder to display a loading spinner while waiting for the
      // VideoPlayerController to finish initializing.
    
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: Padding(
          padding: const EdgeInsets.all(8.0),
        
                 child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
            AnimatedOpacity(
              opacity: _currentopacity,
              duration: Duration(seconds :2),
            child:FloatingActionButton(
                 onPressed: () {
          // Wrap the play or pause in a call to `setState`. This ensures the
          // correct icon is shown.
          _down();
        },
              child: new Icon( const IconData(0xe15b, fontFamily: 'MaterialIcons'),
                 color: Colors.black),
              backgroundColor: Colors.blue.shade600,
          
              ),
            ),
              
              AnimatedOpacity(
              opacity: _currentopacity,
              duration: Duration(seconds :2),
            child: FloatingActionButton(
                onPressed: () {
          // Wrap the play or pause in a call to `setState`. This ensures the
          // correct icon is shown.
         _edio();
        },
        // Display the correct icon depending on the state of the player.
        child: Icon(
          isPlaying ? Icons.pause : Icons.play_arrow,
        ),
        
              ),
              ),
               AnimatedOpacity(
              opacity: _currentopacity,
              duration: Duration(seconds :2),
            child:FloatingActionButton(
              backgroundColor: Colors.red,
              onPressed: () {
                isVideo = true;
                _onImageButtonPressed(ImageSource.gallery);
              },
              heroTag: 'video0',
              tooltip: 'Pick Video from gallery',
              child: const Icon(Icons.video_library),
            ),),
              AnimatedOpacity(
              opacity: _currentopacity,
              duration: Duration(seconds :2),
            child:FloatingActionButton(
                 onPressed: () {
          // Wrap the play or pause in a call to `setState`. This ensures the
          // correct icon is shown.
         _mu();
        },
              child: Icon(
          muted ? Icons.volume_mute_outlined : Icons.volume_up_outlined,
        ), 
             ), ), 
              AnimatedOpacity(
              opacity: _currentopacity,
              duration: Duration(seconds :2),
            child:FloatingActionButton(
                 onPressed: () {
          // Wrap the play or pause in a call to `setState`. This ensures the
          // correct icon is shown.
        _up();
        },
              child:  new Icon(  
       Icons.add, color: Colors.white,),
              backgroundColor: Colors.blue.shade600, ),  
              
              ), 
  AnimatedOpacity(
              opacity: _currentopacity,
              duration: Duration(seconds :2),
            child: FloatingActionButton(
                 onPressed: () {
          // Wrap the play or pause in a call to `setState`. This ensures the
          // correct icon is shown.
          _loo();
        },
              child: Icon(
          muted ? Icons.loop_outlined : Icons.loop_rounded,
        ), 
         
              ),
           ),
            AnimatedOpacity(
              opacity: _currentopacity,
              duration: Duration(seconds :2),
            child: FloatingActionButton(
                 onPressed: () {
          // Wrap the play or pause in a call to `setState`. This ensures the
          // correct icon is shown.
          fullsc();
        },
              child: Icon(
          sc ? Icons.fullscreen_exit : Icons.fullscreen,
        ), 
         
              ),   
            ),
            ],
          ),
        )    
           
    );
  }
  
}


class AspectRatioVideo extends StatefulWidget {
  var kamado;
 var _currentopacity;
  AspectRatioVideo(this.controller,this.kamado,this._currentopacity);

  final VideoPlayerController? controller;

  @override
  AspectRatioVideoState createState() => AspectRatioVideoState();
}

class AspectRatioVideoState extends State<AspectRatioVideo> {
  VideoPlayerController? get controller => widget.controller;
  bool initialized = false;

  get kamado => widget.kamado;
  get _currentopacity => widget._currentopacity;


  void _onVideoControllerUpdate() {
    if (!mounted) {
      return;
    }
    if (initialized != controller!.value.isInitialized) {
      initialized = controller!.value.isInitialized;
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    controller!.addListener(_onVideoControllerUpdate);
  }

  @override
  void dispose() {
    controller!.removeListener(_onVideoControllerUpdate);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (initialized) {
      return Scaffold(
        
        
          body: Container(  
            child:Row(
            
            children:<Widget>[ 
              AnimatedOpacity(
              opacity: _currentopacity,
              duration: Duration(seconds :2),
            child:VideoProgressIndicator(controller!,
          allowScrubbing: true,
          colors: VideoProgressColors(
              backgroundColor: Colors.red,
              bufferedColor: Colors.black,
              playedColor: Colors.blueAccent),
        ),
        ),
            AspectRatio(
            aspectRatio: kamado,
            child: VideoPlayer(controller!),
            ),
            ],
         
            ),
          )
      );
    } else {
      return Container();
    }
  }
} 


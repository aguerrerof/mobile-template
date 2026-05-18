import 'package:flutter/material.dart';
import 'package:mobile_app_template/Services/analitics_service.dart';
import 'package:mobile_app_template/components/custom_button.dart';
import 'package:mobile_app_template/components/custom_scaffold.dart';
import 'package:mobile_app_template/views/theme/extension_colors.dart';
import 'package:flutter_svg/svg.dart';
import 'package:video_player/video_player.dart';

class WelcomeScreen extends StatefulWidget {
  @override
  WelcomeScreenState createState() => WelcomeScreenState();
}

class WelcomeScreenState extends State<WelcomeScreen> {
  final PageController _controller = PageController();
  late VideoPlayerController _videoController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    AnalyticsService().trackEvent("User loads onboarding");
    _videoController =
        VideoPlayerController.asset("assets/videos/mi_video.mp4")
          ..setLooping(true)
          ..initialize().then((_) {
            setState(() {});
            _videoController.setVolume(0.0);
            _videoController.play();
          });
  }

  @override
  void dispose() {
    _controller.dispose();
    _videoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      backgroundColor: MyColors.backgroundColor,
      navBarColor: MyColors.backgroundColor,
      useSafeArea: true,
      child: Column(
        children: [
          Expanded(
            child: Container(
              color: Colors.transparent,

              width: double.infinity,
              child: Stack(
                children: [
                  PageView(
                    controller: _controller,
                    onPageChanged: (index) {
                      setState(() {
                        _currentPage = index;
                      });
                    },
                    children: [
                      // screen 1
                      Padding(
                        padding: EdgeInsetsGeometry.all(10),
                        child: Container(
                          decoration: BoxDecoration(
                            color: MyColors.navBarBackground,
                            borderRadius: BorderRadius.circular(40),
                          ),
                          child: Padding(
                            padding: EdgeInsetsGeometry.all(30),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: 35),
                                Text(
                                  'Bienvenido a',
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    fontFamily: 'NeulisAlt',
                                    fontSize: 30,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                    height: 1.2,
                                  ),
                                ),
                                Text(
                                  'la familia',
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    fontFamily: 'NeulisAlt',
                                    fontSize: 30,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                    height: 1.2,
                                  ),
                                ),
                                SvgPicture.asset(
                                  'assets/icons/nameApp.svg',
                                  // semanticsLabel: ' ',
                                  fit: BoxFit.cover,
                                  width: 108,
                                  height: 29,
                                  // colorFilter: ColorFilter.mode(
                                  //   // MyColors.btnColor,
                                  //   BlendMode.srcIn,
                                  // ),
                                  //   ),
                                  // ],
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: EdgeInsetsGeometry.only(top: 35),
                                    child: LayoutBuilder(
                                      builder: (context, constraints) {
                                        return _videoController
                                                .value
                                                .isInitialized
                                            ? ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              child: FittedBox(
                                                fit: BoxFit.fill,
                                                child: SizedBox(
                                                  width:
                                                      _videoController
                                                          .value
                                                          .size
                                                          .width,
                                                  height: constraints.maxHeight,
                                                  child: VideoPlayer(
                                                    _videoController,
                                                  ),
                                                ),
                                              ),
                                            )
                                            : const Center(
                                              child: CircularProgressIndicator(
                                                color: Colors.grey,
                                                strokeWidth: 1.5,
                                              ),
                                            );
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // Pantalla 2
                      Padding(
                        padding: EdgeInsetsGeometry.all(10),
                        child: Container(
                          decoration: BoxDecoration(
                            color: MyColors.navBarBackground,
                            borderRadius: BorderRadius.circular(40),
                          ),
                          child: Padding(
                            padding: EdgeInsetsGeometry.all(30),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: 35),
                                Text(
                                  'Nunca te quedes sin comida con nuestro Envío Programado',
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    fontFamily: 'NeulisAlt',
                                    fontSize: 30,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                    height: 1.2,
                                  ),
                                ),

                                Expanded(
                                  child: Padding(
                                    padding: EdgeInsetsGeometry.only(top: 35),
                                    child: LayoutBuilder(
                                      builder: (context, constraints) {
                                        return ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                          child: Container(
                                            width: constraints.maxWidth,
                                            height: constraints.maxHeight,
                                            color: MyColors.navBarBackground,
                                            child: Image.asset(
                                              'assets/images/welcome.png',
                                              fit: BoxFit.fill,
                                              colorBlendMode: BlendMode.srcIn,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // Pantalla 3
                      Padding(
                        padding: EdgeInsetsGeometry.all(10),
                        child: Container(
                          decoration: BoxDecoration(
                            color: MyColors.navBarBackground,
                            borderRadius: BorderRadius.circular(40),
                          ),
                          child: Padding(
                            padding: EdgeInsetsGeometry.all(30),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: 35),
                                Text(
                                  'Las mejores marcas de comida para tu hijo peludo.',
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    fontFamily: 'NeulisAlt',
                                    fontSize: 30,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                    height: 1.2,
                                  ),
                                ),

                                Expanded(
                                  child: Padding(
                                    padding: EdgeInsetsGeometry.only(top: 35),
                                    child: LayoutBuilder(
                                      builder: (context, constraints) {
                                        return ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                          child: SizedBox(
                                            width: constraints.maxWidth,
                                            height: constraints.maxHeight,
                                            child: Image.asset(
                                              'assets/images/welcome3.png',
                                              fit: BoxFit.fill,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 160,
                    child: Column(
                      children: [
                        SizedBox(height: 30),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(3, (index) {
                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              margin: const EdgeInsets.symmetric(horizontal: 6),
                              height: 6,
                              width: _currentPage == index ? 12 : 6,
                              decoration: BoxDecoration(
                                color:
                                    _currentPage == index
                                        ? Colors.white
                                        : Colors.white.withAlpha(100),
                                borderRadius: BorderRadius.circular(3),
                              ),
                            );
                          }),
                        ),
                        SizedBox(height: 5),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          Stack(
            children: [
              Container(
                width: double.infinity,

                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(height: 20),
                    Column(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: CustomButton(
                            label: "Iniciar Sesión o Crear Cuenta",
                            onPressed: () {
                              _videoController.pause();
                              Navigator.pushNamed(context, '/login-one');
                            },
                            borderRadius: 23,
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Botón secundario
                        SizedBox(
                          width: double.infinity,
                          child: CustomButton(
                            label: "Explora como invitado",
                            onPressed: () {
                              _videoController.pause();
                              Navigator.pushNamed(context, '/home');
                            },
                            type: CustomButtonType.text,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 50),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}


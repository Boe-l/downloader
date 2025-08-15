import 'package:audio_flux/audio_flux.dart';
import 'package:boel_downloader/shaders/shaders.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_soloud/flutter_soloud.dart';
import 'dart:async';

class ShaderVisualizer extends StatefulWidget {
  const ShaderVisualizer({super.key});

  @override
  ShaderVisualizerState createState() => ShaderVisualizerState();
}

class ShaderVisualizerState extends State<ShaderVisualizer> with TickerProviderStateMixin {
  late AudioData audioData;
  late Ticker ticker;
  @override
  void initState() {
    super.initState();
    WidgetsFlutterBinding.ensureInitialized();

    _initializeAudio();
  }

  Future<void> _initializeAudio() async {
    try {
      audioData = AudioData(GetSamplesKind.linear);
    } catch (e) {
      debugPrint('Erro ao inicializar áudio: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        resizeToAvoidBottomInset: true,
        body: AudioFlux(
          fluxType: FluxType.shader,
          dataSource: DataSources.soloud,
          modelParams: ModelParams(
            shaderParams: Shaders.shaderParams[2],
          ),
        ),
      ),
    );
  }
}

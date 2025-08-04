import 'package:boel_downloader/services/media_provider.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

class Equalizer extends StatefulWidget {
  const Equalizer({super.key});

  @override
  State<Equalizer> createState() => _EqualizerState();
}

class _EqualizerState extends State<Equalizer> {
  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.center,
      spacing: 30,
      children: [
        Flexible(
          child: RotatedBox(
            quarterTurns: 3, // Rotaciona 270 graus para orientação vertical (de baixo para cima)
            child: Selector<MediaProvider, double>(
              selector: (_, provider) => provider.filterParams['eqBand1']!,
              builder: (_, value, __) => Slider(
                value: SliderValue.single(value),
                min: 0.0,
                max: 4.0,
                divisions: 100,
                // label: _value.round().toString(),
                onChanged: (value) => Provider.of<MediaProvider>(context, listen: false).setFilterParam('eqBand1', value.value),
              ),
            ),
          ),
        ),
        Flexible(
          child: RotatedBox(
            quarterTurns: 3, // Rotaciona 270 graus para orientação vertical (de baixo para cima)
            child: Selector<MediaProvider, double>(
              selector: (_, provider) => provider.filterParams['eqBand2']!,
              builder: (_, value, __) => Slider(
                value: SliderValue.single(value),
                min: 0.0,
                max: 4.0,
                divisions: 100,
                // label: _value.round().toString(),
                onChanged: (value) => Provider.of<MediaProvider>(context, listen: false).setFilterParam('eqBand2', value.value),
              ),
            ),
          ),
        ),
        Flexible(
          child: RotatedBox(
            quarterTurns: 3, // Rotaciona 270 graus para orientação vertical (de baixo para cima)
            child: Selector<MediaProvider, double>(
              selector: (_, provider) => provider.filterParams['eqBand3']!,
              builder: (_, value, __) => Slider(
                value: SliderValue.single(value),
                min: 0.0,
                max: 4.0,
                divisions: 100,
                // label: _value.round().toString(),
                onChanged: (value) => Provider.of<MediaProvider>(context, listen: false).setFilterParam('eqBand3', value.value),
              ),
            ),
          ),
        ),
        Flexible(
          child: RotatedBox(
            quarterTurns: 3, // Rotaciona 270 graus para orientação vertical (de baixo para cima)
            child: Selector<MediaProvider, double>(
              selector: (_, provider) => provider.filterParams['eqBand4']!,
              builder: (_, value, __) => Slider(
                value: SliderValue.single(value),
                min: 0.0,
                max: 4.0,
                divisions: 100,
                // label: _value.round().toString(),
                onChanged: (value) => Provider.of<MediaProvider>(context, listen: false).setFilterParam('eqBand4', value.value),
              ),
            ),
          ),
        ),
        Flexible(
          child: RotatedBox(
            quarterTurns: 3, // Rotaciona 270 graus para orientação vertical (de baixo para cima)
            child: Selector<MediaProvider, double>(
              selector: (_, provider) => provider.filterParams['eqBand5']!,
              builder: (_, value, __) => Slider(
                value: SliderValue.single(value),
                min: 0.0,
                max: 4.0,
                divisions: 100,
                // label: _value.round().toString(),
                onChanged: (value) => Provider.of<MediaProvider>(context, listen: false).setFilterParam('eqBand5', value.value),
              ),
            ),
          ),
        ),
        Flexible(
          child: RotatedBox(
            quarterTurns: 3, // Rotaciona 270 graus para orientação vertical (de baixo para cima)
            child: Selector<MediaProvider, double>(
              selector: (_, provider) => provider.filterParams['eqBand6']!,
              builder: (_, value, __) => Slider(
                value: SliderValue.single(value),
                min: 0.0,
                max: 4.0,
                divisions: 100,
                // label: _value.round().toString(),
                onChanged: (value) => Provider.of<MediaProvider>(context, listen: false).setFilterParam('eqBand6', value.value),
              ),
            ),
          ),
        ),
        Flexible(
          child: RotatedBox(
            quarterTurns: 3, // Rotaciona 270 graus para orientação vertical (de baixo para cima)
            child: Selector<MediaProvider, double>(
              selector: (_, provider) => provider.filterParams['eqBand7']!,
              builder: (_, value, __) => Slider(
                value: SliderValue.single(value),
                min: 0.0,
                max: 4.0,
                divisions: 100,
                // label: _value.round().toString(),
                onChanged: (value) => Provider.of<MediaProvider>(context, listen: false).setFilterParam('eqBand7', value.value),
              ),
            ),
          ),
        ),
        Flexible(
          child: RotatedBox(
            quarterTurns: 3, // Rotaciona 270 graus para orientação vertical (de baixo para cima)
            child: Selector<MediaProvider, double>(
              selector: (_, provider) => provider.filterParams['eqBand8']!,
              builder: (_, value, __) => Slider(
                value: SliderValue.single(value),
                min: 0.0,
                max: 4.0,
                divisions: 100,
                // label: _value.round().toString(),
                onChanged: (value) => Provider.of<MediaProvider>(context, listen: false).setFilterParam('eqBand8', value.value),
              ),
            ),
          ),
        ),
        Selector<MediaProvider, bool>(
          selector: (_, provider) => provider.filterStates['eq']!,
          builder: (_, isActive, __) =>
              Toggle(value: isActive, child: Text(isActive ? 'Biquad On' : 'Biquad Off'), onChanged: (_) => Provider.of<MediaProvider>(context, listen: false).toggleFilter('eq')),
        ),
      ],
    );
  }
}

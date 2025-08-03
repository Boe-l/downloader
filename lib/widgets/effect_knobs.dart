import 'package:boel_downloader/services/media_provider.dart';
import 'package:flutter_dial_knob/flutter_dial_knob.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

class EffectKnobs extends StatelessWidget {
  const EffectKnobs({super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Expanded(
            child: Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: [
                // Biquad Filter
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Card(
                    child: Column(
                      children: [
                        const Text('Biquad Filter'),
                        Selector<MediaProvider, double>(
                          selector: (_, provider) => provider.currentMedia!.filterParams['biquadFrequency']!,
                          builder: (_, value, __) => Tooltip(
                            // message: 'Biquad Frequency',
                            tooltip: (context) => Text('Biquad Frequency'),
                            child: DialKnob(
                              value: value,
                              onChanged: (value) => Provider.of<MediaProvider>(context, listen: false).currentMedia!.setFilterParam('biquadFrequency', value),
                              min: 0.0,
                              max: 22050.0,
                              size: 50,
                              trackColor: Colors.gray,
                              levelColorStart: Colors.green,
                              levelColorEnd: Colors.red,
                              knobColor: Colors.blue,
                              indicatorColor: Colors.white,
                            ),
                          ),
                        ),
                        Selector<MediaProvider, double>(
                          selector: (_, provider) => provider.currentMedia!.filterParams['biquadResonance']!,
                          builder: (_, value, __) => Tooltip(
                            // message: 'Biquad Resonance',
                            tooltip: (context) => Text('Biquad Resonance'),
                            child: DialKnob(
                              value: value,
                              onChanged: (value) => Provider.of<MediaProvider>(context, listen: false).currentMedia!.setFilterParam('biquadResonance', value),
                              min: 0.1,
                              max: 10.0,
                              size: 50,
                              trackColor: Colors.gray,
                              levelColorStart: Colors.green,
                              levelColorEnd: Colors.red,
                              knobColor: Colors.blue,
                              indicatorColor: Colors.white,
                            ),
                          ),
                        ),
                        Selector<MediaProvider, bool>(
                          selector: (_, provider) => provider.currentMedia!.filterStates['biquad']!,
                          builder: (_, isActive, __) => Toggle(
                            value: isActive,
                            child: Text(isActive ? 'Biquad On' : 'Biquad Off'),
                            onChanged: (_) => Provider.of<MediaProvider>(context, listen: false).currentMedia!.toggleFilter('biquad'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Echo Filter
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Card(
                    child: Column(
                      children: [
                        const Text('Echo Filter'),
                        Selector<MediaProvider, double>(
                          selector: (_, provider) => provider.currentMedia!.filterParams['echoWet']!,
                          builder: (_, value, __) => Tooltip(
                            // message: 'Echo Wet',
                            tooltip: (context) => Text('Echo Wet'),
                            child: DialKnob(
                              value: value,
                              onChanged: (value) => Provider.of<MediaProvider>(context, listen: false).currentMedia!.setFilterParam('echoWet', value),
                              min: 0.0,
                              max: 1.0,
                              size: 50,
                              trackColor: Colors.gray,
                              levelColorStart: Colors.green,
                              levelColorEnd: Colors.red,
                              knobColor: Colors.blue,
                              indicatorColor: Colors.white,
                            ),
                          ),
                        ),
                        Selector<MediaProvider, double>(
                          selector: (_, provider) => provider.currentMedia!.filterParams['echoDelay']!,
                          builder: (_, value, __) => Tooltip(
                            // message: 'Echo Delay',
                            tooltip: (context) => Text('Echo Delay'),
                            child: DialKnob(
                              value: value,
                              onChanged: (value) => Provider.of<MediaProvider>(context, listen: false).currentMedia!.setFilterParam('echoDelay', value),
                              min: 0.0,
                              max: 1.0,
                              size: 50,
                              trackColor: Colors.gray,
                              levelColorStart: Colors.green,
                              levelColorEnd: Colors.red,
                              knobColor: Colors.blue,
                              indicatorColor: Colors.white,
                            ),
                          ),
                        ),
                        Selector<MediaProvider, double>(
                          selector: (_, provider) => provider.currentMedia!.filterParams['echoDecay']!,
                          builder: (_, value, __) => Tooltip(
                            // message: 'Echo Decay',
                            tooltip: (context) => Text('Echo Decay'),
                            child: DialKnob(
                              value: value,
                              onChanged: (value) => Provider.of<MediaProvider>(context, listen: false).currentMedia!.setFilterParam('echoDecay', value),
                              min: 0.0,
                              max: 1.0,
                              size: 50,
                              trackColor: Colors.gray,
                              levelColorStart: Colors.green,
                              levelColorEnd: Colors.red,
                              knobColor: Colors.blue,
                              indicatorColor: Colors.white,
                            ),
                          ),
                        ),
                        Selector<MediaProvider, bool>(
                          selector: (_, provider) => provider.currentMedia!.filterStates['echo']!,
                          builder: (_, isActive, __) => Toggle(
                            value: isActive,
                            child: Text(isActive ? 'Echo On' : 'Echo Off'),
                            onChanged: (_) => Provider.of<MediaProvider>(context, listen: false).currentMedia!.toggleFilter('echo'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Freeverb Filter
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Card(
                    child: Column(
                      children: [
                        const Text('Freeverb Filter'),
                        Selector<MediaProvider, double>(
                          selector: (_, provider) => provider.currentMedia!.filterParams['freeverbWet']!,
                          builder: (_, value, __) => Tooltip(
                            // message: 'Freeverb Wet',
                            tooltip: (context) => Text('Freeverb Wet'),
                            child: DialKnob(
                              value: value,
                              onChanged: (value) => Provider.of<MediaProvider>(context, listen: false).currentMedia!.setFilterParam('freeverbWet', value),
                              min: 0.0,
                              max: 1.0,
                              size: 50,
                              trackColor: Colors.gray,
                              levelColorStart: Colors.green,
                              levelColorEnd: Colors.red,
                              knobColor: Colors.blue,
                              indicatorColor: Colors.white,
                            ),
                          ),
                        ),
                        Selector<MediaProvider, double>(
                          selector: (_, provider) => provider.currentMedia!.filterParams['freeverbRoomSize']!,
                          builder: (_, value, __) => Tooltip(
                            // message: 'Freeverb Room Size',
                            tooltip: (context) => Text('Freeverb Room Size'),
                            child: DialKnob(
                              value: value,
                              onChanged: (value) => Provider.of<MediaProvider>(context, listen: false).currentMedia!.setFilterParam('freeverbRoomSize', value),
                              min: 0.0,
                              max: 1.0,
                              size: 50,
                              trackColor: Colors.gray,
                              levelColorStart: Colors.green,
                              levelColorEnd: Colors.red,
                              knobColor: Colors.blue,
                              indicatorColor: Colors.white,
                            ),
                          ),
                        ),
                        Selector<MediaProvider, double>(
                          selector: (_, provider) => provider.currentMedia!.filterParams['freeverbDamping']!,
                          builder: (_, value, __) => Tooltip(
                            // message: 'Freeverb Damping',
                            tooltip: (context) => Text('Freeverb Damping'),
                            child: DialKnob(
                              value: value,
                              onChanged: (value) => Provider.of<MediaProvider>(context, listen: false).currentMedia!.setFilterParam('freeverbDamping', value),
                              min: 0.0,
                              max: 1.0,
                              size: 50,
                              trackColor: Colors.gray,
                              levelColorStart: Colors.green,
                              levelColorEnd: Colors.red,
                              knobColor: Colors.blue,
                              indicatorColor: Colors.white,
                            ),
                          ),
                        ),
                        Selector<MediaProvider, double>(
                          selector: (_, provider) => provider.currentMedia!.filterParams['freeverbWidth']!,
                          builder: (_, value, __) => Tooltip(
                            // message: 'Freeverb Width',
                            tooltip: (context) => Text('Freeverb Width'),
                            child: DialKnob(
                              value: value,
                              onChanged: (value) => Provider.of<MediaProvider>(context, listen: false).currentMedia!.setFilterParam('freeverbWidth', value),
                              min: 0.0,
                              max: 1.0,
                              size: 50,
                              trackColor: Colors.gray,
                              levelColorStart: Colors.green,
                              levelColorEnd: Colors.red,
                              knobColor: Colors.blue,
                              indicatorColor: Colors.white,
                            ),
                          ),
                        ),
                        Selector<MediaProvider, bool>(
                          selector: (_, provider) => provider.currentMedia!.filterStates['freeverb']!,
                          builder: (_, isActive, __) => Toggle(
                            value: isActive,
                            child: Text(isActive ? 'Freeverb On' : 'Freeverb Off'),
                            onChanged: (_) => Provider.of<MediaProvider>(context, listen: false).currentMedia!.toggleFilter('freeverb'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Pitch Shift Filter
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Card(
                    child: Column(
                      children: [
                        const Text('Pitch Shift Filter'),
                        Selector<MediaProvider, double>(
                          selector: (_, provider) => provider.currentMedia!.filterParams['pitchShift']!,
                          builder: (_, value, __) => Tooltip(
                            // message: 'Pitch Shift',
                            tooltip: (context) => Text('Pitch Shift'),

                            child: DialKnob(
                              value: value,
                              onChanged: (value) => Provider.of<MediaProvider>(context, listen: false).currentMedia!.setFilterParam('pitchShift', value),
                              min: 0.0,
                              max: 2.0,
                              size: 50,
                              trackColor: Colors.gray,
                              levelColorStart: Colors.green,
                              levelColorEnd: Colors.red,
                              knobColor: Colors.blue,
                              indicatorColor: Colors.white,
                            ),
                          ),
                        ),
                        Selector<MediaProvider, bool>(
                          selector: (_, provider) => provider.currentMedia!.filterStates['pitchShift']!,
                          builder: (_, isActive, __) => Toggle(
                            value: isActive,
                            child: Text(isActive ? 'Pitch Shift On' : 'Pitch Shift Off'),
                            onChanged: (_) => Provider.of<MediaProvider>(context, listen: false).currentMedia!.toggleFilter('pitchShift'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Flanger Filter
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Card(
                    child: Column(
                      children: [
                        const Text('Flanger Filter'),
                        Selector<MediaProvider, double>(
                          selector: (_, provider) => provider.currentMedia!.filterParams['flangerWet']!,
                          builder: (_, value, __) => Tooltip(
                            // message: 'Flanger Wet',
                            tooltip: (context) => Text('Flanger Wet'),

                            child: DialKnob(
                              value: value,
                              onChanged: (value) => Provider.of<MediaProvider>(context, listen: false).currentMedia!.setFilterParam('flangerWet', value),
                              min: 0.0,
                              max: 1.0,
                              size: 50,
                              trackColor: Colors.gray,
                              levelColorStart: Colors.green,
                              levelColorEnd: Colors.red,
                              knobColor: Colors.blue,
                              indicatorColor: Colors.white,
                            ),
                          ),
                        ),
                        Selector<MediaProvider, double>(
                          selector: (_, provider) => provider.currentMedia!.filterParams['flangerFreq']!,
                          builder: (_, value, __) => Tooltip(
                            // message: 'Flanger Frequency',
                            tooltip: (context) => Text('Flanger Frequency'),

                            child: DialKnob(
                              value: value,
                              onChanged: (value) => Provider.of<MediaProvider>(context, listen: false).currentMedia!.setFilterParam('flangerFreq', value),
                              min: 0.1,
                              max: 10.0,
                              size: 50,
                              trackColor: Colors.gray,
                              levelColorStart: Colors.green,
                              levelColorEnd: Colors.red,
                              knobColor: Colors.blue,
                              indicatorColor: Colors.white,
                            ),
                          ),
                        ),
                        Selector<MediaProvider, double>(
                          selector: (_, provider) => provider.currentMedia!.filterParams['flangerDelay']!,
                          builder: (_, value, __) => Tooltip(
                            // message: 'Flanger Delay',
                            tooltip: (context) => Text('Flanger Delay'),

                            child: DialKnob(
                              value: value,
                              onChanged: (value) => Provider.of<MediaProvider>(context, listen: false).currentMedia!.setFilterParam('flangerDelay', value),
                              min: 0.0001,
                              max: 0.01,
                              size: 50,
                              trackColor: Colors.gray,
                              levelColorStart: Colors.green,
                              levelColorEnd: Colors.red,
                              knobColor: Colors.blue,
                              indicatorColor: Colors.white,
                            ),
                          ),
                        ),
                        Selector<MediaProvider, bool>(
                          selector: (_, provider) => provider.currentMedia!.filterStates['flanger']!,
                          builder: (_, isActive, __) => Toggle(
                            value: isActive,
                            child: Text(isActive ? 'Flanger On' : 'Flanger Off'),
                            onChanged: (_) => Provider.of<MediaProvider>(context, listen: false).currentMedia!.toggleFilter('flanger'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Robotize Filter
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Card(
                    child: Column(
                      children: [
                        const Text('Robotize Filter'),
                        Selector<MediaProvider, bool>(
                          selector: (_, provider) => provider.currentMedia!.filterStates['robotize']!,
                          builder: (_, isActive, __) => Toggle(
                            value: isActive,
                            child: Text(isActive ? 'Robotize On' : 'Robotize Off'),
                            onChanged: (_) => Provider.of<MediaProvider>(context, listen: false).currentMedia!.toggleFilter('robotize'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Bassboost Filter
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Card(
                    child: Column(
                      children: [
                        const Text('Bassboost Filter'),
                        Selector<MediaProvider, double>(
                          selector: (_, provider) => provider.currentMedia!.filterParams['bassboostBoost']!,
                          builder: (_, value, __) => Tooltip(
                            // message: 'Bassboost Boost',
                            tooltip: (context) => Text('Bassboost Boost'),

                            child: DialKnob(
                              value: value,
                              onChanged: (value) => Provider.of<MediaProvider>(context, listen: false).currentMedia!.setFilterParam('bassboostBoost', value),
                              min: 0.0,
                              max: 1.0,
                              size: 50,
                              trackColor: Colors.gray,
                              levelColorStart: Colors.green,
                              levelColorEnd: Colors.red,
                              knobColor: Colors.blue,
                              indicatorColor: Colors.white,
                            ),
                          ),
                        ),
                        Selector<MediaProvider, bool>(
                          selector: (_, provider) => provider.currentMedia!.filterStates['bassboost']!,
                          builder: (_, isActive, __) => Toggle(
                            value: isActive,
                            child: Text(isActive ? 'Bassboost On' : 'Bassboost Off'),
                            onChanged: (_) => Provider.of<MediaProvider>(context, listen: false).currentMedia!.toggleFilter('bassboost'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Lo-Fi Filter
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Card(
                    child: Column(
                      children: [
                        const Text('Lo-Fi Filter'),
                        Selector<MediaProvider, double>(
                          selector: (_, provider) => provider.currentMedia!.filterParams['lofiSampleRate']!,
                          builder: (_, value, __) => Tooltip(
                            // message: 'Lo-Fi Sample Rate',
                            tooltip: (context) => Text('Lo-Fi Sample Rate'),

                            child: DialKnob(
                              value: value,
                              onChanged: (value) => Provider.of<MediaProvider>(context, listen: false).currentMedia!.setFilterParam('lofiSampleRate', value),
                              min: 4000.0,
                              max: 44100.0,
                              size: 50,
                              trackColor: Colors.gray,
                              levelColorStart: Colors.green,
                              levelColorEnd: Colors.red,
                              knobColor: Colors.blue,
                              indicatorColor: Colors.white,
                            ),
                          ),
                        ),
                        Selector<MediaProvider, double>(
                          selector: (_, provider) => provider.currentMedia!.filterParams['lofiBitDepth']!,
                          builder: (_, value, __) => Tooltip(
                            tooltip: (context) => Text('Lo-Fi Bit Depth'),
                            child: DialKnob(
                              value: value,
                              onChanged: (value) => Provider.of<MediaProvider>(context, listen: false).currentMedia!.setFilterParam('lofiBitDepth', value),
                              min: 4.0,
                              max: 16.0,
                              size: 50,
                              trackColor: Colors.gray,
                              levelColorStart: Colors.green,
                              levelColorEnd: Colors.red,
                              knobColor: Colors.blue,
                              indicatorColor: Colors.white,
                            ),
                          ),
                        ),
                        Selector<MediaProvider, double>(
                          selector: (_, provider) => provider.currentMedia!.filterParams['lofiWet']!,
                          builder: (_, value, __) => Tooltip(
                            // message: 'Lo-Fi Wet',
                            tooltip: (context) => Text('Lo-Fi Wet'),
                            child: DialKnob(
                              value: value,
                              onChanged: (value) => Provider.of<MediaProvider>(context, listen: false).currentMedia!.setFilterParam('lofiWet', value),
                              min: 0.0,
                              max: 1.0,
                              size: 50,
                              trackColor: Colors.gray,
                              levelColorStart: Colors.green,
                              levelColorEnd: Colors.red,
                              knobColor: Colors.blue,
                              indicatorColor: Colors.white,
                            ),
                          ),
                        ),
                        Selector<MediaProvider, bool>(
                          selector: (_, provider) => provider.currentMedia!.filterStates['lofi']!,
                          builder: (_, isActive, __) => Toggle(
                            value: isActive,
                            child: Text(isActive ? 'Lo-Fi On' : 'Lo-Fi Off'),
                            onChanged: (_) => Provider.of<MediaProvider>(context, listen: false).currentMedia!.toggleFilter('lofi'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

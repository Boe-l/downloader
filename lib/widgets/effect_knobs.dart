import 'package:boel_downloader/services/media_provider.dart';
import 'package:flutter_dial_knob/flutter_dial_knob.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

class EffectKnobs extends StatelessWidget {
  const EffectKnobs({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Card(
          child: SizedBox(
            width: 1000,
            child: Row(
              // spacing: 0.0,

              // runSpacing: 2.0,
              crossAxisAlignment: CrossAxisAlignment.end,
              // mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Biquad Filter
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Padding(padding: const EdgeInsets.all(8.0), child: const Text('Biquad Filter')),
                        Selector<MediaProvider, double>(
                          selector: (_, provider) => provider.filterParams['biquadFrequency']!,
                          builder: (_, value, __) => Tooltip(
                            // message: 'Biquad Frequency',
                            tooltip: (context) => Card(child: Text('Biquad Frequency')),
                            child: DialKnob(
                              value: value,
                              onChanged: (value) => Provider.of<MediaProvider>(context, listen: false).setFilterParam('biquadFrequency', value),
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
                          selector: (_, provider) => provider.filterParams['biquadResonance']!,
                          builder: (_, value, __) => Tooltip(
                            // message: 'Biquad Resonance',
                            tooltip: (context) => Card(child: Text('Biquad Resonance')),
                            child: DialKnob(
                              value: value,
                              onChanged: (value) => Provider.of<MediaProvider>(context, listen: false).setFilterParam('biquadResonance', value),
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
                          selector: (_, provider) => provider.filterStates['biquad']!,
                          builder: (_, isActive, __) =>
                              Toggle(value: isActive, child: Text(isActive ? 'Biquad On' : 'Biquad Off'), onChanged: (_) => Provider.of<MediaProvider>(context, listen: false).toggleFilter('biquad')),
                        ),
                      ],
                    ),
                  ),
                ),
                // Echo Filter
                SizedBox(width: 1, height: 300, child: VerticalDivider()),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Padding(padding: const EdgeInsets.all(8.0), child: const Text('Echo Filter')),
                        Selector<MediaProvider, double>(
                          selector: (_, provider) => provider.filterParams['echoWet']!,
                          builder: (_, value, __) => Tooltip(
                            // message: 'Echo Wet',
                            tooltip: (context) => Card(child: Text('Echo Wet')),
                            child: DialKnob(
                              value: value,
                              onChanged: (value) => Provider.of<MediaProvider>(context, listen: false).setFilterParam('echoWet', value),
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
                          selector: (_, provider) => provider.filterParams['echoDelay']!,
                          builder: (_, value, __) => Tooltip(
                            // message: 'Echo Delay',
                            tooltip: (context) => Card(child: Text('Echo Delay')),
                            child: DialKnob(
                              value: value,
                              onChanged: (value) => Provider.of<MediaProvider>(context, listen: false).setFilterParam('echoDelay', value),
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
                          selector: (_, provider) => provider.filterParams['echoDecay']!,
                          builder: (_, value, __) => Tooltip(
                            // message: 'Echo Decay',
                            tooltip: (context) => Card(child: Text('Echo Decay')),
                            child: DialKnob(
                              value: value,
                              onChanged: (value) => Provider.of<MediaProvider>(context, listen: false).setFilterParam('echoDecay', value),
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
                          selector: (_, provider) => provider.filterStates['echo']!,
                          builder: (_, isActive, __) =>
                              Toggle(value: isActive, child: Text(isActive ? 'Echo On' : 'Echo Off'), onChanged: (_) => Provider.of<MediaProvider>(context, listen: false).toggleFilter('echo')),
                        ),
                      ],
                    ),
                  ),
                ),
                // Freeverb Filter
                SizedBox(width: 1, height: 300, child: VerticalDivider()),

                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Padding(padding: const EdgeInsets.all(8.0), child: const Text('Freeverb Filter')),
                      Selector<MediaProvider, double>(
                        selector: (_, provider) => provider.filterParams['freeverbWet']!,
                        builder: (_, value, __) => Tooltip(
                          // message: 'Freeverb Wet',
                          tooltip: (context) => Card(child: Text('Freeverb Wet')),
                          child: DialKnob(
                            value: value,
                            onChanged: (value) => Provider.of<MediaProvider>(context, listen: false).setFilterParam('freeverbWet', value),
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
                        selector: (_, provider) => provider.filterParams['freeverbRoomSize']!,
                        builder: (_, value, __) => Tooltip(
                          // message: 'Freeverb Room Size',
                          tooltip: (context) => Card(child: Text('Freeverb Room Size')),
                          child: DialKnob(
                            value: value,
                            onChanged: (value) => Provider.of<MediaProvider>(context, listen: false).setFilterParam('freeverbRoomSize', value),
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
                        selector: (_, provider) => provider.filterParams['freeverbDamping']!,
                        builder: (_, value, __) => Tooltip(
                          // message: 'Freeverb Damping',
                          tooltip: (context) => Card(child: Text('Freeverb Damping')),
                          child: DialKnob(
                            value: value,
                            onChanged: (value) => Provider.of<MediaProvider>(context, listen: false).setFilterParam('freeverbDamping', value),
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
                        selector: (_, provider) => provider.filterParams['freeverbWidth']!,
                        builder: (_, value, __) => Tooltip(
                          // message: 'Freeverb Width',
                          tooltip: (context) => Card(child: Text('Freeverb Width')),
                          child: DialKnob(
                            value: value,
                            onChanged: (value) => Provider.of<MediaProvider>(context, listen: false).setFilterParam('freeverbWidth', value),
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
                        selector: (_, provider) => provider.filterStates['freeverb']!,
                        builder: (_, isActive, __) => Toggle(
                          value: isActive,
                          child: Text(isActive ? 'Freeverb On' : 'Freeverb Off'),
                          onChanged: (_) => Provider.of<MediaProvider>(context, listen: false).toggleFilter('freeverb'),
                        ),
                      ),
                    ],
                  ),
                ),
                // Pitch Shift Filter
                SizedBox(width: 1, height: 300, child: VerticalDivider()),

                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Padding(padding: const EdgeInsets.all(8.0), child: const Text('Pitch Shift Filter')),
                        Selector<MediaProvider, double>(
                          selector: (_, provider) => provider.filterParams['pitchShift']!,
                          builder: (_, value, __) => Tooltip(
                            // message: 'Pitch Shift',
                            tooltip: (context) => Card(child: Text('Pitch Shift')),

                            child: DialKnob(
                              value: value,
                              onChanged: (value) => Provider.of<MediaProvider>(context, listen: false).setFilterParam('pitchShift', value),
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
                          selector: (_, provider) => provider.filterStates['pitchShift']!,
                          builder: (_, isActive, __) => Toggle(
                            value: isActive,
                            child: Text(isActive ? 'Pitch Shift On' : 'Pitch Shift Off'),
                            onChanged: (_) => Provider.of<MediaProvider>(context, listen: false).toggleFilter('pitchShift'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Flanger Filter
                SizedBox(width: 1, height: 300, child: VerticalDivider()),

                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Padding(padding: const EdgeInsets.all(8.0), child: const Text('Flanger Filter')),
                        Selector<MediaProvider, double>(
                          selector: (_, provider) => provider.filterParams['flangerWet']!,
                          builder: (_, value, __) => Tooltip(
                            // message: 'Flanger Wet',
                            tooltip: (context) => Card(child: Text('Flanger Wet')),

                            child: DialKnob(
                              value: value,
                              onChanged: (value) => Provider.of<MediaProvider>(context, listen: false).setFilterParam('flangerWet', value),
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
                          selector: (_, provider) => provider.filterParams['flangerFreq']!,
                          builder: (_, value, __) => Tooltip(
                            // message: 'Flanger Frequency',
                            tooltip: (context) => Card(child: Text('Flanger Frequency')),

                            child: DialKnob(
                              value: value,
                              onChanged: (value) => Provider.of<MediaProvider>(context, listen: false).setFilterParam('flangerFreq', value),
                              min: -48.0,
                              max: 48.0,
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
                          selector: (_, provider) => provider.filterParams['flangerDelay']!,
                          builder: (_, value, __) => Tooltip(
                            // message: 'Flanger Delay',
                            tooltip: (context) => Card(child: Text('Flanger Delay')),

                            child: DialKnob(
                              value: value,
                              onChanged: (value) => Provider.of<MediaProvider>(context, listen: false).setFilterParam('flangerDelay', value),
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
                          selector: (_, provider) => provider.filterStates['flanger']!,
                          builder: (_, isActive, __) => Toggle(
                            value: isActive,
                            child: Text(isActive ? 'Flanger On' : 'Flanger Off'),
                            onChanged: (_) => Provider.of<MediaProvider>(context, listen: false).toggleFilter('flanger'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // // // Robotize Filter
                // // SizedBox(width: 1, height: 300, child: VerticalDivider()),

                // Expanded(
                //   child: Padding(
                //     padding: const EdgeInsets.all(8.0),
                //     child: Column(
                //       children: [
                //         const Text('Robotize Filter'),
                //         Selector<MediaProvider, bool>(
                //           selector: (_, provider) => provider.filterStates['robotize']!,
                //           builder: (_, isActive, __) => Toggle(
                //             value: isActive,
                //             child: Text(isActive ? 'Robotize On' : 'Robotize Off'),
                //             onChanged: (_) => Provider.of<MediaProvider>(context, listen: false).toggleFilter('robotize'),
                //           ),
                //         ),
                //       ],
                //     ),
                //   ),
                // ),
                // Bassboost Filter
                SizedBox(width: 1, height: 300, child: VerticalDivider()),

                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Padding(padding: const EdgeInsets.all(8.0), child: const Text('Bassboost Filter')),
                        Selector<MediaProvider, double>(
                          selector: (_, provider) => provider.filterParams['bassboostBoost']!,
                          builder: (_, value, __) => Tooltip(
                            // message: 'Bassboost Boost',
                            tooltip: (context) => Card(child: Text('Bassboost Boost')),

                            child: DialKnob(
                              value: value,
                              onChanged: (value) => Provider.of<MediaProvider>(context, listen: false).setFilterParam('bassboostBoost', value),
                              min: 0.0,
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
                          selector: (_, provider) => provider.filterStates['bassboost']!,
                          builder: (_, isActive, __) => Toggle(
                            value: isActive,
                            child: Text(isActive ? 'Bassboost On' : 'Bassboost Off'),
                            onChanged: (_) => Provider.of<MediaProvider>(context, listen: false).toggleFilter('bassboost'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Lo-Fi Filter
                SizedBox(width: 1, height: 300, child: VerticalDivider()),

                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Padding(padding: const EdgeInsets.all(8.0), child: const Text('Lo-Fi Filter')),
                        Selector<MediaProvider, double>(
                          selector: (_, provider) => provider.filterParams['lofiSampleRate']!,
                          builder: (_, value, __) => Tooltip(
                            // message: 'Lo-Fi Sample Rate',
                            tooltip: (context) => Card(child: Text('Lo-Fi Sample Rate')),

                            child: DialKnob(
                              value: value,
                              onChanged: (value) => Provider.of<MediaProvider>(context, listen: false).setFilterParam('lofiSampleRate', value),
                              min: 100.0,
                              max: 22000.0,
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
                          selector: (_, provider) => provider.filterParams['lofiBitDepth']!,
                          builder: (_, value, __) => Tooltip(
                            tooltip: (context) => Card(child: Text('Lo-Fi Bit Depth')),
                            child: DialKnob(
                              value: value,
                              onChanged: (value) => Provider.of<MediaProvider>(context, listen: false).setFilterParam('lofiBitDepth', value),
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
                          selector: (_, provider) => provider.filterParams['lofiWet']!,
                          builder: (_, value, __) => Tooltip(
                            // message: 'Lo-Fi Wet',
                            tooltip: (context) => Card(child: Text('Lo-Fi Wet')),
                            child: DialKnob(
                              value: value,
                              onChanged: (value) => Provider.of<MediaProvider>(context, listen: false).setFilterParam('lofiWet', value),
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
                          selector: (_, provider) => provider.filterStates['lofi']!,
                          builder: (_, isActive, __) =>
                              Toggle(value: isActive, child: Text(isActive ? 'Lo-Fi On' : 'Lo-Fi Off'), onChanged: (_) => Provider.of<MediaProvider>(context, listen: false).toggleFilter('lofi')),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

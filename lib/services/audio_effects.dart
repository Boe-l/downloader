import 'package:flutter_soloud/flutter_soloud.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AudioEffects {
  SoLoud? _soloud;

  final Map<String, bool> _filterStates = {'biquad': false, 'echo': false, 'freeverb': false, 'pitchShift': false, 'flanger': false, 'robotize': false, 'bassboost': false, 'lofi': false, 'eq': false};

  final Map<String, double> _filterParams = {
    'biquadFrequency': 1000.0,
    'biquadResonance': 1.0,
    'echoWet': 0.5,
    'echoDelay': 0.5,
    'echoDecay': 0.5,
    'freeverbWet': 0.2,
    'freeverbRoomSize': 0.9,
    'freeverbDamping': 0.5,
    'freeverbWidth': 1.0,
    'pitchShift': 1.2,
    'flangerWet': 0.5,
    'flangerFreq': 1.0,
    'flangerDelay': 0.002,
    'bassboostBoost': 0.5,
    'lofiSampleRate': 8000.0,
    'lofiBitDepth': 8.0,
    'lofiWet': 0.5,
    'eqBand1': 2.0,
    'eqBand2': 2.0,
    'eqBand3': 2.0,
    'eqBand4': 2.0,
    'eqBand5': 2.0,
    'eqBand6': 2.0,
    'eqBand7': 2.0,
    'eqBand8': 2.0,
  };

  Map<String, bool> get filterStates => _filterStates;
  Map<String, double> get filterParams => _filterParams;

  void setSoLoud(SoLoud soloud) {
    _soloud = soloud;
  }

  Future<void> loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    _filterStates.forEach((key, _) {
      final value = prefs.getBool('filter_$key');
      if (value != null) _filterStates[key] = value;
    });
    _filterParams.forEach((key, _) {
      final value = prefs.getDouble('param_$key');
      if (value != null) _filterParams[key] = value;
    });
  }

  Future<void> savePrefs() async {
    final prefs = await SharedPreferences.getInstance();
    _filterStates.forEach((key, value) {
      prefs.setBool('filter_$key', value);
    });
    _filterParams.forEach((key, value) {
      prefs.setDouble('param_$key', value);
    });
  }

  Future<void> toggleFilter(String filter) async {
    _filterStates[filter] = !_filterStates[filter]!;
    if (_filterStates[filter]!) {
      switch (filter) {
        case 'biquad':
          _soloud!.filters.biquadResonantFilter.activate();
          _soloud!.filters.biquadResonantFilter.frequency.value = _filterParams['biquadFrequency']!;
          _soloud!.filters.biquadResonantFilter.resonance.value = _filterParams['biquadResonance']!;
          break;
        case 'echo':
          _soloud!.filters.echoFilter.activate();
          _soloud!.filters.echoFilter.wet.value = _filterParams['echoWet']!;
          _soloud!.filters.echoFilter.delay.value = _filterParams['echoDelay']!;
          _soloud!.filters.echoFilter.decay.value = _filterParams['echoDecay']!;
          break;
        case 'freeverb':
          _soloud!.filters.freeverbFilter.activate();
          _soloud!.filters.freeverbFilter.wet.value = _filterParams['freeverbWet']!;
          _soloud!.filters.freeverbFilter.roomSize.value = _filterParams['freeverbRoomSize']!;
          _soloud!.filters.freeverbFilter.damp.value = _filterParams['freeverbDamping']!;
          _soloud!.filters.freeverbFilter.width.value = _filterParams['freeverbWidth']!;
          break;
        case 'pitchShift':
          _soloud!.filters.pitchShiftFilter.activate();
          _soloud!.filters.pitchShiftFilter.shift.value = _filterParams['pitchShift']!;
          break;
        case 'flanger':
          _soloud!.filters.flangerFilter.activate();
          _soloud!.filters.flangerFilter.wet.value = _filterParams['flangerWet']!;
          _soloud!.filters.flangerFilter.freq.value = _filterParams['flangerFreq']!;
          _soloud!.filters.flangerFilter.delay.value = _filterParams['flangerDelay']!;
          break;
        case 'robotize':
          _soloud!.filters.robotizeFilter.activate();
          break;
        case 'bassboost':
          _soloud!.filters.bassBoostFilter.activate();
          _soloud!.filters.bassBoostFilter.boost.value = _filterParams['bassboostBoost']!;
          break;
        case 'lofi':
          _soloud!.filters.lofiFilter.activate();
          _soloud!.filters.lofiFilter.samplerate.value = _filterParams['lofiSampleRate']!;
          _soloud!.filters.lofiFilter.bitdepth.value = _filterParams['lofiBitDepth']!;
          _soloud!.filters.lofiFilter.wet.value = _filterParams['lofiWet']!;
          break;
        case 'eq':
          _soloud!.filters.equalizerFilter.activate();
          _soloud!.filters.equalizerFilter.band1.value = _filterParams['eqBand1']!;
          _soloud!.filters.equalizerFilter.band2.value = _filterParams['eqBand2']!;
          _soloud!.filters.equalizerFilter.band3.value = _filterParams['eqBand3']!;
          _soloud!.filters.equalizerFilter.band4.value = _filterParams['eqBand4']!;
          _soloud!.filters.equalizerFilter.band5.value = _filterParams['eqBand5']!;
          _soloud!.filters.equalizerFilter.band6.value = _filterParams['eqBand6']!;
          _soloud!.filters.equalizerFilter.band7.value = _filterParams['eqBand7']!;
          _soloud!.filters.equalizerFilter.band8.value = _filterParams['eqBand8']!;
          _soloud!.filters.equalizerFilter.wet.value = 1;
          break;
      }
    } else {
      switch (filter) {
        case 'biquad':
          _soloud!.filters.biquadResonantFilter.deactivate();
          break;
        case 'echo':
          _soloud!.filters.echoFilter.deactivate();
          break;
        case 'freeverb':
          _soloud!.filters.freeverbFilter.deactivate();
          break;
        case 'pitchShift':
          _soloud!.filters.pitchShiftFilter.deactivate();
          break;
        case 'flanger':
          _soloud!.filters.flangerFilter.deactivate();
          break;
        case 'robotize':
          _soloud!.filters.robotizeFilter.deactivate();
          break;
        case 'bassboost':
          _soloud!.filters.bassBoostFilter.deactivate();
          break;
        case 'lofi':
          _soloud!.filters.lofiFilter.deactivate();
          break;
        case 'eq':
          _soloud!.filters.equalizerFilter.deactivate();
          break;
      }
    }
  }

  Future<void> setFilterParam(String param, double value) async {
    final constraints = {
      'biquadFrequency': [0.0, 22050.0],
      'biquadResonance': [0.1, 10.0],
      'echoWet': [0.0, 1.0],
      'echoDelay': [0.0, 1.0],
      'echoDecay': [0.0, 1.0],
      'freeverbWet': [0.0, 1.0],
      'freeverbRoomSize': [0.0, 1.0],
      'freeverbDamping': [0.0, 1.0],
      'freeverbWidth': [0.0, 1.0],
      'pitchShift': [0.5, 2.0],
      'flangerWet': [0.0, 1.0],
      'flangerFreq': [0.1, 10.0],
      'flangerDelay': [0.0001, 0.01],
      'bassboostBoost': [0.0, 1.0],
      'lofiSampleRate': [4000.0, 44100.0],
      'lofiBitDepth': [4.0, 16.0],
      'lofiWet': [0.0, 4.0],
      'eqBand1': [0.0, 4.0],
      'eqBand2': [0.0, 4.0],
      'eqBand3': [0.0, 4.0],
      'eqBand4': [0.0, 4.0],
      'eqBand5': [0.0, 4.0],
      'eqBand6': [0.0, 4.0],
      'eqBand7': [0.0, 4.0],
      'eqBand8': [0.0, 4.0],
    };

    final paramToFilter = {
      'biquadFrequency': 'biquad',
      'biquadResonance': 'biquad',
      'echoWet': 'echo',
      'echoDelay': 'echo',
      'echoDecay': 'echo',
      'freeverbWet': 'freeverb',
      'freeverbRoomSize': 'freeverb',
      'freeverbDamping': 'freeverb',
      'freeverbWidth': 'freeverb',
      'pitchShift': 'pitchShift',
      'flangerWet': 'flanger',
      'flangerFreq': 'flanger',
      'flangerDelay': 'flanger',
      'bassboostBoost': 'bassboost',
      'lofiSampleRate': 'lofi',
      'lofiBitDepth': 'lofi',
      'lofiWet': 'lofi',
      'eqBand1': 'eq',
      'eqBand2': 'eq',
      'eqBand3': 'eq',
      'eqBand4': 'eq',
      'eqBand5': 'eq',
      'eqBand6': 'eq',
      'eqBand7': 'eq',
      'eqBand8': 'eq',
    };

    _filterParams[param] = value.clamp(constraints[param]![0], constraints[param]![1]);
    final filter = paramToFilter[param];
    if (filter != null && _filterStates[filter] == true) {
      switch (param) {
        case 'biquadFrequency':
          _soloud!.filters.biquadResonantFilter.frequency.value = value;
          break;
        case 'biquadResonance':
          _soloud!.filters.biquadResonantFilter.resonance.value = value;
          break;
        case 'echoWet':
          _soloud!.filters.echoFilter.wet.value = value;
          break;
        case 'echoDelay':
          _soloud!.filters.echoFilter.delay.value = value;
          break;
        case 'echoDecay':
          _soloud!.filters.echoFilter.decay.value = value;
          break;
        case 'freeverbWet':
          _soloud!.filters.freeverbFilter.wet.value = value;
          break;
        case 'freeverbRoomSize':
          _soloud!.filters.freeverbFilter.roomSize.value = value;
          break;
        case 'freeverbDamping':
          _soloud!.filters.freeverbFilter.damp.value = value;
          break;
        case 'freeverbWidth':
          _soloud!.filters.freeverbFilter.width.value = value;
          break;
        case 'pitchShift':
          _soloud!.filters.pitchShiftFilter.shift.value = value;
          break;
        case 'flangerWet':
          _soloud!.filters.flangerFilter.wet.value = value;
          break;
        case 'flangerFreq':
          _soloud!.filters.flangerFilter.freq.value = value;
          break;
        case 'flangerDelay':
          _soloud!.filters.flangerFilter.delay.value = value;
          break;
        case 'bassboostBoost':
          _soloud!.filters.bassBoostFilter.boost.value = value;
          break;
        case 'lofiSampleRate':
          _soloud!.filters.lofiFilter.samplerate.value = value;
          break;
        case 'lofiBitDepth':
          _soloud!.filters.lofiFilter.bitdepth.value = value;
          break;
        case 'lofiWet':
          _soloud!.filters.lofiFilter.wet.value = value;
          break;
        case 'eqBand1':
          _soloud!.filters.equalizerFilter.band1.value = value;
          break;
        case 'eqBand2':
          _soloud!.filters.equalizerFilter.band2.value = value;
          break;
        case 'eqBand3':
          _soloud!.filters.equalizerFilter.band3.value = value;
          break;
        case 'eqBand4':
          _soloud!.filters.equalizerFilter.band4.value = value;
          break;
        case 'eqBand5':
          _soloud!.filters.equalizerFilter.band5.value = value;
          break;
        case 'eqBand6':
          _soloud!.filters.equalizerFilter.band6.value = value;
          break;
        case 'eqBand7':
          _soloud!.filters.equalizerFilter.band7.value = value;
          break;
        case 'eqBand8':
          _soloud!.filters.equalizerFilter.band8.value = value;
          break;
      }
    }
  }

  void applyActiveFilters() {
    _filterStates.forEach((filter, active) {
      if (active) toggleFilter(filter);
    });
  }
}

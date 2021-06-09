import 'constants.dart';
import 'models/sample_descriptor.dart';

/// The base class for Instruments.
abstract class Instrument  {
  final String idOrPath;
  final bool isAsset;
  final int presetIndex;
  final int bankIndex;

  Instrument(this.idOrPath, this.isAsset, { this.presetIndex = DEFAULT_PATCH_NUMBER, this.bankIndex = DEFAULT_BANK_NUMBER });

  String get displayName {
    return idOrPath.split(RegExp('[\\\\/]')).last;
  }
}

/// Describes a sampler instrument. Use this to create a sampler dynamically.
/// Will be played by the AudioKit Sampler on Android and iOS.
class SamplerInstrument extends Instrument {
  final List<SampleDescriptor> sampleDescriptors;

  SamplerInstrument({ required String id, required this.sampleDescriptors }) : super(id, false);
}

/// Describes an instrument in SFZ format. The SFZ will be parsed and used to
/// create a SamplerInstrument.
class SfzInstrument extends Instrument {
  SfzInstrument({ required String path, required bool isAsset })
    : super(path, isAsset);
}

/// Describes an instrument in SF2 format. Will be played by the SoundFont
/// player for the current platform.
class Sf2Instrument extends Instrument {
  Sf2Instrument({ required String path, required bool isAsset, int presetIndex = DEFAULT_PATCH_NUMBER })
    : super(path, isAsset, presetIndex: presetIndex);
}

/// Describes a channel for an existing SF2 track - played by the SoundFont
/// player for the current platform.
// class Sf2Channel extends Instrument {
//   Sf2Channel({ String path, bool isAsset, int presetIndex = DEFAULT_PATCH_NUMBER, int bankIndex = DEFAULT_BANK_NUMBER })
//       : super(path, isAsset, presetIndex: presetIndex, bankIndex: bankIndex);
// }

/// Describes an AudioUnit instrument (Apple platforms only.)
class AudioUnitInstrument extends Instrument {
  AudioUnitInstrument({ required String manufacturerName, required String componentName })
    : super('$manufacturerName.$componentName', false);
}

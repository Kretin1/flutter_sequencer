import AVFoundation

func isAppleSampler(component: AVAudioUnitComponent) -> Bool {
    let isApple = component.audioComponentDescription.componentManufacturer == kAudioUnitManufacturer_Apple
    let isMIDISynth = component.audioComponentDescription.componentSubType == kAudioUnitSubType_MIDISynth

    return isApple && isMIDISynth
}

func loadSoundFont(avAudioUnit: AVAudioUnit, soundFontURL: URL, presetIndex: Int32) {
    let audioUnit = avAudioUnit.audioUnit
    var mutableSoundFontURL = soundFontURL
    
    // Load SoundFont
    var result = AudioUnitSetProperty(audioUnit,
                                 AudioUnitPropertyID(kMusicDeviceProperty_SoundBankURL),
                                 AudioUnitScope(kAudioUnitScope_Global),
                                 0,
                                 &mutableSoundFontURL,
                                 UInt32(MemoryLayout.size(ofValue: mutableSoundFontURL)))
    assert(result == noErr, "SoundFont could not be loaded")

    var enabled = UInt32(1)
    
    // Enable preload
    result = AudioUnitSetProperty(audioUnit,
                                  AudioUnitPropertyID(kAUMIDISynthProperty_EnablePreload),
                                  AudioUnitScope(kAudioUnitScope_Global),
                                  0,
                                  &enabled,
                                  UInt32(MemoryLayout.size(ofValue: enabled)))
    assert(result == noErr, "Preload could not be enabled")
    
    // Send program change command for patch 0 to preload
    let channel = UInt32(0)
    let pcCommand = UInt32(0xC0 | channel)
    let patch1 = UInt32(presetIndex)
    result = MusicDeviceMIDIEvent(audioUnit, pcCommand, patch1, 0, 0)
    assert(result == noErr, "Patch could not be preloaded")
    
    // Disable preload
    enabled = UInt32(0)
    result = AudioUnitSetProperty(audioUnit,
                                  AudioUnitPropertyID(kAUMIDISynthProperty_EnablePreload),
                                  AudioUnitScope(kAudioUnitScope_Global),
                                  0,
                                  &enabled,
                                  UInt32(MemoryLayout.size(ofValue: enabled)))

    assert(result == noErr, "Preload could not be disabled")

    result = MusicDeviceMIDIEvent(audioUnit, pcCommand, patch1, 0, 0)
    assert(result == noErr, "Patch could not be changed")
}

func loadPatches(avAudioUnit: AVAudioUnit, patches: [UInt32]) {
        
    if !isGraphInitialized() {
        fatalError("initialize graph first")
    }
        
    //let channel = UInt32(0)
    var enabled = UInt32(1)
    var result = AudioUnitSetProperty(
        avAudioUnit,
        AudioUnitPropertyID(kAUMIDISynthProperty_EnablePreload),
        AudioUnitScope(kAudioUnitScope_Global),
        0,
        &enabled,
        UInt32(sizeof(UInt32)))
    //AudioUtils.CheckError(status)
    assert(result == noErr, "Preload could not be enabled")
    
    for (index, element) in patches.enumerated() {
        //print(index, ":", element)
        let channel = UInt32(index)
        let patch = UInt32(element)
        let pcCommand = UInt32(0xC0 | channel)
        result = MusicDeviceMIDIEvent(self.midisynthUnit, pcCommand, patch, 0, 0)
        assert(result == noErr, "Patch could not be preloaded")
    }
        
    enabled = UInt32(0)
    result = AudioUnitSetProperty(
        avAudioUnit,
        AudioUnitPropertyID(kAUMIDISynthProperty_EnablePreload),
        AudioUnitScope(kAudioUnitScope_Global),
        0,
        &enabled,
        UInt32(sizeof(UInt32)))
    assert(result == noErr, "Preload could not be disabled")
}

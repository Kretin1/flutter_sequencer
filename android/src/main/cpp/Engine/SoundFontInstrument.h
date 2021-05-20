#ifndef SOUND_FONT_INSTRUMENT_H
#define SOUND_FONT_INSTRUMENT_H

#include "IInstrument.h"
#include "../Utils/AssetManager.h"

#define TSF_IMPLEMENTATION
#include "tsf.h"

class SoundFontInstrument : public IInstrument {
public:
    int presetIndex;

    SoundFontInstrument(int32_t sampleRate, bool isStereo, const char* path, bool isAsset, int32_t presetIndex) {
        this->presetIndex = presetIndex;

        if (isAsset) {
            auto asset = openAssetBuffer(path);
            auto assetBuffer = AAsset_getBuffer(asset);
            auto assetLength = AAsset_getLength(asset);

            mTsf = tsf_load_memory(assetBuffer, assetLength);

            AAsset_close(asset);
        } else {
            mTsf = tsf_load_filename(path);
        }

        tsf_set_output(mTsf, isStereo ? TSF_STEREO_INTERLEAVED : TSF_MONO, sampleRate);
    }

    ~SoundFontInstrument() {
        tsf_close(mTsf);
    }

    void renderAudio(float *audioData, int32_t numFrames) override {
        tsf_render_float(mTsf, audioData, numFrames);
    }

    void handleMidiEvent(uint8_t status, uint8_t data1, uint8_t data2, uint8_t channel) override {
        if (status == 0xC0) {
            // Program Change
            tsf_channel_set_presetnumber(mTsf, channel, data1, data2);
        }
        else if (status == 0x90) {
            // Note On
            tsf_channel_note_on(mTsf, channel, data1, data2 / 127.0f);
            //tsf_note_on(mTsf, presetIndex, data1, data2 / 255.0);
        }
        else if (status == 0x80) {
            // Note Off
            tsf_channel_note_off(mTsf, channel, data1);
            //tsf_note_off(mTsf, presetIndex, data1);
        }
        else if (status == 0xB0) {
            // Control
            tsf_channel_midi_control(mTsf, channel, data1, data2);
        }
    }

    void reset() override {
    }

private:
    tsf* mTsf;
};

#endif //SOUND_FONT_INSTRUMENT_H

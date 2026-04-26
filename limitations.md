# Limits of Godot

## Text

- Labels
- RichTextLabel
- TextEdit
- CodeEdit

## Audio

- [AudioStream](https://docs.godotengine.org/en/stable/classes/class_audiostream.html#class-audiostream) - `Base class for audio streams. Audio streams are used for sound effects and music playback, and support WAV (via AudioStreamWAV) and Ogg (via AudioStreamOggVorbis) file formats.`
- [AudioStreamMP3](https://docs.godotengine.org/en/stable/classes/class_audiostreammp3.html#class-audiostreammp3) - `Note: This class can optionally support legacy MP1 and MP2 formats, provided that the engine is compiled with the minimp3_extra_formats=yes SCons option. These extra formats are not enabled by default.`
- AudioStreamMP3, AudioStreamOggVorbis, AudioStreamWAV have been implemented
- -> no support for .flac, .aac

## Image

- as we're using TextureRect, which in turn use Texture2D - `Note: The maximum texture size is 16384×16384 pixels due to graphics hardware limitations. Larger textures may fail to import.`
- [Documentation](https://docs.godotengine.org/en/stable/tutorials/assets_pipeline/importing_images.html)

## Video

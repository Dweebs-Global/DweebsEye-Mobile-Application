# DweebsEye-Mobile-Application
=======
## mic_speech

Takes audio input with the microphone and displaying the recognised words.

Uses (speech_to_text 3.1.0)[https://pub.dev/packages/speech_to_text] package for speech recognition.

Tap the microphone button and say something. Above the button you will see the recognised text or an error message. The app listens for 5 seconds. **Continuous listening is not supported** by this or other speech recognition packages. The user has to invoke listening (it could be a huge button in the middle of a screen or touching of any part of the screen).

## speaker_audio

Gives speaker output based on the contents of mic input.

Uses (flutter_tts 2.1.0)[https://pub.dev/packages/flutter_tts] package for text-to-speech.

After taking mic input the button becomes disabled, the input gets filtered in commands.dart function ```checkCommand()``` and either returns the command description (for words "object" and "face") or returns what the user had said. When the audio stops playing, the mic button becomes enabled again.

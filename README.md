# DweebsEye-Mobile-Application
=======
## mic_speech

A basic app taking audio input with the microphone and displaying the recognised words.

Uses (speech_to_text 3.1.0)[https://pub.dev/packages/speech_to_text] package for speech recognition.

Tap the microphone button and say something. Above the button you will see the recognised text or an error message. The app listens for 5 seconds. **Continuous listening is not supported** by this or other speech recognition packages. The user has to invoke listening (it could be a huge button in the middle of a screen or touching of any part of the screen).

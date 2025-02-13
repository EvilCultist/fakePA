import sounddevice as sd
import speech_recognition as sr
import pyttsx3
from scipy.io.wavfile import write
import whisper

fs = 44100
seconds = 6

model = whisper.load_model("medium")
engine = pyttsx3.init()

def listen(s = seconds):
    print("speak")
    myrecording = sd.rec(int(seconds * fs), samplerate=fs, channels=2)
    sd.wait()  # Wait until recording is finished
    print("thank you")
    write('output.wav', fs, myrecording)  # Save as WAV file


    # model = whisper.load_model("large")

    # load audio and pad/trim it to fit 30 seconds
    audio = whisper.load_audio("output.wav")
    audio = whisper.pad_or_trim(audio)

    # make log-Mel spectrogram and move to the same device as the model
    mel = whisper.log_mel_spectrogram(audio, n_mels=model.dims.n_mels).to(model.device)

    # detect the spoken language
    _, probs = model.detect_language(mel)
    print(f"Detected language: {max(probs, key=probs.get)}")

    # decode the audio
    options = whisper.DecodingOptions()
    result = whisper.decode(model, mel, options)
    return result.text, max(probs, key=probs.get)

# print the recognized text

def speak(audio):
    global engine
    engine.say(audio)
    engine.runAndWait()
    engine.say("")
    engine.runAndWait()

def getSpeech_google():
    r = sr.Recognizer()
    with sr.Microphone() as source:
        speak("Speak mortal")
        r.pause_threshold = 1
        while True:
            print("talk..")
            audio_text = r.listen(source)
            print("you're done")
            try:
                words = r.recognize_google(audio_text, language='en-in')
                print("I heard: ", words)
                return words
            except:
                 print("sorry... I didn't get that")

# # def getSpeech():
# #     r = sr.Recognizer()
# #     with sr.Microphone() as source:
# #         speak("Speak mortal, yo")
# #         speak("What ails you, yo")
# #         r.pause_threshold = 2
# #         while True:
# #             print("talk..")
# #             audio_text = r.listen(source)
# #             print("you're done")
# #             try:
# #                 print("I heard: ", r.recognize_google(audio_text, language='en-in'))
# #                 break
# #             except:
# #                 print("yeah... no dice")
# 
if __name__=='__main__':
    # getSpeech_google()
    speak("How can I help you")
    l = listen()[0]
    print(l)
    speak(l)
    #speak(getSpeech_google())

import speech_recognition as sr
import pyttsx3
import whisper

engine = pyttsx3.init()
#model = whisper.load_model("medium")

model = whisper.load_model("turbo")

# load audio and pad/trim it to fit 30 seconds
audio = whisper.load_audio("audio.mp3")
audio = whisper.pad_or_trim(audio)

# make log-Mel spectrogram and move to the same device as the model
mel = whisper.log_mel_spectrogram(audio, n_mels=model.dims.n_mels).to(model.device)

# detect the spoken language
_, probs = model.detect_language(mel)
print(f"Detected language: {max(probs, key=probs.get)}")

# decode the audio
options = whisper.DecodingOptions()
result = whisper.decode(model, mel, options)

# print the recognized text
print(result.text)

def speak(audio):
    global engine
    engine.say(audio)
    engine.runAndWait()

def getSpeech():
    r = sr.Recognizer()
    with sr.Microphone() as source:
        speak("Speak mortal, yo")
        speak("What ails you, yo")
        r.pause_threshold = 2
        while True:
            print("talk..")
            audio_text = r.listen(source)
            print("you're done")
            try:
                print("I heard: ", r.recognize_google(audio_text, language='en-in'))
                break
            except:
                print("yeah... no dice")

# def getSpeech():
#     r = sr.Recognizer()
#     with sr.Microphone() as source:
#         speak("Speak mortal, yo")
#         speak("What ails you, yo")
#         r.pause_threshold = 2
#         while True:
#             print("talk..")
#             audio_text = r.listen(source)
#             print("you're done")
#             try:
#                 print("I heard: ", r.recognize_google(audio_text, language='en-in'))
#                 break
#             except:
#                 print("yeah... no dice")

# if __name__=='__main__':
#     getSpeech()

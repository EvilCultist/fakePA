import sounddevice as sd
from scipy.io.wavfile import write
import whisper

fs = 44100
seconds = 2

myrecording = sd.rec(int(seconds * fs), samplerate=fs, channels=2)
sd.wait()  # Wait until recording is finished
write('output.wav', fs, myrecording)  # Save as WAV file

# engine = pyttsx3.init()

# model = whisper.load_model("large")
model = whisper.load_model("medium")

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

# print the recognized text
print(result.text)

# def speak(audio):
#     global engine
#     engine.say(audio)
#     engine.runAndWait()
# 
# def getSpeech():
#     r = sr.Recognizer()
#     with sr.Microphone() as source:
#         speak("Speak mortal, yo")
#         speak("What ails you, yo")
#         r.pause_threshold = 1
#         while True:
#             print("talk..")
#             audio_text = r.listen(source)
#             print("you're done")
#             try:
#                 print("I heard: ", r.recognize_google(audio_text, language='en-in'))
#                 break
#             except:
#                 print("yeah... no dice")
# 
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
# if __name__=='__main__':
#     getSpeech()

import speech_recognition as sr

def getSpeech():
    r = sr.Recognizer()
    with sr.Microphone() as source:
        print("talk..")
        audio_text = r.listen(source)
        print("you're done")
        try:
            print("I heard: ", r.recognize_google(audio_text))
        except:
            print("yeah... no dice")

if __name__=='__main__':
    getSpeech()

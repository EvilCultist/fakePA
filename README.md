# fakePA
heath appointment maker

# How to run app

sudo apt install ffmpeg
sudo apt install xawtv-tools
pip install pyaudio, sounddevice
pip install openai-whisper
python3 getData.py
python3 main.py

# How to Use Github

pehle install git
- https://git-scm.com/downloads

then goto wherever you want to download the project, copy waha ka path
eg - c:/users/ec/desktop/iis/project
ye valid windows path nahi hai apna apne hisab se dekho

ctrl + x dabao, usse ek window khulegi
click open powershell as admin
kush windows versions pe open terminal as admin aata hai

enter this - (obviously apne path ke sath)
```
cd c:/users/ec/desktop/iis/project
git clone "https://github.com/EvilCultist/fakePA.git"
```

phir jo download hua hai use vscode/pycharm/jupiter me khol lo
waha se apne ide me git login krna hoga, wo kaise krna hai google kr lo
iski aage ka ignore maro, everything post this is very ide specific

if using vs code, read this from staging and commiting upto and including pushing and pulling
- https://code.visualstudio.com/docs/sourcecontrol/intro-to-git#_staging-and-committing-code-changes

pycharm ka is very to the point pura hi padh lo
- https://www.jetbrains.com/help/pycharm/commit-and-push-changes.html#use-git-staging-area-to-commit-changes

aur kuch use krte ho to khud dhund lo...
me command line use krta hoon to command line ka maine hi likh diya hai


jab kuch change upload(git ki bhasha me ise push kehte hai) krna ho,
to pehle apne changes git me add kro
```
cd c:/users/ec/desktop/iis/project/fakePA
git add .
```
iska tumhare ide me koi button bhi ho sakta hai
like this adds all changes to git
then "save"(files me jo saved hai usi ko git ke sath sync kro basically) this to your local git(isko git ki bhasha me commit kehte hai)
iska button hoga
```
git commit -m "yaha pe kya kiya wo likho"
```

then push to remote origin(iska button hoga)
iska as it is kaam nahi krega, you need to give git your github credentials if you want to push to github via command line, to personal access token(PAN), bnana hoga. uske baad
```
git push
```


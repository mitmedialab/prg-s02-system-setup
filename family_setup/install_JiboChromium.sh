echo -e "${G}Install low version Chromium for Jibo Console${N}"
FILE="/home/prg/chrome-linux.zip"
if [[ ! -f "$FILE" ]]; then
   wget http://commondatastorage.googleapis.com/chromium-browser-snapshots/Linux_x64/629479/chrome-linux.zip -P ~/ 
fi
unzip -qq ~/chrome-linux.zip -d ~/ &&
cp -R -u -p ../src/JiboChromium_logo.png ~/chrome-linux &&
cp -R -u -p ../src/JiboChromium.desktop ~/Desktop &&
echo "OK"

@echo off
cd /d C:\Users\40748\forgemigration_bundle
echo ==== git status ====
git status --short
echo ==== ensure branch ====
git checkout forge-1.20.1-port
echo ==== set remote to HTTPS ====
git remote set-url origin https://github.com/Luoyu1337/Xibao-Plus-Plus_forge.git
git remote -v
echo ==== push ====
git push -u origin forge-1.20.1-port
pause

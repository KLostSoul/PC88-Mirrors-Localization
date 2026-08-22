@echo off
SET ccdFile="Mirrors.ccd"
SET imgFile="Mirrors.img"
SET subFile="Mirrors.sub"
SET enCcdFile="Mirrors eng v1.0.ccd"
SET enImgFile="Mirrors eng v1.0.img"
SET enSubFile="Mirrors eng v1.0.sub"
SET patchCcdFile="MirrorsCCD 1.0.xdelta"
SET patchImgFile="MirrorsIMG 1.0.xdelta"
SET patchSubFile="MirrorsSUB 1.0.xdelta"

if not exist %ccdFile% goto :errorNotFound 
if not exist %imgFile% goto :errorNotFound 
if not exist %subFile% goto :errorNotFound 

echo Patching %ccdFile%...
xdelta.exe -d -f -s  %ccdFile% %patchCcdFile% %enCcdFile%
if errorlevel 1 goto :exit
echo Patching %imgFile%...
xdelta.exe -d -f -s  %imgFile% %patchImgFile% %enImgFile%
if errorlevel 1 goto :exit
echo Patching %subFile%...
xdelta.exe -d -f -s  %subFile% %patchSubFile% %enSubFile%
if errorlevel 1 goto :exit
echo Patching done
goto :exit

:errorNotFound
echo Can't find the files required for patching. Make sure that %ccdFile%, %imgFile% and %subFile% files are located in the same folder as the .bat file.
goto :exit

:exit
echo Press any key...
pause
exit
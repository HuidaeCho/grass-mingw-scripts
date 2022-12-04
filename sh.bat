@echo off
set ENV=%APPDATA%\GRASS8\shrc
if not exist "%ENV%" (
	echo [ -f ~/.shrc ] ^&^& source ~/.shrc
	echo grass_ps(^){
	echo.	g.gisenv LOCATION_NAME,MAPSET sep=/
	echo }
	echo export PS1="\[\033]0;GRASS \$(grass_ps) \w\007\]\w> "
) > "%ENV%"
%GISBASE%\etc\busybox64.exe sh

@echo off& call loadJ.bat DivideStrUtil
::将长字符按照指定宽度(字节长度)进行分割, 单行中若有不足, 使用空格补足
::          √[此类函数变量名约定   _xxxxxx   为了不对调用者变量影响]
::IN[长字符串]    IN[分割值]     OUT[分割后字符串变量名]     OUT[分割数量]
%DivideStrUtil% "%~1" %2>%temp%\_divideStr.txt
set _divideStrIndex=1
for /f "delims=" %%i in (%temp%\_divideStr.txt) do set "%3_!_divideStrIndex!=%%i"& set /a _divideStrIndex+=1
set /a %4=!_divideStrIndex!-1& goto :EOF
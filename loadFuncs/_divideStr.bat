@echo off& call loadJ.bat DivideStrUtil
::�����ַ�����ָ�����(�ֽڳ���)���зָ�, ���������в���, ʹ�ÿո���
::          ��[���ຯ��������Լ��   _xxxxxx   Ϊ�˲��Ե����߱���Ӱ��]
::IN[���ַ���]    IN[�ָ�ֵ]     OUT[�ָ���ַ���������]     OUT[�ָ�����]
%DivideStrUtil% "%~1" %2>%temp%\_divideStr.txt
set _divideStrIndex=1
for /f "delims=" %%i in (%temp%\_divideStr.txt) do set "%3_!_divideStrIndex!=%%i"& set /a _divideStrIndex+=1
set /a %4=!_divideStrIndex!-1& goto :EOF
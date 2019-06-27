@echo off& call load.bat _strlen _strlen2 _infiniteLoopPause& call loadF.bat _params _errorMsg _help _divideStr& call loadE.bat Cext CurS CPaint& setlocal enabledelayedexpansion& title �����¼& color 0A
:::˵��
:::  ����������չʾ���˵������¼
:::�ο�
:::  F:\����\��������\΢�������¼\readme.txt
:::����
:::  [-u1 user1] [-u2 user2] [-c msgColor] [-s startTime] [-e endTime] [-w width] [-h height] [-p pauseTime] chatFilePath
:::      user1 - �û�1�ǳ�, ��[her]
:::      user2 - �û�2�ǳ�, ��[he]
:::      msgColor - ��Ϣ��ɫ, ��Ҫ����, ��[0D0B]
:::      startTime - �����¼��ʼʱ��
:::      endTime - �����¼����ʱ��
:::      width - ��Ļ���
:::      height - ��Ļ�߶�
:::      pauseTime - �������ʱ��
:::      chatFilePath - �����¼�ļ�
:::  [-h help]
:::      help - ��ӡע����Ϣ
:::chatFile��ʽ�淶
:::     2013/11/04#14:18:48#qiao#ok
:::      ����#ʱ��#��ɫ#word
:::TODO
:::  1. chatFile��ʽ�淶�ض���
:::  2. ǰ����Ϣ������С��3����, ��չʾ����ʱ����Ϣ
:::  3. ��΢�Ÿ�����Ϣ������Ϣ��ȡ
:::  4. ֧��startTime\endTime����
::========================= set default param =========================
%CurS% /crv 0
set user1=her
set user2=he
set msgColor=0D0B
set startTime=
set endTime=
set screenWidth=80
set screenHeight=35
set pauseTime=80
set chatFilePath=playChatHistoryDemo.txt
call %_params% %*

::========================= set user param =========================
if defined _param-h (call %_help% "%~f0"& goto :EOF)
if defined _param-help (call %_help% "%~f0"& goto :EOF)
if defined _param-u1 (set user1=%_param-u1%)
if defined _param-u2 (set user2=%_param-u2%)
if defined _param-c (set msgColor=%_param-c%)
if defined _param-s (set startTime=%_param-s%)
if defined _param-e (set endTime=%_param-e%)
if defined _param-w (set screenWidth=%_param-w%)
if defined _param-h (set screenHeight=%_param-h%)
if defined _param-p (set pauseTime=%_param-p%)
if defined _param-0 (
    set chatFilePath=%_param-0%
    if not exist "!chatFilePath!" (call %_errorMsg% %0 "!chatFilePath! FILE NOT EXIST")
)
title [!user1!]��[!user2!]�������¼

::========================= pre-calc =========================
set /a mod=screenWidth%%2& if !mod! NEQ 0 set /a screenWidth+=1
mode !screenWidth!,!screenHeight!
REM cpaint����λ���ǰ�ȫ�Ǽ���, x����Ϊ3, ��ǰ����6������ַ�[�϶���ż��], ��������ǰ����һ���ո���ɫ0Dһ�λ���ɫ2������ַ�, ��Ҫ����2
set /a msgShowLine=0, msgShowLineMax=screenHeight-1

REM user1ǰĬ�ϼ�һ���ո�, ��ȷ��userLen1����Ϊż��ֵ��user2��Ĭ�ϼ�һ���ո񣬲�ȷ��userLen2����Ϊż��ֵ
(%_call% ("user1 userLen1") %_strlen2%)& set userStr1= !user1!& set /a userLen1+=1, mod=userLen1%%2& (if !mod! NEQ 0 set /a userLen1+=1& set userStr1= !userStr1!)
(%_call% ("user2 userLen2") %_strlen2%)& set userStr2=!user2! & set /a userLen2+=1, mod=userLen2%%2& (if !mod! NEQ 0 set /a userLen2+=1& set userStr2=!userStr2! )
set userBlank1=& set userBlank2=& (for /l %%i in (1,1,!userLen1!) do set userBlank1=!userBlank1! )& (for /l %%i in (1,1,!userLen2!) do set userBlank2=!userBlank2! )


REM ��Ļ��һ����Ϣ��󳤶�oneLineMsgLen: ��Ļ��� - �û�1���� - �û�2���� - ��Ϣǰ��߿� - ���۶�������ֵ
set /a oneLineColorNum=(screenWidth-2)/2, oneLineMsgLen=screenWidth-userLen1-userLen2-6-2, oneLineMsgLen2=oneLineMsgLen/2
set msgColor1=!msgColor:~0,2!& if "!msgColor1!" EQU "" set msgColor1=0D
set msgColor2=!msgColor:~2,2!& if "!msgColor2!" EQU "" set msgColor2=0B
set oneLineColor1=& set oneLineColor2=& for /l %%i in (1,1,!oneLineColorNum!) do set oneLineColor1=!oneLineColor1!!msgColor1!& set oneLineColor2=!oneLineColor2!!msgColor2!
(set oneLineMsgBlank=& for /l %%i in (1,1,!oneLineMsgLen!) do set oneLineMsgBlank=!oneLineMsgBlank! )& (set oneLineMsgBorder=& for /l %%i in (1,1,!oneLineMsgLen2!) do set oneLineMsgBorder=!oneLineMsgBorder!��)
set "checkMsgShowLine=if ^!msgShowLine^! EQU ^!msgShowLineMax^! (%Cext% /mov 0 1 ^!screenWidth^! ^!msgShowLineMax^! 0 0) else (set /a msgShowLine+=1)"
for /f "eol=  tokens=1-3* delims=#" %%i in (!chatFilePath!) do (
    if "%%i"=="blankLine" (
        (%checkMsgShowLine%)
    ) else (
        set date=%%i& set time=%%j& set user=%%k& set msg=%%l
        REM ��Ļ��߿�Ϊ[�� ��],��5������ַ�, ������Ļ��ʾ����x��Ϊ5��ʼ, cpaintλ�ð���ȫ�Ǽ�����˳���2
        set timestamp=!date: =! !time: =!& (%_call% ("timestamp len") %_strlen2%)& set /a showXTemp="(screenWidth-len)"/4& %CPaint% !showXTemp! !msgShowLine! "" "!timestamp!"& (%checkMsgShowLine%)
        
        set msg=!msg:^"='!& (%_call% ("msg len") %_strlen2%)
        if !len! GTR !oneLineMsgLen! call %_divideStr% "!msg!" !oneLineMsgLen! divideMsg divideNum& set len=!oneLineMsgLen!& set msg=!divideMsg_1!
        set /a mod=len%%2& if !mod! NEQ 0 set /a len+=1& set msg=!msg! 
        
        set /a msgBorderLenTemp=len/2& for %%m in (!msgBorderLenTemp!) do set msgBorderTemp=!oneLineMsgBorder:~0,%%m!
        if !user!==!user1! (
            REM ��Ҫ���Ƶ���ɫ���볤��colorNumTemp: ��Ϣ���� + �û�1���� + ��Ϣǰ��߿򳤶�:�� ��
            set /a colorNumTemp=len+userLen1+6& for %%m in (!colorNumTemp!) do set oneLineColorTemp=!oneLineColor1:~0,%%m!
            %CPaint% 0 !msgShowLine! "!oneLineColorTemp!" "!userBlank1!   /!msgBorderTemp!\\"& (%checkMsgShowLine%)
            %CPaint% 0 !msgShowLine! "!oneLineColorTemp!" "!userStr1!:�� !msg!��"& (%checkMsgShowLine%)
            if defined divideNum (for /l %%m in (2,1,!divideNum!) do %CPaint%  0 !msgShowLine! "!oneLineColorTemp!" "!userBlank1!  ��!divideMsg_%%m!��"& (%checkMsgShowLine%))& set divideNum=
            %CPaint% 0 !msgShowLine! "!oneLineColorTemp!" "!userBlank1!  �t!msgBorderTemp!�s"& (%checkMsgShowLine%)
        )
        if !user!==!user2! (
            REM cpaint�����ַ�ʱ������(ȫ��)showXTemp: ��Ļ��� - ��Ϣ���� - �û�2���� - ��Ϣǰ��߿򳤶�:�� ��
            REM ��Ҫ���Ƶ���ɫ���볤��colorNumTemp: ��Ϣ���� + �û�2���� + ��Ϣǰ��߿򳤶ȩ� ��:
            set /a showXTemp="(screenWidth-len-userLen2-6)"/2, colorNumTemp=len+userLen2+6& for %%m in (!colorNumTemp!) do set oneLineColorTemp=!oneLineColor2:~0,%%m!
            %CPaint% !showXTemp! !msgShowLine! "!oneLineColorTemp!" " /!msgBorderTemp!\!userBlank2!"& (%checkMsgShowLine%)
            %CPaint% !showXTemp! !msgShowLine! "!oneLineColorTemp!" "��!msg! ��:!userStr2!"& (%checkMsgShowLine%)
            if defined divideNum (for /l %%m in (2,1,!divideNum!) do %CPaint% !showXTemp! !msgShowLine! "!oneLineColorTemp!" "��!divideMsg_%%m!��!userBlank2!"& (%checkMsgShowLine%))& set divideNum=
            %CPaint% !showXTemp! !msgShowLine! "!oneLineColorTemp!" "�t!msgBorderTemp!�s!userBlank2!"& (%checkMsgShowLine%)
        )
        sleep !pauseTime!>nul
    )
)
echo.& echo.& (%_infiniteLoopPause%)
@echo off& call load.bat _strlen _strlen2 _infiniteLoopPause& call loadF.bat _params _errorMsg _help _divideStr& call loadE.bat Cext CurS CPaint& setlocal enabledelayedexpansion& title 聊天记录& color 0A
:::说明
:::  解析并滚动展示两人的聊天记录
:::参考
:::  F:\资料\备份资料\微信聊天记录\readme.txt
:::参数
:::  [-u1 user1] [-u2 user2] [-c msgColor] [-s startTime] [-e endTime] [-w width] [-h height] [-p pauseTime] chatFilePath
:::      user1 - 用户1昵称, 如[her]
:::      user2 - 用户2昵称, 如[he]
:::      msgColor - 消息颜色, 需要两种, 如[0D0B]
:::      startTime - 聊天记录开始时间
:::      endTime - 聊天记录结束时间
:::      width - 屏幕宽度
:::      height - 屏幕高度
:::      pauseTime - 滚动间隔时长
:::      chatFilePath - 聊天记录文件
:::  [-h help]
:::      help - 打印注释信息
:::chatFile格式规范
:::     2013/11/04#14:18:48#qiao#ok
:::      日期#时间#角色#word
:::TODO
:::  1. chatFile格式规范重定义
:::  2. 前后消息如果间隔小于3分钟, 则不展示日期时间信息
:::  3. 将微信复杂信息进行信息提取
:::  4. 支持startTime\endTime参数
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
title [!user1!]与[!user2!]的聊天记录

::========================= pre-calc =========================
set /a mod=screenWidth%%2& if !mod! NEQ 0 set /a screenWidth+=1
mode !screenWidth!,!screenHeight!
REM cpaint坐标位置是按全角计算, x坐标为3, 则前面有6个半角字符[肯定是偶数], 造成聊天框前后多出一个空格；颜色0D一次会上色2个半角字符, 需要除以2
set /a msgShowLine=0, msgShowLineMax=screenHeight-1

REM user1前默认加一个空格, 并确保userLen1长度为偶数值；user2后默认加一个空格，并确保userLen2长度为偶数值
(%_call% ("user1 userLen1") %_strlen2%)& set userStr1= !user1!& set /a userLen1+=1, mod=userLen1%%2& (if !mod! NEQ 0 set /a userLen1+=1& set userStr1= !userStr1!)
(%_call% ("user2 userLen2") %_strlen2%)& set userStr2=!user2! & set /a userLen2+=1, mod=userLen2%%2& (if !mod! NEQ 0 set /a userLen2+=1& set userStr2=!userStr2! )
set userBlank1=& set userBlank2=& (for /l %%i in (1,1,!userLen1!) do set userBlank1=!userBlank1! )& (for /l %%i in (1,1,!userLen2!) do set userBlank2=!userBlank2! )


REM 屏幕中一行消息最大长度oneLineMsgLen: 屏幕宽度 - 用户1长度 - 用户2长度 - 消息前后边框 - 美观对齐缩进值
set /a oneLineColorNum=(screenWidth-2)/2, oneLineMsgLen=screenWidth-userLen1-userLen2-6-2, oneLineMsgLen2=oneLineMsgLen/2
set msgColor1=!msgColor:~0,2!& if "!msgColor1!" EQU "" set msgColor1=0D
set msgColor2=!msgColor:~2,2!& if "!msgColor2!" EQU "" set msgColor2=0B
set oneLineColor1=& set oneLineColor2=& for /l %%i in (1,1,!oneLineColorNum!) do set oneLineColor1=!oneLineColor1!!msgColor1!& set oneLineColor2=!oneLineColor2!!msgColor2!
(set oneLineMsgBlank=& for /l %%i in (1,1,!oneLineMsgLen!) do set oneLineMsgBlank=!oneLineMsgBlank! )& (set oneLineMsgBorder=& for /l %%i in (1,1,!oneLineMsgLen2!) do set oneLineMsgBorder=!oneLineMsgBorder!─)
set "checkMsgShowLine=if ^!msgShowLine^! EQU ^!msgShowLineMax^! (%Cext% /mov 0 1 ^!screenWidth^! ^!msgShowLineMax^! 0 0) else (set /a msgShowLine+=1)"
for /f "eol=  tokens=1-3* delims=#" %%i in (!chatFilePath!) do (
    if "%%i"=="blankLine" (
        (%checkMsgShowLine%)
    ) else (
        set date=%%i& set time=%%j& set user=%%k& set msg=%%l
        REM 屏幕左边框为[│ │],共5个半角字符, 真正屏幕显示是在x轴为5开始, cpaint位置按照全角计算因此除以2
        set timestamp=!date: =! !time: =!& (%_call% ("timestamp len") %_strlen2%)& set /a showXTemp="(screenWidth-len)"/4& %CPaint% !showXTemp! !msgShowLine! "" "!timestamp!"& (%checkMsgShowLine%)
        
        set msg=!msg:^"='!& (%_call% ("msg len") %_strlen2%)
        if !len! GTR !oneLineMsgLen! call %_divideStr% "!msg!" !oneLineMsgLen! divideMsg divideNum& set len=!oneLineMsgLen!& set msg=!divideMsg_1!
        set /a mod=len%%2& if !mod! NEQ 0 set /a len+=1& set msg=!msg! 
        
        set /a msgBorderLenTemp=len/2& for %%m in (!msgBorderLenTemp!) do set msgBorderTemp=!oneLineMsgBorder:~0,%%m!
        if !user!==!user1! (
            REM 需要绘制的颜色代码长度colorNumTemp: 消息长度 + 用户1长度 + 消息前后边框长度:〈 │
            set /a colorNumTemp=len+userLen1+6& for %%m in (!colorNumTemp!) do set oneLineColorTemp=!oneLineColor1:~0,%%m!
            %CPaint% 0 !msgShowLine! "!oneLineColorTemp!" "!userBlank1!   /!msgBorderTemp!\\"& (%checkMsgShowLine%)
            %CPaint% 0 !msgShowLine! "!oneLineColorTemp!" "!userStr1!:〈 !msg!│"& (%checkMsgShowLine%)
            if defined divideNum (for /l %%m in (2,1,!divideNum!) do %CPaint%  0 !msgShowLine! "!oneLineColorTemp!" "!userBlank1!  │!divideMsg_%%m!│"& (%checkMsgShowLine%))& set divideNum=
            %CPaint% 0 !msgShowLine! "!oneLineColorTemp!" "!userBlank1!  ╰!msgBorderTemp!╯"& (%checkMsgShowLine%)
        )
        if !user!==!user2! (
            REM cpaint绘制字符时左坐标(全角)showXTemp: 屏幕宽度 - 消息长度 - 用户2长度 - 消息前后边框长度:〈 │
            REM 需要绘制的颜色代码长度colorNumTemp: 消息长度 + 用户2长度 + 消息前后边框长度│ 〉:
            set /a showXTemp="(screenWidth-len-userLen2-6)"/2, colorNumTemp=len+userLen2+6& for %%m in (!colorNumTemp!) do set oneLineColorTemp=!oneLineColor2:~0,%%m!
            %CPaint% !showXTemp! !msgShowLine! "!oneLineColorTemp!" " /!msgBorderTemp!\!userBlank2!"& (%checkMsgShowLine%)
            %CPaint% !showXTemp! !msgShowLine! "!oneLineColorTemp!" "│!msg! 〉:!userStr2!"& (%checkMsgShowLine%)
            if defined divideNum (for /l %%m in (2,1,!divideNum!) do %CPaint% !showXTemp! !msgShowLine! "!oneLineColorTemp!" "│!divideMsg_%%m!│!userBlank2!"& (%checkMsgShowLine%))& set divideNum=
            %CPaint% !showXTemp! !msgShowLine! "!oneLineColorTemp!" "╰!msgBorderTemp!╯!userBlank2!"& (%checkMsgShowLine%)
        )
        sleep !pauseTime!>nul
    )
)
echo.& echo.& (%_infiniteLoopPause%)
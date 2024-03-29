@echo off& (if "%1"=="" goto :showExample)& (if "%1"=="0" goto :showDescript)& (if "%1"=="1" goto :searchFunction)
::Author[Allen]    邮箱[bjc5233@gmail.com]    扣扣[692008411]    words[有共同兴趣,有建议,有bug都欢迎来联系我哦~]

::介绍
::  load.bat主要是为了统一管理内敛函数而写的
::  我在开始学习使用内敛函数的时候, 它的速度相比call快了近乎10倍, 但经常在各个bat代码中书写相同的内敛函数代码, 
::  于是模仿了Java中导入的做法写了load.bat, 现在我自己编写代码时, 需要用到的函数都会放到这里进行调用
::  这里的各个内敛函数大部分是我自己写的, 有从网上收集的[抱歉不能一一写出作者名字]


::4种调用方式
::  必须在延迟变量[setlocal enabledelayedexpansion]开启之前 【当调用位置错误会有提示语句】
::  1.call load.bat                   无参打印调用实例[使用到工具clip]
::  2.call load.bat _fun1 _func2...   正常调用内敛函数[将需要的内敛函数作为参数传入]
::  3.call load.bat 0 _fun1 _func2... 打印内敛函数说明[当不指定函数,则打印所有函数说明]
::  4.call load.bat 1 keyWord         按关键字搜索内敛函数[当不指定keyWord打印所有函数列表][使用到工具find ckey clip]


::编写内敛函数时的建议和注意点
::  1.理解基本结构for /f "tokens=1-9 delims= " %%1 in ("参数1 参数2...") do setlocal enabledelayedexpansion..... endlocal
::                [              ↑                  ] [       ↑        ] [                  ↑                           ]
::                            %_call%                    用户输入的参数                   内敛函数
::  2.书写内敛函数使用说明: 第一行写函数作用, 第二行写参数
::        参数声明需要指定参数类型IN OUT IN-OUT, 参数之间一般间隔4个空格, 可选参数使用{}包围
::  2.通常情况下内敛函数需要被[setlocal--endlocal]包围, 防止对调用者环境变量产生影响
::  3.在内敛函数中, 需要保证[setlocal--endlocal]成对, 否则可能会将调用者环境变量全部清除
::  4.内敛函数调用内敛函数[if not defined _xxx call :_xxx]【判断要调用的内敛函数是否已经定义, 防止多次调用】
::  5.调用者对内敛函数的影响
::        内敛函数可以访问到调用者的变量, 被[setlocal--endlocal]包围的内敛函数对该变量做的操作没有直接影响, 调用者之后读取到的变量值不变[除非没有包围\ 或者在endlocal时设值]
::            set str=outer
::            echo [!str!]
::            %_test% ------------ setlocal enabledelayedexpansion& echo [!str!]& set str=inner& echo [!str!]& endlocal
::            echo [!str!]
::        由于内敛函数可以访问到调用者变量, 因此在进行如字符自叠加[set a=!a!b], 数字自增[set /a a+=1]时, 应该首先置空变量[set a=]
::  6.是否型内敛函数[isFolder]的推荐写法
::        通常做法是传入单独变量, 在调用之后通过该变量的值使用if进行判断, 这里推荐使用_true\_false两个内敛函数处理[实质上最后是通过errorlevel值进行判断]
::        内敛函数写法: (if condition (endlocal& %_true%) else (endlocal& %_false%)) ------ 确保此为内敛函数最后一句, 需要将该if语句用括号包围
::        调用者的写法: (%_call% ("myFolder") %_isFolder%) && echo true || echo false ------ echo true处可以使用多个语句,只要包围在括号内


::检查调用者在调用load.bat前是否开启延迟变量, 是则不通过
set _positionCheck=0& if "!_positionCheck!"=="0" echo 请在[setlocal enabledelayedexpansion]前调用load.bat& for /l %%i in () do pause>nul
(if not defined _call call :_call)& (for %%i in (%*) do call :%%i)
goto :EOF



:showExample
::显示调用实例
call :_getLF& setlocal enabledelayedexpansion& mode 32,15
set "exampleStr=@echo off!LF!call load.bat _strlen!LF!setlocal enabledelayedexpansion!LF!!LF!set str=123你好啊!LF!%%_call%% ("str len") %%_strlen%%!LF!echo [^!str^!]的字符长度: ^!len^!!LF!pause>nul"
echo ------调用内敛函数实例------& echo.& echo !exampleStr!& echo.& echo ------调用内敛函数实例------& echo.& echo.
set /p=任意键复制到剪贴板<nul& pause>nul& echo !exampleStr!>%temp%\exampleStr.temp& clip<%temp%\exampleStr.temp
goto :EOF

:showDescript
::打印指定内敛函数说明
setlocal enabledelayedexpansion
if "%2"=="" (
    set functionStrat=0
    for /f "delims=" %%i in (%~f0) do (
        if "%%i"==":_call" set functionStrat=1
        if !functionStrat!==1 set curLine=%%i& set prefix=!curLine:~0,2!& if "!prefix!"==":_" (echo.& echo !curLine:~1!) else (if "!prefix!"=="::" echo %%i)
    )
) else (
    for %%i in (%*) do if %%i NEQ %1 (
        echo %%i& set printFlag=0& for /f "delims=" %%j in (%~f0) do set curLine=%%j& (if !printFlag!==1 if "!curLine:~0,2!"=="::" (echo !curLine!) else (set printFlag=0))& (if /i "%%j"==":%%i" set printFlag=1)
        echo.& echo.
    )
)
pause>nul& goto :EOF

:searchFunction
call loadE.bat CurS CKey
::列出所有已经定义内敛函数\搜索包含指定字符串的内敛函数
(call :_getLF)& (call :_call)
setlocal enabledelayedexpansion
(for /f "delims=" %%i in (%~f0) do set curLine=%%i& if "!curLine:~0,2!"==":_" if "!curLine:~-1!" NEQ "_" echo !curLine:~1!)>>%temp%\functionList.tmp
if "%2"=="" (for /f "delims=" %%i in (%temp%\functionList.tmp) do set /a functionIndex+=1& set function_!functionIndex!=%%i& set function_!functionIndex!=%%i) else (title [%2]& for /f "skip=2 delims=" %%i in ('find /i "%2" %temp%\functionList.tmp') do set /a functionIndex+=1& set function_!functionIndex!=%%i)
del /q %temp%\functionList.tmp
if !functionIndex! LSS 1 echo 找不到包含[%2]的函数& pause>nul& exit
set /a functionIndexMax=functionIndex, pointer=functionIndex/2, winWide=30, winHeight=functionIndexMax&  (if !pointer!==0 set pointer=1)& mode !winWide!, !winHeight!& %CurS% /crv 0
REM [1上]  [2下] [3Enter] [4Esc]
for /l %%i in () do (
    cls& set functionStr=& (for /l %%i in (1,1,!functionIndex!) do if %%i==!pointer!  (set functionStr=!functionStr!→  !function_%%i!!LF!) else (set functionStr=!functionStr!    !function_%%i!!LF!))& set /p "=_!functionStr:~0,-1!"<nul
    pause>nul& %CKey% 0 38 40 13& (if !errorlevel!==1 set /a pointerTemp=pointer-1)& (if !errorlevel!==2 set /a pointerTemp=pointer+1)& (if !errorlevel!==3 for %%i in (!pointer!) do set /p"=!function_%%i!"<nul | clip& exit)& (if !pointerTemp! GEQ 1 if !pointerTemp! LEQ !functionIndexMax! set pointer=!pointerTemp!)
)
goto :EOF







:_call
::调用有参内敛函数的调用前缀
::在书写内敛函数时根据传入参数的数量选择版本, 一般情况下都是用版本一[很少有参数数量多于9个]
::(%_call% ("arg1 arg2 arg3...") %_func%)        
::   版本一支持[%%1--%%9]共9个参数
::   版本二支持[%%A--%%Z]共26个参数
set _call=for /f "tokens=1-9 delims= " %%1 in
set _call_=for /f "tokens=1-26 delims= " %%A in
goto :EOF


:_checkDepend
::检查调用者所在路径以及path路径中是否包含指定的文件
::    注意: 内敛函数中有些需要使用第三方, 应调用此函数检查依赖的第三方; 但对于一般系统携带的exe如find等不进行检查
::IN[文件名,包含后缀]
(call :_getLF)& (if not defined _true call :_true)& (if not defined _false call :_false)
set "_checkDepend=do setlocal enabledelayedexpansion& set path="%cd%"!LF!"%path:;="!LF!"%"& set flag=0& (for %%i in (!path!) do if exist %%~i\%%1 set flag=1)& (if "!flag!"=="1" (endlocal& %_true%) else (endlocal& %_false%))"& goto :EOF




:_strlen
::计算字符串的字符数
::所求字符串不超过8192==>4096 2048 1024 512 256 128 64 32 16
::所求字符串不超过4096==>2048 1024 512 256 128 64 32 16
::所求字符串不超过2048==>1024 512 256 128 64 32 16
::IN[字符串变量名]    OUT[len]
set "_strlen=do setlocal enabledelayedexpansion& set $=!%%1!#& set N=& (for %%a in (2048 1024 512 256 128 64 32 16) do if !$:~%%a!. NEQ . set /a N+=%%a& set $=!$:~%%a!)& set $=!$!fedcba9876543210& set /a N+=0x!$:~16,1!& for %%i in (!N!) do endlocal& set /a %%2=%%i"& goto :EOF



:_strlen2
::计算字符串的字节数
::注意:创建的临时文件应该具有唯一性[时间信息], 否则两个bat文件同时使用该函数会导致字节数计算错误
::IN[字符串变量名]    OUT[len]
set "_strlen2=do setlocal enabledelayedexpansion& set _timeStr=%time::=%& set _timeStr=!_timeStr: =!& (>%temp%\_strlen2_!_timeStr!.tmp echo.!%%1!)& for %%i in (%temp%\_strlen2_!_timeStr!.tmp) do endlocal& set /a %%2=%%~zi-2& del /q %%~i" & goto :EOF



:_parseArray
::解析数组字符串,将变量array={a,b}转换为3个变量array.length=3, array[0]=a, array[1]=b, array.maxIndex=2
::IN[数组字符串变量名]
::set "_parseArray=do setlocal enabledelayedexpansion& (for /f "tokens=1 delims={}" %%i in ("!%%1!") do set arrayIndex=0& for %%j in (%%i) do (for %%k in (!arrayIndex!) do endlocal& set %%1[%%k]=%%j)& set /a arrayIndex+=1& setlocal enabledelayedexpansion)& for %%i in (!arrayIndex!) do endlocal& set %%1.length=%%i& set arrayIndex="& goto :EOF
set "_parseArray=do setlocal enabledelayedexpansion& (for /f "tokens=1 delims={}" %%i in ("!%%1!") do set arrayIndex=0& for %%j in (%%i) do (for %%k in (!arrayIndex!) do endlocal& set %%1[%%k]=%%j)& set /a arrayIndex+=1& setlocal enabledelayedexpansion)& for %%i in (!arrayIndex!) do (set /a arrayMaxIndex=%%i-1& for %%j in (!arrayMaxIndex!) do endlocal& set %%1.length=%%i& set %%1.maxIndex=%%j& set arrayIndex=& set arrayMaxIndex=)"& goto :EOF


:_destoryArray
::销毁数组元素变量
::IN[数组字符串变量名]
set "_destoryArray=do setlocal enabledelayedexpansion& set /a %%1.length-=1& (for %%i in (!%%1.length!) do for /l %%j in (0,1,%%i) do endlocal& set %%1[%%j]=& setlocal enabledelayedexpansion)& set %%1.length=& set %%1.maxIndex=& set %%1="& goto :EOF



:_parseJSON
::解析JSON字符串,将变量json={name:鲍xx,age:24} 转换为 array.length=2, array.name=鲍xx, array.age=24
::IN[JSON字符串变量名]
set "_parseJSON=do setlocal enabledelayedexpansion& (for /f "tokens=1 delims={}" %%i in ("!%%1!") do for %%j in (%%i) do (for /f "tokens=1* delims=:" %%k in ("%%j") do endlocal& set %%1.%%k=%%l& set /a %%1.length+=1)& setlocal enabledelayedexpansion)& endlocal"& goto :EOF
:_destoryJSON
::销毁JSON元素变量
::IN[JSON字符串变量名]
set "_destoryJSON=do (for /f "tokens=1 delims==" %%i in ('set %%1.') do set %%i=)& set %%1="& goto :EOF



:_isPureNum
::是否是纯数字   调用者: [(调用内敛函数) && echo isPureNum || echo non-isPureNum]
::IN[字符串变量名]
(if not defined _true call :_true)& (if not defined _false call :_false)
set "_isPureNum=do setlocal enabledelayedexpansion& (set /a flag=!%%~1!*1 >nul 2>nul)& (if "!flag!"=="!%%~1!" (endlocal& %_true%) else (endlocal& %_false%))"& goto :EOF



:_getRandomNum
::取指定范围内的随机数
::IN[最小值]    IN[最大值]    OUT[随机数]
set "_getRandomNum=do setlocal enabledelayedexpansion& for %%i in (!random!) do endlocal& set /a %%3=%%i%%"(%%2-%%1+1)"+%%1"& goto :EOF


:_getRandomNum2
::从指定数字范围内随机选择指定个数字的数字
::IN[最小值]    IN[最大值]    IN[选取个数]    OUT[输出的数字字符串,以空格分隔]
set "_getRandomNum2=do setlocal enabledelayedexpansion& set /a maxIndex=%%2-%%1& set numStr= & (for /l %%i in (%%1,1,%%2) do set numStr=!numStr!%%i )& (for /l %%i in (1,1,%%3) do set /a curIndex=!random!%%"(maxIndex+1)"& set numIndex=0& (for %%j in (!numStr!) do (if !curIndex!==!numIndex! set curNum=%%j)& set /a numIndex+=1)& (for %%j in (!curNum!) do set numStr=!numStr: %%j = !)& set /a maxIndex-=1& set pickNumStr=!pickNumStr!!curNum! )& for %%i in ("!pickNumStr!") do endlocal& set %%4=%%~i"& goto :EOF



:_getRandomColor
::获取一个随机颜色值
::OUT[随机颜色值] {IN[是否包含前缀0]}
if not defined _getRandomNum call :_getRandomNum
set "_getRandomColor=do setlocal enabledelayedexpansion& set colorStr=abcdef123456789& (%_call% ("0 14 index") %_getRandomNum%)& for %%i in (!index!) do set color=!colorStr:~%%i,1!& for %%j in (!color!) do if "%%2"=="" (endlocal& set %%1=0%%j) else (endlocal& set %%1=%%j)"& goto :EOF

:_randomColor
::设置一个随机颜色
if not defined _getRandomColor call :_getRandomColor
set "_randomColor=setlocal enabledelayedexpansion& (%_call% ("color") %_getRandomColor%)& color !color!& endlocal"& goto :EOF

:_parseColor
::解析单个颜色值, 当无法解析时打印出所支持的颜色
::IN[原始颜色字符][如红]    OUT[处理后颜色代码][如C]
set "_parseColor=do setlocal enabledelayedexpansion& (if %%1==黑 set c=0)& (if /i %%1==black set c=0)& (if %%1==蓝 set c=1)& (if /i %%1==blue set c=1)& (if %%1==绿 set c=2)& (if /i %%1==green set c=2)& (if %%1==水绿 set c=3)& (if /i %%1==aqua set c=3)& (if %%1==红 set c=4)& (if /i %%1==red set c=4)& (if %%1==紫 set c=5)& (if /i %%1==purple set c=5)& (if %%1==黄 set c=6)& (if /i %%1==yellow set c=6)& (if %%1==白 set c=7)& (if /i %%1==white set c=7)& (if %%1==灰 set c=8)& (if /i %%1==gray set c=8)& (if %%1==淡蓝 set c=9)& (if /i %%1==lightblue set c=9)& (if /i %%1==lblue set c=9)& (if %%1==淡绿 set c=A)& (if /i %%1==lightgreen set c=A)& (if /i %%1==lgreen set c=A)& (if %%1==淡水绿 set c=B)& (if /i %%1==lightaqua set c=B)& (if /i %%1==laqua set c=B)& (if %%1==淡红 set c=C)& (if /i %%1==lightred set c=C)& (if /i %%1==lred set c=C)& (if %%1==淡紫 set c=D)& (if /i %%1==lightpurple set c=D)& (if /i %%1==lpurple set c=D)& (if %%1==淡黄 set c=E)& (if /i %%1==lightyellow set c=E)& (if /i %%1==lyellow set c=E)& (if %%1==淡白 set c=F)& (if /i %%1==lightwhite set c=F)& (if /i %%1==lwhite set c=F)& (if "!c!"=="" set c=0& for %%i in (--无法解析指定颜色--- 0-黑-black 1-蓝-blue 2-绿-green 3-水绿-aqua 4-红-red 5-紫-purple 6-黄-yellow 7-白-white 8-灰-gray 9-淡蓝-lightblue-lblue A-淡绿-lightgreen-lgreen B-淡水绿-lightaqua-laqua C-淡红-lightred-lred D-淡紫-lightpurple-lpurple E-淡黄-lightyellow-lyellow F-淡白-lightwhite-lwhite ---------------------) do echo %%i)& for %%i in (!c!) do endlocal& set %%2=%%i"& goto :EOF



:_downcase
::大写字符串转小写字符串
::IN[字符串变量名]      OUT[处理后字符串]
set "_downcase=do setlocal enabledelayedexpansion& set str=!%%1!& (for %%i in (a b c d e f g h i j k l m n o p q r s t u v w x y z) do set str=!str:%%i=%%i!)& for %%i in (!str!) do endlocal& set %%2=%%i"& goto :EOF

:_upcase
::小写字符串转大写字符串
::IN[字符串变量名]      OUT[处理后字符串]
set "_upcase=do setlocal enabledelayedexpansion& set str=!%%1!& (for %%i in (A B C D E F G H I J K L M N O P Q R S T U V W X Y Z) do set str=!str:%%i=%%i!)& for %%i in (!str!) do endlocal& set %%2=%%i"& goto :EOF



:_px2colsLines
::像素值转cmd宽度高度值    cmd默认[点阵字体8x16], 即每个字符是8个像素宽，16个像素高
::除不尽时使用[ceil]方式
::IN[pxWidth]    IN[pxHeight]    OUT[cols]    OUT[lines]    {IN[字体大小][查看属性字体选项卡]}
set "_px2colsLines=do setlocal enabledelayedexpansion& (if "%%5"=="" (set fontSize=8x16) else (set fontSize=%%5))& (for /f "tokens=1,2 delims=x" %%i in ("!fontSize!") do set /a mod=%%1%%%%i& (if !mod!==0 (set offset=0) else (set offset=1))& set /a cols=%%1/%%i+offset& set /a mod=%%2%%%%j& (if !mod!==0 (set offset=0) else (set offset=1))& set /a lines=%%2/%%j+offset)& for /f "tokens=1,2 delims= " %%i in ("!cols! !lines!") do endlocal& set /a %%3=%%i, %%4=%%j"& goto :EOF


:_px2colsLinesFloor
::像素值转cmd宽度高度值    cmd默认[点阵字体8x16], 即每个字符是8个像素宽，16个像素高
::除不尽时使用[floor]方式
::IN[pxWidth]    IN[pxHeight]    OUT[cols]    OUT[lines]    {IN[字体大小][查看属性字体选项卡]}
set "_px2colsLinesFloor=do setlocal enabledelayedexpansion& (if "%%5"=="" (set fontSize=8x16) else (set fontSize=%%5))& (for /f "tokens=1,2 delims=x" %%i in ("!fontSize!") do set /a cols=%%1/%%i& set /a lines=%%2/%%j)& for /f "tokens=1,2 delims= " %%i in ("!cols! !lines!") do endlocal& set /a %%3=%%i, %%4=%%j"& goto :EOF



:_colsLines2px
::cmd宽度高度值转像素值    cmd默认[点阵字体8x16], 即每个字符是8个像素宽，16个像素高
::IN[cols]    IN[lines]    OUT[pxWidth]    OUT[pxHeight]    {IN[字体大小][查看属性字体选项卡]}
set "_colsLines2px=do setlocal enabledelayedexpansion& (if "%%5"=="" (set fontSize=8x16) else (set fontSize=%%5))& for /f "tokens=1,2 delims=x" %%i in ("!fontSize!") do endlocal& set /a %%3=%%1*%%i, %%4=%%2*%%j"& goto :EOF


:_getColsLines
::得到当前cmd屏幕宽度高度值
::OUT[cols]    OUT[lines]
set "_getColsLines=do for /f "tokens=1,3 delims=: " %%i in ('mode') do (if "%%i"=="行" set %%2=%%j)& (if "%%i"=="列" set %%1=%%j)"& goto :EOF



:_buildFile
::创建空文件, 0字节, 文件内没有任何内容
::    注意:echo.>1.txt方式创建的不是空文件
::IN[文件名]
set "_buildFile=do cd.>%%1"& goto :EOF


:_getFileName
::解析文件路径字符串得到文件名
::IN[文件路径变量名]    OUT[文件名]    {OUT[文件扩展名]}
set "_getFileName=do setlocal enabledelayedexpansion& for %%i in ("!%%~1!") do endlocal& set %%2=%%~ni& if "%%3" NEQ "" set %%3=%%~xi"& goto :EOF


:_getFileLine
::计算指定文件行数[忽略空行]
::IN[文件名]    OUT[文件行数]
set "_getFileLine=do setlocal enabledelayedexpansion& (for /f "eol= delims=" %%j in (%%1) do set /a line+=1)& for %%i in (!line!) do endlocal& set %%2=%%i"& goto :EOF
:_getFileLine2
::IN[文件路径变量名]    OUT[文件行数]
set "_getFileLine2=do setlocal enabledelayedexpansion& (for %%i in ("!%%~1!") do for /f "eol= delims=" %%j in (%%~si) do set /a line+=1)& for %%i in (!line!) do endlocal& set %%2=%%i"& goto :EOF



:_getFileSize
::计算指定文件大小, 单位byte
::IN[文件路径变量名]   OUT[文件大小]
set "_getFileSize=do setlocal enabledelayedexpansion& for %%i in ("!%%~1!") do for %%j in (%%~si) do endlocal& set %%2=%%~zj"& goto :EOF

:_isFolder
::是否是文件夹       [%调用表达式% && echo folder || echo file]
::IN[文件夹路径变量名]
(if not defined _true call :_true)& (if not defined _false call :_false)
set "_isFolder=do setlocal enabledelayedexpansion& (if exist "!%%1!\" (endlocal& %_true%) else (endlocal& %_false%))"& goto :EOF



:_uniqueStr
::使用当前日期时间得到一个唯一的字符串
::OUT[唯一字符串]
set "_uniqueStr=do setlocal enabledelayedexpansion& for /f "tokens=1-7 delims=/:." %%i in ("!date:~0,10!:!time: =0!") do endlocal& set %%1=%%i%%j%%k%%l%%m%%n%%o"& goto :EOF




:_getCR
::得到回车符Carriage Return, 导入之后使用约定变量CR, 调用者开启延迟变量使用[!CR!], 未开启延迟变量无法调用
(for /f %%i in ('copy /Z "%~dpf0" nul') do set CR=%%i)& goto :EOF

:_getLF
::得到换行符Line Feed[行满], 导入之后使用约定变量LF\LF_, 调用者开启延迟变量使用[!LF! \ %LF_%], 未开启延迟变量使用[%LF_%]
set LF=^


set LF_=^^^%LF%%LF%^%LF%%LF%& goto :EOF

:_getTab
::得到Tab符, 导入之后使用约定变量Tab, 调用者开启延迟变量使用[!Tab! \ %Tab%], 未开启延迟变量使用[%Tab%]
set Tab=	& goto :EOF

:_getBS
::得到退格符, 导入之后使用约定变量Tab, 调用者开启延迟变量使用[!BS! \ %BS%], 未开启延迟变量使用[%BS%]
(for /f %%i in ('"prompt $h&for %%i in (1) do rem"') do set BS=%%i)& goto :EOF



:_speak
::计算机speak文字  会在%temp%目录生成tool_speak.vbs
::IN[文字变量名]
set "_speak=do setlocal enabledelayedexpansion& (if not exist %temp%\tool_speak.vbs echo CreateObject^("SAPI.SpVoice"^).Speak^(Wscript.Arguments^(0^)^)>%temp%\tool_speak.vbs)& for /f "delims=" %%i in ("!%%1!") do call %temp%\tool_speak.vbs "%%~i""& goto :EOF



:_getScreenSize
::获取显示器屏幕大小
::OUT[宽度]    OUT[高度]
set "_getScreenSize=do for /f "tokens=1,2 delims==" %%i in ('wmic DESKTOPMONITOR where Status^='ok' get ScreenWidth^,ScreenHeight /VALUE') do (if "%%i"=="ScreenWidth" set %%1=%%j)& (if "%%i"=="ScreenHeight" set %%2=%%j)"& goto :EOF


:_getDeskWallpaperPath
::获取桌面壁纸路径
::OUT[桌面壁纸路径]
set "_getDeskWallpaperPath=do for /f "skip=2 tokens=2* delims= " %%i in ('reg query "HKEY_CURRENT_USER\Control Panel\Desktop" /v WallPaper') do set %%1=%%j"& goto :EOF



:_roundFloat
::四舍五入
::IN[原始浮点数字字符串]    IN[精确小数位数]    OUT[处理后浮点数字字符串]
set "_roundFloat=do setlocal enabledelayedexpansion& for /f "tokens=1,2 delims=." %%i in ("%%1") do if "%%j" NEQ "" (set integerPart=%%i& set decimalPart=%%j& set boundaryNum=!decimalPart:~%%2,1!& set decimalPart=!decimalPart:~0,%%2!& (if "!boundaryNum!" NEQ "" if !boundaryNum! GEQ 5 if "!decimalPart!"=="" (set /a integerPart+=1) else (set /a decimalPart+=1))& for /f "tokens=1,2 delims= " %%k in ("!integerPart! !decimalPart!") do endlocal& if "%%l"=="" (set %%3=%%k) else (set %%3=%%k.%%l)) else (endlocal& set %%3=%%i)"& goto :EOF



:_infiniteLoopPause
::无限pause>nul, 一般用于bat结尾, 用户只能手动关闭窗口
set "_infiniteLoopPause=for /l %%i in () do pause>nul"& goto :EOF

:_infiniteLoopSome
::无限处理用户指定命令,    使用双引号包围每条命令, 命令之间以空格分隔          set some="echo ok" "pause" "set /a count+=1" "echo ^!count^!"& %_call% ("some") %_infiniteLoopSome%
::IN[指定命令字符串变量名]
set "_infiniteLoopSome=do setlocal enabledelayedexpansion& (for /l %%i in () do for %%j in (!%%1!) do %%~j)& endlocal"& goto :EOF



:_trimStrLeft
::修整字符串，移除左空格
::IN-OUT[字符串变量名]
set "_trimStrLeft=do setlocal enabledelayedexpansion& for /f "tokens=* delims= " %%i in ("!%%~1!") do set %%1=%%i"& goto :EOF

:_trimStrRight
::修整字符串，移除右空格
::IN-OUT[字符串变量名]
if not defined _strlen call :_strlen
set "_trimStrRight=do setlocal enabledelayedexpansion& (%_call% ("%%1 len") %_strlen%)& set str=!%%1!& (for /l %%i in (1,1,!len!) do if "!str:~-1,1!"==" " set "str=!str:~0,-1!")& for %%i in ("!str!") do endlocal& set "%%1=%%~i""& goto :EOF

:_trimStr
::修整字符串，移除左右空格
::IN-OUT[字符串变量名]
(if not defined _trimStrLeft call :_trimStrLeft)& (if not defined _trimStrRight call :_trimStrRight)
set "_trimStr=do (%_call% ("%%1") %_trimStrLeft%)& (%_call% ("%%1") %_trimStrRight%)"& goto :EOF


:_reverseStr
::将字符串反序处理
::IN[字符串变量名]     OUT[处理后字符串]
if not defined _strlen call :_strlen
set "_reverseStr=do setlocal enabledelayedexpansion& (%_call% ("%%1 len") %_strlen%)& set "str=!%%1!"& set /a len-=1& (for /l %%i in (0,1,!len!) do set str2=!str:~%%i,1!!str2!)& for %%i in ("!str2!") do endlocal& set "%%2=%%~i""& goto :EOF



:_shuffleStr
::将字符串乱序处理
::IN[字符串变量名]     OUT[处理后字符串]
(if not defined _strlen call :_strlen)& (if not defined _getRandomNum call :_getRandomNum)
set "_shuffleStr=do setlocal enabledelayedexpansion& (%_call% ("%%1 len") %_strlen%)& set "str=!%%1!"& set /a len-=1& (for /l %%i in (0,1,!len!) do (%_call% ("0 !len! index") %_getRandomNum%)& set /a index2=index+1& for /f "tokens=1,2 delims= " %%j in ("!index! !index2!") do set str2=!str2!!str:~%%j,1!& set str=!str:~0,%%j!!str:~%%k!& set /a len-=1)& for %%i in ("!str2!") do endlocal& set "%%2=%%~i""& goto :EOF



:_true
::得到一个标识成功的值(errorlevel为0), 导入之后使用约定变量_true，注意只能使用%_true%, 不能使用!_true!, 原因未知
::  1.嵌入call调用：放在call代码段最后处使用, 这样call就如同存在一个是否的返回值
::        call :test && echo true || echo false
::        :test
::        %_true%& goto :EOF
::  2.嵌入内敛函数调用
::        内敛函数写法: (if condition (endlocal& %_true%) else (endlocal& %_false%)) ------ 确保此为内敛函数最后一句, 需要将该if语句用括号包围
::        调用者的写法: (%_call% ("myFolder") %_isFolder%) && echo true || echo false ------ echo true处可以使用多个语句,只要包围在括号内
set "_true=echo.>nul"& goto :EOF
:_false
::得到一个标识失败的值(errorlevel大于0), 导入之后使用约定变量_false，注意只能使用%_false%, 不能使用!_false!, 原因未知
::  1.嵌入call调用：放在call代码段最后处使用, 这样call就如同存在一个是否的返回值
::        call :test && echo true || echo false
::        :test
::        %_false%& goto :EOF
::  2.嵌入内敛函数调用
::        内敛函数写法: (if condition (endlocal& %_true%) else (endlocal& %_false%)) ------ 确保此为内敛函数最后一句, 需要将该if语句用括号包围
::        调用者的写法: (%_call% ("myFolder") %_isFolder%) && echo true || echo false ------ echo true处可以使用多个语句,只要包围在括号内
set "_false=set=2>nul"& goto :EOF



:_parseBlockNum
::解析数字字符串为bolckNum形式, 可接受字符[数字 +-*/], 对未知字符使用空格替代
::IN[数字字符串变量名]    IN-OUT[处理后字符串变量名]    OUT[处理后字符串行数]
if not defined _strlen call :_strlen
set "_parseBlockNum=do setlocal enabledelayedexpansion& (%_call% ("%%1 len") %_strlen%)& set "numStr=!%%1!"& set /a len-=1& (for /l %%i in (1,1,5) do set line%%i=)& (for /l %%i in (0,1,!len!) do set char=!numStr:~%%i,1!& set blockChar=& ((if "!char!"=="0" set blockChar=■■■ #■  ■ #■  ■ #■  ■ #■■■ )& (if "!char!"=="1" set blockChar= ■  # ■  # ■  # ■  # ■  )& (if "!char!"=="2" set blockChar=■■■ #    ■ #■■■ #■     #■■■ )& (if "!char!"=="3" set blockChar=■■■ #    ■ #■■■ #    ■ #■■■ )& (if "!char!"=="4" set blockChar=■  ■ #■  ■ #■■■ #    ■ #    ■ )& (if "!char!"=="5" set blockChar=■■■ #■     #■■■ #    ■ #■■■ )& (if "!char!"=="6" set blockChar=■■■ #■     #■■■ #■  ■ #■■■ )& (if "!char!"=="7" set blockChar=■■■ #    ■ #    ■ #    ■ #    ■ )& (if "!char!"=="8" set blockChar=■■■ #■  ■ #■■■ #■  ■ #■■■ )& (if "!char!"=="9" set blockChar=■■■ #■  ■ #■■■ #    ■ #■■■ )& (if "!char!"=="." set blockChar=   #   #   #   #■ )& (if "!char!"==":" set blockChar=   #■ #   #■ #   )& (if "!char!"=="+" set blockChar=       #  ■   #■■■ #  ■   #       )& (if "!char!"=="-" set blockChar=       #       #■■■ #       #       )& (if "!char!"=="*" set blockChar=       #■  ■ #  ■   #■  ■ #       )& (if "!char!"=="/" set blockChar=      #   ■ #  ■  # ■   #      )& (if "!char!"=="=" set blockChar=       #■■■ #       #■■■ #       )& (if "!blockChar!"=="" set blockChar= # # # # ))& for /f "tokens=1-5 delims=#" %%j in ("!blockChar!") do set line1=!line1!%%j& set line2=!line2!%%k& set line3=!line3!%%l& set line4=!line4!%%m& set line5=!line5!%%n)& for /f "tokens=1-5 delims=#" %%i in ("!line1!#!line2!#!line3!#!line4!#!line5!") do endlocal& set %%2_1=%%i& set %%2_2=%%j& set %%2_3=%%k& set %%2_4=%%l& set %%2_5=%%m& set %%3=5"& goto :EOF

:_parseShowBlockNum
::解析数字字符串为bolckNum形式, 并显示, 可接受字符[数字 +-*/], 对未知字符使用空格替代
::IN[数字字符串变量名]    {IN[行前缀]}    {IN[行后缀]}
(if not defined _parseBlockNum call :_parseBlockNum)& (if not defined _showBlockASCII call :_showBlockASCII)
set "_parseShowBlockNum=do setlocal enabledelayedexpansion& (%_call% ("%%1 numStr numLine") %_parseBlockNum%)& (%_call% ("numStr numLine %%2 %%3") %_showBlockASCII%)& endlocal"& goto :EOF

:_parseShowBlockNum2
::解析数字字符串为bolckNum形式, 并显示, 可接受字符[数字 空格 +-*/], 对未知字符使用空格替代
::IN[数字字符串变量名]    {IN[行前缀变量名]}    {IN[行后缀变量名]}
(if not defined _parseBlockNum call :_parseBlockNum)& (if not defined _showBlockASCII2 call :_showBlockASCII2)
set "_parseShowBlockNum2=do setlocal enabledelayedexpansion& (%_call% ("%%1 numStr numLine") %_parseBlockNum%)& (%_call% ("numStr numLine %%2 %%3") %_showBlockASCII2%)& endlocal"& goto :EOF



:_parseASCIIStr
::解析字符串转为ASCII形式, 可接受字符[英文大小写 数字 空格 ~@#$*(-_+=[]{}\:;'.,?/], 对未知字符使用空格替代
::    注意: 大写字母\标点符号是以figlet的banner3.flf字体作为基础，小写字母是以xhelv.flf字体作为基础修改而来，在bat中一些特殊字符不能处理! % & ) | " <> ^
::    注意: 此内敛函数中采用压缩处理, bat中变量值最大长度是8189个字符, 不压缩则长度则超过上限
::          压缩形式[-]=>[           $           $ ####      $##  ##  ## $     ####  $           $       ]=>[H$H$H$7A$H$H$H]，具体参考C:\path\bat\batlearn\ASCIIChar\convert.bat
::IN[字符串变量名]    IN-OUT[处理后字符串变量名]    OUT[处理后字符串行数]
if not defined _strlen call :_strlen
set "_parseASCIIStr=do setlocal enabledelayedexpansion& (%_call% ("%%1 len") %_strlen%)& set "asciiStr=!%%1!"& set /a len-=1& (for /l %%i in (1,1,7) do set line%%i=)& (for /l %%i in (0,1,!len!) do set c=!asciiStr:~%%i,1!& set c2=& ((if "!c!"=="~" set c2=K$K$A4F$2B2B2A$E4B$K$K)& (if "!c!"=="@" set c2=A7B$2E2A$2A3A2A$2A3A2A$2A5B$2H$A7B)& (if "!c!"=="#" set c2=B2A2C$B2A2C$9A$B2A2C$9A$B2A2C$B2A2C)& (if "!c!"=="$" set c2=A8B$2B2B2A$2B2E$A8B$D2B2A$2B2B2A$A8B)& (if "!c!"=="*" set c2=J$A2C2B$B2A2C$9A$B2A2C$A2C2B$J)& (if "!c!"=="(" set c2=B3A$A2C$2D$2D$2D$A2C$B3A)& (if "!c!"=="-" set c2=H$H$H$7A$H$H$H)& (if "!c!"=="_" set c2=H$H$H$H$H$H$7A)& (if "!c!"=="+" set c2=G$B2C$B2C$6A$B2C$B2C$G)& (if "!c!"=="=" set c2=F$F$5A$F$5A$F$F)& (if "!c!"=="[" set c2=6A$2E$2E$2E$2E$2E$6A)& (if "!c!"=="]" set c2=6A$D2A$D2A$D2A$D2A$D2A$6A)& (if "!c!"=="{" set c2=B4A$A2D$A2D$3D$A2D$A2D$B4A)& (if "!c!"=="}" set c2=4C$C2B$C2B$C3A$C2B$C2B$4C)& (if "!c!"=="\" set c2=2G$A2F$B2E$C2D$D2C$E2B$F2A)& (if "!c!"==":" set c2=E$4A$4A$E$4A$4A$E)& (if "!c!"==";" set c2=4A$4A$E$4A$4A$A2B$2C)& (if "!c!"=="'" set c2=4A$4A$A2B$E$E$E$E)& (if "!c!"=="." set c2=D$D$D$D$D$3A$3A)& (if "!c!"=="," set c2=E$E$E$4A$4A$A2B$2C)& (if "!c!"=="?" set c2=A7B$2E2A$F2B$D3C$C2E$J$C2E)& (if "!c!"=="/" set c2=F2A$E2B$D2C$C2D$B2E$A2F$2G)& (if "!c!"=="0" set c2=B5C$A2C2B$2E2A$2E2A$2E2A$A2C2B$B5C)& (if "!c!"=="1" set c2=C2C$A4C$C2C$C2C$C2C$C2C$A6A)& (if "!c!"=="2" set c2=A7B$2E2A$G2A$A7B$2H$2H$9A)& (if "!c!"=="3" set c2=A7B$2E2A$G2A$A7B$G2A$2E2A$A7B)& (if "!c!"=="4" set c2=2H$2D2B$2D2B$2D2B$9A$F2B$F2B)& (if "!c!"=="5" set c2=8A$2G$2G$7B$F2A$2D2A$A6B)& (if "!c!"=="6" set c2=A7B$2E2A$2H$8B$2E2A$2E2A$A7B)& (if "!c!"=="7" set c2=8A$2D2A$D2C$C2D$B2E$B2E$B2E)& (if "!c!"=="8" set c2=A7B$2E2A$2E2A$A7B$2E2A$2E2A$A7B)& (if "!c!"=="9" set c2=A7B$2E2A$2E2A$A8A$G2A$2E2A$A7B)& (if "!c!"=="a" set c2=H$A4C$D2B$A5B$2B2B$A4A1A$H)& (if "!c!"=="b" set c2=2F$2F$2A3B$3B2A$3B2A$2A3B$H)& (if "!c!"=="c" set c2=G$A4B$2B2A$2E$2B2A$A4B$G)& (if "!c!"=="d" set c2=D2A$D2A$A5A$2B2A$2B2A$A5A$G)& (if "!c!"=="e" set c2=G$A4B$2B2A$6A$2E$A5A$G)& (if "!c!"=="f" set c2=A3A$A2B$4A$A2B$A2B$A2B$E)& (if "!c!"=="g" set c2=H$A5B$2C2A$2C2A$A6A$E2A$A5B)& (if "!c!"=="h" set c2=2E$2E$5B$2B2A$2B2A$2B2A$G)& (if "!c!"=="i" set c2=2A$C$2A$2A$2A$2A$C)& (if "!c!"=="j" set c2=A2A$D$A2A$A2A$A2A$A2A$2B)& (if "!c!"=="k" set c2=2E$2B2A$2A2B$4C$2A2B$2B2A$G)& (if "!c!"=="l" set c2=2A$2A$2A$2A$2A$2A$C)& (if "!c!"=="m" set c2=K$A3A4B$2B2B2A$2B2B2A$2B2B2A$2B2B2A$K)& (if "!c!"=="n" set c2=H$A5B$2C2A$2C2A$2C2A$2C2A$H)& (if "!c!"=="o" set c2=H$A5B$2C2A$2C2A$2C2A$A5B$H)& (if "!c!"=="p" set c2=H$6B$2C2A$2C2A$6B$2F$2F)& (if "!c!"=="q" set c2=H$B5A$2C2A$2C2A$A6A$E2A$E2A)& (if "!c!"=="r" set c2=F$2A2A$2A1B$3C$2D$2D$F)& (if "!c!"=="s" set c2=G$A4B$2E$A4B$D2A$A4B$G)& (if "!c!"=="t" set c2=E$A2B$4A$A2B$A2B$A3A$E)& (if "!c!"=="u" set c2=G$2B2A$2B2A$2B2A$2B2A$A3A1A$G)& (if "!c!"=="v" set c2=H$2C2A$2C2A$A2A2B$A2A2B$C1D$H)& (if "!c!"=="w" set c2=K$2B2B2A$A2A2A2B$A2A2A2B$B2B2C$C1B1D$K)& (if "!c!"=="x" set c2=I$2D2A$A2B2B$C2D$A2B2B$2D2A$I)& (if "!c!"=="y" set c2=H$2C2A$2B2B$A4C$B2D$A2E$2F)& (if "!c!"=="z" set c2=G$6A$C2B$B2C$A2D$6A$G)& (if "!c!"=="A" set c2=C3D$B2A2C$A2C2B$2E2A$9A$2E2A$2E2A)& (if "!c!"=="B" set c2=8B$2E2A$2E2A$8B$2E2A$2E2A$8B)& (if "!c!"=="C" set c2=A6B$2D2A$2G$2G$2G$2D2A$A6B)& (if "!c!"=="D" set c2=8B$2E2A$2E2A$2E2A$2E2A$2E2A$8B)& (if "!c!"=="E" set c2=8A$2G$2G$6C$2G$2G$8A)& (if "!c!"=="F" set c2=8A$2G$2G$6C$2G$2G$2G)& (if "!c!"=="G" set c2=A6C$2D2B$2H$2C4A$2D2B$2D2B$A6C)& (if "!c!"=="H" set c2=2E2A$2E2A$2E2A$9A$2E2A$2E2A$2E2A)& (if "!c!"=="I" set c2=4A$A2B$A2B$A2B$A2B$A2B$4A)& (if "!c!"=="J" set c2=F2A$F2A$F2A$F2A$2D2A$2D2A$A6B)& (if "!c!"=="K" set c2=2D2A$2C2B$2B2C$5D$2B2C$2C2B$2D2A)& (if "!c!"=="L" set c2=2G$2G$2G$2G$2G$2G$8A)& (if "!c!"=="M" set c2=2E2A$3C3A$4A4A$2A3A2A$2E2A$2E2A$2E2A)& (if "!c!"=="N" set c2=2D2A$3C2A$4B2A$2A2A2A$2B4A$2C3A$2D2A)& (if "!c!"=="O" set c2=A7B$2E2A$2E2A$2E2A$2E2A$2E2A$A7B)& (if "!c!"=="P" set c2=8B$2E2A$2E2A$8B$2H$2H$2H)& (if "!c!"=="Q" set c2=A7B$2E2A$2E2A$2E2A$2B2A2A$2D2B$A5A2A)& (if "!c!"=="R" set c2=8B$2E2A$2E2A$8B$2C2C$2D2B$2E2A)& (if "!c!"=="S" set c2=A6B$2D2A$2G$A6B$F2A$2D2A$A6B)& (if "!c!"=="T" set c2=8A$C2D$C2D$C2D$C2D$C2D$C2D)& (if "!c!"=="U" set c2=2E2A$2E2A$2E2A$2E2A$2E2A$2E2A$A7B)& (if "!c!"=="V" set c2=2E2A$2E2A$2E2A$2E2A$A2C2B$B2A2C$C3D)& (if "!c!"=="W" set c2=2F2A$2B2B2A$2B2B2A$2B2B2A$2B2B2A$2B2B2A$A3B3B)& (if "!c!"=="X" set c2=2E2A$A2C2B$B2A2C$C3D$B2A2C$A2C2B$2E2A)& (if "!c!"=="Y" set c2=2D2A$A2B2B$B4C$C2D$C2D$C2D$C2D)& (if "!c!"=="Z" set c2=8A$E2B$D2C$C2D$B2E$A2F$8A)& (if "!c2!"=="" set c2=C$C$C$C$C$C$C))& ((set c2=!c2:K=           !)& (set c2=!c2:J=          !)& (set c2=!c2:I=         !)& (set c2=!c2:H=        !)& (set c2=!c2:G=       !)& (set c2=!c2:F=      !)& (set c2=!c2:E=     !)& (set c2=!c2:D=    !)& (set c2=!c2:C=   !)& (set c2=!c2:B=  !)& (set c2=!c2:A= !)& (set c2=!c2:9=#########!)& (set c2=!c2:8=########!)& (set c2=!c2:7=#######!)& (set c2=!c2:6=######!)& (set c2=!c2:5=#####!)& (set c2=!c2:4=####!)& (set c2=!c2:3=###!)& (set c2=!c2:2=##!)& (set c2=!c2:1=#!))& for /f "tokens=1-7 delims=$" %%j in ("!c2!") do set line1=!line1!%%j& set line2=!line2!%%k& set line3=!line3!%%l& set line4=!line4!%%m& set line5=!line5!%%n& set line6=!line6!%%o& set line7=!line7!%%p)& for /f "tokens=1-7 delims=$" %%i in ("!line1!$!line2!$!line3!$!line4!$!line5!$!line6!$!line7!") do endlocal& set %%2_1=%%i& set %%2_2=%%j& set %%2_3=%%k& set %%2_4=%%l& set %%2_5=%%m& set %%2_6=%%n& set %%2_7=%%o& set %%3=7"& goto :EOF

:_parseShowASCIIStr
::解析字符串转为ASCII形式, 并显示, 可接受字符[英文大小写 数字 空格 ~@#$*(-_+=[]{}\:;'.,?/], 对未知字符使用空格替代
::    注意: 大写字母\标点符号是以figlet的banner3.flf字体作为基础，小写字母是以xhelv.flf字体作为基础修改而来，在bat中一些特殊字符不能处理! % & ) | " <> ^
::    注意: 此内敛函数中采用压缩处理, bat中变量值最大长度是8189个字符, 不压缩则长度则超过上限
::          压缩形式[-]=>[           $           $ ####      $##  ##  ## $     ####  $           $       ]=>[H$H$H$7A$H$H$H]，具体参考C:\path\bat\batlearn\ASCIIChar\convert.bat
::IN[字符串变量名]      {IN[行前缀]}      {IN[行后缀]}
(if not defined _parseASCIIStr call :_parseASCIIStr)& (if not defined _showBlockASCII call :_showBlockASCII)
set "_parseShowASCIIStr=do setlocal enabledelayedexpansion& (%_call% ("%%1 asciiStr asciiLine") %_parseASCIIStr%)& (%_call% ("asciiStr asciiLine %%2 %%3") %_showBlockASCII%)& endlocal"& goto :EOF

:_parseShowASCIIStr2
::解析字符串转为ASCII形式, 并显示, 可接受字符[英文大小写 数字 空格 ~@#$*(-_+=[]{}\:;'.,?/], 对未知字符使用空格替代
::    注意: 大写字母\标点符号是以figlet的banner3.flf字体作为基础，小写字母是以xhelv.flf字体作为基础修改而来，在bat中一些特殊字符不能处理! % & ) | " <> ^
::    注意: 此内敛函数中采用压缩处理, bat中变量值最大长度是8189个字符, 不压缩则长度则超过上限
::          压缩形式[-]=>[           $           $ ####      $##  ##  ## $     ####  $           $       ]=>[H$H$H$7A$H$H$H]，具体参考C:\path\bat\batlearn\ASCIIChar\convert.bat
::IN[字符串变量名]      {IN[行前缀变量名]}      {IN[行后缀变量名]}
(if not defined _parseASCIIStr call :_parseASCIIStr)& (if not defined _showBlockASCII2 call :_showBlockASCII2)
set "_parseShowASCIIStr2=do setlocal enabledelayedexpansion& (%_call% ("%%1 asciiStr asciiLine") %_parseASCIIStr%)& (%_call% ("asciiStr asciiLine %%2 %%3") %_showBlockASCII2%)& endlocal"& goto :EOF


:_showBlockASCII
::显示bolckNum\ ASCIIStr字符串
::IN[字符串变量名]    IN[行数变量名]    {IN[行前缀]}    {IN[行后缀]}
set "_showBlockASCII=do setlocal enabledelayedexpansion& (for /l %%i in (1,1,!%%2!) do echo.%%3!%%1_%%i!%%4)& endlocal"& goto :EOF
:_showBlockASCII2
::显示bolckNum\ ASCIIStr字符串
::IN[字符串变量名]    IN[行数变量名]    {IN[行前缀变量名]}    {IN[行后缀变量名]}
set "_showBlockASCII2=do setlocal enabledelayedexpansion& (for /l %%i in (1,1,!%%2!) do echo.!%%3!!%%1_%%i!!%%4!)& endlocal"& goto :EOF


:_playMusicMini
::指定次数播放音乐集, 需要工具gplay.exe支持
::IN[musicPaths][路径有空格加双引号][多个路径使用空格间隔]    IN[times][不写或者0表示循环]
call loadE.bat gplay
set "_playMusicMini=do setlocal enabledelayedexpansion& (if "%%2"=="" (set times=) else (if %%2==0 (set times=) else (set times=1,1,%%2)))& (for /l %%i in (!times!) do %gplay% !%%1!>nul 2>nul)& endlocal"& goto :EOF

:_playMusic
::指定播放模式播放音乐集, 需要gplay.exe支持
::IN[musicPaths][路径有空格加双引号][多个路径使用空格间隔]    IN[mode][单曲播放0\单曲循环1\顺序播放2\循环播放3\随机播放4]
call loadE.bat gplay
if not defined _getRandomNum call :_getRandomNum
set "_playMusic=do setlocal enabledelayedexpansion& (if "%%2"=="" (set mode=0) else (set mode=%%2))& (if !mode!==0 set times=1,1,1& set musicPath=& for %%i in (!%%1!) do if not defined musicPath set musicPath=%%i)& (if !mode!==1 set times=& set musicPath=& for %%i in (!%%1!) do if "!musicPath!"=="" set musicPath=%%i)& (if !mode!==2 set times=1,1,1& set musicPath=!%%1!)& (if !mode!==3 set times=& set musicPath=!%%1!)& (if !mode!==4 set times=& set musicPath=!%%1!& set musicIndex=0& (for %%i in (!%%1!) do set /a musicIndex+=1& set musicPath_!musicIndex!=%%i)& set musicIndexMax=!musicIndex!)& (for /l %%i in (!times!) do (if !mode!==4 (%_call% ("1 !musicIndexMax! musicIndex") %_getRandomNum%)& for %%j in (!musicIndex!) do set musicPath=!musicPath_%%j!)& %gplay% !musicPath!>nul 2>nul)& endlocal"& goto :EOF



:_setFontSize
::修改cmd窗口字体大小   目前只支持[点阵字体]
::    注意:注册表中FontSize字段[高四位为字高, 低四位为字宽], 如00100008，即字体宽x高=16进制08Hx10H=10进制8×16
::IN[字体宽x高][8x16]
set "_setFontSize=do setlocal enabledelayedexpansion& set fontSize=& (if %%1==3x5 set fontSize=0x00050003)& (if %%1==5x8 set fontSize=0x00080005)& (if %%1==6x12 set fontSize=0x000c0006)& (if %%1==8x16 set fontSize=0x00100008)& (if %%1==8x18 set fontSize=0x00120008)& (if %%1==10x20 set fontSize=0x0014000a)& (if defined fontSize reg add "HKEY_CURRENT_USER\Console\%%SystemRoot%%_system32_cmd.exe" /v "FontSize" /t REG_DWORD /d !fontSize! /f >nul)"& goto :EOF



:_setWallpaper
::设置桌面壁纸  会在%temp%目录生成tool_setWallpaper.vbs
::IN[壁纸路径变量名]
set "_setWallpaper=do setlocal enabledelayedexpansion& (if not exist %temp%\tool_setWallpaper.vbs (echo Dim shApp, picFile, items& echo Set shApp = CreateObject^("Shell.Application"^)& echo Set picFile = CreateObject^("Scripting.FileSystemObject"^).GetFile^(Wscript.Arguments^(0^)^)& echo Set items = shApp.NameSpace^(picFile.ParentFolder.Path^).ParseName^(picFile.Name^).Verbs& echo For Each item In items& echo   If item.Name = "设置为桌面背景(^&B)" Then item.DoIt& echo Next& echo WScript.Sleep 3000)>%temp%\tool_setWallpaper.vbs)& for /f "delims=" %%i in ("!%%1!") do call %temp%\tool_setWallpaper.vbs "%%~i""& goto :EOF



:_readConfig
::读取指定配置文件指定key值      从配置文件中读出键为key的值, 如果value参数存在, 将值设置到value中, 否则设置到key中
::    注意:for语句读取文件时默认跳过;开头的行, 因此;开头的行可以作为注释
::IN[配置文件路径]    IN[key]    {OUT[value变量名]}
set "_readConfig=do setlocal enabledelayedexpansion& for /f "tokens=1* delims==" %%i in (%%1) do if %%i==%%2 endlocal& if "%%3" EQU "" (set "%%2=%%j") else (set "%%3=%%j")"& goto :EOF

:_readConfigMulti
::读取指定配置文件指定的多个key值      从配置文件中读出键为key的值, 如果value参数存在, 将值设置到value中, 否则设置到key中
::    注意:for语句读取文件时默认跳过;开头的行, 因此;开头的行可以作为注释
::IN[配置文件路径]    IN-OUT[keys变量名][空格分隔key]
set "_readConfigMulti=do setlocal enabledelayedexpansion& (for /f "tokens=1* delims==" %%i in (%%1) do (for %%k in (!%%2!) do (if %%i==%%k endlocal& set "%%k=%%j"& setlocal enabledelayedexpansion)))& endlocal"& goto :EOF
REM set "_readConfigMulti=do setlocal enabledelayedexpansion& for /f "tokens=1* delims==" %%i in (%%1) do (for %%k in (!%%2!) do (if %%i==%%k endlocal& set "%%k=%%j")& setlocal enabledelayedexpansion)& endlocal"& goto :EOF


:_writeConfig
::读取指定配置文件指定key值      从配置文件中寻找键为key的行, 如果value参数存在, 将值设为value, 否则读取key变量值
::    注意:for语句读取文件时默认跳过;开头的行, 因此;开头的行可以作为注释
::IN[配置文件路径]    IN[key变量名]    {IN[value]}
set "_writeConfig=do setlocal enabledelayedexpansion& (for /f "eol= delims=" %%i in (%%1) do set line=%%i& if "!line:~0,1!"==";" (echo %%i) else (for /f "tokens=1* delims==" %%j in ("!line!") do if %%j==%%2 (if "%%3" EQU "" (echo %%j=!%%2!) else (echo %%j=%%3)) else (echo %%i)))>>%temp%\config.tmp& (copy /y %temp%\config.tmp %%1>nul)& (del /q %temp%\config.tmp)& endlocal"& goto :EOF
:_writeConfig2
::IN[配置文件路径]    IN[key变量名]    {IN[value变量名]}
set "_writeConfig2=do setlocal enabledelayedexpansion& (for /f "eol= delims=" %%i in (%%1) do set line=%%i& if "!line:~0,1!"==";" (echo %%i) else (for /f "tokens=1* delims==" %%j in ("!line!") do if %%j==%%2 (if "%%3" EQU "" (echo %%j=!%%2!) else (echo %%j=!%%3!)) else (echo %%i)))>>%temp%\config.tmp& (copy /y %temp%\config.tmp %%1>nul)& (del /q %temp%\config.tmp)& endlocal"& goto :EOF

:_writeConfigMulti
::将指定的多个key值写入配置文件
::    注意:for语句读取文件时默认跳过;开头的行, 因此;开头的行可以作为注释
::IN[配置文件路径]    IN[keys变量名][空格分隔key]
set "_writeConfigMulti=do setlocal enabledelayedexpansion& (for /f "eol= delims=" %%i in (%%1) do set line=%%i& if "!line:~0,1!"==";" (echo %%i) else (for /f "tokens=1* delims==" %%j in ("!line!") do (set flag=0& (for %%k in (!%%2!) do if %%j==%%k set flag=1& echo %%j=!%%k!)& if !flag!==0 echo %%i)))>>%temp%\config.tmp& (copy /y %temp%\config.tmp %%1>nul)& (del /q %temp%\config.tmp)& endlocal"& goto :EOF




:_readConfig
::读取指定配置文件指定key值      从配置文件中读出键为key的值, 如果value参数存在, 将值设置到value中, 否则设置到key中
::    注意:for语句读取文件时默认跳过;开头的行, 因此;开头的行可以作为注释
::IN[配置文件路径]    IN[key]    {OUT[value变量名]}
set "_readConfig=do setlocal enabledelayedexpansion& for /f "tokens=1* delims==" %%i in (%%1) do if %%i==%%2 endlocal& if "%%3" EQU "" (set "%%2=%%j") else (set "%%3=%%j")"& goto :EOF



:_getDate
::取当前的年月日
::OUT[年-月-日] {IN[separator连接符], 默认值为空}
set "_getDate=do setlocal enabledelayedexpansion& set dateTemp=!date:~0,10!& for %%i in ("!dateTemp:/=%%2!") do endlocal& set %%1=%%~i"& goto :EOF
:_getYear
::取当前的年
::OUT[年]
set "_getYear=do setlocal enabledelayedexpansion& for %%i in ("!date:~0,4!") do endlocal& set %%1=%%~i"& goto :EOF
:_getMonth
::取当前的月
::OUT[月] {IN[needRemoveZeroPrefix]: 0否 1是}
::set "_getMonth=do setlocal enabledelayedexpansion& (if "!date:~5,1!" EQU "0" if "%%2" EQU "1" (set monthTemp=!date:~6,1!) else (set monthTemp=!date:~5,2!))& for %%i in (!monthTemp!) do endlocal& set %%1=%%i"& goto :EOF
set "_getMonth=do setlocal enabledelayedexpansion& (if "!date:~5,1!" EQU "0" if "%%2" EQU "1" (set needRemoveZeroPrefix=1) else (set needRemoveZeroPrefix=0))& (if !needRemoveZeroPrefix!==1 (set monthTemp=!date:~6,1!) else (set monthTemp=!date:~5,2!))& for %%i in (!monthTemp!) do endlocal& set %%1=%%i"& goto :EOF
:_getDay
::取当前的日
::OUT[日] {IN[needRemoveZeroPrefix]: 0否 1是}
set "_getDay=do setlocal enabledelayedexpansion& (if "!date:~8,1!" EQU "0" if "%%2" EQU "1" (set needRemoveZeroPrefix=1) else (set needRemoveZeroPrefix=0))& (if !needRemoveZeroPrefix!==1 (set dayTemp=!date:~9,1!) else (set dayTemp=!date:~8,2!))& for %%i in (!dayTemp!) do endlocal& set %%1=%%i"& goto :EOF



:_bell
::发声
set "_bell=echo "& goto :EOF



:_isOddNum
::是否是奇数   调用者: [(调用内敛函数) && echo isOddNum || echo non-isOddNum]
::IN[变量名]
(if not defined _true call :_true)& (if not defined _false call :_false)
set "_isOddNum=do setlocal enabledelayedexpansion& set /a mod=!%%1! %% 2& if "!mod!"=="1" (endlocal& %_true%) else (endlocal& %_false%)"& goto :EOF



:_isEvenNum
::是否是偶数   调用者: [(调用内敛函数) && echo isEvenNum || echo non-isEvenNum]
::IN[变量名]
(if not defined _true call :_true)& (if not defined _false call :_false)
set "_isEvenNum=do setlocal enabledelayedexpansion& set /a mod=!%%1! %% 2& if "!mod!"=="0" (endlocal& %_true%) else (endlocal& %_false%)"& goto :EOF



:_showHR
::打印横线
::IN[元素(默认-)]    IN[长度(默认10)]
set "_showHR=do setlocal enabledelayedexpansion& (if "%%1" EQU "" (set hrElement=-) else (set hrElement=%%1))& (if "%%2" EQU "" (set hrLen=10) else (set hrLen=%%2))& set hrStr=& (for /l %%i in (1,1,!hrLen!) do set hrStr=!hrStr!!hrElement!)& echo !hrStr!"& goto :EOF



:_getMinNum
::取指定范围内的随机数
::IN[数字1]    IN[数字2]    OUT[最小数]
set "_getMinNum=do if %%1 GTR %%2 (set /a %%3=%%2) else (set /a %%3=%%1)"& goto :EOF



:_getConsoleCurColor
::获取cmd当前颜色
::OUT[cmd当前颜色]
set _getConsoleCurColorTemp=%%SystemRoot%%
set "_getConsoleCurColor=do setlocal enabledelayedexpansion& for /f "skip=2 tokens=2* delims= " %%i in ('reg query "HKEY_CURRENT_USER\Console\%%_getConsoleCurColorTemp%%_system32_cmd.exe" /v ScreenColors') do endlocal& set %%1=%%j"& goto :EOF



:_getThemeColor
::获取当前主题颜色 颜色目前不是实时刷新的[不建议使用]
::OUT[当前主题颜色]
set "_getThemeColor=do for /f "skip=2 tokens=2* delims= " %%i in ('reg query "HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize" /v SpecialColor') do set %%1=%%j"& goto :EOF


:_fillZero
::对于数字小于10的进行补零操作
::IN-OUT[数字变量名]
set "_fillZero=do setlocal enabledelayedexpansion& set value=!%%~1!& for %%i in (!value!) do ((set /a flag=%%i*1 >nul 2>nul)& if "!flag!"=="!value!" (if !%%~1! LSS 10 (endlocal& set %%1=0%%i) else (endlocal& set %%1=%%i)) else (endlocal& set %%1=00))"& goto :EOF


:_pass
::占位语句, 什么也不做
set "_pass=ver >nul"& goto :EOF


:_getProxyStatus
::获取系统代理设置状态
::OUT[代理设置状态]
set "_getProxyStatus=do for /f "skip=2 tokens=2* delims= " %%i in ('reg query "HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings" /v ProxyEnable') do set %%1=%%j"& goto :EOF



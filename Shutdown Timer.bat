@Echo off & title Shutdown Timer & mode 60,5
SETLOCAL EnableExtensions DisableDelayedExpansion
for /F %%a in (
'echo prompt $E ^| cmd'
) do (
  set "ESC=%%a"
)
:Action

ECHO Choose the action you want to excute:
ECHO 1)%ESC%[31mShutdown%ESC%[0m 	2)%ESC%[32mRestart%ESC%[0m	3)%ESC%[33mHibernate%ESC%[0m	4)%ESC%[34mSign out%ESC%[0m

Set /p action=Your Choice? 

if %action% GTR 4 (
   ECHO.
   ECHO %ESC%[31mError: Wrong Choise. Retry...%ESC%[0m
   ECHO.
   goto :Action
)

if %action% LSS 1 (
   ECHO.
   ECHO %ESC%[31mError: Wrong Choise. Retry...%ESC%[0m
   ECHO.
   goto :Action
)

cls

ECHO Input the time you want...

:Hour

Set /p h=Hour: 

if %h% GTR 12 (
   ECHO.
   ECHO %ESC%[31m	Error: Wrong Input. Input must be between 0 and 12.%ESC%[0m
   ECHO.
   goto :Hour
)

:Min

Set /p m=Minutes: 

if %m% GEQ 60 (
   ECHO.
   ECHO %ESC%[31m	Error: Wrong Input. Input must be between 0 and 60.%ESC%[0m
   ECHO.
   goto :Min
)

:Day

Set /p t=[1]PM or [2]AM ? 

if %t% GTR 2 (
   goto :ErrorD
)

if %t% LEQ 0 (
   goto :ErrorD
)

if %m% LEQ 9 (
   Set m=0%m%
)

if %t% == 1 (
   Set tm=pm
) else (
   Set tm=am
)

Set s=0

mode 45,3

:Time

if %h% GTR 12 (
   Set /a "h=%h% - 12"
)

cls

if %action%==1 ECHO This PC will %ESC%[7mSHUTDOWN%ESC%[0m at %ESC%[36m%h%:%m% %tm%%ESC%[0m
if %action%==2 ECHO This PC will %ESC%[7mRESTART%ESC%[0m at %ESC%[36m%h%:%m% %tm%%ESC%[0m
if %action%==3 ECHO This PC will %ESC%[7mHIBERNATE%ESC%[0m at %ESC%[36m%h%:%m% %tm%%ESC%[0m
if %action%==4 ECHO This user will be %ESC%[7mSIGNED OUT%ESC%[0m %ESC%[36mat %h%:%m% %tm%%ESC%[0m

if %t% == 1 (
   Set /a "h=%h% + 12"
)

Set /a "hour=%h% - %time:~0,2%"

if %time:~0,2% GTR %h% (
   Set /a "hour=%hour% + 24"
)

if %time:~0,2% EQU %h% (
   if %time:~3,2% GTR %m% (
	Set /a "hour=%hour% + 24"
   )
)

if %m% LSS %time:~3,2% (
   Set /a "hour=%hour% - 1"
   if %time:~3,2% LSS 10 (
      Set /a "min=%m% + 60 - %time:~4,1%"
   ) else (
      Set /a "min=%m% + 60 - %time:~3,2%"
   )
) else (
   if %time:~3,2% LSS 10 (
      Set /a "min=%m% - %time:~4,1%"
   ) else (
      Set /a "min=%m% - %time:~3,2%"
   )
)

if %s% LSS %time:~6,2% (
   Set /a "min=%min% - 1"
   if %time:~6,2% LSS 10 (
	Set /a "sec=%s% + 60 - %time:~7,1%"
   ) else (
   	Set /a "sec=%s% + 60 - %time:~6,2%" 
   )
)

if %sec% GTR 0 (
   Set /a "sec=%sec% - 1"
) else (
   Set sec=59
   if %min% GTR 0 (
      Set /a "min=%min% - 1"
   ) else ( 
      Set min=59
      Set /a "hour=%hour% - 1"
   )
)

if %hour% LSS 10 (
   Set hour1=0%hour%
) else (
   Set hour1=%hour%
)

if %min% LSS 10 (
   Set min1=0%min%
) else (
   Set min1=%min%
)

if %sec% LSS 10 (
   Set sec1=0%sec%
) else (
   Set sec1=%sec%
)

Set /a "total=(hour*60+min)*60+sec"

echo Which will occur after %ESC%[94m%hour1%:%min1%:%sec1%%ESC%[0m (%ESC%[33m%total%%ESC%[0m sec)

if %total% LEQ 60 goto :Done

timeout /t 1 /nobreak >nul

goto :Time

:ErrorD

ECHO.
ECHO %ESC%[31m	Error: Wrong input. Choose between 1 and 2.%ESC%[0m
ECHO.

goto :Day

:Done

if %action%==1 msg * /time:60 Warning: This PC will SHUTDOWN in less than 1 min !
if %action%==2 msg * /time:60 Warning: This PC will RESTART in less than 1 min !
if %action%==3 msg * /time:60 Warning: This PC will HIBERNATE in less than 1 min !
if %action%==4 msg * /time:60 Warning: This PC will SIGN OUT in less than 1 min !

mode 65,2

:Timer

cls

if %action%==1 echo %ESC%[33mWarning:%ESC%[0m This PC will %ESC%[1mSHUTDOWN%ESC%[0m in %ESC%[33m%total%%ESC%[0m ! Press Ctrl+C to abort.
if %action%==2 echo %ESC%[33mWarning:%ESC%[0m This PC will %ESC%[1mRESTART%ESC%[0m in %ESC%[33m%total%%ESC%[0m ! Press Ctrl+C to abort.
if %action%==3 echo %ESC%[33mWarning:%ESC%[0m This PC will %ESC%[1mHIBERNATE%ESC%[0m in %ESC%[33m%total%%ESC%[0m ! Press Ctrl+C to abort.
if %action%==4 echo %ESC%[33mWarning:%ESC%[0m This PC will %ESC%[1mSIGN OUT%ESC%[0m in %ESC%[33m%total%%ESC%[0m ! Press Ctrl+C to abort.

PowerShell.exe -Window Normal { cmd.exe } >nul

if %total% LEQ 0 (
   if %action%==1 shutdown.exe -s -f
   if %action%==2 shutdown.exe -r
   if %action%==3 shutdown.exe -h
   if %action%==4 shutdown.exe -l

   exit
)

Set /a "total=%total% - 1"

timeout /t 1 /nobreak >nul

goto :Timer
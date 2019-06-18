@echo off
pushd %~dp0
set ubuvers=1.74.0.3
set ubuup=17x

set sdir=Files\intel
set sdig=Files\intel\gop
set sdiv=Files\intel\vbios
set sdli=Files\Intel\lan
set sdim=Files\Intel\mcode

set sdar=Files\amd\raid
set sdag=Files\amd\gop
set sdav=Files\amd\vbios
set sdam=Files\amd\mcode

set sdlr=Files\Realtek
set sdlb=Files\Broadcom
set sdllx=Files\Lx
set sdly=Files\Yukon

set sdsm=Files\Marvell
set sdsa=Files\ASMedia
set sdsj=Files\JMicron

set wf=Files\Workfiles

set uf=uefifind bios.bin
set ufbl=uefifind bios.bin body list
set ue=uefiextract bios.bin
set renb=if exist tmpr\body.bin move tmpr\body.bin
set renf=if exist tmpr\file.ffs move tmpr\file.ffs
set rdir=if exist tmpr rd /s /q tmpr
set ur=uefireplace bios.bin

set ok=File replaced

set pguid=00000000-0000-0000-0000-000000000000

for %%a in (UEFIReplace.exe UEFIReplace_025.exe UEFIFind.exe UEFIExtract.exe DrvVer.exe FindVer.exe findhex.exe mCodeFIT.exe SetDevID.exe cecho.exe) do (
 	if not exist %%a echo !!! %%a not found !!! && pause && exit
)

for /f "tokens=*" %%f in ('dir /a-d *.CAP *.ROM *.F?? *.BS? *.0?? *.1?? *.2?? *.3?? *.4?? *.5?? *.6?? *.7?? *.8?? *.9?? *.??0 *.??1 *.??2 *.??3 *.??4 bios.bin /b') do (
 	echo %%f
	set biosname=%%f
	if /I %%f==bios.bin goto rises
 	if /I exist bios.bin del /f /q bios.bin && ren "%%f" bios.bin && goto rises
	if /I not exist bios.bin ren "%%f" bios.bin && goto rises
)

setlocal
for /f "usebackq delims=" %%i in (
	`@"%systemroot%\system32\mshta.exe" "about:<FORM><INPUT type='file' name='qq'></FORM><script>document.forms[0].elements[0].click();var F=document.forms[0].elements[0].value;try {new ActiveXObject('Scripting.FileSystemObject').GetStandardStream(1).Write(F)};catch (e){};close();</script>" ^
	1^|more`
) do copy "%%i" "%~dp0\bios.bin">nul && set biosname=%%~nxi
if not exist bios.bin goto err
endlocal && set biosname=%biosname%

:rises
set tit=title UEFI BIOS Updater v%ubuvers% - %biosname%
%tit%
set capdel=
%uf% header count 8BA63C4A2377FB48803D578CC1FEC44D>nul && UEFIExtract bios.bin 4A3CA68B-7723-48FB-803D-578CC1FEC44D>nul && echo Remove Capsule Header
if exist bios.bin.dump copy /y bios.bin.dump\body.bin "%~dp0\bios.bin">nul
set fit=0
%ufbl% 5F4649545F202020..0000000001>nul && set fit=1
if %fit%==1 mcodefit -fit_backup bios.bin

:rise
if exist ubu%ubuup%_upd*.exe for /f %%f in ('dir ubu%ubuup%_upd*.exe /b') do start /wait %%f -y && del /f /q %%f
findhex FFFFFFFFEAD0FF00F0000000000000000000272DFFFFFFFF bios.bin>nul && set ur=uefireplace_025 bios.bin

:mn
cls
if exist tmp (del /f /q tmp\*.*) else (md tmp)
 %rdir%
if exist _OROM_in_FFS.txt del /f /q _OROM_in_FFS.txt

set irst=0
set irste=0
set vmd=0
set vmdd=0
set rxpt2=0
set o43xx=0
set o78xx=0
set mrvl=0
set mrvl61=0
set mrvl91=0
set mrvl92=0
set asmo=0
set jmbo=0
set lani=0
set lanrtk=0
set rtk1=0
set rtk2=0
set lanlx=0
set lanbcm=0
set lanyuk=0
set m1=0
set m2=0
set m3=0
set m4=0
set m5=0
set m6=0
set m7=0
set m8=0
set m9=0
set csm=0
set asus=0
set caphdr=0
set aa=0
set mc_pad=0
set gmc_count=0
set amd=0
set mmtool=0

echo Scanning BIOS file %biosname%. 
echo Please wait...
<nul set /p TmpStr=BIOS platform - 
%uf% body count 244649440.......................................................3034>nul && echo AMI Aptio 4 && set aa=4 && goto next
%uf% body count 244649440.......................................................3035>nul && echo AMI Aptio V && set aa=5 && goto next
(%uf% body count 49006E00740065006C00AE004400650073006B0074006F007000200042006F00610072006400>nul || %uf% body count 49006E00740065006C00........4400650073006B0074006F007000200042006F00610072006400>nul) && echo Intel Desktop Board. Not supported. && goto exit1
%uf% body count 494E5359444548324F>nul && echo InsydeH2O
rem Not supported. && pause && goto exit1
%uf% body count 50686F656E697820534354>nul && echo PhoenixSCT

:next
%uf% body count 4153555342....24>nul && set asus=1
if %aa%==0 goto next1

%ue% AB56DC60-0057-11DA-A8DB-000102EEE626 -o mfactur -m body -t 18>nul
if exist mfactur\body.bin (
	findhex 4153526F636B mfactur\body.bin>nul || findver "BIOS version  - " 4D6567617472656E647320496E632E 16 00 10 1 mfactur\body.bin
	findver "Manufacturer  - " 0000020F02000102030405 17 00 34 1 mfactur\body.bin
)
for /f "eol=# tokens=*" %%a in (%wf%\_List_Models.txt) do findver "Model         - "  %%a bios.bin && goto next1
:next1
if %aa%==5 findhex 4153526F636B mfactur\body.bin>nul && for /f %%a in ('%uf% header list AD944D418D99D247BFCD4E882241DE32') do %ue% %%a -o asr_prot -m body -t 18>nul && set guid=%%a
if exist asr_prot\body.bin findhex 00000000 asr_prot\body.bin>nul && for %%s in (asr_prot\body.bin) do (
	if %%~zs==2048 %ur% %guid% 18 %wf%\asrx99.pad -o bios.bin>nul
	if %%~zs==4096 %ur% %guid% 18 %wf%\asrx100.pad -o bios.bin>nul
)
rem Platform
%uf% body count 4147455341>nul && set amd=1 && goto findextr
if %fit%==0 %ue% 1BA0062E-C779-4582-8566-336AE8F78F09 -o tmpr -m file>nul && findhex 00F8FFFF tmpr\file.ffs>nul && set mc_pad=1

%uf% header count 728508177F37EF448F4EB09FFF46A070>nul && set mc_guid=17088572-377F-44EF-8F4E-B09FFF46A070 && set mc_patt=728508177F37EF448F4EB09FFF46A070&& set mc_patt_01=728508177F37EF448F4EB09FFF46A071&& set mc_patt_02=728508177F37EF448F4EB09FFF46A072
%uf% header count 36B27D1956F8244990F8CDF12FB875F3>nul && set mc_guid=197DB236-F856-4924-90F8-CDF12FB875F3 && set mc_patt=36B27D1956F8244990F8CDF12FB875F3&& set mc_patt_01=36B27D1956F8244990F8CDF12FB875F4&& set mc_patt_02=36B27D1956F8244990F8CDF12FB875F5
for /f "tokens=1" %%a in ('%uf% header count %mc_patt%') do set gmc_count=%%a

:findextr
for %%a in (asr_prot mfactur tmpr) do if exist %%a rd /s /q %%a
echo;
echo		[EFI  Drivers - Find and Extract]
if %amd%==0 set list=%wf%\_List_Extri.txt
if %amd%==1 set list=%wf%\_List_Extra.txt
for /f "eol=# tokens=1-4" %%a in (%list%  %wf%\_List_Extro.txt) do (
	for /f "tokens=1,2" %%e in ('%ufbl% %%d') do (
	set SubGUID=%%f
	if defined SubGUID	(
		%ue% %%f -o tmpr -m body -t 18>nul && if exist tmpr\body* %renb% tmp\%%c_%%f>nul && echo %%a %%b SubGUID %%f
	) else (
		%ue% %%e -o tmpr -m body -t 10>nul && if exist tmpr\body* %renb% tmp\%%c_%%e>nul && echo %%a %%b GUID %%e
	)
	%rdir%
))
 
set vergop=0
set vergop2=0
set cfl=0
set oeguid=A0327FE0-1FDA-4E5B-905D-B510C45A61D0
 if %amd%==0 if exist tmp\gop_* for /f "tokens=*" %%a in ('dir tmp\gop* /b') do (
	for /f "tokens=4,6" %%b in ('drvver tmp\%%a') do (
	if %%b==SandyBridge set vergop2=2
	if %%b==IvyBridge set vergop=3
	if %%b==Haswell set vergop=5
	if %%b==HSW-BDW set vergop=5
	if %%b==SkyLake set vergop=9
	if %%b==SKL-KBL set vergop=9
	if %%b==SKL-CFL set vergop=9
	if %%c GEQ 9.0.1082 set cfl=1
))

rem LAN PRO/1000
if exist tmp\lani1Gp_* for /f "tokens=*" %%a in ('dir tmp\lani1Gp_* /b') do (
	for /f "tokens=3" %%b in ('drvver tmp\%%a') do (
	if %%b==Gigabit ren tmp\%%a lani1Gb_*>nul
))

rem set efipro=6
rem if exist tmp\lani1Gp_* for /f "tokens=*" %%a in ('dir tmp\lani1Gp_* /b') do (
rem	for /f "tokens=6" %%b in ('drvver tmp\%%a') do (
rem		if %%b geq 7.0.00 set efipro=7
rem ))

set vervb=0
echo;
echo 	[OROM  - Find and Extract]
rem Intel  VBIOS
if %amd%==0 for /f "tokens=1,2" %%a in ('%ufbl% 49424D20564741') do (
	if %%a==%pguid% (
		echo VBIOS in Padding
	) else (
		%ue% %%a -o tmpr -m file>nul && if exist tmpr\file* %renf% tmp\vbios_%%a>nul && echo VBIOS in GUID %%a
	)
	%rdir%
)
rem AMD VBIOS
if %amd%==1 for /f "tokens=1,2" %%a in ('%ufbl% 41544F4D42494F53424B2D41') do (
 	set SubGUID=%%b
	if defined SubGUID (
 		%ue% %%b -o tmpr -m body -t 18>nul && if exist tmpr\body* %renb% tmp\vbios_%%b>nul && echo VBIOS in SubGUID %%b
	) else (
		%ue% %%a -o tmpr -m body -t 19>nul && if exist tmpr\body* %renb% tmp\vbios_%%a>nul && echo VBIOS in GUID %%a
	)
	if %%a==%pguid% echo VBIOS in Padding
	%rdir%
)
for /f "tokens=1" %%a in ('%ufbl% 24506E500102') do (
	if %%a==%pguid% (
		echo OROM in Padding
	) else (
		if exist tmp\vbios_%%a move tmp\vbios_%%a tmp\orom_%%a>nul
		if not exist tmp\orom_%%a %ue% %%a -o tmpr -m file>nul && %renf% tmp\orom_%%a>nul
		echo OROM in GUID %%a
	)
	%rdir%
)
If %aa%==5 if exist tmp\vbios_%oeguid% move tmp\vbios_%oeguid% tmp\orom_%oeguid%>nul
for %%a in (
	A0327FE0-1FDA-4E5B-905D-B510C45A61D0
	A062CF1F-8473-4AA3-8793-600BC4FFE9A8
	365C62BA-05EF-4B2E-A7F7-92C1781AF4F9
	9F3A0016-AE55-4288-829D-D22FD344C347
) do if exist tmp\orom_%%a del /f /q tmp\orom_%%a && set csmguid=%%a && if %aa%==5 goto set_extr

:set_extr
set csmx=call :csm_extr
%csmx% || set csmx=echo;
rem  && if %aa% neq 0 cecho {0E}CSM not found or cannot open/extract file{#}{\n}
if not exist csmcore echo Dummy CSMCORE>csmcore
if %aa% NEQ 0 call :check_mmt

rem OROM Intel Lan
set bacl=0
for /f "eol=# tokens=1" %%f in (%sdli%\obacl.txt) do (
	if %aa%==4 findhex 008680%%f00 csmcore>nul && set bacl=1
	if %aa%==5 findhex 504349528680%%f csmcore>nul && set bacl=1
)
set bage=0
for /f "eol=# tokens=1" %%f in (%sdli%\obage.txt) do (
	if %aa%==4 findhex 008680%%f00 csmcore>nul && set bage=1
	if %aa%==5 findhex 504349528680%%f csmcore>nul && set bage=1
)
set baxe=0
set x550=0
for /f "eol=# tokens=1" %%f in (%sdli%\obaxe.txt) do (
	if %aa%==4 findhex 008680%%f csmcore>nul && set baxe=1
	if %aa%==5 findhex 504349528680%%f csmcore>nul && set baxe=1
)

%uf% body count 4D617276656C6C2038385345363178782041646170746572>nul && set mrvl61=1
%uf% body count 4D617276656C6C2038385345393178782041646170746572>nul && set mrvl91=1
%uf% body count 4D617276656C6C2038385345393278782041646170746572>nul && set mrvl92=1
if %amd%==0 goto end_fae

rem AMD Xpert2
if exist tmp\raidxpt2_* set rxpt2=1
if %aa%==4 (%ufbl% 5043495202109243>nul && set rxpt2=6) || (%ufbl% 5043495222100578>nul && set rxpt2=7)

rem Stupid 55aa
if %mmtool%==1 if %aa%==4 (
	findhex 000210AA55 csmcore>nul && %mmt% /e /l tmp\aahci_55aa 1002 55aa
	findhex 002210AA55 csmcore>nul && %mmt% /e /l tmp/aahci_55aa 1022 55aa
)

rem END Find/Extract
:end_fae
pause

:mn1
%rdir%
cls
set fefi=
set forom=
set brend=Wrong
echo;
echo                       Main Menu
echo             [Current version in BIOS file]
echo 1 - Disk Controller
if %amd%== 0 	call :irstd
if %amd%== 1 	call :amdd
rem if %m1%==0 echo      Not found
if exist tmp\anvme* echo      EFI AMI NVMe Driver present
if exist tmp\otnvme* echo      EFI NVMe Driver present

echo 2 - Video OnBoard
call :video_ver
call :othvideo_ver

echo 3 - Network
call :inlver
call :rtkver
call :lxver
call :bcmver
call :yukver

echo 4 - Other SATA Controller
call :mrvlver
call :asmver
call :jmbver

echo 5 - CPU MicroCode
echo      View/Extract/Search/Replace

if %aa% neq 0 echo S - AMI Setup IFR Extractor
if exist tmp\OROM_* echo O - Other Option ROM in FFS
echo 0 - Exit

echo RS - Re-Scanning
if exist ubu_abt.mht echo A - About

:mnm
set sel=
set /p sel=Choice:
if not defined sel goto mnm
if %amd%==0 if %sel%==1 goto isata
if %amd%==1 if %sel%==1 goto asata
if %sel%==2 goto video
if %sel%==3 goto lan
if %mrvl%==1 if %sel%==4 goto osata
if %asmo%==1 if %sel%==4 goto osata
if %jmbo%==1 if %sel%==4 goto osata
if %sel%==5 goto cpu
if %aa% neq 0 if /I %sel%==s goto setup_ifr
if exist tmp\OROM_* if /I %sel%==o goto rg
if /I %sel%==rs goto mn
if exist ubu_abt.mht if /I %sel%==a (start ubu_abt.mht) && goto mn1

if %sel%==0 goto exit
goto mnm

:isata
set m11=0
%rdir%
cls
echo,
echo 			Disk Controller
echo 	[Current version]
call :irstd
echo,
echo 	[Available version]
if %irst%==1 (
	if exist %sdir%\rst\RaidDriver.efi drvver %sdir%\rst\RaidDriver.efi && set m11=1
	if exist %sdir%\rst\RaidOrom.bin findver "     OROM IRST RAID for SATA    - " 496E74656C2852292052617069642053746F7261676520546563686E6F6C6F6779202D204F7074696F6E20524F4D 49 0A 12 2 %sdir%\rst\RaidOrom.bin  && set m11=1
)
if %irste%==1 (
	if exist %sdir%\rste\RaidDriver.efi drvver %sdir%\rste\RaidDriver.efi && set m11=1
	if exist %sdir%\rste\sSataDriver.efi drvver %sdir%\rste\sSataDriver.efi && set m11=1
	if exist %sdir%\rste\SCUDriver.efi drvver %sdir%\rste\SCUDriver.efi && set m11=1
	if %vmd%==1 if exist %sdir%\vroc_vmd\vmdvroc_1.efi drvver %sdir%\vroc_vmd\vmdvroc_1.efi && set m11=1
	if exist %sdir%\rste\RaidOrom.bin (findver "     OROM Intel VROC for SATA   - " 496E74656C285229205669727475616C2052414944206F6E20435055202D2053415441204F7074696F6E20524F4D 49 0A 12 2 %sdir%\rste\RaidOrom.bin || findver "     OROM IRSTe RAID for SATA   - " 496E74656C2852292052617069642053746F7261676520546563686E6F6C6F677920656E7465727072697365202D2053415441204F7074696F6E20524F4D 65 0A 12 2 %sdir%\rste\RaidOrom.bin) && set m11=1
	if exist %sdir%\rste\sSataOrom.bin (findver "     OROM Intel VROC for sSATA  - " 496E74656C285229205669727475616C2052414944206F6E20435055202D207353415441204F7074696F6E20524F4D  50 0A 12 2 %sdir%\rste\sSATAOrom.bin || findver "     OROM IRSTe RAID for sSATA  - " 496E74656C2852292052617069642053746F7261676520546563686E6F6C6F677920656E7465727072697365202D207353415441204F7074696F6E20524F4D 66 0A 12 2 %sdir%\rste\sSATAOrom.bin) && set m11=1
	if exist %sdir%\rste\SCUOrom.bin findver "     OROM IRSTe RAID for SCU    - " 496E74656C2852292052617069642053746F7261676520546563686E6F6C6F677920656E7465727072697365202D20534355204F7074696F6E20524F4D 64 0A 12 2 %sdir%\rste\SCUOrom.bin && set m11=1
)
if defined intnvme drvver %sdir%\nvme\NVMeDriver.efi && set m11=
if %m11%==0 echo     There are no files to replace in %sdir% \RST(e) folders. && pause && goto mn1

set ec=
echo;
echo 1 - Replace
if %irst%==1 if %irste%==1 echo 2 - Replace only RST
if %irst%==1 if %irste%==1 echo 3 - Replace only RSTe/VROC
if defined intnvme echo N - Replace NVMe
echo 0 - Exit to Main Menu
:mnis
set /p ec=Choice:
if not defined ec goto mnis
if %ec%==1 echo; && goto prcs
if %ec%==2 echo; && goto prcs
if %ec%==3 echo; && goto prcse
if defined intnvme if /I %ec%==n echo; && goto prcsn
if %ec%==0 goto mn1
goto mnis

:prcs
if %irst%==0 goto prcse
set fefi=%sdir%\rst\RaidDriver.efi
if exist %fefi% for /f "tokens=1,2" %%a in ('%ufbl% 49006E00740065006C00280052002900200052005300540020003.00') do (
	set subguid=%%b
	<nul set /p TmpStr=EFI IRST 
	if defined subguid (
		echo SubGUID %%b
		%ur% %%b 18  %fefi% -o bios.bin && %ue% %%b -o tmpr -m body -t 18>nul && %renb% tmp\irst_%%b>nul
	) else (
		echo GUID %%a
		%ur% %%a 10  %fefi% -o bios.bin && %ue% %%a -o tmpr -m body -t 10>nul && %renb% tmp\irst_%%a>nul
	)
	%rdir%
)

set brend=OROM IRST
set forom=%sdir%\rst\RaidOrom.bin
if exist %forom% for /f "tokens=1,2" %%a in ('%ufbl% 5043495286802228') do (
	if %aa% neq 4 set subguid=%%b
	if defined subguid (
		echo %brend%  SubGUID %%b
		%ur% %%b 18 %forom% -o bios.bin
	) else (
		(findhex 0086802228 csmcore>nul || findhex A086802228 csmcore>nul) && set did=2822 && set romf=%forom% 8086 2822 && call :romu
		(findhex 0086802a28 csmcore>nul || findhex A086802a28 csmcore>nul) && set did=282a && set romf=%forom% 8086 282a && call :romu
		rem if exist tmp\55aa findhex 5043495286802228 tmp\55aa>nul && set did=55aa && set romf=%v%\RaidOrom.bin 8086 55aa && call :romu
))

if %irste%==0 goto sataend
if %ec%==2 goto sataend

:prcse
set fefi=%sdir%\rste\RaidDriver.efi
if exist %fefi% for /f "tokens=1,2" %%a in ('%ufbl% 5.005.00..00..0020003.002E003.002E003.002E003.003.003.003.0020005300410054004100') do (
	<nul set /p TmpStr=EFI SATA 
	set subguid=%%b
	if defined subguid (
		echo SubGUID %%b
		%ur% %%b 18  %fefi% -o bios.bin && %ue% %%b -o tmpr -m body -t 18>nul && %renb% tmp\irste_%%b>nul
	) else (
		echo GUID %%a
		%ur% %%a 10  %fefi% -o bios.bin && %ue% %%a -o tmpr -m body -t 10>nul && %renb% tmp\irste_%%a>nul
	)
	%rdir%
)

set fefi=%sdir%\vroc_vmd\vmdvroc_1.efi
if %vmd%==1 if exist %fefi% for /f "tokens=1,2" %%a in ('%ufbl% 560052004F00430020007700690074006800200056004D004400200054006500630068006E006F006C006F006700790020003.002E00') do (
	<nul set /p TmpStr=EFI VROC with VMD 
	set subguid=%%b
	if defined subguid (
		echo SubGUID %%b
		%ur% %%b 18  %fefi% -o bios.bin && %ue% %%b -o tmpr -m body -t 18>nul && %renb% tmp\vmd_%%b>nul
	) else (
		echo GUID %%a
		%ur% %%a 10  %fefi% -o bios.bin && %ue% %%a -o tmpr -m body -t 10>nul && %renb% tmp\vmd_%%a>nul
	)
	%rdir%
)

set fefi=%sdir%\vroc_vmd\vmdvroc_2.efi
if %vmdd%==1 if %vmd%==1 if exist %fefi% for /f "tokens=1,2" %%a in ('%ufbl% 56006F006C0075006D00650020004D0061006E006100670065006D0065006E00740020004400650076006900630065002000440072006900760065007200') do (
	<nul set /p TmpStr=EFI VMDD 
	set subguid=%%b
	if defined subguid (
		echo SubGUID %%b
		%ur% %%b 18  %fefi% -o bios.bin
	) else (
		echo GUID %%a
		%ur% %%a 10  %fefi% -o bios.bin
	)
	%rdir%
)

set fefi=%sdir%\rste\ssatadriver.efi
if exist %fefi% for /f "tokens=1,2" %%a in ('%ufbl% 5.005.00..00..0020003.002E003.002E003.002E003.003.003.003.00200073005300410054004100') do (
	<nul set /p TmpStr=EFI sSATA 
	set subguid=%%b
	if defined subguid (
		echo SubGUID %%b
		%ur% %%b 18  %fefi% -o bios.bin && %ue% %%b -o tmpr -m body -t 18>nul && %renb% tmp\irste_%%b>nul
	) else (
		echo GUID %%a
		%ur% %%a 10  %fefi% -o bios.bin && %ue% %%a -o tmpr -m body -t 10>nul && %renb% tmp\irste_%%a>nul
	)
	%rdir%
)

set fefi=%sdir%\rste\scudriver.efi
if exist %fefi% for /f "tokens=1,2" %%a in ('%ufbl% 49006E00740065006C00200052005300540065002000..002E00..002E00..002E00..00..00..00..00200053004300') do (
	<nul set /p TmpStr=EFI SCU 
	set subguid=%%b
	if defined subguid (
		echo SubGUID %%b
		%ur% %%b 18  %fefi% -o bios.bin && %ue% %%b -o tmpr -m body -t 18>nul && %renb% tmp\irste_%%b>nul
	) else (
		echo GUID %%a
		%ur% %%a 10  %fefi% -o bios.bin && %ue% %%a -o tmpr -m body -t 10>nul && %renb% tmp\irste_%%a>nul
	)
	%rdir%
)

set brend=OROM SATA
set forom=%sdir%\rste\RaidOrom.bin
if exist %forom% for /f "tokens=1,2" %%a in ('%ufbl% 5043495286802628') do (
	if %aa% neq 4 set subguid=%%b
	if defined subguid (
		echo %brend%  SubGUID %%b
		%ur% %%b 18 %forom% -o bios.bin
	) else (
		(findhex 0086802628 csmcore>nul || findhex A086802628 csmcore>nul) && set did=2826 && set romf=%forom% 8086 2826 && call :romu
))

set brend=OROM sSata
set forom=%sdir%\rste\sSataOrom.bin
if exist %forom% for /f "tokens=1,2" %%a in ('%ufbl% 5043495286802728') do (
	if %aa% neq 4 set subguid=%%b
	if defined subguid (
		%ur% %%b 18 %forom% -o bios.bin
	) else (
		echo %brend%  SubGUID %%b
		echo Strabge location OROM
))

set brend=OROM SCU
set forom=%sdir%\rste\ScuOrom.bin
if exist %forom% for /f "tokens=1,2" %%a in ('%ufbl% 504349528680601D') do (
	if %aa% neq 4 set subguid=%%b
	if defined subguid (
		echo %brend%  SubGUID %%b
		%ur% %%b 18 %forom% -o bios.bin
	) else (
		(findhex 008680681D csmcore>nul || findhex A08680681D csmcore>nul) && set did=1d68 && set romf=%forom% 8086 1d68 && call :romu
		(findhex 008680691D csmcore>nul || findhex A08680691D csmcore>nul) && set did=1d69 && set romf=%forom% 8086 1d69 && call :romu
))

goto sataend

:prcsn
set fefi=%sdir%\nvmenvmeDriver.efi
for /f "tokens=1,2" %%a in ('%ufbl% 20004E0056004D006500200055004500460049002000440072006900760065007200') do (
	<nul set /p TmpStr=EFI NVMe 
	set subguid=%%b
	if defined subguid (
		echo SubGUID %%b
		%ur% %%b 18  %fefi% -o bios.bin && %ue% %%b -o tmpr -m body -t 18>nul && %renb% tmp\invme_%%b>nul
	) else (
		echo GUID %%a
		%ur% %%a 10  %fefi% -o bios.bin && %ue% %%a -o tmpr -m body -t 10>nul && %renb% tmp\invme_%%a>nul
	)
	%rdir%
)

:sataend
%csmx%
echo;
if %irst%==1 if %irste%==1 	pause && goto isata
call :irstd
pause
goto mn1

:asata
%rdir%
cls
echo,
echo 			Disk Controller
echo 	[Current version]
call :amdd

echo,
echo 	[Available versions for replacement]
if %rxpt2%==6 (
	if exist tmp\raidxpt2_* findver "1 -  EFI AMD RAIDXpert2-Fxx     - " 5243424E454E44 8 00 12 1 %sdar%\Xpert_6\RAID_f10.efi
	findver "2 -  OROM AMD RAIDXpert2-Fxx    - " 5243424E42474E 8 00 12 1 %sdar%\Xpert_6\RAID_F10.bin
)
if %rxpt2%==7 (
	if exist tmp\raidxpt2_* findver "1 -  EFI AMD RAIDXpert2-Fxx     - " 5243424E454E44 8 00 12 1 %sdar%\Xpert_7\RAID_F10.efi
	findver "2 -  OROM AMD RAIDXpert2-Fxx    - " 5243424E42474E 8 00 12 1 %sdar%\Xpert_7\RAID_F10.bin
)
if exist tmp\raid_* (
	echo R - \
	drvver %sdar%\efi\RaidDriver.efi
	drvver %sdar%\efi\RaidUtility.efi
)
if %o43xx%==1 (
	echo O - \
	findver "     OROM AMD RAID MISC 4392    - " 9243021092436C -22 00 12 1 %sdar%\439x\4392r.bin
	findver "     OROM AMD RAID MISC 4393    - " 9343021093436C -22 00 12 1 %sdar%\439x\4393r.bin
)
if %o78xx%==1 (
	echo O - \
	findver "     OROM AMD RAID MISC 7802    - " 0278221002786C -22 00 12 1 %sdar%\780x\7802r.bin
	findver "     OROM AMD RAID MISC 7803    - " 0378221003786C -22 00 12 1 %sdar%\780x\7803r.bin
)
if defined oahci findver "A -  OROM AMD AHCI              - " 414D442041484349 22 00 10 1 %sdar%\780x\7801a.bin
if %rxpt2%==1 (
	findver "1 -  EFI AMD RAIDXpert2-Fxx     - " 5243424E454E44 8 00 12 1 %sdar%\Xpert_9\RAIDXpert2_Fxx.efi
	findver "2 -  OROM AMD RAIDXpert2-Fxx    - " 5243424E42474E 8 00 12 1 %sdar%\Xpert_8\RAIDXpert2_7905.bin
rem	findver "3 -  EFI AMD RAIDXpert2-Fxx     - " 5243424E454E44 8 00 12 1 %sdar%\Xpert_9\RAIDXpert2_Fxx.efi
)
echo 0 - Exit to Main Menu
echo;

:as1
set ec=
set /p ec=Choice:
if not defined ec goto as1
if %rxpt2% neq 0 if %ec%==1 goto samde
if %rxpt2% neq 0 if %ec%==2 goto samdo
rem if %rxpt2%==1 if %ec%==3 goto samde
if exist tmp\raid_* if /I %ec%==r goto araid
if %o78xx%==1 if /I %ec%==o goto araido
if %o43xx%==1 if /I %ec%==o goto araido
if defined oahci if /I %ec%==a goto aahci
if %ec%==0 goto mn1
goto as1

:samde
if %rxpt2%==1 goto samden
for /f "tokens=1,2" %%a in ('%ufbl% 41004D0044002D005200410049004400') do (
	set subguid=%%b
	if not defined subguid (
		echo EFI RAIDXpert2 GUID %%a
		if exist tmp\raidxpt2_%%a findhex 632E00004000 tmp\raidxpt2_%%a>nul && %ur% %%a 10 %sdar%\Xpert_%rxpt2%\RAID_F10.efi -o bios.bin && %ue% %%a -o tmpr -m body -t 10>nul && %renb% tmp\raidxpt2_%%a>nul && %rdir%
		if exist tmp\raidxpt2_%%a findhex 632E00006300 tmp\raidxpt2_%%a>nul && %ur% %%a 10 %sdar%\Xpert_%rxpt2%\RAID_F50.efi -o bios.bin && %ue% %%a -o tmpr -m body -t 10>nul && %renb% tmp\raidxpt2_%%a>nul && %rdir%
	) else (
		echo Oops! Please, send report and BIOS file
	)
	%rdir%
)
goto samdend

:samdo
if %rxpt2%==1 goto samdon
set brend=OROM RAIDXpert2
findhex 0022100388 csmcore>nul && set did=8803 && set romf=%sdar%\Xpert_%rxpt2%\RAID_F10.bin 1022 8803 && call :romu
findhex 0022100488 csmcore>nul && set did=8804 && set romf=%sdar%\Xpert_%rxpt2%\RAID_F50.bin 1022 8804 && call :romu
goto samdend

:araid
for /f "eol=# tokens=1-4" %%a in (%sdar%\efi\_List_driver.txt) do (
	for /f "tokens=1" %%e in ('%ufbl% %%d') do (
	echo EFI %%b GUID %%e
	%ur% %%e 10 %sdar%\efi\%%a -o bios.bin && %ue% %%e -o tmpr -m body -t 10>nul && %renb% tmp\%%c_%%e>nul && %rdir%
))
goto samdend

:araido
set brend=OROM RAID
if %o43xx%==1 if %asus%==0 (
	findhex 5043495202109243 csmcore>nul && set did=4392 && set romf=%sdar%\439x\4392r.bin 1002 4392 && call :romu && echo MISC 4392 && %ur% 9BD5C81D-096C-4625-A08B-405F78FE0CFC 19 %sdar%\439x\4392m.bin -o bios.bin
	findhex 5043495202109343 csmcore>nul && set did=4393 && set romf=%sdar%\439x\4393r.bin 1002 4393 && call :romu && echo MISC 4393 && %ur% 9BD5C81D-096C-4625-A08B-405F78FE0CFD 19 %sdar%\439x\4393m.bin -o bios.bin
)
if %o43xx%==1 if %asus%==1 (
	findhex 5043495202109243 csmcore>nul && set did=4392 && set romf=%sdar%\439x\4392r.bin 1002 4392 && call :romu && echo MISC 4392 && %ur% 9BD5C81D-096C-4625-A08B-405F78FE0CFD 19 %sdar%\439x\4392m.bin -o bios.bin
	findhex 5043495202109343 csmcore>nul && set did=4393 && set romf=%sdar%\439x\4393r.bin 1002 4393 && call :romu && echo MISC 4393 && %ur% 9BD5C81D-096C-4625-A08B-405F78FE0CFC 19 %sdar%\439x\4393m.bin -o bios.bin
)
if %o78xx%==1 (
	findhex 5043495222100278 csmcore>nul && set did=7802 && set romf=%sdar%\780x\7802r.bin 1022 7802 && call :romu && echo MISC 7802 && %ur% 9BD5C81D-096C-4625-A08B-405F78FE0CFC 19 %sdar%\780x\7802m.bin -o bios.bin
	findhex 5043495222100378 csmcore>nul && set did=7803 && set romf=%sdar%\780x\7803r.bin 1022 7803 && call :romu && echo MISC 7803 && %ur% 9BD5C81D-096C-4625-A08B-405F78FE0CFD 19 %sdar%\780x\7803m.bin -o bios.bin
)
goto araido_end

:aahci
set brend=OROM AHCI
if exist tmp\aahci_55aa (
	findhex 5043495202109143 csmcore>nul && set did=4391 && set romf=%sdar%\439x\4391a.bin 1002 55aa && call :romu
	findhex 5043495222100178 csmcore>nul && set did=7801 && set romf=%sdar%\780x\7801a.bin 1022 55aa && call :romu
) else (
	findhex 5043495202109143 csmcore>nul && set did=4391 && set romf=%sdar%\439x\4391a.bin 1002 4391 && call :romu
	findhex 5043495222100178 csmcore>nul && set did=7801 && set romf=%sdar%\780x\7801a.bin 1022 7801 && call :romu
)

:araido_end
%csmx%
echo;
call :amdd1
pause
goto asata

:samden
if %ec%==1 set fefi=%sdar%\Xpert_9\RAIDXpert2_Fxx.efi
rem if %ec%==3 set fefi=%sdar%\Xpert_9\RAIDXpert2_Fxx.efi
for /f "tokens=1,2" %%a in ('%ufbl% 41004D0044002D005200410049004400') do (
	set subguid=%%b
	<nul set /p TmpStr=EFI RAIDXpert2 
	if defined subguid (
		echo SubGUID %%b
		%ur% %%b 18  %fefi% -o bios.bin && %ue% %%b -o tmpr -m body -t 18>nul && %renb% tmp\raidxpt2_%%b>nul
	) else (
		echo GUID %%a
		%ur% %%a 10  %fefi% -o bios.bin && %ue% %%a -o tmpr -m body -t 10>nul && %renb% tmp\raidxpt2_%%a>nul
	)
	%rdir%
)
goto samdend

:samdon
set brend=OROM RAIDXpert2
for %%a in (0579 1679) do for /f "tokens=1,2" %%b in ('%ufbl% 504349522210%%a') do (
	set subguid=%%c
	if defined subguid (
		echo %brend% SubGUID %%c
		if %%a==0579 %ur% %%c 18 %sdar%\Xpert_8\RAIDXpert2_7905.bin -o bios.bin
		if %%a==1679 %ur% %%c 18 %sdar%\Xpert_8\RAIDXpert2_7916.bin -o bios.bin
	) else (
		echo Oops! Please, send report and BIOS file
))
	
:samdend
%csmx%
echo;
call :amdd
pause
goto asata

:video
%rdir%
cls
if exist tmp\gop_* (set m21=1) else (set m21=0)
set m22=0
if %amd%==0 (
	if %vergop2%==2 set fefi2=%sdig%\1155\SNB\IntelGopDriver.efi
	if %vergop%==3 set fefi=%sdig%\1155\IVB\IntelGopDriver.efi
	if %vergop%==5 set fefi=%sdig%\1150\IntelGopDriver.efi
	if %vergop%==9 if %cfl%==0 set fefi=%sdig%\1151\IntelGopDriver.efi
	if %vergop%==9 if %cfl%==1 set fefi=%sdig%\1151v2\IntelGopDriver.efi
) && set goppat=49006E00740065006C00280052002900200047004F0050002000440072006900760065007200000000
if %amd%==1 (
	set fefi=%sdag%\AMDGopDriver.efi
	set fefi2=%sdag%\AMDGopDriver2.efi
) && set goppat=000041004D004400200047004F0050002000..00..00..002000

echo,
echo 		Video OnBoard
echo 	[Current version]
call :video_ver
echo,
echo 	[Available version]
if %amd%==0 (
	if defined fefi if %m21%==1 drvver %fefi% && set m21==1
	if %vergop2%==2 drvver %fefi2% && set m21==1
	if exist %sdiv%\vbiossib.dat if %vervb%==3 findver "     OROM VBIOS SNB-IVB         - " 2456425420534E 79 FF 4 1 %sdiv%\vbiossib.dat && set forom=%sdiv%\vbiossib.dat && set m22=1
	if exist %sdiv%\vbioshsw.dat if %vervb%==5 findver "     OROM VBIOS HSW-BDW         - " 24564254204841 79 FF 4 1 %sdiv%\vbioshsw.dat && set forom=%sdiv%\vbioshsw.dat && set m22=1
	if exist %sdiv%\vbiosskc.dat if %vervb%==9 findver "     OROM VBIOS SKL/KBL/CFL     - " 2456425420 79 FF 4 1 %sdiv%\vbiosskc.dat && set forom=%sdiv%\vbiosskc.dat && set m22=1
)
if %amd%==1 (
	if defined fefi2 if %m21%==1 drvver %fefi2%
	if defined fefi if %m21%==1 drvver %fefi%
	if defined ra if defined fefi2 if %m21%==1 drvver %fefi2%
	if defined sp findver "     OROM VBIOS Kaveri          - " 41544F4D42494F53424B 18 00 22 1 %sdav%\vbios_1304.dat && set m22=1
	if defined tr findver "     OROM VBIOS Trinity         - " 41544F4D42494F53424B 18 00 22 1 %sdav%\vbios_9901.dat && set m22=1
	if defined ka findver "     OROM VBIOS Kabini          - " 41544F4D42494F53424B 18 00 22 1 %sdav%\vbios_9830.dat && set m22=1
	if defined st findver "     OROM VBIOS Stoney          - " 41544F4D42494F53424B 18 00 22 1 %sdav%\vbios_98E0.dat && set m22=1
	if defined ca findver "     OROM VBIOS Carrizo         - " 41544F4D42494F53424B 18 00 22 1 %sdav%\vbios_9870.dat && set m22=1
	if defined pi findver "     OROM VBIOS Picasso         - " 41544F4D42494F53424B 18 00 22 1 %sdav%\vbios_15D8.dat && set m22=1
	if defined ra1 findver "     OROM VBIOS Raven           - " 41544F4D42494F53424B 18 00 22 1 %sdav%\vbios_15DD_1.dat && set m22=1
	if defined ra2 findver "     OROM VBIOS Raven 2         - " 41544F4D42494F53424B 18 00 22 1 %sdav%\vbios_15DD_2.dat && set m22=1
	if defined wp findver "     OROM VBIOS Weston Pro      - " 41544F4D42494F53424B 18 00 22 1 %sdav%\vbios_6900.dat && set m22=1
)

:is
set ec=
echo;
if %m21%==1 echo 1 - Replace GOP Driver
if %m22%==1 echo 2 - Replace OROM VBIOS
echo 0 - Exit to Main Menu
:mnv
set /p ec=Choice:
if not defined ec goto mnv
if %m21%==1 if %ec%==1 goto gopup
if %m22%==1 if %ec%==2 goto vbup
if %ec%==0 goto mn1
goto mnv

:gopup
for /f "tokens=1,2" %%a in ('%ufbl% %goppat%') do (
	set subguid=%%b
	<nul set /p TmpStr=EFI GOP Driver 
	if defined subguid (	
		echo SubGUID %%b
		if %amd%==0 %ur% %%b 18  %fefi% -o bios.bin && %ue% %%b -o tmpr -m body -t 18>nul && %renb% tmp\gop_%%b>nul && %rdir%
		if %amd%==1 (findhex 5200650076002E003100 tmp\gop_%%b>nul && %ur% %%b 18  %fefi% -o bios.bin && %ue% %%b -o tmpr -m body -t 18>nul && %renb% tmp\gop_%%b>nul && %rdir%
								findhex 5200650076002E003200 tmp\gop_%%b>nul && %ur% %%b 18  %fefi2% -o bios.bin && %ue% %%b -o tmpr -m body -t 18>nul && %renb% tmp\gop_%%b>nul && %rdir%)
	) else (
		echo GUID %%a
		if %amd%==0 (
			if %vergop%==3 (findhex 49007600790020004200 tmp\gop_%%a>nul && %ur% %%a 10  %fefi% -o bios.bin && %ue% %%a -o tmpr -m body -t 10>nul && %renb% tmp\gop_%%a>nul && %rdir%
										findhex 530061006E0064007900 tmp\gop_%%a>nul && %ur% %%a 10  %fefi2% -o bios.bin && %ue% %%a -o tmpr -m body -t 10>nul && %renb% tmp\gop_%%a>nul && %rdir%)
			if %vergop%==5 %ur% %%a 10  %fefi% -o bios.bin -all && %ue% %%a -o tmpr -m body -t 10>nul && %renb% tmp\gop_%%a>nul && %rdir% && goto end_video
		) else (
			%ur% %%a 10  %fefi% -o bios.bin -all && %ue% %%a -o tmpr -m body -t 10>nul && %renb% tmp\gop_%%a>nul && %rdir%
)))

rem set brend=Intel VBT HSW/BDW
rem set fefi=%sdiv%\vbthsw.bin
rem if %s1150%==1 if exist %sdiv%\vbthsw.bin for /f "tokens=1" %%a in ('%uf% all list 00F8245642542048415357454C4C') do (
rem )
goto end_video

:vbup
if %amd%==1 goto vbup1
set brend=OROM VBIOS
If %vervb%==3 (
	findhex 0086800201 csmcore>nul && set did=102 && set romf=%forom% 8086 102 && call :romu
	findhex 0086806201 csmcore>nul && set did=162 && set romf=%forom% 8086 162 && call :romu
	if %asus%==1 vbios2pad bios.bin %forom%
)
If %vervb%==5 (
	findhex 0086800204 csmcore>nul && set did=402 && set romf=%forom% 8086 402 && call :romu
	findhex 0086801204 csmcore>nul && set did=412 && set romf=%forom% 8086 412 && call :romu
	findhex 008680020c csmcore>nul && set did=c02 && set romf=%forom% 8086 c02 && call :romu
	findhex 008680120c csmcore>nul && set did=c12 && set romf=%forom% 8086 c12 && call :romu
	if %asus%==1 vbios2pad bios.bin %forom%
)
If %vervb%==9 (
for /f "tokens=1,2" %%a in ('%ufbl% 5043495286800604') do (
	set subguid=%%b
	if defined subguid (
		echo %brend% SubGUID %%b
		%ur% %%b 18 %forom% -o bios.bin
	))
	if %asus%==1 vbios2pad bios.bin %forom%
)
goto end_video

:vbup1
set brend=OROM VBIOS
for /f "eol=# tokens=1,2" %%a in (%sdav%\_List_vbios.txt) do (
	for /f "tokens=1,2" %%c in ('%ufbl% %%a') do (
	set subguid=%%d
	if not defined subguid (
		echo %brend% GUID %%c
		if %%c neq %pguid% %ur% %%c 19 %sdav%\%%b -o bios.bin && %ue% %%c -o tmpr -m body -t 19>nul && %renb% tmp\vbios_%%c>nul
	) else (
		echo %brend% SubGUID %%d
		%ur% %%d 18 %sdav%\%%b -o bios.bin && %ue% %%d -o tmpr -m body -t 18>nul && if exist tmpr\body* %renb% tmp\vbios_%%d>nul
	)
	%rdir%
))

:end_video
echo;
%csmx%
call :video_ver
pause
if %m21%==1 if %m22%==1 goto video
goto mn1

:lan
%rdir%
cls
set ge2cl=0
echo,
echo 			Network
echo 	[Current version]
call :inlver
call :rtkver
call :lxver
call ::bcmver
call :yukver

echo,
echo 	[Available version]
if %lani%==1 (
	echo  -\ for i82579/i217/i218/i219 chips
	if exist tmp\lani1G* drvver %sdli%\E1GbEX7.efi
	findver "     OROM Intel Boot Agent CL   - " 496E74656C28522920426F6F74204167656E7420434C 24 00 7 1 %sdli%\obacl.lom 
	echo  -\ for i210/i211/i350 chips
	if exist tmp\lani1G* drvver %sdli%\EPro1000X3.efi
	findver "     OROM Intel Boot Agent GE   - " 496E74656C28522920426F6F74204167656E74204745 24 00 7 1 %sdli%\obage.lom
	echo  -\ for 10 Gigabit chips
	if exist tmp\lani10G* drvver %sdli%\E10GbEX4.efi
	if %baxe%==1 findver "     OROM Intel Boot Agent XE   - " 496E74656C28522920426F6F74204167656E74205845 24 00 7 1 %sdli%\obaxe.lom
)
if %lanrtk%==1 (
	drvver %sdlr%\RtkUndiDxe.efi
rem	if %rtk2%==1 findver "     OROM Realtek 2.5 Gb PXE    - " 5265616C74656B20322E3520476967616269742045746865726E657420436F6E74726F6C6C6572205365726965732076 48 20 4 1 %sdlr%\rtegpxe.lom
	if %rtk1%==1 findver "     OROM Realtek Boot Agent GE - " 5265616C74656B2050434965204742452046616D696C7920436F6E74726F6C6C657220536572696573 43 20 4 1 %sdlr%\rtegpxe.lom
)
if %lanlx%==1 (
	drvver %sdllx%\LxUndi.efi
	findver "     OROM QCM-Atheros PXE       - " 504349452045746865726E657420436F6E74726F6C6C6572 26 28 8 1 %sdllx%\Lxpxe.lom
)
if %lanbcm%==1 (
	drvver %sdlb%\b57undix64.efi
	findver "     OROM Broadcom Boot Agent   - " 42726F6164636F6D20554E444920505845 23 00 7 1 %sdlb%\b57pxee.lom
)

if %lanyuk%==1 findver "     OROM Mrvl-Yukon Boot Agent - " 59756B6F6E205058450020 12 20 9 2 %sdly%\yukonpxe.lom

echo,
if %lani%==1 echo 1 - Replace Intel
if %lanrtk%==1 echo 2 - Replace Realtek
if %lanlx%==1 echo 3 - Replace Lx Network Killer
if %lanbcm%==1 echo 4 - Replace Broadcom
if %lanyuk%==1 echo 5 - Replace Marvell-Yukon
echo 0 - Exit to Main Menu

:lm1
set ec=
set /p ec=Choice:
if not defined ec goto lm1
if %lani%==1 if %ec%==1 goto intl
if %lanrtk%==1 if %ec%==2 goto rtk
if %lanlx%==1 if %ec%==3 goto lxkil
if %lanbcm%==1 if %ec%==4 goto bcm
if %lanyuk%==1 if %ec%==5 goto ykn
if %ec%==0 goto mn1
goto lm1

:intl
rem echo bacl %bacl% bage %bage%
if %bacl%==1 if %bage%==0 if not exist tmp\lani1Gb_* if exist tmp\lani1Gp_* goto lm2
goto intl_up
:lm2
echo;
echo LAN Chip Configuration for %biosname%
echo 1 - only 1 or 2 chips 82579/i217/i218 (Recommended)
echo 2 - only 1 or 2 chips i210/i211/i350
echo   \ or other possible combinations
echo 0 - Cancel
:lm3
set ec=
set /p ec=Choice:
if not defined ec goto lm3
if %ec%==1 ren tmp\lani1Gp_* lani1Gb_*>nul && set ge2cl=1 && set chp2=2 && goto intl_up
if %ec%==2 goto intl_up
if %ec%==0 goto lan
goto lm3

:intl_up
echo;
echo For compatibility of the DevID, 
echo it is possible to install up to versions 6.6.04 and/or 1.5.62
echo;

set fefi7=%sdli%\E1GbEX7.efi
if %bage%==0 set fefi=%sdli%\E6604x3.efi
if %bage%==1 set fefi=%sdli%\EPro1000X3.efi
if %bacl%==1 if %bage%==1 if not exist tmp\lani1gb* if exist tmp\lani1gp* set fefi=%sdli%\E6604x3.efi && set chp2=1
if exist tmp\lani1g* for /f "tokens=1,2" %%a in ('%ufbl% 49006E00740065006C002800520029002000500052004F002F003100300030003000') do (
	set subguid=%%b
	if defined subguid (
		if exist tmp\lani1gb_%%b echo EFI Intel Gigabit SubGUID %%b && %ur% %%b 18  %fefi7% -o bios.bin && %ue% %%b -o tmpr -m body -t 18>nul && %renb% tmp\lani1gb_%%b>nul && %rdir%
		if exist tmp\lani1gp_%%b echo EFI Intel PRO/1000 SubGUID %%b && %ur% %%b 18  %fefi% -o bios.bin %ue% %%b -o tmpr -m body -t 18>nul && %renb% tmp\lani1gp_%%b>nul && %rdir%
	) else (
		if exist tmp\lani1gb_%%a echo EFI Intel Gigabit SubGUID %%a && %ur% %%a 10  %fefi7% -o bios.bin && %ue% %%a -o tmpr -m body -t 10>nul && %renb% tmp\lani1gb_%%a>nul && %rdir%
		if exist tmp\lani1gp_%%a echo EFI Intel PRO/1000 GUID %%a && %ur% %%a 10  %fefi% -o bios.bin && %ue% %%a -o tmpr -m body -t 10>nul && %renb% tmp\lani1gp_%%a>nul && %rdir%
	)
	%rdir%
)
if %ge2cl%==1 goto i1

set brend=OROM Boot Agent CL
set forom=%sdli%\OBACL.LOM
for /f "tokens=1,2" %%a in ('%ufbl% 426F6F74204167656E7420434C') do (
	if %aa% neq 4 set subguid=%%b
	set chp2=0
	if defined subguid (
		echo %brend% SubGUID %%b
		%ue% %%b -o tmpr -m body -t 18>nul && for /f "eol=# tokens=1,2" %%c in (%sdli%\obacl.txt) do findhex 504349528680%%c tmpr\body.bin>nul && setdevid %%d %forom% tmp\bacl_%%b && %ur% %%b 18 tmp\bacl_%%b -o bios.bin
	) else (
		for /f "eol=# tokens=1,2" %%c in (%sdli%\obacl.txt) do findhex 008680%%c00 csmcore>nul && setdevid %%d %forom% tmp\bacl_%%d && set did=%%d && set romf=tmp\bacl_%%d 8086 %%d && call :romu
	)
	%rdir%
)
set chp2=1
:i1
set brend=OROM Boot Agent GE
if %bage%==0 set forom=%sdli%\o1562GE.lom && set list_ge=o1562GE.txt
if %bage%==1 set forom=%sdli%\OBAGE.LOM && set list_ge=OBAGE.txt
if %chp2%==2 set forom=%sdli%\OBACL.LOM && set list_ge=OBACL.txt
for /f "tokens=1,2" %%a in ('%ufbl% 426F6F74204167656E74204745') do (
	if %aa% neq 4 set subguid=%%b
	set /A chp2+=1
	if defined subguid (
		echo %brend% SubGUID %%b
		%ue% %%b -o tmpr -m body -t 18>nul && for /f "eol=# tokens=1,2" %%c in (%sdli%\%list_ge%) do findhex 504349528680%%c tmpr\body.bin>nul && setdevid %%d %forom% tmp\bage_%%b && %ur% %%b 18 tmp\bage_%%b -o bios.bin
	) else (
		for /f "eol=# tokens=1,2" %%c in (%sdli%\%list_ge%) do findhex 008680%%c00 csmcore>nul && setdevid %%d %forom% tmp\bage_%%d && set did=%%d && set romf=tmp\bage_%%d 8086 %%d && call :romu
	)
	%rdir%
)
if %chp2%==2 if %bacl%==1 if %bage%==1 if not exist tmp\lani1gb* if exist tmp\lani1gp* goto i1

set fefi=%sdli%\E10GbEX4.efi
if exist tmp\lani10g* for /f "tokens=1,2" %%a in ('%ufbl% 49006E00740065006C00280052002900200031003000470062004500200044007200690076006500720020002500') do (
	set subguid=%%b
	<nul set /p TmpStr=EFI Intel 10Gb 
	if defined subguid (
		echo SubGUID %%b
		%ur% %%b 18  %fefi% -o bios.bin && %ue% %%b -o tmpr -m body -t 18>nul && %renb% tmp\lani10g_%%b>nul
	) else (
		echo GUID %%a
		%ur% %%a 10  %fefi% -o bios.bin && %ue% %%a -o tmpr -m body -t 10>nul && %renb% tmp\lani10g_%%a>nul
	)
	%rdir%
)

if %baxe%==0 goto xe_end
set brend=OROM Boot Agent XE
set forom=%sdli%\OBAXE.LOM
for /f "tokens=1,2" %%a in ('%ufbl% 426F6F74204167656E742058452076') do (
	if %aa% neq 4 set subguid=%%b
	if defined subguid (
		echo %brend% SubGUID %%b
		%ue% %%b -o tmpr -m body -t 18>nul && for /f "eol=# tokens=1,2" %%c in (%sdli%\obaxe.txt) do findhex 504349528680%%c tmpr\body.bin>nul && setdevid %%d %forom% tmp\baxe_%%b && %ur% %%b 18 tmp\baxe_%%b -o bios.bin
	) else (
		for /f "eol=# tokens=1,2" %%c in (%sdli%\obaxe.txt) do findhex 008680%%c00 csmcore>nul && setdevid %%d %forom% tmp\baxe_%%d && set did=%%d && set romf=tmp\baxe_%%d 8086 %%d && call :romu
	)
	%rdir%
)
if %x550%==0 goto xe_end
set brend=OROM Boot Agent XE x550
set forom=%sdli%\OBAXE_x550.LOM
for /f "tokens=1,2" %%a in ('%ufbl% 426F6F74204167656E742058452028') do (
	if %aa% neq 4 set subguid=%%b
	if defined subguid (
		echo %brend% SubGUID %%b
		%ue% %%b -o tmpr -m body -t 18>nul && for /f "eol=# tokens=1,2" %%c in (%sdli%\obaxe_x550.txt) do findhex 504349528680%%c tmpr\body.bin>nul && setdevid %%d %forom% tmp\baxe_%%b && %ur% %%b 18 tmp\baxe_%%b -o bios.bin
	) else (
		for /f "eol=# tokens=1,2" %%c in (%sdli%\obaxe_x550.txt) do findhex 008680%%c00 csmcore>nul && setdevid %%d %forom% tmp\baxe_%%d && set did=%%d && set romf=tmp\baxe_%%d 8086 %%d && call :romu
	)
	%rdir%
)
:xe_end
echo;
%csmx%
call :inlver
pause
goto lan

:rtk
set fefi=%sdlr%\RtkUndiDxe.efi
for /f "tokens=1,2" %%a in ('%ufbl% 00005200650061006C00740065006B0020005500450046004900200055004E004400490020004400720069007600650072000000') do (
	set subguid=%%b
	<nul set /p TmpStr=EFI Realtek 
	if defined subguid (
		echo SubGUID %%b
		%ur% %%b 18 %fefi% -o bios.bin && %ue% %%b -o tmpr -m body -t 18>nul && %renb% tmp\lanr_%%b>nul
	) else (
		echo GUID %%a
		%ur% %%a 10 %fefi% -o bios.bin && %ue% %%a -o tmpr -m body -t 10>nul && %renb% tmp\lanr_%%a>nul
	)
	%rdir%
)

set brend=OROM Realtek
set forom=%sdlr%\rtegpxe.lom
for /f "tokens=1,2" %%a in ('%ufbl% 50434952EC106881') do (
	if %aa% neq 4 set subguid=%%b
	if defined subguid (
		echo %brend%  SubGUID %%b
		%ur% %%b 18 %forom% -o bios.bin
	) else (
		(findhex 00EC106881 csmcore>nul || findhex A0EC106881 csmcore>nul) && set did=8168 && set romf=%forom% 10EC 8168 && call :romu
		(findhex 00EC106981 csmcore>nul || findhex A0EC106981 csmcore>nul) && set did=8169 && set romf=%forom% 10EC8169 && call :romu
))
echo;
%csmx%
call :rtkver
pause
goto lan

:lxkil
set fefi=%sdllx%\LxUndi.efi
for /f "tokens=1,2" %%a in ('%ufbl% 5C4C78556E64694478655C') do (
	set subguid=%%b
	<nul set /p TmpStr=EFI Lx Killer 
	if defined subguid (
		echo SubGUID %%b
		%ur% %%b 18  %fefi% -o bios.bin && %ue% %%b -o tmpr -m body -t 18>nul && %renb% tmp\lanlx_%%b>nul
	) else (
		echo GUID %%a
		%ur% %%a 10  %fefi% -o bios.bin && %ue% %%a -o tmpr -m body -t 10>nul && %renb% tmp\lanlx_%%a>nul
	)
	%rdir%
)
set brend=OROM Boot Agent QCA
set forom=%sdllx%\Lxpxe.lom
for /f "tokens=1,2" %%a in ('%ufbl% 504349526919...01C') do (
	if %aa% neq 4 set subguid=%%b
	if defined subguid (
		echo %brend% SubGUID %%b
		%ue% %%b -o tmpr -m body -t 18>nul && for /f "eol=# tokens=1,2" %%c in (%sdllx%\Lxpxe.txt) do findhex 504349526919%%c tmpr\body.bin>nul && setdevid %%d %forom% tmp\lx_%%b && %ur% %%b 18 tmp\lx_%%b -o bios.bin
	) else (
		for /f "eol=# tokens=1,2" %%c in (%sdllx%\Lxpxe.txt) do findhex 006919%%c00 csmcore>nul && setdevid %%d %forom% tmp\lx_%%d && set did=%%d && set romf=tmp\lx_%%d 1969 %%d && call :romu
	)
	%rdir%
)
echo;
%csmx%
call :lxver
pause
goto lan

:bcm
set fefi=%sdlb%\b57undix64.efi
for /f "tokens=1,2" %%a in ('%ufbl% 0000420072006F006100640063006F006D0020004E006500740058007400720065006D006500200047006900670061006200690074002000450074006800650072006E00650074002000') do (
	set subguid=%%b
	<nul set /p TmpStr=EFI Broadcom 
	if defined subguid (
		echo SubGUID %%b
		%ur% %%b 18  %fefi% -o bios.bin && %ue% %%b -o tmpr -m body -t 18>nul && %renb% tmp\lanb_%%b>nul
	) else (
		echo GUID %%a
		%ur% %%a 10  %fefi% -o bios.bin && %ue% %%a -o tmpr -m body -t 10>nul && %renb% tmp\lanb_%%a>nul
	)
	%rdir%
)
set brend=OROM Boot Agent BCM
set forom=%sdlb%\b57pxee.lom
for /f "tokens=1,2" %%a in ('%ufbl% 42726F6164636F6D204E6574587472656D652045746865726E657420426F6F74204167656E74 ') do (
	if %aa% neq 4 set subguid=%%b
	if defined subguid (
		echo %brend% SubGUID %%b
		%ue% %%b -o tmpr -m body -t 18>nul && for /f "eol=# tokens=1,2" %%c in (%sdlb%\b57pxee.txt) do findhex 50434952e414%%c tmpr\body.bin>nul && setdevid %%d %forom% tmp\bcm_%%b && %ur% %%b 18 tmp\bcm_%%b -o bios.bin
	) else (
		for /f "eol=# tokens=1,2" %%c in (%sdlb%\b57pxee.txt) do findhex 00e414%%c00 csmcore>nul && setdevid %%d %forom% tmp\bcm_%%d && set did=%%d && set romf=tmp\bcm_%%d 14e4 %%d && call :romu
	)
	%rdir%
)
echo;
%csmx%
call ::bcmver
pause
goto lan

:ykn
set brend=OROM Boot Agent Marvell-Yukon
set forom=%sdly%\yukonpxe.lom
for /f "eol=# tokens=1,2" %%a in (%sdly%\yukonpxe.txt) do findhex 00AB11%%a00 csmcore>nul && setdevid %%b %forom% tmp\yuk_%%b && set did=%%b && set romf=tmp\yuk_%%b 11AB %%b && call :romu
echo;
%csmx%
call ::yukver
pause
goto lan

:osata
%rdir%
cls
echo,
echo 		Other Disk Controller
echo 	[Current version]
call :mrvlver
call :asmver
call :jmbver

echo,
echo 	[Available version]
if exist tmp\mrvs* drvver %sdsm%\mrvlahci.efi
if exist tmp\mrvr* drvver %sdsm%\mrvlraid.efi
if %mrvl91%==1 (
	if defined mrvlar (
		findver "     OROM Marvell 88SE91xx      - " 504349524B1B -21 00 10 1 %sdsm%\mrvl91xxa.bin
		findver "     OROM Marvell 88SE91xx      - " 504349524B1B -21 00 10 1 %sdsm%\mrvl91xxr.bin
	)
	if defined mrvlrd findver "     OROM Marvell 88SE91xx      - " 004D565244004D56554900 -10 00 10 1 %sdsm%\mrvl91xxrd.bin
)
if %mrvl92%==1 findver "     OROM Marvell 88SE92xx      - " 504349524B1B -21 00 10 1 %sdsm%\mrvl92xx.bin
if %mrvl61%==1 findver "     OROM Marvell 88SE92xx      - " 50434952AB11 -21 00 10 1 %sdsm%\mrvl61xx.bin

if %asmo%==1 for /f %%a in ('dir %sdsa%\*.* /b') do findver "     OROM Asmedia 106X          - " 41736D65646961203130365820534154412F5041544120436F6E74726F6C6C6572 38 00 6 1 %sdsa%\%%a
if %jmbo%==1 (
	findver "     OROM JMicron JMB36x        - " 504349204578707265737320746F2053415441494920484F535420436F6E74726F6C6C657220524F4D 43 00 8 1 %sdsj%\jmb362_7.bin
	findver "     OROM JMicron JMB36x        - " 504349204578707265737320746F2053415441494920484F535420436F6E74726F6C6C657220524F4D 43 00 8 1 %sdsj%\jmb362_8.bin
)

set ec=
set mvv=
echo;
if %mrvl%==1 echo 1 - Replace Marvell
if %asmo%==1 echo 2 - Replace ASMedia
if %jmbo%==1 echo 3 - Replace JMicron
echo 0 - Exit to Main Menu
:mno
set /p ec=Choice:
if not defined ec goto mno
if %ec%==0 goto mn1
if %mrvl%==1 if %ec%==1 goto marvs
if %asmo%==1 if %ec%==2 goto asm
if %jmbo%==1 if %ec%==3 goto jmb
goto mno

:marvs
set fefi=%sdsm%\mrvlahci.efi
for /f "tokens=1,2" %%a in ('%ufbl% 00004D0061007200760065006C006C00200053004300530049002000440072006900760065007200') do (
	set subguid=%%b
	<nul set /p TmpStr=EFI Marvell AHCI 
	if defined subguid (
		echo SubGUID %%b
		%ur% %%b 18  %fefi% -o bios.bin && %ue% %%b -o tmpr -m body -t 18>nul && %renb% tmp\mrvs_%%b>nul
	) else (
		echo GUID %%a
	%ur% %%a 10  %fefi% -o bios.bin && %ue% %%a -o tmpr -m body -t 10>nul && %renb% tmp\mrvs_%%a>nul
	)
	%rdir%
)
set fefi=%sdsm%\mrvlraid.efi
for /f "tokens=1,2" %%a in ('%ufbl% 00004D0061007200760065006C006C00200052004100490044002000440072006900760065007200') do (
	set subguid=%%b
	<nul set /p TmpStr=EFI Marvell RAID 
	if defined subguid (
		echo SubGUID %%b
		%ur% %%b 18  %fefi% -o bios.bin && %ue% %%b -o tmpr -m body -t 18>nul && %renb% tmp\mrvr_%%b>nul
	) else (
		echo GUID %%a
		%ur% %%a 10  %fefi% -o bios.bin && %ue% %%a -o tmpr -m body -t 10>nul && %renb% tmp\mrvr_%%a>nul
	)
	%rdir%
)

set brend=OROM Marvell
set forom=%sdsm%\Mrvl92xx.bin
if %mrvl92%==1 for /f "tokens=1,2" %%a in ('%ufbl% 504349524B1B..92') do (
	if %aa% neq 4 set subguid=%%b
	if defined subguid (
		echo %brend% SubGUID %%b
		%ue% %%b -o tmpr -m body -t 18>nul && for /f "eol=# tokens=1,2" %%c in (%sdsm%\Mrvl92xx.txt) do findhex 504349524B1B%%c tmpr\body.bin>nul && setdevid %%d %forom% tmp\%%d_%%b && %ur% %%b 18 tmp\%%d_%%b -o bios.bin
	) else (
		for /f "eol=# tokens=1,2" %%c in (%sdsm%\Mrvl92xx.txt) do findhex 004B1B%%c csmcore>nul && setdevid %%d %forom% tmp\%%d && set did=%%d && set romf=tmp\%%d 1B4B %%d && call :romu
	)
	%rdir%
)
set forom=%sdsm%\Mrvl91xxrd.bin
if %mrvl91%==1 if defined mrvlrd for /f "tokens=1,2" %%a in ('%ufbl% 504349524B1B..91') do (
	if %aa% neq 4 set subguid=%%b
	if defined subguid (
		echo %brend% SubGUID %%b
		%ue% %%b -o tmpr -m body -t 18>nul && for /f "eol=# tokens=1,2" %%c in (%sdsm%\Mrvl91xxrd.txt) do findhex 504349524B1B%%c tmpr\body.bin>nul && setdevid %%d %forom% tmp\%%d_%%b && %ur% %%b 18 tmp\%%d_%%b -o bios.bin
	) else (
		for /f "eol=# tokens=1,2" %%c in (%sdsm%\Mrvl91xxrd.txt) do findhex 004B1B%%c csmcore>nul && setdevid %%d %forom% tmp\%%d && set did=%%d && set romf=tmp\%%d 1B4B %%d && call :romu
	)
	%rdir%
)
set forom=%sdsm%\Mrvl91xxa.bin
set forom1=%sdsm%\Mrvl91xxr.bin
if %mrvl91%==1 if defined mrvlar for /f "tokens=1,2" %%a in ('%ufbl% 504349524B1B..91') do (
	if %aa% neq 4 set subguid=%%b
	if defined subguid (
		echo Oops! Please, send report and BIOS file
	) else (
		for /f "eol=# tokens=1,2" %%c in (%sdsm%\Mrvl91xx.txt) do (
			findhex 004B1B%%c csmcore>nul && %mmt% /e /l tmp\%%d 1B4B %%d && if exist tmp\%%d findhex 23902890 tmp\%%d>nul && (setdevid %%d %forom% tmp\%%d && set did=%%d AHCI && set romf=tmp\%%d 1B4B %%d && call :romu) || (setdevid %%d %forom1% tmp\%%d && set did=%%d RAID && set romf=tmp\%%d 1B4B %%d && call :romu)
)))

rem Old Marvell 61xx
set forom=%sdsm%\Mrvl61xx.bin
(findhex 00AB112161 csmcore>nul || findhex A0AB112161 csmcore>nul) && set did=6121 && set romf=%forom% 11AB 6121 && call :romu
set forom=%sdsm%\Mrvl61xxr.bin
(findhex 00AB114561 csmcore>nul || findhex A0AB112161 csmcore>nul) && set did=6121 && set romf=%forom% 11AB 6145 && call :romu

%csmx%
echo;
call :mrvlver
pause
goto osata

:asm
set ec=
echo;
setlocal enableextensions enabledelayedexpansion
set /A asmch=0
for /f %%a in ('dir %sdsa%\*.* /b') do set /A asmch+=1 && findver "!asmch! -  OROM Asmedia 106X          - " 41736D65646961203130365820534154412F5041544120436F6E74726F6C6C6572 38 00 6 1 %sdsa%\%%a
endlocal
echo 0 - Cancel
:asm1
set /p ec=Choice:
if not defined ec goto asm1
if %ec%==1 set forom=%sdsa%\ASM106x.0951 && goto asms
if %ec%==2 set forom=%sdsa%\ASM106x.097 && goto asms
if %ec%==3 set forom=%sdsa%\ASM106x.427 && goto asms
if %ec%==0 goto osata
goto asm1
:asms
set brend=OROM ASM106x
for /f "tokens=1,2" %%a in ('%ufbl% 50434952211b1206') do (
	if %aa% neq 4 set subguid=%%b
	if defined subguid (
		echo %brend%  SubGUID %%b
		%ur% %%b 18 %forom% -o bios.bin
	) else (
		(findhex 00211b1106 csmcore>nul || findhex A0211b1106 csmcore>nul) && set did=611 && set romf=%forom% 1b21 611 && call :romu
		(findhex 00211b1206 csmcore>nul || findhex A0211b1206 csmcore>nul) && set did=612 && set romf=%forom% 1b21 612 && call :romu
		(findhex 00211b1306 csmcore>nul || findhex A0211b1306 csmcore>nul) && set did=613 && set romf=%forom% 1b21 613 && call :romu
))
echo;
%csmx%
call :asmver
pause
goto osata

:jmb
set ec=
echo;
findver "1 -  OROM JMicron JMB36x        - " 504349204578707265737320746F2053415441494920484F535420436F6E74726F6C6C657220524F4D 43 00 8 1 %sdsj%\jmb362_7.bin
findver "2 -  OROM JMicron JMB36x        - " 504349204578707265737320746F2053415441494920484F535420436F6E74726F6C6C657220524F4D 43 00 8 1 %sdsj%\jmb362_8.bin
echo 0 - Cancel
:jmb1
set /p ec=Choice:
if not defined ec goto jmb1
if %ec%==1 set jmb362=%sdsj%\jmb362_7.bin && set jmb363=%sdsj%\jmb363_7.bin && goto jmbs
if %ec%==2 set jmb362=%sdsj%\jmb362_8.bin && set jmb363=%sdsj%\jmb363_8.bin && goto jmbs
if %ec%==0 goto osata
goto jmb1
:jmbs
set brend=OROM JMicron 362/363
findhex 007b196223 csmcore>nul && set did=2362 && set romf=%jmb362% 197b 2362 && call :romu
findhex 007b196323 csmcore>nul && set did=2363 && set romf=%jmb363% 197b 2363 && call :romu
echo;
%csmx%
call :jmbver
pause
goto osata

:cpu
%rdir%
cls
copy /y %wf%\Z_MCU.txt tmp\Z_MCU.txt>nul
mce bios.bin -skip -ubu -exit
%tit%

set ec=
set mc1=
set mc2=
set mpdt=
set str=
set /A count_try=0

if defined mc_guid (
	echo 	These microcodes are in your BIOS file 
	echo	 	GUID %mc_guid%
	echo;
	echo 	[Intel CPU MicroCode]
	echo C - Create FFS with microcodes
	echo E - View/Edit MCUpdate.txt
	echo M - User Select only 1 Microcode File
)
if %amd%==1 (
	if %aa%==4 if %mmtool%==0 cecho {\n}{\t}{0E}It is recommended to use MMTool.{#}{\n} && goto mce_mrnu
	echo;
	echo 	[AMD CPU MicroCode]
	echo F - Find and Replace MicroCode
)
:mce_mrnu
echo;
echo 	[MC Extractor]
echo X - Extract all CPU microcodes
echo S - Search for available microcode in DB.
echo 	[Internet access required]
echo U - Check for  MCE and DB updates
echo D - Go and Download latest versions MCE and DB
echo 0 - Exit to Main Menu

:mnmc
set /p ec=Choice:
if not defined ec goto mnmc
if %amd%==0 if defined mc_guid (
	if /I %ec%==c goto createffs
	if /I %ec%==e %sdim%\MCUpdate.txt
	if /I %ec%==m goto mcg
)
if %amd%==1 (
	if %aa%==4 if %mmtool%==1 if /I %ec%==f goto cpua
	if %aa%==5 if /I %ec%==f goto cpua
)
if /I %ec%==x echo Extracting... && mce bios.bin -skip>nul && goto cpu
if /I %ec%==s goto sdb
if /I %ec%==u (mce -updchk && goto cpu) || goto cpu
if /I %ec%==d start https://github.com/platomav/MCExtractor/releases && goto cpu
if %ec%==0 goto mn1
goto mnmc

:sdb
set /p str=Enter CPUID, example 000306C3 :^>
if not defined str goto cpu
mce -search  %str%
goto cpu

:createffs
for /f "eol=# tokens=1,2" %%a in (%sdim%\MCUpdate.txt) do mcodefit -cpuid bios.bin %%a && set mc1=%sdim%\%%b && echo %%a %%b>>tmp\Z_MCU.txt && call :varmc
if not defined mc2 echo Nothing found && pause && goto cpu
goto umc

:varmc
set mc1=%mc1%
echo %mc1%
mcodefit -mc_check %mc1% || pause && goto cpu
set mc2=%mc2% -i %mc1%
if %mc_pad%==1 mcodefit -0x800 %mc1%>nul || set mc2=%mc2% -i %wf%\Z_PAD.bin
exit /b

:mcg
setlocal
for /f "usebackq delims=" %%m in (
	`@"%systemroot%\system32\mshta.exe" "about:<FORM><INPUT type='file' name='qq'></FORM><script>document.forms[0].elements[0].click();var F=document.forms[0].elements[0].value;try {new ActiveXObject('Scripting.FileSystemObject').GetStandardStream(1).Write(F)};catch (e){};close();</script>" ^
	1^|more`
) do  set mc1=%%m
endlocal && echo %mc1% && mcodefit -mc_check %mc1% && set mc2=-i %mc1%
echo %mc2%
if not defined mc2 goto cpu

:umc
echo Generate FFS with Microcode
findhex 4D5044540001000010000000000010 bios.bin>nul && set mpdt=-i %wf%\MPDT_BOOT_YES.bin
findhex 4D5044540000000010000000000010  bios.bin>nul && set mpdt=-i %wf%\MPDT_BOOT_NO.bin

set mc_cs=1
%uf% all count %mc_patt%..AA01........F801000000>nul && set mc_cs=0
if %mc_cs%==0 (
	%wf%\GenFFS -t EFI_FV_FILETYPE_RAW -g %mc_guid% %mc2% %mpdt% -o tmp\mCode.ffs
) else (
	%wf%\GenFFS -s -t EFI_FV_FILETYPE_RAW -g %mc_guid% %mc2% %mpdt% -o tmp\mCode.ffs
)
set modcpu=tmp\mCode.ffs
%tit%
echo;
mce tmp\mCode.ffs -skip -ubu -exit
echo 	These microcodes will be entered into your BIOS file

if %aa% neq 0 if %mmtool%==0 if %gmc_count% geq 2 cecho {\n}{\t}{0E}It is recommended to use MMTool.{#}{\n} && pause && goto cpu

set ec=
echo;
echo R - Start replacement
if %aa%==5 if %mmtool%==1 if %gmc_count%==1 echo A - Start replacement Alternative
if %aa%==5 if %mmtool%==1 if %gmc_count%==2 (
	echo.
	echo 	[For MSI x299 Series]
	echo P - Replacement in PEI volume
	echo D - Inserting into a DXE volume - Test
)
echo 0 - Cancel
:mnmcu
set /p ec=Choice:
if not defined ec goto mnmcu
if /I %ec%==r goto cpus
if %aa%==5 if %mmtool%==1 if %gmc_count% LEQ 2 (
	if /I %ec%==a goto msi_x299
	if /I %ec%==d goto msi_x299
	if /I %ec%==p goto msi_x299
)
if %ec%==0 goto cpu
goto mnmcu

:cpus
set /A count_try+=1
echo 	[Preparing for replacement]
copy /y bios.bin tmp\bios.bak>nul && cecho {0B}BIOS file backup{#}{\n}
if %gmc_count%==1 goto one_repl
for /f "tokens=1" %%m in ('%uf% header list %mc_patt%') do (
	%ue% %%m -o tmpr -m file>nul && 	findhex 00F8FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF tmpr\file.ffs>nul
	if not errorlevel 1 (
		copy /y tmpr\file.ffs tmp\mCode_pad.ffs>nul
		<nul set /p TmpStr=Dummy GUID: 
 		mcodefit -mc_guid_repl01 bios.bin || mcodefit -mc_guid_repl01 tmpr\file.ffs>nul && %ur% %%m 1 tmpr\file.ffs -o bios.bin -asis || move tmp\bios.bak bios.bin>nul && cecho {0B}BIOS file restored{#}{\n} && pause && goto cpu
	) else (
		<nul set /p TmpStr=mCode GUID: 
		mcodefit -mc_guid_repl02 bios.bin || mcodefit -mc_guid_repl02 tmpr\file.ffs>nul && set rplguid=%%m && set rplfile=tmpr\file.ffs && call :upd_mcffs || move tmp\bios.bak bios.bin>nul && cecho {0B}BIOS file restored{#}{\n} && pause && goto cpu
	)
	%rdir%
)

echo 	[Replacement]
for /f "tokens=1" %%m in ('%uf% header list %mc_patt_02%') do (
	<nul set /p TmpStr=mCode FFS: 
	set rplguid=%%m && set rplfile=%modcpu% && call :upd_mcffs || move tmp\bios.bak bios.bin>nul && cecho {0B}BIOS file restored{#}{\n} && goto rs_mmt
)

for /f "tokens=1" %%m in ('%uf% header list %mc_patt_01%') do 	(
	<nul set /p TmpStr=Dummy FFS: 
	mcodefit -mc_guid_rest01 bios.bin || %ur% %%m 1 tmp\mCode_pad.ffs -o bios.bin -asis || move tmp\bios.bak bios.bin>nul && cecho {0B}BIOS file restored{#}{\n} && pause && goto cpu
)
goto Func_FIT_

:one_repl
echo 	[Replacement]
<nul set /p TmpStr=mCode FFS: 
%ur% %mc_guid% 1 %modcpu% -o bios.bin -asis || move tmp\bios.bak bios.bin>nul && cecho {0B}BIOS file restored{#}{\n} && pause && goto cpu
goto Func_FIT_

:msi_x299
if exist mmtool_a5.exe (
	findhex 35002E00300032002E0030003000 mmtool_a5.exe>nul || cecho {0E}Is required MMRool v5.2.0.2x+t{#}{\n} && pause && goto cpu
	set mmt=start /b /min /wait mmtool_a5 bios.bin
)
call :mcu_msi_x299 || move tmp\bios.bak bios.bin>nul && cecho {0B}BIOS file restored{#}{\n} && pause && goto cpu

rem mce bios.bin -skip -ubu -exit
:Func_FIT_
if %fit%==1 (
	mcodefit -fit_check bios.bin || mcodefit -fit_restore bios.bin>nul
	mcodefit -fit_fixed bios.bin && mcodefit -fit_backup bios.bin>nul
)

pause
goto cpu

:cpua
echo;
echo 	[Replacement]
rem set patt_acpu=2455434F44455653
set patt_acpu=20............0.80.00............0.......0............0.
if %aa%==4 for /f "tokens=1,2" %%a in ('%ufbl% %patt_acpu%') do (
	set subguid=%%b
	if not defined subguid (
		%ue% %%a -o tmpr -m file>nul
		if exist tmpr (
			for /f %%d in ('dir %sdam%\old\*.bin /b') do set mcaf=%%d && call :mca_rpl
			set rplguid=%%a
			set rplfile=tmpr\file.ffs
			if defined amc_rpl mcodefit -ffs_fixed_cs tmpr\file.ffs && call :upd_mcffs
		)
	set amc_rpl=
	%rdir%
))
if %aa%==5 for /f %%d in ('dir %sdam%\am4\*.bin /b') do mcodefit -amd bios.bin  %sdam%\am4\%%d
pause
goto cpu

:mca_rpl
mcodefit -amd tmpr\file.ffs %sdam%\old\%mcaf% && set amc_rpl=1 && exit /b 0
exit /b 1

:upd_mcffs
%mmt% /r %rplguid% %rplfile%
if %errorlevel% neq 0 (cecho {0C}MMTool Error!{#}{\n} && exit /b 1) else (echo %ok%)
exit /b 0

:mcu_msi_x299
if %gmc_count% gtr 2 echo Cancel! Is there something wrong! && pause && goto cpu
echo 	[Preparing for replacement]
copy /y bios.bin tmp\bios.bak>nul && cecho {0B}BIOS file backup{#}{\n}
if %gmc_count%==1 goto one_mmt_repl
%ue% %mc_guid% -o tmpr -m file>nul
copy /y tmpr\file.ffs tmp\mcode_pad.ffs>nul
<nul set /p TmpStr=Dummy GUID: 
mcodefit -mc_guid_repl01 bios.bin || mcodefit -mc_guid_repl01 tmpr\file.ffs>nul && %ur% %mc_guid% 1 tmpr\file.ffs -o bios.bin -asis

:one_mmt_repl
echo 	[Replacement]
<nul set /p TmpStr=Delete old mCode - 
for /f "eol=# tokens=1,2" %%a in (tmp\Z_MCU.txt) do (
	set _mc=%mmt% /d /p 1
	call :mc_up_one || exit /b 1
	<nul set /p TmpStr=%%a 
)
if /I %ec%==p goto m2up
if /I %ec%==a goto m2up
echo;
<nul set /p TmpStr=mCode FFS: 
%ur% 17088572-377F-44EF-8F4E-B09FFF46A071 1 tmp\mcode.ffs -o bios.bin -asis
%rdir%
exit /b 0
:m2up
echo;
if %gmc_count%==2 start /wait tmp\Z_MCU.txt
<nul set /p TmpStr=Insert new mCode - 
for /f "eol=# tokens=1,2" %%a in (tmp\Z_MCU.txt) do (
	set _mc=%mmt% /i /p %sdim%\%%b
	call :mc_up_one || exit /b 1
	<nul set /p TmpStr=%%a 
)
%rdir%
if %gmc_count%==1 exit /b 0
echo;
<nul set /p TmpStr=Dummy FFS: 
mcodefit -mc_guid_rest01 bios.bin || %ur% 17088572-377F-44EF-8F4E-B09FFF46A071 1 tmp\mcode_pad.ffs -o bios.bin -asis
exit /b 0

:mc_up_one
%_mc%
if %errorlevel% neq 0 exit /b 1
exit /b 0

:csm_extr
%rdir%
if %aa%==0 exit /b 1
rem echo %csmguid%
if defined csmguid (
	%ue% %csmguid% -o tmpr -m body>nul && %renb% csmcore>nul && if not exist tmpr\body_*.bin %rdir% && exit /b 0
	(for /f %%r in ('dir tmpr\body_*.bin /b') do copy /b csmcore+tmpr\%%r csmcore>nul) && %rdir% && exit /b 0
)

rem	if %aa%==4 %ue% %csmguid% -o tmpr -m body -t 19>nul && %renb% csmcore>nul && %rdir% && exit /b 0
rem )
%rdir%
exit /b 1

:setup_ifr
if not exist ifrextract.exe cecho {0B}IFR Extractor not found{#}{\n} && pause && goto mn1
cls
if exist "_Setup_%biosname%" rd /s /q "_Setup_%biosname%"
echo;
echo 	[AMI Setup IFR Extractor]
echo;
echo Find AMI Setup
for /f "tokens=1,2" %%a in ('%ufbl% 530079007300740065006D0020004C0061006E0067007500610067006500') do (
	set subguid=%%b
	if defined subguid (
		cecho {0B}AMI Setup in GUID %%a{#}{\n}
		cecho {0B}          SubGUID %%b{#}{\n}
		%ue% %%a -o _Setup_%biosname% -m body -t 18>nul
	) else (
		cecho {0B}AMI Setup in GUID %%a{#}{\n}
		%ue% %%a -o _Setup_%biosname% -m body -t 10>nul
))
if exist _Setup_%biosname%\body.bin ifrextract _Setup_%biosname%\body.bin _Setup_%biosname%\setup_extr.txt && echo Done!
if exist _Setup_%biosname%\setup_extr.txt findver "BIOS Lock VarOffset - " 42494F53204C6F636B 45 2C 6 2 _Setup_%biosname%\setup_extr.txt && findver "BIOS Lock VarOffset - " 42494F53204C6F636B 45 2C 6 2 _Setup_%biosname%\setup_extr.txt>_Setup_%biosname%\BIOSLock_str.txt
pause
goto mn1

:rg
echo;
echo 	Other Option ROM in FFS
echo;
call :oromguid
echo;
pause
goto mn1

:romu
if %mmtool%==0 echo File not replaced && exit /b 1
echo %brend% DevID %did%
%mmt% /r /l %romf%
if %errorlevel% neq 0 (cecho {0C}MMTool Error!{#}{\n} && exit /b 1) else (echo %ok%)
exit /b 0

:err
cecho {0D}!!! File BIOS not found !!!{#}{\n}
pause
exit

:exit
 if %fit%==1 mcodefit -fit_check bios.bin || mcodefit -fit_restore bios.bin
set ec=
echo;
if %asus%==1 echo 1 - Rename to ASUS USB BIOS Flashback
if %asus%==0 echo 1 - Rename to mod_%biosname%
echo 0 - As Is BIOS.BIN
echo;
:ubf
set /p ec=Rename? :
if not defined ec goto ubf
if %ec%==1 if %asus%==1 goto ren_ubf
if %ec%==1 if %asus%==0 (
	ren bios.bin mod_%biosname%
	echo bios.bin ===^> mod_%biosname%
	goto exit1
)
if %ec%==0 goto exit1
goto ubf

:ren_ubf
if exist bios.bin.dump for /f %%u in ('findver "" 24424F4F5445464924 145 00 12 1 bios.bin') do (
if exist bios.bin.dump (
	echo Restore Capsule Header
	copy /b /y bios.bin.dump\header.bin+bios.bin %%u>nul
	echo bios.bin ===^> %%u
	del bios.bin
) else (
	ren bios.bin %%u && echo bios.bin ===^> %%u
))
if exist bios.bin ren bios.bin mod_%biosname% && echo bios.bin ===^> mod_%biosname%

:exit1
echo;
echo *******************************************
echo * Many thanks for the use of the project. *              *
echo *******************************************

%rdir%
if exist bios.bin.dump rd /s /q bios.bin.dump
if exist tmp rd /s /q tmp
if exist fit.dump del /f /q fit.dump
if exist csmcore del /f /q csmcor*
pause
EXIT

REM display version
:video_ver
if exist tmp\gop_* for /f "tokens=*" %%b in ('dir tmp\gop_* /b') do drvver tmp\%%b
if %amd%==1 goto amd_video
findver "      OROM VBIOS SandyBridge     - " 24564254205341 79 FF 4 2 csmcore && set vervb=3
findver "      OROM VBIOS SNB-IVB         - " 2456425420534E 79 FF 4 2 csmcore && set vervb=3 && exit /b
for /f "tokens=*" %%b in ('findver "" 24564254204841 79 FF 4 2 csmcore') do (
	if %%b LSS 2000 (echo      OROM VBIOS HSW-BDW         - %%b) else (echo      OROM VBIOS Haswell         - %%b)) && set vervb=5 && exit /b
for /f "tokens=*" %%b in ('findver "" 2456425420534B 79 FF 4 2 csmcore') do (
	if %%b LSS 1034 (echo      OROM VBIOS SkyLake         - %%b) else (echo      OROM VBIOS SKL-KBL         - %%b)) && set vervb=9
findver "     OROM VBIOS CoffeeLake      - " 2456425420434F 79 FF 4 2 csmcore && set vervb=9 && exit /b
findver "     OROM VBIOS CherryView      - " 24564254204348 79 FF 4 2 csmcore && exit /b
findver "     OROM VBIOS ValleyView      - " 24564254205641 79 FF 4 2 csmcore && exit /b
findver "     OROM VBIOS ApolloLake      - " 24564254204252 79 FF 4 2 csmcore
findver "     OROM VBIOS GeminiLake      - " 24564254204745 79 FF 4 2 csmcore
findver "     OROM VBIOS IceLake         - " 24564254204943 79 FF 4 2 csmcore
findver "     OROM VBIOS Ironlake        - " 24564254204952 79 FF 4 2 csmcore
findver "     OROM VBIOS Eaglelake       - " 24564254204541 79 FF 4 2 csmcore
if exist tmp\vbios_* for /f %%a in ('dir tmp\vbios_* /b') do (
	for /f %%b in ('findver "" 002456425420 06 64 15 1 tmp\%%a') do (
		for /f %%c in ('findver "" 002456425420 80 FF 4 1 tmp\%%a') do echo      FFS-OROM VBIOS %%b Version %%c
))
exit /b

:amd_video
if exist tmp\vbios_* for /f "tokens=*" %%b in ('dir tmp\vbios_* /b') do (
	findhex 5043495202100413 tmp\%%b>nul && findver "     OROM VBIOS Kaveri          - " 41544F4D42494F53424B 18 00 22 1 tmp\%%b && set sp=1) || (
	findhex 5043495202100199 tmp\%%b>nul && findver "     OROM VBIOS Trinity         - " 41544F4D42494F53424B 18 00 22 1 tmp\%%b && set tr=1) || (
	findhex 5043495202103098 tmp\%%b>nul && findver "     OROM VBIOS Kabini          - " 41544F4D42494F53424B 18 00 22 1 tmp\%%b && set ka=1) || (
	findhex 504349520210E098 tmp\%%b>nul && findver "     OROM VBIOS Stoney          - " 41544F4D42494F53424B 18 00 22 1 tmp\%%b && set st=1) || (
	findhex 504349520210D815 tmp\%%b>nul && findver "     OROM VBIOS Picasso         - " 41544F4D42494F53424B 18 00 22 1 tmp\%%b && set pi=1) || (	
	findhex 5043495202107098 tmp\%%b>nul && findver "     OROM VBIOS Carrizo         - " 41544F4D42494F53424B 18 00 22 1 tmp\%%b && set ca=1) || (
	findhex 526176656E47656E tmp\%%b>nul && findver "     OROM VBIOS Raven           - " 41544F4D42494F53424B 18 00 22 1 tmp\%%b && set ra1=1) || (
	findhex 526176656E3247656E tmp\%%b>nul && findver "     OROM VBIOS Raven 2         - " 41544F4D42494F53424B 18 00 22 1 tmp\%%b && set ra2=1) || (
	findhex 5043495202100069 tmp\%%b>nul && findver "     OROM VBIOS Weston Pro      - " 41544F4D42494F53424B 18 00 22 1 tmp\%%b && set wp=1) || (
	findhex 5043495202105098 tmp\%%b>nul && findver "     OROM VBIOS Mullins         - " 41544F4D42494F53424B 18 00 22 1 tmp\%%b) || (
	findver "     FFS-OROM VBIOS Unknown     - " 41544F4D42494F53424B 18 00 22 1 tmp\%%b)
if not exist tmp\vbios_* findver "     OROM AMD VBIOS             - " 41544F4D42494F53424B 18 00 22 2 csmcore
exit /b

:othvideo_ver
if exist tmp\othgop_* for /f "tokens=*" %%b in ('dir tmp\othgop_* /b') do drvver tmp\%%b
findver "     OROM VBIOS ASPEED          - " 004153542047505500 9 00 7 2 csmcore
rem if exist tmp\vbios_* for /f %%a in ('dir tmp\vbios_* /b') do (
rem		for /f %%b in ('findver "" 4E564944494120436F72702E 0 20 6 1 tmp\%%a') do (
rem		for /f %%c in ('findver "" 56657273696F6E 8 20 14 1 tmp\%%a') do echo      FFS-OROM VBIOS %%b Version %%c
rem ))
exit /b

:irstd
if exist tmp\irst_* for /f "tokens=*" %%b in ('dir tmp\irst_* /b') do drvver tmp\%%b && set m1=1 && set irst=1
findver "     OROM IMSM RAID for SATA    - " 496E74656C285229204D61747269782053746F72616765204D616E61676572206F7074696F6E20524F4D 44 20 12 2 csmcore && set m1=1 && set irst=1
findver "     OROM IRST RAID for SATA    - " 496E74656C2852292052617069642053746F7261676520546563686E6F6C6F6779202D204F7074696F6E20524F4D 49 0A 12 2 csmcore && set m1=1 && set irst=1
if exist tmp\irste_* for /f "tokens=*" %%b in ('dir tmp\irste_* /b') do drvver tmp\%%b && set m1=1 && set irste=1
if exist tmp\vmd_* for /f "tokens=*" %%b in ('dir tmp\vmd_* /b') do drvver tmp\%%b && set m1=1 && set vmd=1
if exist tmp\vmdd_* set vmdd=1
findver "     OROM IRSTe RAID for SATA   - " 496E74656C2852292052617069642053746F7261676520546563686E6F6C6F677920656E7465727072697365202D2053415441204F7074696F6E20524F4D 65 0A 12 2 csmcore && set m1=1 && set irste=1
findver "     OROM Intel VROC for SATA   - " 496E74656C285229205669727475616C2052414944206F6E20435055202D2053415441204F7074696F6E20524F4D 49 0A 12 2 csmcore && set m1=1 && set irste=1
findver "     OROM IRSTe RAID for sSATA  - " 496E74656C2852292052617069642053746F7261676520546563686E6F6C6F677920656E7465727072697365202D207353415441204F7074696F6E20524F4D 66 0A 12 2 csmcore && set m1=1 && set irste=1
findver "     OROM Intel VROC for sSATA  - " 496E74656C285229205669727475616C2052414944206F6E20435055202D207353415441204F7074696F6E20524F4D  50 0A 12 2 csmcore && set m1=1 && set irste=1
findver "     OROM IRSTe RAID for SCU    - " 496E74656C2852292052617069642053746F7261676520546563686E6F6C6F677920656E7465727072697365202D20534355204F7074696F6E20524F4D 64 0A 12 2 csmcore && set m1=1 && set irste=1
if exist tmp\invme_* for /f "tokens=*" %%b in ('dir tmp\invme_* /b') do drvver tmp\%%b && set intnvme=1
exit /b

:amdd
if exist tmp\raidxpt2_* for /f "tokens=*" %%a in ('dir tmp\raidxpt2_* /b') do findver "     EFI AMD RAIDXpert2-Fxx     - " 5243424E454E44 8 00 12 1 tmp\%%a
findver "     OROM AMD RAIDXpert2-Fxx    - " 5243424E42474E 8 00 12 2 csmcore
if exist tmp\raid_* for /f "tokens=*" %%a in ('dir tmp\raid_* /b') do drvver tmp\%%a
:amdd1
findver "     OROM AMD RAID MISC 4392    - " 9243021092436C -22 00 12 1 csmcore && set o43xx=1
findver "     OROM AMD RAID MISC 4393    - " 9343021093436C -22 00 12 1 csmcore && set o43xx=1
findver "     OROM AMD RAID MISC 7802    - " 0278221002786C -22 00 12 1 csmcore && set o78xx=1
findver "     OROM AMD RAID MISC 7803    - " 0378221003786C -22 00 12 1 csmcore && set o78xx=1
findver "     OROM AMD AHCI              - " 414D442041484349 22 00 10 1 csmcore && set oahci=1
exit /b

:mrvlver
if exist tmp\mrv* for /f "tokens=*" %%b in ('dir tmp\mrv* /b') do drvver tmp\%%b && set mrvl=1
if %mrvl91%==1 for /f "eol=# tokens=1,2" %%a in (%sdsm%\Mrvl91xx.txt) do (
	findhex 004B1B%%a csmcore>nul && findver "     OROM Marvell 88SE%%b      - " 004B1B%%a 16 00 10 1 csmcore && set mrvl=1 && set mrvlar=1
)
if %mrvl91%==1 for /f "eol=# tokens=1,2" %%a in (%sdsm%\Mrvl91xxrd.txt) do (
	findhex 004B1B%%a csmcore>nul && findver "     OROM Marvell 88SE%%b      - " 004D565244004D56554900 -10 00 10 1 csmcore && set mrvl=1 && set mrvlrd=1
)
if %mrvl92%==1 for /f "eol=# tokens=1,2" %%a in (%sdsm%\Mrvl92xx.txt) do (
	findhex 004B1B%%a csmcore>nul && findver "     OROM Marvell 88SE%%b      - " 004B1B%%a 16 00 10 1 csmcore && set mrvl=1
)

findver "     OROM Marvell 88SE61xx      - " 50434952AB112161 -22 00 10 1 csmcore && set mrvl=1
exit /b

:asmver
findver "     OROM Asmedia 106X          - " 41736D65646961203130365820534154412F5041544120436F6E74726F6C6C6572 38 00 6 1 csmcore  && set asmo=1
exit /b

:jmbver
findver "     OROM JMicron JMB36x        - " 504349204578707265737320746F2053415441494920484F535420436F6E74726F6C6C657220524F4D 43 00 8 1 csmcore && set jmbo=1
exit /b

:inlver
if exist tmp\lani* for /f "tokens=*" %%b in ('dir tmp\lani* /b') do drvver tmp\%%b && set lani=1
rem findver "     OROM Intel Boot Agent FE   - " 496E74656C28522920426F6F74204167656E74204645 24 00 7 2 csmcore && set lanir=0
findver "     OROM Intel Boot Agent CL   - " 496E74656C28522920426F6F74204167656E7420434C 24 00 7 2 csmcore && set lani=1
findver "     OROM Intel Boot Agent GE   - " 496E74656C28522920426F6F74204167656E74204745 24 00 7 2 csmcore && set lani=1
findver "     OROM Intel Boot Agent XE   - " 496E74656C28522920426F6F74204167656E742058452076 24 00 7 2 csmcore && set lani=1
findver "     OROM Intel Boot Agent x550 - " 496E74656C28522920426F6F74204167656E742058452028 31 00 7 2 csmcore && set lani=1 && set x550=1
rem findver "     OROM Intel Boot Agent XG   - " 496E74656C28522920426F6F74204167656E74205847 24 00 7 2 csmcore
rem findver "     OROM Intel Boot Agent 40G  - " 496E74656C28522920426F6F74204167656E74203430 24 00 7 2 csmcore
rem findver "     OROM Intel iSCSI Boot      - " 496E74656C2852292069534353492052656D6F746520426F6F74 35 00 7 1 csmcore
exit /b

:rtkver
if exist tmp\lanr* for /f "tokens=*" %%b in ('dir tmp\lanr* /b') do drvver tmp\%%b && set lanrtk=1
findver "     OROM Realtek 2.5 Gb PXE    - " 5265616C74656B20322E3520476967616269742045746865726E657420436F6E74726F6C6C6572205365726965732076 48 20 4 1 csmcore
rem  && set lanrtk=1 && set rtk2=1
findver "     OROM Realtek Boot Agent GE - " 5265616C74656B2050434965204742452046616D696C7920436F6E74726F6C6C657220536572696573 43 20 4 1 csmcore && set lanrtk=1 && set rtk1=1
rem findver "     OROM Realtek Boot Agent FE - " 5265616C74656B20504349652046452046616D696C7920436F6E74726F6C6C657220536572696573 42 20 4 1 csmcore
exit /b

:lxver
if exist tmp\lanlx* for /f "tokens=*" %%b in ('dir tmp\lanlx* /b') do drvver tmp\%%b && set lanlx=1
findver "     OROM QCM-Atheros PXE       - " 504349452045746865726E657420436F6E74726F6C6C6572 26 28 8 2 csmcore && set lanlx=1
exit /b

:bcmver
if exist tmp\lanb* for /f "tokens=*" %%b in ('dir tmp\lanb* /b') do drvver tmp\%%b && set lanbcm=1
findver "     OROM Broadcom Boot Agent   - " 42726F6164636F6D20554E444920505845 23 00 7 1 csmcore && set lanbcm=1
exit /b

:yukver
findver "     OROM Mrvl-Yukon Boot Agent - " 59756B6F6E205058450020 12 20 9 2 csmcore && set lanyuk=1
exit /b

:oromguid
if exist _OROM_in_FFS.txt del /f /q _OROM_in_FFS.txt
for /f %%f in ('dir tmp\orom_* /b') do (
echo - %%f
echo - %%f>>_OROM_in_FFS.txt
for /f "tokens=*" %%a in ('findver "     " 496E74656C2852292052617069642053746F7261676520546563686E6F6C6F677920 00 0A 80 2 tmp\%%f') do (
	echo      %%a && 	echo      %%a>>_OROM_in_FFS.txt
)
for /f "tokens=*" %%a in ('findver "     " 496E74656C28522920426F6F74204167656E7420 00 00 72 2 tmp\%%f') do (
	echo      %%a && 	echo      %%a>>_OROM_in_FFS.txt
)
for /f "tokens=*" %%a in ('findver "     " 496E74656C2852292069534353492052656D6F746520426F6F742076657273696F6E 00 0D 45 2 tmp\%%f') do (
	echo      %%a && 	echo      %%a>>_OROM_in_FFS.txt
)
for /f "tokens=*" %%a in ('findver "     " 5265616C74656B2050434965204742452046616D696C79 00 0D 60 2 tmp\%%f') do (
	echo      %%a && 	echo      %%a>>_OROM_in_FFS.txt
)
for /f "tokens=*" %%a in ('findver "     " 504349452045746865726E657420436F6E74726F6C6C6572 -8 0D 60 2 tmp\%%f') do (
	echo      %%a && 	echo      %%a>>_OROM_in_FFS.txt
)
for /f "tokens=*" %%a in ('findver "" 4252434D204D424100536C6F742030303030 20 00 7 2 tmp\%%f') do (
	echo      Broadcom Ethernet Boot Agent %%a && echo      Broadcom Ethernet Boot Agent %%a>>_OROM_in_FFS.txt
)
for /f "tokens=*" %%a in ('findver "" 4D617276656C6C203838534539 00 00 39 1 tmp\%%f') do (
	for /f %%b in ('findver "" 4D617276656C6C203838534539 41 00 10 1 tmp\%%f') do (
	echo      %%a %%b &&	echo      %%a %%b>>_OROM_in_FFS.txt
)))
exit /b

:rs_mmt
if %aa%==4 pause && goto cpu
if exist mmtool_a5.exe (
	cecho {0B}Re-Select MMTool... {#}
	findhex 35002E00300032002E0030003000 mmtool_a5.exe>nul || cecho {0E}MMRool v5.2.0.2x+ not present{#}{\n} && pause && goto cpu
	set mmt=start /b /min /wait mmtool_a5 bios.bin
	if %count_try%==1 cecho {0B}Try again.{#}{\n}{\n} && goto cpus
)
cecho {0E}Unsuccessful. Try other methods.{#}{\n} && pause && goto cpu

:check_mmt
if exist mmtool_a4.exe set mmt=start /b /min /wait mmtool_a4 bios.bin && set mmtool=1 && exit /b 0
rem if %aa%==5 if exist mmtool_a5.exe set mmt=start /b /min /wait mmtool_a5 bios.bin && set mmtool=1 && exit /b 0

if exist mmtool.exe (
	if %aa%==4 if not exist mmtool_a4.exe findhex 35002E00300030002E003000300030003700 mmtool.exe>nul && move /y mmtool.exe mmtool_a4.exe>nul && goto check_mmt
rem	ff %aa%==5 if not exist mmtool_a5.exe findhex 35002E00300032002E0030003000 mmtool.exe>nul && move /y mmtool.exe mmtool_a5.exe>nul && goto check_mmt
)
set mmt=rem 
if %aa%==5 (
	if %amd%==0 if %gmc_count%==1 exit /b 0
	if %amd%==1 exit /b 0
)
if %mmtool%==0 if %aa% neq 0 (
	cecho {\n}{0E}MMTool not present.{#}{\n}
	if %aa%==4 cecho {0E}Replacement of OROM and microcodes will not be available.{#}{\n}
	if %aa%==5 if %amd%==0 cecho {0E}Replacing microcodes will not be available.{#}{\n}
	cecho {0E}Recomended MMTool v5.0.0.7 as mmtool_a4.exe{#} && if %aa%==5 cecho {0E}Recomended MMTool v5.2.0.2x+ as mmtool_a5.exe{#}{\n}
)
rem if %aa%==5 cecho {0E}Recomended MMTool v5.2 as mmtool_a5.exe{#}{\n}
echo;
exit /b 1
#RequireAdmin
#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=4.ico
#AutoIt3Wrapper_Outfile_x64=AdobeReaderUpdater.exe
#AutoIt3Wrapper_Compression=4
#AutoIt3Wrapper_UseUpx=y
#AutoIt3Wrapper_UseX64=y
#AutoIt3Wrapper_Res_Comment=go here to get the URL" https://get.adobe.com/reader/enterprise/
#AutoIt3Wrapper_Res_Description=Clean install Adobe reader
#AutoIt3Wrapper_Res_Fileversion=1.1.1.0
#AutoIt3Wrapper_Res_ProductName=Adobe reader installer
#AutoIt3Wrapper_Res_ProductVersion=1.1.1.0
#AutoIt3Wrapper_Res_CompanyName=Carm0
#AutoIt3Wrapper_Res_LegalCopyright=Carm0
#AutoIt3Wrapper_Res_Language=1033
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
#include <InetConstants.au3>
#include <Inet.au3>
#include <Array.au3>
#include <Debug.au3>
#include <File.au3>
#include <EventLog.au3>
#include <Constants.au3>
TraySetToolTip("Odobe Reader DC updater")
HotKeySet("^!m", "MyExit") ; ctrl+Alt+m kills program ( hotkey )
Opt("TrayMenuMode", 3) ; The default tray menu items will not be shown and items are not checked when selected. These are options 1 and 2 for TrayMenuMode.
Opt("TrayOnEventMode", 1) ; Enable TrayOnEventMode.
TrayCreateItem("About")
TrayItemSetOnEvent(-1, "About")
TrayCreateItem("") ; Create a separator line.
TrayCreateItem("Exit")
TrayItemSetOnEvent(-1, "ExitScript")
TraySetOnEvent($TRAY_EVENT_PRIMARYDOUBLE, "About") ; Display the About MsgBox when the tray icon is double clicked on with the primary mouse button.
TraySetState($TRAY_ICONSTATE_SHOW) ; Show the tray menu.
Local $sSite, $sSite1, $hDownload2, $sdownload, $sfilename, $q, $i = 0, $sversion, $w = 0, $downloadlink, $filename, $sFileinstver

SplashTextOn("Progress", "", 220, 70, -1, -1, 16, "")
Initialize()
getfile()
dlfile()
fileprop()
verifyinstall()
SplashOff()
Exit


Func fileprop()
	Local $sFileVersion = FileGetVersion(@TempDir & "\" & $filename, "ProductName")
	;MsgBox(0, "", @TempDir & "\" & $filename)
	;MsgBox(0, "", $sFileVersion)
	If $sFileVersion = 'Adobe Self Extractor' Then
		clean()
		install()
	Else
		Call('log2')
		Exit ('667')
	EndIf
EndFunc   ;==>fileprop

Func verifyinstall()
	Local $sFileinstalled = FileGetVersion('C:\Program Files (x86)\Adobe\Acrobat Reader DC\Reader\AcroRd32.exe', "ProductName")
	Local $sFileinstver = FileGetVersion('C:\Program Files (x86)\Adobe\Acrobat Reader DC\Reader\AcroRd32.exe', "FileVersion")
	If $sFileinstalled = "Adobe Acrobat Reader DC" Then
		Log4()
		Exit
	Else
		Log5()
		Exit (667)
	EndIf
EndFunc   ;==>verifyinstall



Func Initialize() ; get reader version
	ControlSetText("Progress", "", "Static1", 'Initializing')
	$sSite1 = 'https://get.adobe.com/reader/webservices/adm/?cname=996e.exe&bname=readerdc&site=live&type=install&language=cn'
	; https://www.adobe.com/devnet-docs/acrobatetk/tools/ReleaseNotesDC/index.html  - can also be considered to pull release versions
	$source = _INetGetSource($sSite1)
	$sTxt = StringSplit($source, @LF)
	;_DebugArrayDisplay($sTxt)
	For $i = 1 To UBound($sTxt) - 1
		If StringInStr($sTxt[$i], 'Reader_DC') > 1 Then
			$a = StringSplit($sTxt[$i], '>')
			_DebugArrayDisplay($a)
			$b = StringSplit($a[2], '<')
			;_DebugArrayDisplay($b)
			$sversion = $b[1]
			MsgBox(0, "", $sversion)
			$w = 1
		EndIf
	Next
	If $w = 0 Then
		Log3()
		Exit (404)
	EndIf
EndFunc   ;==>Initialize

Func alt_Initialize()
ControlSetText("Progress", "", "Static1", 'Initializing')
	;$sSite1 = 'https://get.adobe.com/reader/webservices/adm/?cname=996e.exe&bname=readerdc&site=live&type=install&language=cn'
	$sSite1  = 'https://www.adobe.com/devnet-docs/acrobatetk/tools/ReleaseNotesDC/index.html'
	; https://www.adobe.com/devnet-docs/acrobatetk/tools/ReleaseNotesDC/index.html  - can also be considered to pull release versions
	; <link rel="next" title="19.008.20080 Optional update, October 22, 2018" href="continuous/dccontinuousoctober2018qfe2.html" />

	$source = _INetGetSource($sSite1)
	$sTxt = StringSplit($source, @LF)
	_DebugArrayDisplay($sTxt)
	For $i = 1 To UBound($sTxt) - 1
		If StringInStr($sTxt[$i], 'href="continuous/') > 1 And StringInStr($sTxt[$i], 'update') > 1 Then
			$a = StringSplit($sTxt[$i], '>')
			_DebugArrayDisplay($a)
			$b = StringSplit($a[2], '<')
			;_DebugArrayDisplay($b)
			$sversion = $b[1]
			MsgBox(0, "", $sversion)
			$w = 1
		EndIf
	Next
	If $w = 0 Then
		Log3()
		Exit (404)
	EndIf

EndFunc   ;==>alt_Initialize



Func getfile() ; download reader based off version
	ControlSetText("Progress", "", "Static1", 'Getting download information')
	;http://prodesigntools.com/ardownload/pub/adobe/reader/win/AcrobatDC/1502320053/AcroRdrDC15 02320053_en_US.exe
	;http://prodesigntools.com/ardownload/pub/adobe/reader/win/AcrobatDC/1900820071/AcroRdrDC1900820071_en_US.exe
	;$sSite2 = 'https://get.adobe.com/reader/completion/?installer=' & $sversion & '&stype=7690&direct=true&standalone=1'
	; https://forums.adobe.com/thread/1174806
	$re = StringSplit($sversion, '_')
	$rf = StringSplit($re[3], '.')
	$rg = StringRight($rf[1], 2)
	$rh = $rg & $rf[2] & $rf[3]
	If StringIsDigit($rh) = False Then
		Log3()
		Exit (404)
	EndIf
	$filename = 'AcroRdrDC' & $rh & '_en_US.exe'
	$downloadlink = 'http://prodesigntools.com/ardownload/pub/adobe/reader/win/AcrobatDC/' & $rh & '/' & $filename
	SplashOff()
EndFunc   ;==>getfile

Func clean()
	SplashTextOn("Progress", "", 220, 70, -1, -1, 16, "")
	ControlSetText("Progress", "", "Static1", 'Placing Cleanup Files')
	;$sSite = "https://get.adobe.com/reader/completion/?installer=Reader_DC_2018.011.20058_English_for_Windows&stype=7687&direct=true&standalone=1"; https://get.adobe.com/reader/enterprise/
	FileInstall('cleaner.rar', @TempDir & "\cleaner.rar")
	FileInstall('C:\Program Files (x86)\unrar\UnRAR.exe', @TempDir & "\Unrar.exe", 1)
	Sleep(500)
	ShellExecuteWait('UnRAR.exe', ' X -o+ cleaner.rar', @TempDir, "", @SW_HIDE)
	FileDelete(@TempDir & "\Unrar.exe")
	FileDelete(@TempDir & "\cleaner.rar")
	ControlSetText("Progress", "", "Static1", 'Running AdobeAcroCleaner')
	ShellExecuteWait('AdobeAcroCleaner_DC2015.exe', ' /silent /product=1', @TempDir, "", @SW_HIDE)
	FileDelete(@TempDir & "\AdobeAcroCleaner_DC2015.exe")
	;_ArrayDisplay($sTxt)
EndFunc   ;==>clean


Func dlfile()
	_webDownloader($downloadlink, $filename, $filename)
EndFunc   ;==>dlfile

Func install()
	ControlSetText("Progress", "", "Static1", 'Installing Adobe Reader')
	Sleep(1000)
	ShellExecuteWait($filename, ' /sAll /msi /norestart ALLUSERS=1 EULA_ACCEPT=YES', @TempDir) ; https://forums.adobe.com/thread/754256
	Sleep(1000)
	FileDelete(@TempDir & "\" & $filename)
	FileDelete('C:\Users\Public\Desktop\Acrobat Reader DC.lnk')
EndFunc   ;==>install



Func Log2()
	Local $hEventLog, $aData[4] = [0, 6, 6, 7]
	$hEventLog = _EventLog__Open("", "Application")
	_EventLog__Report($hEventLog, 2, 0, 667, @UserName, @UserName & " Unable to Verify Adobe Reader install File downloaded" & @CRLF & 'file downloaded: ' & @TempDir & "\" & $filename, $aData)
	_EventLog__Close($hEventLog)
EndFunc   ;==>Log2

Func Log3()
	Local $hEventLog, $aData[4] = [0, 4, 0, 4]
	$hEventLog = _EventLog__Open("", "Application")
	_EventLog__Report($hEventLog, 2, 0, 404, @UserName, @UserName & " Unable to determine Adobe Reader Version or no download location determined", $aData)
	_EventLog__Close($hEventLog)
EndFunc   ;==>Log3

Func Log4()
	Local $hEventLog, $aData[4] = [0, 4, 1, 1]
	$hEventLog = _EventLog__Open("", "Application")
	_EventLog__Report($hEventLog, 4, 0, 411, @UserName, @UserName & " Adobe Acrobat Reader DC successfully installed " & @CRLF & "Installed Version: " & $sFileinstver, $aData)
	_EventLog__Close($hEventLog)
EndFunc   ;==>Log4

Func Log5()
	Local $hEventLog, $aData[4] = [0, 6, 6, 7]
	$hEventLog = _EventLog__Open("", "Application")
	_EventLog__Report($hEventLog, 2, 0, 667, @UserName, @UserName & " Unable to Verify Adobe Reader Version installed", $aData)
	_EventLog__Close($hEventLog)
EndFunc   ;==>Log5

Func _webDownloader($sSourceURL, $sTargetName, $sVisibleName, $sTargetDir = @TempDir, $bProgressOff = True, $iEndMsgTime = 2000, $sDownloaderTitle = "Odobe Reader")
	; Declare some general vars
	Local $iMBbytes = 1048576

	; If the target directory doesn't exist -> create the dir
	If Not FileExists($sTargetDir) Then DirCreate($sTargetDir)

	; Get download and target info
	Local $sTargetPath = $sTargetDir & "\" & $sTargetName
	Local $iFileSize = InetGetSize($sSourceURL)
	Local $hFileDownload = InetGet($sSourceURL, $sTargetPath, $INET_LOCALCACHE, $INET_DOWNLOADBACKGROUND)

	; Show progress UI
	ProgressOn($sDownloaderTitle, "" & $sVisibleName, "0%", -1, -1, $DLG_MOVEABLE)
	GUISetFont(8, 400)
	; Keep checking until download completed
	Do
		Sleep(250)

		; Set vars
		Local $iDLPercentage = Round(InetGetInfo($hFileDownload, $INET_DOWNLOADREAD) * 100 / $iFileSize, 0)
		Local $iDLBytes = Round(InetGetInfo($hFileDownload, $INET_DOWNLOADREAD) / $iMBbytes, 2)
		Local $iDLTotalBytes = Round($iFileSize / $iMBbytes, 2)

		; Update progress UI
		If IsNumber($iDLBytes) And $iDLBytes >= 0 Then
			ProgressSet($iDLPercentage, $iDLPercentage & "% - Downloaded " & $iDLBytes & " MB of " & $iDLTotalBytes & " MB")
		Else
			ProgressSet(0, "Downloading '" & $sVisibleName & "'")
		EndIf
	Until InetGetInfo($hFileDownload, $INET_DOWNLOADCOMPLETE)

	; If the download was successfull, return the target location
	If InetGetInfo($hFileDownload, $INET_DOWNLOADSUCCESS) Then
		ProgressSet(100, "Downloading '" & $sVisibleName & "' completed")
		If $bProgressOff Then
			Sleep($iEndMsgTime)
			ProgressOff()
		EndIf
		Return $sTargetPath
		; If the download failed, set @error and return False
	Else
		Local $errorCode = InetGetInfo($hFileDownload, $INET_DOWNLOADERROR)
		ProgressSet(0, "Downloading '" & $sVisibleName & "' failed." & @CRLF & "Error code: " & $errorCode)
		If $bProgressOff Then
			Sleep($iEndMsgTime)
			ProgressOff()
		EndIf
		SetError(1, $errorCode, False)
		SplashOff()
	EndIf
EndFunc   ;==>_webDownloader


Func MyExit()
	FileDelete(@TempDir & "\" & $filename)
	;Log5()
	Exit ('666')
EndFunc   ;==>MyExit

Func About()
	; Display a message box about the AutoIt version and installation path of the AutoIt executable.
	MsgBox($MB_SYSTEMMODAL, "", "Acrobat Reader DC updater" & @CRLF & @CRLF & _
			"Version: 1.1.1.0" & @CRLF & _
			"Acrobat Reader DC updater by Carm0@Sourceforge" & @CRLF & "CTRL+ALT+m to kill", 5) ; Find the folder of a full path.
EndFunc   ;==>About

Func ExitScript()
	FileDelete(@TempDir & "\" & $filename)
	;Log5()
	Exit ('666')
EndFunc   ;==>ExitScript

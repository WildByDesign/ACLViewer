; *** Start added Standard Include files by AutoIt3Wrapper ***
#include <GuiToolTip.au3>
#include <ButtonConstants.au3>
#include <ColorConstants.au3>
#include <GuiTreeView.au3>
#include <GuiImageList.au3>
; *** End added Standard Include files by AutoIt3Wrapper ***
#NoTrayIcon
#RequireAdmin

#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#include <HeaderConstants.au3>
#include <ListViewConstants.au3>
#include <StructureConstants.au3>
#include <WinAPISysInternals.au3>
#include <WinAPISysWin.au3>
#include <MsgBoxConstants.au3>
#include <FontConstants.au3>
#include <Array.au3>
#include <AutoItConstants.au3>
#include <Security.au3>
#include <GuiListView.au3>
#include <WinAPIInternals.au3>
#include <EditConstants.au3>
#include <File.au3>
#include <FileConstants.au3>
#include <StringConstants.au3>
#include <Misc.au3>
#include <String.au3>
Global $isDarkMode = False
Global $sRet, $aRet, $newItem, $oldItem, $isFolder, $aUniques, $TV_Icons
#include "include\GUIFrame.au3"
#include "include\GUIDarkMode_v0.02mod.au3"
#include "include\Permissions-Unicode.au3"
#include "include\TreeListExplorer.au3"

;#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=app.ico
#AutoIt3Wrapper_UseX64=y
#AutoIt3Wrapper_Res_Description=ACL Viewer
#AutoIt3Wrapper_res_requestedExecutionLevel=requireAdministrator
#AutoIt3Wrapper_Res_Fileversion=2.0.0
#AutoIt3Wrapper_Res_ProductVersion=2.0.0
#AutoIt3Wrapper_Res_ProductName=ACLViewer
#AutoIt3Wrapper_Outfile_x64=ACLViewer.exe
#AutoIt3Wrapper_OutFile_x86=ACLViewer.exe
#AutoIt3Wrapper_Res_LegalCopyright=@ 2025 WildByDesign
#AutoIt3Wrapper_Res_Language=1033
#AutoIt3Wrapper_Res_HiDpi=P
#AutoIt3Wrapper_Res_Icon_Add=app.ico
#AutoIt3Wrapper_Res_Icon_Add=icons\folder.ico ; @ScriptFullPath, 3
#AutoIt3Wrapper_Res_Icon_Add=icons\harddrive.ico ; @ScriptFullPath, 4
#AutoIt3Wrapper_Res_Icon_Add=icons\file.ico ; @ScriptFullPath, 5
#AutoIt3Wrapper_Res_Icon_Add=icons\removable.ico ; @ScriptFullPath, 6
#AutoIt3Wrapper_Res_Icon_Add=icons\foldersel.ico ; @ScriptFullPath, 7
#AutoIt3Wrapper_Res_Icon_Add=icons\filesel.ico ; @ScriptFullPath, 8
#AutoIt3Wrapper_Res_Icon_Add=icons\harddrivesel.ico ; @ScriptFullPath, 9
;#AutoIt3Wrapper_Res_Icon_Add=AppControl-Disabled.ico ;
;#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****

;Opt('GuiOnEventMode', 1)

If @Compiled = 0 Then
	; System aware DPI awareness
	;DllCall("User32.dll", "bool", "SetProcessDPIAware")
	; Per-monitor V2 DPI awareness
	DllCall("User32.dll", "bool", "SetProcessDpiAwarenessContext" , "HWND", "DPI_AWARENESS_CONTEXT" -4)
EndIf

Global $sRootFolder = StringLeft(@AutoItExe, StringInStr(@AutoItExe, "\", Default, -1))
;ConsoleWrite($sRootFolder & @CRLF)
Global $oOwner, $aAcct, $AccessMaskBits, $sFolder, $expandedItem, $displaySelected, $sDisplayOwner
Global $b00, $b01, $b02, $b03, $b04, $b05, $b06, $b07, $b08, $b09, $b10, $b11, $b12, $b13, $b14, $b15, $b16, $b17, $b18, $b19, $b20, $b21, $b22, $b23, $b24, $b25, $b26, $b27, $b28, $b29, $b30, $b31

$GetDPI = _GetDPI()

; 96 DPI = 100% scaling
; 120 DPI = 125% scaling
; 144 DPI = 150% scaling
; 192 DPI = 200% scaling

If $GetDPI = 96 Then
	$DPIScale = 100
    $TV_Icons = 16
ElseIf $GetDPI = 120 Then
	$DPIScale = 125
    $TV_Icons = 20
ElseIf $GetDPI = 144 Then
	$DPIScale = 150
    $TV_Icons = 24
ElseIf $GetDPI = 168 Then
	$DPIScale = 175
    $TV_Icons = 24
ElseIf $GetDPI = 192 Then
	$DPIScale = 200
    $TV_Icons = 32
ElseIf $GetDPI = 240 Then
	$DPIScale = 250
    $TV_Icons = 40
ElseIf $GetDPI = 288 Then
	$DPIScale = 300
    $TV_Icons = 48
Else
    $TV_Icons = 16
EndIf


Func _GetDPI()
    Local $iDPI, $iDPIRat, $Logpixelsy = 90, $hWnd = 0
    Local $hDC = DllCall("user32.dll", "long", "GetDC", "long", $hWnd)
    Local $aRet = DllCall("gdi32.dll", "long", "GetDeviceCaps", "long", $hDC[0], "long", $Logpixelsy)
    DllCall("user32.dll", "long", "ReleaseDC", "long", $hWnd, "long", $hDC)
    $iDPI = $aRet[0]
    ;; Set a ratio for the GUI dimensions based upon the current DPI value.
    If $iDPI < 145 And $iDPI > 121 Then
        $iDPIRat = $iDPI / 95
    ElseIf $iDPI < 121 And $iDPI > 84 Then
        $iDPIRat = $iDPI / 96
    ElseIf $iDPI < 84 And $iDPI > 0 Then
        $iDPIRat = $iDPI / 105
    ElseIf $iDPI = 0 Then
        $iDPI = 96
        $iDPIRat = 94
    Else
        $iDPIRat = $iDPI / 94
    EndIf
    Return SetError(0, $iDPIRat, $iDPI)
EndFunc

isDarkMode()
Func isDarkMode()
Global $isDarkMode = _WinAPI_ShouldAppsUseDarkMode()
Endfunc

If $isDarkMode = True Then
	Global $iDllGDI = DllOpen("gdi32.dll")
	Global $iDllUSER32 = DllOpen("user32.dll")

	;Three column colours
	Global $aCol[11][2] = [[0xffffff, 0xffffff],[0xffffff, 0xffffff],[0xffffff, 0xffffff],[0xffffff, 0xffffff],[0xffffff, 0xffffff],[0xffffff, 0xffffff],[0xffffff, 0xffffff],[0xffffff, 0xffffff],[0xffffff, 0xffffff],[0xffffff, 0xffffff],[0xffffff, 0xffffff]]

	;Convert RBG to BGR for SetText/BkColor()
	For $i = 0 To UBound($aCol)-1
		$aCol[$i][0] = _BGR2RGB($aCol[$i][0])
		$aCol[$i][1] = _BGR2RGB($aCol[$i][1])
	Next
EndIf

Global $sCascadiaPath = @WindowsDir & "\fonts\CascadiaCode.ttf"
Global $iCascadiaExists = FileExists($sCascadiaPath)

Global Const $sSegUIVar = @WindowsDir & "\fonts\SegUIVar.ttf"
Global $SegUIVarExists = FileExists($sSegUIVar)

If $SegUIVarExists Then
	Global $MainFont = "Segoe UI Variable Display"
	GUISetFont(10.5, $FW_NORMAL, 0, $MainFont)
Else
	Global $MainFont = "Segoe UI"
	GUISetFont(10.5, $FW_NORMAL, 0, $MainFont)
EndIf


_InitiatePermissionResources()

; StartUp of the TreeListExplorer UDF (required)
__TreeListExplorer_StartUp($__TreeListExplorer_Lang_EN, $TV_Icons)
If @error Then ConsoleWrite("__TreeListExplorer_StartUp failed: "&@error&":"&@extended&@crlf)


HotKeySet("{F5}", "RefreshTV")


;Create GUI
;$hGUI_1 = GUICreate("ACL Viewer", @DesktopWidth - 100, @DesktopHeight - 140, -1, -1, BitOR($WS_OVERLAPPEDWINDOW, $WS_MAXIMIZE))
$hGUI_1 = GUICreate("ACL Viewer", @DesktopWidth - 100, @DesktopHeight - 140, -1, -1, $WS_OVERLAPPEDWINDOW)
;$hGUI_1 = GUICreate("ACL Viewer", 800, 600, 100, 100, BitOR($WS_MAXIMIZEBOX, $WS_MAXIMIZE))
;GUISetOnEvent($GUI_EVENT_CLOSE, "SpecialEvents")
$FrameWidth1 = @DesktopWidth / 4
$FrameWidth2 = $FrameWidth1 - 14

;Create Frames
;$iFrame_A = _GUIFrame_Create($hGUI_1, 0, $FrameWidth1, 3)
$iFrame_A = _GUIFrame_Create($hGUI_1, 0, $FrameWidth1)

;Set min sizes for the frames
_GUIFrame_SetMin($iFrame_A, 200, 600)

;Create Explorer Listviews
_GUIFrame_Switch($iFrame_A, 1)
$aWinSize1 = WinGetClientSize(_GUIFrame_GetHandle($iFrame_A, 1))
GUISetFont(10.5,  $FW_NORMAL, 0, $MainFont)

;$cTreeView=GUICtrlCreateTreeView(10,15,$aWinSize1[0] - 10, $aWinSize1[1] - 15)

Global $hTreeViewRight = GUICtrlCreateTreeView(10,15,$aWinSize1[0] - 10, $aWinSize1[1] - 15)

; Create TLE system for the right side
Global $hTLESystemRight = __TreeListExplorer_CreateSystem($hGUI_1, "", Default, "_selectCallback")
If @error Then ConsoleWrite("__TreeListExplorer_CreateSystem failed: "&@error&":"&@extended&@crlf)

; Add Views to TLE system: ShowFolders=True, ShowFiles=True
__TreeListExplorer_AddView($hTLESystemRight, $hTreeViewRight, True, True)
If @error Then ConsoleWrite("__TreeListExplorer_AddView $hTreeView failed: "&@error&":"&@extended&@crlf)


    Func _currentFolder($hSystem, $sRoot, $sFolder, $sSelected)
    EndFunc
    
    Func _selectCallback($hSystem, $sRoot, $sFolder, $sSelected)
        $newItem = $sRoot&$sFolder&$sSelected
        $displaySelected = $sSelected
        treeviewChangesfunc()
    EndFunc
    
    Func _clickCallback($hSystem, $hView, $sRoot, $sFolder, $sSelected, $item)
        ;ConsoleWrite("Click at "&$hView&": "&$sRoot&$sFolder&"["&$sSelected&"] :"&$item&@CRLF)
    EndFunc

    Func _doubleClickCallback($hSystem, $hView, $sRoot, $sFolder, $sSelected, $item)
        ;ConsoleWrite("Double click at "&$hView&": "&$sRoot&$sFolder&"["&$sSelected&"] :"&$item&@CRLF)
    EndFunc
    
    Func _loadingCallback($hSystem, $hView, $sRoot, $sFolder, $sSelected, $sPath, $bLoading)
        If $bLoading Then
            Switch $hView
                Case GUICtrlGetHandle($hTreeViewRight)
                    ;ToolTip("Loading: "&$sRoot&$sFolder)
                    ;GUICtrlSetData($hProgressRight, 50)
            EndSwitch
        Else
            Switch $hView
                Case GUICtrlGetHandle($hTreeViewRight)
                    ;ToolTip("Loading: "&$sRoot&$sFolder)
                    ;GUICtrlSetData($hProgressRight, 0)
            EndSwitch
            ;ToolTip("")
            ;ConsoleWrite("Done: "&$hView&" >> "&$sRoot&$sFolder&@crlf)
        EndIf
    EndFunc



_GUIFrame_Switch($iFrame_A, 2)
$aWinSize2 = WinGetClientSize(_GUIFrame_GetHandle($iFrame_A, 2))
GUISetFont(10.5,  $FW_NORMAL, 0, $MainFont)


;$ownerLabel = GUICtrlCreateLabel(@TAB & "Object Name: " & @CRLF & @TAB & "Owner Name: ", 10, 15, $aWinSize2[0] - 20, -1, $WS_BORDER)
$ownerLabel = GUICtrlCreateLabel(" " & @CRLF & " ", 10, 15, $aWinSize2[0] - 20, -1, $WS_BORDER)
$hownerLabel = GUICtrlGetHandle($ownerLabel)
$aPos = ControlGetPos($hGUI_1, "", $ownerLabel)
;MsgBox($MB_SYSTEMMODAL, "", "Position: " & $aPos[0] & ", " & $aPos[1] & @CRLF & "Size: " & $aPos[2] & ", " & $aPos[3])

$ownerLabelPosV = $aPos[1] + $aPos[3]
$ownerLabelPosV2 = $aPos[1]
$ownerLabelHeight = $aPos[3]
$ownerLabelWidth = $aPos[2]


$ownerLabelName = GUICtrlCreateLabel("Object Name:" & @CRLF & "Owner Name:", 80, $ownerLabelPosV2 + 2, -1)
$hownerLabelName = GUICtrlGetHandle($ownerLabelName)
$aPos = ControlGetPos($hGUI_1, "", $ownerLabelName)
;MsgBox($MB_SYSTEMMODAL, "", "Position: " & $aPos[0] & ", " & $aPos[1] & @CRLF & "Size: " & $aPos[2] & ", " & $aPos[3])

$ownerLabelNamePosV = $aPos[1] + $aPos[3]
$ownerLabelNameHeight = $aPos[3]
$ownerLabelNameWidth = $aPos[2]


$ownerLabelData = GUICtrlCreateLabel(" " & @CRLF & " ", 80 + $ownerLabelNameWidth + 20, $ownerLabelPosV2 + 2, 2000)
$hownerLabelData = GUICtrlGetHandle($ownerLabelData)
$aPos = ControlGetPos($hGUI_1, "", $ownerLabelData)
;MsgBox($MB_SYSTEMMODAL, "", "Position: " & $aPos[0] & ", " & $aPos[1] & @CRLF & "Size: " & $aPos[2] & ", " & $aPos[3])

$ownerLabelDataPosV = $aPos[1] + $aPos[3]
$ownerLabelDataHeight = $aPos[3]
$ownerLabelDataWidth = $aPos[2]


GUISetFont(10.5, $FW_NORMAL, 0, $MainFont)


;$cListView = GUICtrlCreateListView("Type|Principal|Access|Inherited|Applies to|Propagate|ACCESS_MASK", 10, $ownerLabelPosV + 14, $aWinSize2[0] - 20, $aWinSize2[1] / 2.5, $LVS_SINGLESEL)
$cListView = GUICtrlCreateListView("Type|Principal|Access|Inherited|Applies to|Propagate", 10, $ownerLabelPosV + 14, $aWinSize2[0] - 20, $aWinSize2[1] / 2.8, $LVS_SINGLESEL)
$exStyles = BitOR($LVS_EX_FULLROWSELECT, $LVS_EX_DOUBLEBUFFER)
$hListView = GUICtrlGetHandle($cListView)
$aPos = ControlGetPos($hGUI_1, "", $cListView)
;MsgBox($MB_SYSTEMMODAL, "", "Position: " & $aPos[0] & ", " & $aPos[1] & @CRLF & "Size: " & $aPos[2] & ", " & $aPos[3])

$cListViewPosV = $aPos[1] + $aPos[3]
$cListViewHeight = $aPos[3]
$cListViewWidth = $aPos[2]
_GUICtrlListView_SetExtendedListViewStyle($hListView, $exStyles)
;GUICtrlSetResizing(-1, $GUI_DOCKALL)


GUISetFont(8.5, $FW_NORMAL, $GUI_FONTUNDER, $MainFont)


$exportCSVLabel = GUICtrlCreateLabel("Export ListView as CSV", $aWinSize2[1] - 100, $cListViewPosV + 6, -1, -1)
GUICtrlSetColor($exportCSVLabel, 0x1E90FF)
$hexportCSVLabel = GUICtrlGetHandle($exportCSVLabel)
$aPos = ControlGetPos($hGUI_1, "", $exportCSVLabel)
;MsgBox($MB_SYSTEMMODAL, "", "Position: " & $aPos[0] & ", " & $aPos[1] & @CRLF & "Size: " & $aPos[2] & ", " & $aPos[3])

$exportCSVLabelPosV = $aPos[1] + $aPos[3]
$exportCSVLabelPosV2 = $aPos[1]
$exportCSVLabelHeight = $aPos[3]
$exportCSVLabelWidth = $aPos[2]


$verboseACELabel = GUICtrlCreateLabel("Verbose ACE Permissions", $aWinSize2[1] - 100 + $exportCSVLabelWidth + 10, $cListViewPosV + 6, -1, -1)
GUICtrlSetColor($verboseACELabel, 0x1E90FF)
$hverboseACELabel = GUICtrlGetHandle($verboseACELabel)
GUICtrlSetState($verboseACELabel, $GUI_HIDE)


GUISetFont(14, $FW_NORMAL, $GUI_FONTITALIC, $MainFont)

;$OutputText = GUICtrlCreateInput("", 100, $cListViewPosV + 20, 800, @DesktopHeight / 2.2, $ES_MULTILINE + $ES_AUTOVSCROLL, -1)
$OutputText = GUICtrlCreateEdit("", 100, $exportCSVLabelPosV + 4, $aWinSize2[1] / 1.4, $aWinSize2[1] / 2, BitOr($ES_AUTOVSCROLL, $WS_VSCROLL), 0)
;GUICtrlSetResizing(-1, $GUI_DOCKALL)

$selectACE = GUICtrlCreateLabel("Select an ACE", 100, $cListViewPosV + 30)
GUICtrlSetResizing(-1, $GUI_DOCKALL)
;GUICtrlSetState($selectACE, $GUI_HIDE)

GUISetFont(16, $FW_NORMAL, $GUI_FONTNORMAL, $MainFont)
$ErrorAce = GUICtrlCreateLabel("Error", 100, $cListViewPosV + 30, 300)
GUICtrlSetState($ErrorAce, $GUI_HIDE)

GUISetFont(10.5,  $FW_NORMAL, 0, $MainFont)

$hOutputText = GUICtrlGetHandle($OutputText)
GUICtrlSetState($OutputText, $GUI_HIDE)

GUISetFont(10.5,  $FW_NORMAL, 0, $MainFont)
;$AccessInfo = @TAB & 'Type:' & @CRLF & @TAB & 'Principal:' & @CRLF & @TAB & 'Applies to:'
;$AccessInfoLabel = GUICtrlCreateLabel($AccessInfo, 10, $cListViewPosV + 15, $aWinSize2[0] - 20, -1, $WS_BORDER)
$AccessInfo = ' ' & @CRLF & ' ' & @CRLF & ' '
$AccessInfoLabel = GUICtrlCreateLabel($AccessInfo, 10, $exportCSVLabelPosV + 4, $aWinSize2[0] - 20, -1, $WS_BORDER)
;GUICtrlSetResizing(-1, $GUI_DOCKALL)
$aPos = ControlGetPos($hGUI_1, "", $AccessInfoLabel)
;MsgBox($MB_SYSTEMMODAL, "", "Position: " & $aPos[0] & ", " & $aPos[1] & @CRLF & "Size: " & $aPos[2] & ", " & $aPos[3])

$AccessInfoLabelPosV = $aPos[1] + $aPos[3]
$AccessInfoLabelPosV2 = $aPos[1]
$AccessInfoLabelHeight = $aPos[3]
$AccessInfoLabelWidth = $aPos[2]

GUICtrlSetState($AccessInfoLabel, $GUI_HIDE)


$AccessInfoName = GUICtrlCreateLabel('Type:' & @CRLF & 'Principal:' & @CRLF & 'Applies to:', 80, $AccessInfoLabelPosV2 + 2, -1, -1)
;GUICtrlSetResizing(-1, $GUI_DOCKALL)
$aPos = ControlGetPos($hGUI_1, "", $AccessInfoName)
;MsgBox($MB_SYSTEMMODAL, "", "Position: " & $aPos[0] & ", " & $aPos[1] & @CRLF & "Size: " & $aPos[2] & ", " & $aPos[3])

$AccessInfoNamePosV = $aPos[1] + $aPos[3]
$AccessInfoNameHeight = $aPos[3]
$AccessInfoNameWidth = $aPos[2]

GUICtrlSetState($AccessInfoName, $GUI_HIDE)


$AccessInfoData = GUICtrlCreateLabel(' ' & @CRLF & ' ' & @CRLF & ' ', 80 + $ownerLabelNameWidth + 20, $AccessInfoLabelPosV2 + 2, 2000, -1)
;GUICtrlSetResizing(-1, $GUI_DOCKALL)
$aPos = ControlGetPos($hGUI_1, "", $AccessInfoData)
;MsgBox($MB_SYSTEMMODAL, "", "Position: " & $aPos[0] & ", " & $aPos[1] & @CRLF & "Size: " & $aPos[2] & ", " & $aPos[3])

$AccessInfoDataPosV = $aPos[1] + $aPos[3]
$AccessInfoDataHeight = $aPos[3]
$AccessInfoDataWidth = $aPos[2]

GUICtrlSetState($AccessInfoData, $GUI_HIDE)


GUISetFont(10.5,  $FW_NORMAL, 0, $MainFont)

;GUICtrlCreateLabel(" ", 100 - 10, $AccessInfoLabelPosV + 10 - 10, 1200, 800, $WS_BORDER)
;GUICtrlSetResizing(-1, $GUI_DOCKALL)

$ListviewMeasure = GUICtrlCreateCheckbox(" Create Folders / Append Data", 100, $AccessInfoLabelPosV + 80, -1, -1, $WS_BORDER)
GUICtrlSetState($ListviewMeasure, $GUI_HIDE)
$aPos = ControlGetPos($hGUI_1, "", $ListviewMeasure)
;MsgBox($MB_SYSTEMMODAL, "", "Position: " & $aPos[0] & ", " & $aPos[1] & @CRLF & "Size: " & $aPos[2] & ", " & $aPos[3])

$ListviewMeasurePosV = $aPos[1] + $aPos[3]
$ListviewMeasureHeight = $aPos[3]
$ListviewMeasureWidth = $aPos[2]


$ListviewMeasure2 = GUICtrlCreateLabel("1" & @CRLF & "2" & @CRLF & "3" & @CRLF & "4" & @CRLF & "5" & @CRLF & "6" & @CRLF & "7" & @CRLF & @CRLF, 100, $AccessInfoLabelPosV + 80, -1, -1)
GUICtrlSetState($ListviewMeasure2, $GUI_HIDE)
$aPos = ControlGetPos($hGUI_1, "", $ListviewMeasure2)
;MsgBox($MB_SYSTEMMODAL, "", "Position: " & $aPos[0] & ", " & $aPos[1] & @CRLF & "Size: " & $aPos[2] & ", " & $aPos[3])

$ListviewMeasure2PosV = $aPos[1] + $aPos[3]
$ListviewMeasure2Height = $aPos[3]
$ListviewMeasure2Width = $aPos[2]


$BlockLVLabel = GUICtrlCreateLabel(" ", 100 - 10, $AccessInfoLabelPosV + 30 - 2, $ListviewMeasureWidth * 3 + 60 + 120 + 40, $ListviewMeasure2Height + 100)
;GUICtrlSetResizing(-1, $GUI_DOCKALL)

$idListview = GUICtrlCreateListView("col1", 100, $AccessInfoLabelPosV + 30, $ListviewMeasureWidth + 20, $ListviewMeasure2Height, $LVS_NOCOLUMNHEADER, BitOR($LVS_EX_FULLROWSELECT, $LVS_EX_CHECKBOXES, $LVS_EX_DOUBLEBUFFER))
_GUICtrlListView_SetView($idListview, 3)
;GUICtrlSetResizing(-1, $GUI_DOCKALL)
$sFILE_ALL_ACCESS = GUICtrlCreateListViewItem(" Full Control", $idListview)
$sFILE_EXECUTE = GUICtrlCreateListViewItem(" Traverse Folder / Execute File", $idListview)
$sFILE_READ_DATA = GUICtrlCreateListViewItem(" List Folder / Read Data", $idListview)
$sFILE_READ_ATTRIBUTES = GUICtrlCreateListViewItem(" Read Attributes", $idListview)
$sFILE_READ_EA = GUICtrlCreateListViewItem(" Read Extended Attributes", $idListview)
$sFILE_WRITE_DATA = GUICtrlCreateListViewItem(" Create Files / Write Data", $idListview)
$sFILE_APPEND_DATA = GUICtrlCreateListViewItem(" Create Folders / Append Data", $idListview)

$aPos = ControlGetPos($hGUI_1, "", $idListview)
;MsgBox($MB_SYSTEMMODAL, "", "Position: " & $aPos[0] & ", " & $aPos[1] & @CRLF & "Size: " & $aPos[2] & ", " & $aPos[3])

$idListviewPosV = $aPos[1] + $aPos[3]
$idListviewPosH = $aPos[0] + $aPos[2]
$idListviewHeight = $aPos[3]
$idListviewWidth = $aPos[2]

_GUICtrlListView_SetColumnWidth($idListview, 0, $LVSCW_AUTOSIZE_USEHEADER)
GUICtrlSetState($idListview, $GUI_HIDE)


$idListview2 = GUICtrlCreateListView("col1", 100 + $idListviewWidth + 40, $AccessInfoLabelPosV + 30, $ListviewMeasureWidth + 20, $ListviewMeasure2Height, $LVS_NOCOLUMNHEADER, BitOR($LVS_EX_FULLROWSELECT, $LVS_EX_CHECKBOXES, $LVS_EX_DOUBLEBUFFER))
_GUICtrlListView_SetView($idListview2, 3)
;GUICtrlSetResizing(-1, $GUI_DOCKALL)
$sFILE_WRITE_ATTRIBUTES = GUICtrlCreateListViewItem(" Write Attributes", $idListview2)
$sFILE_WRITE_EA = GUICtrlCreateListViewItem(" Write Extended Attributes", $idListview2)
$sFILE_DELETE_CHILD = GUICtrlCreateListViewItem(" Delete Subfolders and Files", $idListview2)
$sFILE_DELETE = GUICtrlCreateListViewItem(" Delete", $idListview2)
$sREAD_CONTROL = GUICtrlCreateListViewItem(" Read Permissions", $idListview2)
$sWRITE_DAC = GUICtrlCreateListViewItem(" Change Permissions", $idListview2)
$sWRITE_OWNER = GUICtrlCreateListViewItem(" Take Ownership", $idListview2)

$aPos = ControlGetPos($hGUI_1, "", $idListview2)
;MsgBox($MB_SYSTEMMODAL, "", "Position: " & $aPos[0] & ", " & $aPos[1] & @CRLF & "Size: " & $aPos[2] & ", " & $aPos[3])

$idListview2PosV = $aPos[1] + $aPos[3]
$idListview2PosH = $aPos[0] + $aPos[2]
$idListview2Height = $aPos[3]
$idListview2Width = $aPos[2]

_GUICtrlListView_SetColumnWidth($idListview2, 0, $LVSCW_AUTOSIZE_USEHEADER)
GUICtrlSetState($idListview2, $GUI_HIDE)


$idListview3 = GUICtrlCreateListView("col1", 100 + $idListviewWidth + 40 + $idListviewWidth + 40, $AccessInfoLabelPosV + 30, $ListviewMeasureWidth + 20, $ListviewMeasure2Height, $LVS_NOCOLUMNHEADER, BitOR($LVS_EX_FULLROWSELECT, $LVS_EX_CHECKBOXES, $LVS_EX_DOUBLEBUFFER))
_GUICtrlListView_SetView($idListview3, 3)
;GUICtrlSetResizing(-1, $GUI_DOCKALL)
$IsPropagated = GUICtrlCreateListViewItem(" Propagate to child objects", $idListview3)

$aPos = ControlGetPos($hGUI_1, "", $idListview3)
;MsgBox($MB_SYSTEMMODAL, "", "Position: " & $aPos[0] & ", " & $aPos[1] & @CRLF & "Size: " & $aPos[2] & ", " & $aPos[3])

$idListview3PosV = $aPos[1] + $aPos[3]
$idListview3PosH = $aPos[0] + $aPos[2]
$idListview3Height = $aPos[3]
$idListview3Width = $aPos[2]

_GUICtrlListView_SetColumnWidth($idListview3, 0, $LVSCW_AUTOSIZE_USEHEADER)
GUICtrlSetState($idListview3, $GUI_HIDE)


; listviews for file ACL only

$idListviewfile = GUICtrlCreateListView("col1", 100, $AccessInfoLabelPosV + 30, $ListviewMeasureWidth + 20, $ListviewMeasure2Height, $LVS_NOCOLUMNHEADER, BitOR($LVS_EX_FULLROWSELECT, $LVS_EX_CHECKBOXES, $LVS_EX_DOUBLEBUFFER))
_GUICtrlListView_SetView($idListviewfile, 3)
;GUICtrlSetResizing(-1, $GUI_DOCKALL)
$sFILE_ALL_ACCESSfile = GUICtrlCreateListViewItem(" Full Control", $idListviewfile)
$sFILE_EXECUTEfile = GUICtrlCreateListViewItem(" Traverse Folder / Execute File", $idListviewfile)
$sFILE_READ_DATAfile = GUICtrlCreateListViewItem(" List Folder / Read Data", $idListviewfile)
$sFILE_READ_ATTRIBUTESfile = GUICtrlCreateListViewItem(" Read Attributes", $idListviewfile)
$sFILE_READ_EAfile = GUICtrlCreateListViewItem(" Read Extended Attributes", $idListviewfile)
$sFILE_WRITE_DATAfile = GUICtrlCreateListViewItem(" Create Files / Write Data", $idListviewfile)
$sFILE_APPEND_DATAfile = GUICtrlCreateListViewItem(" Create Folders / Append Data", $idListviewfile)

$aPos = ControlGetPos($hGUI_1, "", $idListviewfile)
;MsgBox($MB_SYSTEMMODAL, "", "Position: " & $aPos[0] & ", " & $aPos[1] & @CRLF & "Size: " & $aPos[2] & ", " & $aPos[3])

$idListviewfilePosV = $aPos[1] + $aPos[3]
$idListviewfilePosH = $aPos[0] + $aPos[2]
$idListviewfileHeight = $aPos[3]
$idListviewfileWidth = $aPos[2]

_GUICtrlListView_SetColumnWidth($idListviewfile, 0, $LVSCW_AUTOSIZE_USEHEADER)
GUICtrlSetState($idListviewfile, $GUI_HIDE)


$idListviewfile2 = GUICtrlCreateListView("col1", 100 + $idListviewfileWidth + 80, $AccessInfoLabelPosV + 30, $ListviewMeasureWidth + 20, $ListviewMeasure2Height, $LVS_NOCOLUMNHEADER, BitOR($LVS_EX_FULLROWSELECT, $LVS_EX_CHECKBOXES, $LVS_EX_DOUBLEBUFFER))
_GUICtrlListView_SetView($idListviewfile2, 3)
;GUICtrlSetResizing(-1, $GUI_DOCKALL)
$sFILE_WRITE_ATTRIBUTESfile = GUICtrlCreateListViewItem(" Write Attributes", $idListviewfile2)
$sFILE_WRITE_EAfile = GUICtrlCreateListViewItem(" Write Extended Attributes", $idListviewfile2)
;$sFILE_DELETE_CHILD = GUICtrlCreateListViewItem(" Delete Subfolders and Files", $idListviewfile2)
$sFILE_DELETEfile = GUICtrlCreateListViewItem(" Delete", $idListviewfile2)
$sREAD_CONTROLfile = GUICtrlCreateListViewItem(" Read Permissions", $idListviewfile2)
$sWRITE_DACfile = GUICtrlCreateListViewItem(" Change Permissions", $idListviewfile2)
$sWRITE_OWNERfile = GUICtrlCreateListViewItem(" Take Ownership", $idListviewfile2)

_GUICtrlListView_SetColumnWidth($idListviewfile2, 0, $LVSCW_AUTOSIZE_USEHEADER)
GUICtrlSetState($idListviewfile2, $GUI_HIDE)


;GUICtrlCreateTabItem("Raw")

;Register functions for Windows Message IDs needed.
;GUIRegisterMsg($WM_SIZE, "_ExpFrame_WMSIZE_Handler")
;GUIRegisterMsg($WM_NOTIFY, "_ExpFrame_WMNotify_Handler")
;GUIRegisterMsg($WM_COMMAND, '_ExpFrame_WMCOMMAND_Handler')

; Set resizing flag for all created frames
_GUIFrame_ResizeSet(0)

; Register the $WM_SIZE handler to permit resizing
_GUIFrame_ResizeReg()

HeaderFix()

Func HeaderFix()
If $isDarkMode = True Then
;get handle to child SysHeader32 control of ListView
Global $hHeader = HWnd(GUICtrlSendMsg($cListView, $LVM_GETHEADER, 0, 0))
;Turn off theme for header
DllCall("uxtheme.dll", "int", "SetWindowTheme", "hwnd", $hHeader, "wstr", "", "wstr", "")
;subclass ListView to get at NM_CUSTOMDRAW notification sent to ListView
Global $wProcNew = DllCallbackRegister("_LVWndProc", "ptr", "hwnd;uint;wparam;lparam")
Global $wProcOld = _WinAPI_SetWindowLong($hListView, $GWL_WNDPROC, DllCallbackGetPtr($wProcNew))

;Optional: Flat Header - remove header 3D button effect
Global $iStyle = _WinAPI_GetWindowLong($hHeader, $GWL_STYLE)
_WinAPI_SetWindowLong($hHeader, $GWL_STYLE, BitOR($iStyle, $HDS_FLAT))
EndIf
Endfunc

;GuiDarkmodeApply($hGUI_1)

ApplyThemeColor()
Func ApplyThemeColor()

If $isDarkMode = True Then
	GuiDarkmodeApply($hGUI_1)
Else
	Local $bEnableDarkTheme = False
    GuiLightmodeApply($hGUI_1)
EndIf

Endfunc


GUIRegisterMsg($WM_NOTIFY, "WM_NOTIFY2")

GUISetState(@SW_SHOW, $hGUI_1)


ApplyBgColor()
Func ApplyBgColor()

If $isDarkMode = True Then
    GUICtrlSetBkColor($ownerLabel, 0x262626)
    GUICtrlSetBkColor($AccessInfoLabel, 0x262626)
    GUICtrlSetBkColor($AccessInfoName, $GUI_BKCOLOR_TRANSPARENT)
    GUICtrlSetBkColor($AccessInfoData, $GUI_BKCOLOR_TRANSPARENT)
    GUICtrlSetBkColor($ownerLabelName, $GUI_BKCOLOR_TRANSPARENT)
    GUICtrlSetBkColor($ownerLabelData, $GUI_BKCOLOR_TRANSPARENT)
    GUICtrlSetColor($exportCSVLabel, 0x1E90FF)
    GUICtrlSetColor($verboseACELabel, 0x1E90FF)
    ;GUICtrlSetBkColor($idListview, 0x303030)
Else
    GUICtrlSetBkColor($ownerLabel, 0xE5E4E2)
    GUICtrlSetBkColor($AccessInfoLabel, 0xE5E4E2)
    GUICtrlSetBkColor($AccessInfoName, $GUI_BKCOLOR_TRANSPARENT)
    GUICtrlSetBkColor($AccessInfoData, $GUI_BKCOLOR_TRANSPARENT)
    GUICtrlSetBkColor($ownerLabelName, $GUI_BKCOLOR_TRANSPARENT)
    GUICtrlSetBkColor($ownerLabelData, $GUI_BKCOLOR_TRANSPARENT)
    GUICtrlSetColor($exportCSVLabel, 0x1E90FF)
    GUICtrlSetColor($verboseACELabel, 0x1E90FF)
EndIf

Endfunc


$oldItem = ''
;$newItem = 'C:\'
;Sleep(5000)
;CheckFileSystem()

; Set the root directory for all drives
__TreeListExplorer_SetRoot($hTLESystemRight, "")
If @error Then ConsoleWrite("__TreeListExplorer_SetRoot failed: "&@error&":"&@extended&@crlf)
; Select the users' home drive for initial view
__TreeListExplorer_OpenPath($hTLESystemRight, @HomeDrive)
If @error Then ConsoleWrite("__TreeListExplorer_OpenPath failed: "&@error&":"&@extended&@crlf)

$getInitialItem = _GUICtrlTreeView_GetSelection($hTreeViewRight)
$newItem = _GUICtrlTreeView_GetText($hTreeViewRight, $getInitialItem)
$displaySelected = $newItem
CheckFileSystem()


Func SpecialEvents()
    Select
            Case @GUI_CtrlId = $GUI_EVENT_CLOSE
                    ;MsgBox($MB_SYSTEMMODAL, "Close Pressed", "ID=" & @GUI_CtrlId & " WinHandle=" & @GUI_WinHandle)
                    Exit

            ;Case @GUI_CtrlId = $GUI_EVENT_MINIMIZE
            ;        MsgBox($MB_SYSTEMMODAL, "Window Minimized", "ID=" & @GUI_CtrlId & " WinHandle=" & @GUI_WinHandle)

            ;Case @GUI_CtrlId = $GUI_EVENT_RESTORE
            ;        MsgBox($MB_SYSTEMMODAL, "Window Restored", "ID=" & @GUI_CtrlId & " WinHandle=" & @GUI_WinHandle)

    EndSelect
EndFunc   ;==>SpecialEvents

;_TLE_TreeViewOpenPath("C:\",$oExplorer)
;$oldItem = _TLE_getActPath($oExplorer)
;$newItem = _TLE_getActPath($oExplorer)

;MsgBox($MB_SYSTEMMODAL, "test", $newItem)


;TreeviewChanges()
Func TreeviewChanges()
        ; Check for treeview changes every 1 second
		AdlibRegister("treeviewChangesfunc", 120)
EndFunc

Func treeviewChangesfunc()
    ;Sleep(500)
    ;$newItem = _TLE_getActPath($oExplorer)
    If $newItem <> $oldItem Then
        $oldItem = $newItem
        ;do stuff here with $newItem
        ;GetACL()
        ;MsgBox($MB_SYSTEMMODAL, "test", $newItem)
        ;GUICtrlDelete($OutputText)
        ;GUICtrlSetData($OutputText, "")
        GUICtrlSetState($verboseACELabel, $GUI_HIDE)
        GUICtrlSetState($OutputText, $GUI_HIDE)
        GUICtrlSetState($selectACE, $GUI_SHOW)
        GUICtrlSetState($idListview, $GUI_HIDE)
        GUICtrlSetState($idListview2, $GUI_HIDE)
        GUICtrlSetState($idListviewfile, $GUI_HIDE)
        GUICtrlSetState($idListviewfile2, $GUI_HIDE)
        GUICtrlSetState($idListview3, $GUI_HIDE)
        GUICtrlSetState($AccessInfoLabel, $GUI_HIDE)
        GUICtrlSetState($AccessInfoName, $GUI_HIDE)
        GUICtrlSetState($AccessInfoData, $GUI_HIDE)
        CheckFileSystem()
        ;GetPermissions()
    endif
EndFunc

Func CheckFileSystem()
    Local $sDrive = "", $sDir = "", $sFileName = "", $sExtension = ""
    Local $aPathSplit = _PathSplit($newItem, $sDrive, $sDir, $sFileName, $sExtension)
    Local $DriveRoot = $sDrive & "\"

    Local $sFileSystem = DriveGetFileSystem($DriveRoot)
    ;MsgBox($MB_SYSTEMMODAL, "test", $sFileSystem)
    If $sFileSystem = 'NTFS' Then
        GetPermissions()
    ElseIf $sFileSystem = 'ReFS' Then
        GetPermissions()
    Else
        GUICtrlSetData($ownerLabel, @TAB & "Object Name:" & @CRLF & @TAB & "Owner Name:")
        _GUICtrlListView_DeleteAllItems($cListView)
        ;MsgBox($MB_SYSTEMMODAL, "", "NULL ACL")
        ;GUICtrlSetState($OutputText, $GUI_SHOW)
        ;GUICtrlSetState($idListview, $GUI_SHOW)
        ;GUICtrlSetState($idListview2, $GUI_SHOW)
        ;If $iCascadiaExists Then
        ;    GUICtrlSetFont($OutputText, 20, $FW_THIN, -1, "Cascadia Code")
        ;Else
        ;    GUICtrlSetFont($OutputText, 20, $FW_NORMAL, -1, "Consolas")
        ;EndIf
        GUICtrlSetData($ErrorAce, "NULL ACL (full access)")
        GUICtrlSetState($ErrorAce, $GUI_SHOW)
        GUICtrlSetState($selectACE, $GUI_HIDE)
        Return
	EndIf
EndFunc

Func GetPermissions()
    _GUICtrlListView_DeleteAllItems($cListView)
    $FileOrFolder = FileGetAttrib ($newItem)
    $isFolder = StringInStr($FileOrFolder, "D")
    ;ConsoleWrite($newItem & ' info: ' & $FileOrFolder & @CRLF)
    ;$getSelectedItem = _GUICtrlTreeView_GetSelection($hTreeViewRight)
    ;$displaySelected = _GUICtrlTreeView_GetText($hTreeViewRight, $getSelectedItem)


    Global $oOwner = _GetObjectOwner($newItem)
    ;If @error Then GUICtrlSetData($ownerLabel, @TAB & "Object Name:" & @TAB & $displaySelected & @CRLF & @TAB & "Owner Name:" & @TAB & 'Error')
    If @error Then GUICtrlSetData($ownerLabelData, $displaySelected & @CRLF & ' ')
    Global $Dacl = _GetObjectDacl($newItem)
    If @error Then
        GUICtrlSetData($ErrorAce, "Error")
        GUICtrlSetState($ErrorAce, $GUI_SHOW)
        GUICtrlSetState($selectACE, $GUI_HIDE)
        _GUICtrlListView_SetColumnWidth($hListView, 0, $LVSCW_AUTOSIZE_USEHEADER)
        _GUICtrlListView_SetColumnWidth($hListView, 1, $LVSCW_AUTOSIZE_USEHEADER)
        _GUICtrlListView_SetColumnWidth($hListView, 2, $LVSCW_AUTOSIZE_USEHEADER)
        _GUICtrlListView_SetColumnWidth($hListView, 3, $LVSCW_AUTOSIZE_USEHEADER)
        _GUICtrlListView_SetColumnWidth($hListView, 4, $LVSCW_AUTOSIZE_USEHEADER)
        Return
    Else
        GUICtrlSetState($ErrorAce, $GUI_HIDE)
        GUICtrlSetState($selectACE, $GUI_SHOW)
    EndIf
    Global $aAcct = _Security__LookupAccountSid($oOwner)
    Global $AceSize = _GetDaclSizeInformation($Dacl)
    If IsArray($aAcct) Then
        $sAcct = ($aAcct[1] <> "" ? $aAcct[1] & "\" : "" ) & $aAcct[0]
        ;GUICtrlSetData($ownerLabel, @TAB & "Object Name:" & @TAB & $displaySelected & @CRLF & @TAB & "Owner Name:" & @TAB & $sAcct)
        GUICtrlSetData($ownerLabelData, $displaySelected & @CRLF & $sAcct)
        $sDisplayOwner = $sAcct
    Else
        ;GUICtrlSetData($ownerLabel, @TAB & "Object Name:" & @TAB & $displaySelected & @CRLF & @TAB & "Owner Name:" & @TAB & $oOwner)
        GUICtrlSetData($ownerLabelData, $displaySelected & @CRLF & $oOwner)
        $sDisplayOwner = $oOwner
    EndIf
    
    Global $aOldArray[0][8]
    
    For $i = 0 To $AceSize[0] -1
        ; put all ACEs in array and get SID
        $aAce = _GetAce($Dacl, $i)
        _ArrayTranspose($aAce)
        _ArrayAdd($aOldArray, $aAce)
        ;$sUser = _SidToStringSid(DllStructGetPtr($aOldArray[$i][0]))
        $GetSidPtr = DllStructGetPtr($aOldArray[$i][0])
        $sUser = _Security__SidToStringSid($GetSidPtr)
        If @error Then
            $aOldArray[$i][0] = 'Error'
        Else
            $aOldArray[$i][0] = $sUser
        EndIf
        ;$sUser = 'test'
        ;$aOldArray[$i][0] = $sUser
        Assign("ACE" & $i, $aAce, 2)

        ; make sure certain SIDs don't make it to lookup
        ;$aOldArray[$i][0] = $sUser
        $sString = StringRight($aOldArray[$i][0], 10)
        $checkSID = StringInStr($aOldArray[$i][0], "S-1-15-3-")
        $knownAC = StringInStr($sString, "S-1-15-2-1")
        $ACact = StringInStr($aOldArray[$i][0], "S-1-15-2-")
        $knownLPAC = StringInStr($sString, "S-1-15-2-2")
        If $knownAC <> 0 Or $knownLPAC <> 0 Then
            $sUser2 = _Security__LookupAccountSid($aOldArray[$i][0])
            $aOldArray[$i][0] = $sUser2[1] & "\" & $sUser2[0] ; Domain\Username
        ElseIf $ACact <> 0 Then
            $aOldArray[$i][0] = $aOldArray[$i][0]
        ElseIf $checkSID <> 0 Then
            $aOldArray[$i][0] = $aOldArray[$i][0]
        Else
            $sUser2 = _Security__LookupAccountSid($aOldArray[$i][0])
            If @error Then
                $aOldArray[$i][0] = $aOldArray[$i][0]
            Else
                $aOldArray[$i][0] = $sUser2[1] & "\" & $sUser2[0] ; Domain\Username
            EndIf
        EndIf
        ; parse access type
        $aOldArray[$i][1] = StringReplace($aOldArray[$i][1], '0', 'Allow ', 0)
        $aOldArray[$i][1] = StringReplace($aOldArray[$i][1], '1', 'Deny ', 0)
        $aOldArray[$i][1] = StringReplace($aOldArray[$i][1], '9', 'Allow ', 0)

        ; Parse SIDs
        $aOldArray[$i][0] = StringReplace($aOldArray[$i][0], 'APPLICATION PACKAGE AUTHORITY\', '')
        $aOldArray[$i][0] = StringReplace($aOldArray[$i][0], '\CREATOR OWNER', 'CREATOR OWNER')
        $aOldArray[$i][0] = StringReplace($aOldArray[$i][0], 'NT SERVICE\', '')
        $aOldArray[$i][0] = StringReplace($aOldArray[$i][0], '\Everyone', 'Everyone')
        $aOldArray[$i][0] = StringReplace($aOldArray[$i][0], 'NT AUTHORITY\', '')
        $aOldArray[$i][0] = StringReplace($aOldArray[$i][0], 'BUILTIN\Administrators', 'Administrators (' & @ComputerName & '\Administrators)')
        $aOldArray[$i][0] = StringReplace($aOldArray[$i][0], 'BUILTIN\Users', 'Users (' & @ComputerName & '\Users)')
        
        ; copy access mask to last column for later parsing
        $aOldArray[$i][5] = $aOldArray[$i][2]

        ; convert access mask to binary
        $aOldArray[$i][5] = _NumberToBinary($aOldArray[$i][5])

        ; get basic permission from access mask
        If $aOldArray[$i][5] = '00000000000111110000000111111111' Then $aOldArray[$i][2] = 'Full Control'
        If $aOldArray[$i][5] = '00010000000000000000000000000000' Then $aOldArray[$i][2] = 'Full Control'
        If $aOldArray[$i][5] = '00010000000111110000000111111111' Then $aOldArray[$i][2] = 'Full Control'
        If $aOldArray[$i][5] = '11110000000000000000000000000000' Then $aOldArray[$i][2] = 'Full Control'
        If $aOldArray[$i][5] = '10100000000000000000000000000000' Then $aOldArray[$i][2] = 'Read & Execute'
        If $aOldArray[$i][5] = '00000000000100100000000010101001' Then $aOldArray[$i][2] = 'Read & Execute'
        If $aOldArray[$i][5] = '00000000000100110000000110111111' Then $aOldArray[$i][2] = 'Modify'
        If $aOldArray[$i][5] = '11100000000000010000000000000000' Then $aOldArray[$i][2] = 'Modify'
        If $aOldArray[$i][5] = '00000000000000000000000100010110' Then $aOldArray[$i][2] = 'Write'
        If $aOldArray[$i][5] = '00000000000100100000000010001001' Then $aOldArray[$i][2] = 'Read'
        If $aOldArray[$i][5] = '10000000000000000000000000000000' Then $aOldArray[$i][2] = 'Read'
        If $aOldArray[$i][5] = '10000000000100100000000010001001' Then $aOldArray[$i][2] = 'Read'
        If $aOldArray[$i][5] = '00000000000000010000000000000000' Then $aOldArray[$i][2] = 'Delete'
        If $aOldArray[$i][5] = '00000000000000000000000000000001' Then $aOldArray[$i][2] = 'List folder contents'
        If $aOldArray[$i][5] = '00000000000100100000000110111111' Then $aOldArray[$i][2] = 'Read, write & execute'
        If $aOldArray[$i][5] = '11100000000000000000000000000000' Then $aOldArray[$i][2] = 'Read, write & execute'
        If $aOldArray[$i][5] = '00000000000000000000000000100000' Then $aOldArray[$i][2] = 'Traverse folder / execute file'
        If $aOldArray[$i][5] = '00000000000100100000000010100000' Then $aOldArray[$i][2] = 'Traverse / execute'

        If $aOldArray[$i][5] = '00000000000100000000000000100001' Then $aOldArray[$i][2] = 'Special'
        If $aOldArray[$i][5] = '00000000000100100000000010101111' Then $aOldArray[$i][2] = 'Special'
        If $aOldArray[$i][5] = '00000000000100100000000110101101' Then $aOldArray[$i][2] = 'Special'
        If $aOldArray[$i][5] = '00000000000100000000000010100001' Then $aOldArray[$i][2] = 'Special'
        If $aOldArray[$i][5] = '00000000000100000000000000100000' Then $aOldArray[$i][2] = 'Special'
        If $aOldArray[$i][5] = '00000000000100110000000111111111' Then $aOldArray[$i][2] = 'Special'
        If $aOldArray[$i][5] = '00000000000000010000000001000000' Then $aOldArray[$i][2] = 'Special'
        If $aOldArray[$i][5] = '00000000000100100000000010101011' Then $aOldArray[$i][2] = 'Special'
        If $aOldArray[$i][5] = '00000000000100000000000000100110' Then $aOldArray[$i][2] = 'Special'
        If $aOldArray[$i][5] = '00000000000100100000000110011111' Then $aOldArray[$i][2] = 'Special'
        If $aOldArray[$i][5] = '11000000000000000000000000000000' Then $aOldArray[$i][2] = 'Special'
        If $aOldArray[$i][5] = '00000000000100110000000110011111' Then $aOldArray[$i][2] = 'Special'
        If $aOldArray[$i][5] = '11000000000000010000000000000000' Then $aOldArray[$i][2] = 'Special'
        If $aOldArray[$i][5] = '00000000000100100000000000100000' Then $aOldArray[$i][2] = 'Special'
        If $aOldArray[$i][5] = '00000000000100100000000100010110' Then $aOldArray[$i][2] = 'Special'
        If $aOldArray[$i][5] = '00000000000111110000000110011111' Then $aOldArray[$i][2] = 'Special'
;#cs
        ; parse inheritance flags
        If $aOldArray[$i][3] = '10' Then $aOldArray[$i][6] = 'True'
        If $aOldArray[$i][3] = '10' Then $aOldArray[$i][3] = 'This folder and subfolders'
        If $aOldArray[$i][3] = '11' Then $aOldArray[$i][6] = 'True'
        If $aOldArray[$i][3] = '11' Then $aOldArray[$i][3] = 'This folder, subfolders and files'
        If $aOldArray[$i][3] = '19' Then
            $aOldArray[$i][3] = 'This folder, subfolders and files'
            $aOldArray[$i][4] = 'True'
            $aOldArray[$i][6] = 'True'
        EndIf
        If $aOldArray[$i][3] = '18' Then
            $aOldArray[$i][3] = 'This folder and subfolders'
            $aOldArray[$i][4] = 'True'
            $aOldArray[$i][6] = 'True'
        EndIf
        If $aOldArray[$i][3] = '25' Then
            $aOldArray[$i][3] = 'This folder and files'
            $aOldArray[$i][4] = 'True'
            $aOldArray[$i][6] = 'True'
        EndIf
        If $aOldArray[$i][3] = '26' Then
            $aOldArray[$i][3] = 'This folder and subfolders'
            $aOldArray[$i][4] = 'True'
            $aOldArray[$i][6] = 'True'
        EndIf
        If $aOldArray[$i][3] = '16' Then
            $aOldArray[$i][3] = 'This folder only'
            $aOldArray[$i][4] = 'True'
        EndIf
        If $aOldArray[$i][3] = '27' Then
            $aOldArray[$i][3] = 'This folder, subfolders and files'
            $aOldArray[$i][4] = 'True'
            $aOldArray[$i][6] = 'True'
        EndIf
        If $aOldArray[$i][3] = '9' Then
            $aOldArray[$i][3] = 'Files only'
            $aOldArray[$i][6] = 'True'
        EndIf
        If $aOldArray[$i][3] = '0' Then $aOldArray[$i][3] = 'This folder only'
        If $aOldArray[$i][3] = '4' Then $aOldArray[$i][6] = 'True'
        If $aOldArray[$i][3] = '4' Then $aOldArray[$i][3] = ' '
        If $aOldArray[$i][3] = '3' Then $aOldArray[$i][6] = 'True'
        If $aOldArray[$i][3] = '3' Then $aOldArray[$i][3] = 'This folder, subfolders and files'
        If $aOldArray[$i][3] = '2' Then $aOldArray[$i][6] = 'True'
        If $aOldArray[$i][3] = '2' Then $aOldArray[$i][3] = 'This folder and subfolders'
        If $aOldArray[$i][3] = '1' Then $aOldArray[$i][6] = 'True'
        If $aOldArray[$i][3] = '1' Then $aOldArray[$i][3] = 'This folder and files'
;#ce        

    Next
    
    ;_ArrayDisplay($aOldArray, "ACE")
    _ArraySwap($aOldArray, 0, 1, True)
    _ArraySwap($aOldArray, 3, 4, True)
    _ArraySwap($aOldArray, 5, 6, True)


    ;Reverse array before unique removal
    $aOldArray = _Reverse2DArray($aOldArray)

    ;_ArrayDisplay($aOldArray, "test")
    ; Combine ACEs with equal values
	$aUniques = _ArrayUnique2D_Ex($aOldArray, "0,1,2", True)
    ;_ArrayDisplay($aUniques, "test")

    ;Reverse array after unique removal
    $aOldArray = _Reverse2DArray($aUniques)

    _GUICtrlListView_AddArray($hListView,$aOldArray)
    ;_GUICtrlListView_HideColumn($cListView, 6)
    ;If $isFolder = 0 Then _GUICtrlListView_HideColumn($cListView, 4)
    hListViewRefreshColWidth()

EndFunc

Func hListViewRefreshColWidth()
_GUICtrlListView_SetColumnWidth($hListView, 0, $LVSCW_AUTOSIZE)
_GUICtrlListView_SetColumnWidth($hListView, 1, $LVSCW_AUTOSIZE)
_GUICtrlListView_SetColumnWidth($hListView, 2, $LVSCW_AUTOSIZE)
_GUICtrlListView_SetColumnWidth($hListView, 3, $LVSCW_AUTOSIZE_USEHEADER)
If $isFolder = 0 Then
    _GUICtrlListView_HideColumn($cListView, 4)
    _GUICtrlListView_HideColumn($cListView, 5)
Else
    _GUICtrlListView_SetColumnWidth($hListView, 4, $LVSCW_AUTOSIZE)
    _GUICtrlListView_SetColumnWidth($hListView, 5, $LVSCW_AUTOSIZE_USEHEADER)
EndIf
;If $isFolder = 0 Then _GUICtrlListView_SetColumnWidth($hListView, 4, $LVSCW_AUTOSIZE)
;_GUICtrlListView_SetColumnWidth($hListView, 5, $LVSCW_AUTOSIZE_USEHEADER)
;_GUICtrlListView_SetColumnWidth($hListView, 6, $LVSCW_AUTOSIZE_USEHEADER)

GUICtrlSendMsg( $cListView, $WM_CHANGEUISTATE, 65537, 0 )

EndFunc


; CREDIT: weaponx
; LINK: https://www.autoitscript.com/forum/topic/70528-reverse-a-2-dimensional-array/
Func _Reverse2DArray($aArray)
    $rows = Ubound($aArray)
    $columns = Ubound($aArray, 2)
    
    Local $aTemp[$rows][$columns]
    
    For $Y = 0 to $rows-1
        ;ConsoleWrite("Row " & $Y & ": ")
        
        For $X = 0 to $columns-1
            $aTemp[$Y][$X] = $aArray[$rows - $Y - 1][$X]
            
            ;ConsoleWrite("Column " & $X & ": " & $aArray[$Y][$X] & ", ")
        Next
        ;ConsoleWrite(@CRLF)
    Next
    Return $aTemp
EndFunc


; Remove duplicates
; Global $aUniques = _ArrayUnique2D_Ex($aArray1, "1,2,3,4", True)
; _ArrayDisplay($aUniques, "Output array")
;
; CREDIT: Gianni
; LINK: https://www.autoitscript.com/forum/topic/169361-_arrayunique-on-multiple-columns/#findComment-1237749
Func _ArrayUnique2D_Ex(ByRef $aSource, $sColumns = "*", $iReturnAllCols = True)
    ; check wanted columns
    If $sColumns = "*" Then
        Local $aColumns[UBound($aSource, 2)]
        For $i = 0 To UBound($aColumns) - 1
            $aColumns[$i] = $i
        Next
    Else
        Local $aColumns = StringSplit($sColumns, ",", 2) ; NO count in element 0
    EndIf

    ; chain fields to check
    Local $aChainFileds[UBound($aSource, 1)][2]
    For $iRow = 0 To UBound($aSource, 1) - 1
        $aChainFileds[$iRow][1] = 0
        For $iField = 0 To UBound($aColumns) - 1
            $aChainFileds[$iRow][0] &= $aSource[$iRow][$aColumns[$iField]]
        Next
    Next
    ; uniqe from chain
    $aTemp = _ArrayUnique($aChainFileds, 0, 0, 0, 1) ; remove duplicate records (if any)
    If $iReturnAllCols Then
        Local $aUniques[UBound($aTemp)][UBound($aSource, 2)] ; Return all columns
    Else
        Local $aUniques[UBound($aTemp)][UBound($aColumns)] ; Return only checked columns
    EndIf
    $aUniques[0][0] = 0 ; pointer to next free row to fill
    If UBound($aChainFileds) <> $aTemp[0] Then ; there are some duplicate
        Local $aDuplicates[UBound($aChainFileds, 1) - $aTemp[0] + 1][UBound($aSource, 2)] ; will hold only duplicate
        $aDuplicates[0][0] = 0 ; pointer to next free row to fill

        For $iRow = 0 To UBound($aChainFileds, 1) - 1
            If Not $aChainFileds[$iRow][1] Then ; this record still not checked
                $aTemp = _ArrayFindAll($aChainFileds, $aChainFileds[$iRow][0]) ; find duplicates (if any)
                For $i = 0 To UBound($aTemp) - 1
                    $aChainFileds[$aTemp[$i]][1] = UBound($aTemp) ; mark this record as a duplicate
                Next
                $aUniques[0][0] += 1
                If $iReturnAllCols Then
                    For $iField = 0 To UBound($aSource, 2) - 1
                        $aUniques[$aUniques[0][0]][$iField] = $aSource[$aTemp[0]][$iField]
                    Next
                Else
                    For $iField = 0 To UBound($aColumns) - 1
                        $aUniques[$aUniques[0][0]][$iField] = $aSource[$aTemp[0]][$aColumns[$iField]]
                    Next
                EndIf
                If UBound($aTemp) > 1 Then ; there are duplicates of this record
                    For $i = 1 To UBound($aTemp) - 1
                        $aDuplicates[0][0] += 1
                        For $iField = 0 To UBound($aSource, 2) - 1
                            $aDuplicates[$aDuplicates[0][0]][$iField] = $aSource[$aTemp[$i]][$iField]
                        Next
                    Next
                EndIf
            EndIf
        Next
        ; _ArrayDisplay($aUniques, "Those are unique elements")
        ; _ArrayDisplay($aDuplicates, "These are duplicates discarded")
    Else
        ; there are not duplicates in source array
        ; return passed array unchanged
        Return $aSource
    EndIf
    _ArrayDelete($aUniques, 0) ; remove the count row
    Return $aUniques

EndFunc   ;==>_ArrayUnique2D_Ex



; CREDIT: Jos (original function)
; LINK: https://www.autoitscript.com/forum/topic/207058-binary-to-hex/
;
;BinaryToHex($BinIn)
Func BinaryToHex($BinIn)
    $Bits = StringSplit($BinIn, "")
    $dec = 0
    For $x = $Bits[0] To 1 Step -1
        $dec += (2 ^ ($Bits[0] - $x)) * $Bits[$x]
    Next
    $hex = Hex(int($dec))
    ;MsgBox($MB_ICONINFORMATION, "Info", "bin:" & $BinIn & "  Dec:" & $dec & "   Hex:" & $hex & @CRLF)
    ;ConsoleWrite("bin:" & $BinIn & "  Dec:" & $dec & "   Hex:" & $hex & @CRLF)
    Return $dec
EndFunc   ;==>BinaryToHex


; CREDIT: Ascend4nt (original function)
; LINK: https://www.autoitscript.com/forum/topic/90056-decimal-to-binary-number-converter/
;
; CREDIT: Nine (updated function to support unsigned integers)
; LINK: https://www.autoitscript.com/forum/topic/212714-need-help-converting-uint32-to-32-bit-binary/
;
; =================================================================================================
; Func _NumberToBinary($iNumber)
;
; Converts a 32-bit signed # to a binary bit string. (Limitation due to AutoIT functionality)
;   NOTE: range for 32-bit signed values is -2147483648 to 2147483647!
;       Anything outside the range will return an empty string!
;
; $iNumber = # to convert, obviously
;
; Returns:
;   Success: Binary bit string
;   Failure: "" and @error set
;
; Author: Ascend4nt, with help from picaxe (Changing 'If BitAND/Else' to just one line)
;   See it @ http://www.autoitscript.com/forum/index.php?showtopic=90056
; =================================================================================================

Func _NumberToBinary($iNumber)
    Local $sBinString = ""
    ; Maximum 32-bit # range is -2147483648 to 2147483647
    ;If $iNumber<-2147483648 Or $iNumber>2147483647 Then Return SetError(1,0,"")
    If $iNumber<-2147483648 Or $iNumber>2147483647 Then
        Return DllCall("ntdll.dll", "str:cdecl", "_ultoa", "long", $iNumber, "str", "", "int", 2)[0]
    Else

    ; Convert to a 32-bit unsigned integer. We can't work on signed #'s
    $iUnsignedNumber=BitAND($iNumber,0x7FFFFFFF)
    
    ; Cycle through each bit, shifting to the right until 0
    Do
        $sBinString = BitAND($iUnsignedNumber, 1) & $sBinString
        $iUnsignedNumber = BitShift($iUnsignedNumber, 1)
    Until Not $iUnsignedNumber
    
    ; Was it a negative #? Put the sign bit on top, and pad the bits that aren't set
    ;If $iNumber<0 Then Return '1' & StringRight("000000000000000000000000000000" & $sBinString,31)
    
    ;Return $sBinString
	$sBinString=StringRight("000000000000000000000000000000" & $sBinString,31)
	If $iNumber<0 Then Return '1' & $sBinString
	Return '0' & $sBinString
    EndIf
EndFunc   ;==>_NumberToBinary


Func ParseAccessMaskBits()

    $b31 = StringMid($AccessMaskBits, 0 + 1, 1)    ; Bit 31 Generic read (GENERIC_READ)
    $b30 = StringMid($AccessMaskBits, 1 + 1, 1)    ; Bit 30 Generic write (GENERIC_WRITE)
    $b29 = StringMid($AccessMaskBits, 2 + 1, 1)    ; Bit 29 Generic execute (GENERIC_EXECUTE)
    $b28 = StringMid($AccessMaskBits, 3 + 1, 1)    ; Bit 28 Generic all (GENERIC_ALL)
    $b27 = StringMid($AccessMaskBits, 4 + 1, 1)    ; Bit 27 Reserved
    $b26 = StringMid($AccessMaskBits, 5 + 1, 1)    ; Bit 26 Reserved
    $b25 = StringMid($AccessMaskBits, 6 + 1, 1)    ; Bit 25 Maximum allowed (MAXIMUM_ALLOWED)
    $b24 = StringMid($AccessMaskBits, 7 + 1, 1)    ; Bit 24 Access system security (ACCESS_SYSTEM_SECURITY)
    $b23 = StringMid($AccessMaskBits, 8 + 1, 1)    ; Bit 23 Standard rights (?)
    $b22 = StringMid($AccessMaskBits, 9 + 1, 1)    ; Bit 22 Standard rights (?)
    $b21 = StringMid($AccessMaskBits, 10 + 1, 1)   ; Bit 21 Standard rights (?)
    $b20 = StringMid($AccessMaskBits, 11 + 1, 1)   ; Bit 20 Standard rights (SYNCHRONIZE)
    $b19 = StringMid($AccessMaskBits, 12 + 1, 1)   ; Bit 19 Standard rights (WRITE_OWNER)
    $b18 = StringMid($AccessMaskBits, 13 + 1, 1)   ; Bit 18 Standard rights (WRITE_DAC)
    $b17 = StringMid($AccessMaskBits, 14 + 1, 1)   ; Bit 17 Standard rights (READ_CONTROL)
    $b16 = StringMid($AccessMaskBits, 15 + 1, 1)   ; Bit 16 Standard rights (DELETE)
    $b15 = StringMid($AccessMaskBits, 16 + 1, 1)   ; Bit 15 Specific rights (?)
    $b14 = StringMid($AccessMaskBits, 17 + 1, 1)   ; Bit 14 Specific rights (?)
    $b13 = StringMid($AccessMaskBits, 18 + 1, 1)   ; Bit 13 Specific rights (?)
    $b12 = StringMid($AccessMaskBits, 19 + 1, 1)   ; Bit 12 Specific rights (?)
    $b11 = StringMid($AccessMaskBits, 20 + 1, 1)   ; Bit 11 Specific rights (?)
    $b10 = StringMid($AccessMaskBits, 21 + 1, 1)   ; Bit 10 Specific rights (?)
    $b09 = StringMid($AccessMaskBits, 22 + 1, 1)   ; Bit 9  Specific rights (?)
    $b08 = StringMid($AccessMaskBits, 23 + 1, 1)   ; Bit 8  Specific rights (FILE_WRITE_ATTRIBUTES)
    $b07 = StringMid($AccessMaskBits, 24 + 1, 1)   ; Bit 7  Specific rights (FILE_READ_ATTRIBUTES)
    $b06 = StringMid($AccessMaskBits, 25 + 1, 1)   ; Bit 6  Specific rights (FILE_DELETE_CHILD)
    $b05 = StringMid($AccessMaskBits, 26 + 1, 1)   ; Bit 5  Specific rights (FILE_TRAVERSE)
    $b04 = StringMid($AccessMaskBits, 27 + 1, 1)   ; Bit 4  Specific rights (FILE_WRITE_EA)
    $b03 = StringMid($AccessMaskBits, 28 + 1, 1)   ; Bit 3  Specific rights (FILE_READ_EA)
    $b02 = StringMid($AccessMaskBits, 29 + 1, 1)   ; Bit 2  Specific rights (FILE_APPEND_DATA)
    $b01 = StringMid($AccessMaskBits, 30 + 1, 1)   ; Bit 1  Specific rights (FILE_WRITE_DATA)
    $b00 = StringMid($AccessMaskBits, 31 + 1, 1)   ; Bit 0  Specific rights (FILE_READ_DATA)
    
    Global $hBitListItems[32]

    If $b31 = 1 Then $hBitListItems[31] = "GENERIC_READ" & @TAB & @TAB & @TAB & "(0x80000000)"
    If $b30 = 1 Then $hBitListItems[30] = "GENERIC_WRITE" & @TAB & @TAB & @TAB & "(0x40000000)"
    If $b29 = 1 Then $hBitListItems[29] = "GENERIC_EXECUTE" & @TAB & @TAB & @TAB & "(0x20000000)"
    If $b28 = 1 Then $hBitListItems[28] = "GENERIC_ALL" & @TAB & @TAB & @TAB & "(0x10000000)"
    If $b27 = 1 Then $hBitListItems[27] = ""
    If $b26 = 1 Then $hBitListItems[26] = ""
    If $b25 = 1 Then $hBitListItems[25] = "MAXIMUM_ALLOWED" & @TAB & @TAB & @TAB & "(0x2000000)"
    If $b24 = 1 Then $hBitListItems[24] = "ACCESS_SYSTEM_SECURITY" & @TAB & @TAB & @TAB & "(0x1000000)"
    If $b23 = 1 Then $hBitListItems[23] = ""
    If $b22 = 1 Then $hBitListItems[22] = ""
    If $b21 = 1 Then $hBitListItems[21] = ""
    If $b20 = 1 Then $hBitListItems[20] = "SYNCHRONIZE" & @TAB & @TAB & @TAB & "(0x100000)"
    If $b19 = 1 Then $hBitListItems[19] = "WRITE_OWNER" & @TAB & @TAB & @TAB & "(0x80000)"
    If $b18 = 1 Then $hBitListItems[18] = "WRITE_DAC" & @TAB & @TAB & @TAB & "(0x40000)"
    If $b17 = 1 Then $hBitListItems[17] = "READ_CONTROL" & @TAB & @TAB & @TAB & "(0x20000)"
    If $b16 = 1 Then $hBitListItems[16] = "DELETE" & @TAB & @TAB & @TAB & @TAB & "(0x10000)"
    If $b15 = 1 Then $hBitListItems[15] = ""
    If $b14 = 1 Then $hBitListItems[14] = ""
    If $b13 = 1 Then $hBitListItems[13] = ""
    If $b12 = 1 Then $hBitListItems[12] = ""
    If $b11 = 1 Then $hBitListItems[11] = ""
    If $b10 = 1 Then $hBitListItems[10] = ""
    If $b09 = 1 Then $hBitListItems[9] = ""
    If $b08 = 1 Then $hBitListItems[8] = "FILE_WRITE_ATTRIBUTES" & @TAB & @TAB & "(0x100)"
    If $b07 = 1 Then $hBitListItems[7] = "FILE_READ_ATTRIBUTES" & @TAB & @TAB & "(0x80)"
    If $b06 = 1 Then $hBitListItems[6] = "FILE_DELETE_CHILD" & @TAB & @TAB & "(0x40)"
    If $b05 = 1 Then $hBitListItems[5] = "FILE_TRAVERSE" & @TAB & @TAB & @TAB & "(0x20),FILE_EXECUTE" & @TAB & @TAB & @TAB & "(0x20)"
    If $b04 = 1 Then $hBitListItems[4] = "FILE_WRITE_EA" & @TAB & @TAB & @TAB & "(0x10)"
    If $b03 = 1 Then $hBitListItems[3] = "FILE_READ_EA" & @TAB & @TAB & @TAB & "(0x8)"
    If $b02 = 1 Then $hBitListItems[2] = "FILE_APPEND_DATA" & @TAB & @TAB & "(0x4)"
    If $b01 = 1 Then $hBitListItems[1] = "FILE_WRITE_DATA" & @TAB & @TAB & @TAB & "(0x2)"
    If $b00 = 1 Then $hBitListItems[0] = "FILE_READ_DATA" & @TAB & @TAB & @TAB & "(0x1)"

    ; Obtain STANDARD_RIGHTS_READ (0x20000)
    ; Obtain STANDARD_RIGHTS_WRITE (0x20000)
    ; Obtain STANDARD_RIGHTS_EXECUTE (0x20000)
    ; Requires READ_CONTROL
    Local $sSTANDARD_RIGHTS_READ, $sSTANDARD_RIGHTS_WRITE, $sSTANDARD_RIGHTS_EXECUTE
    If $hBitListItems[17] <> "" Then
        $sSTANDARD_RIGHTS_READ = True
        $sSTANDARD_RIGHTS_WRITE = True
        $sSTANDARD_RIGHTS_EXECUTE = True
    EndIf

    ; Obtain STANDARD_RIGHTS_REQUIRED (0xf0000)
    ; Requires DELETE, READ_CONTROL, WRITE_DAC and WRITE_OWNER
    Local $sSTANDARD_RIGHTS_REQUIRED
    If $hBitListItems[16] <> "" And $hBitListItems[17] <> "" And $hBitListItems[18] <> "" And $hBitListItems[19] <> "" Then $sSTANDARD_RIGHTS_REQUIRED = True
    
    ; Obtain STANDARD_RIGHTS_ALL (0x1f0000)
    ; Requires DELETE, READ_CONTROL, WRITE_DAC, WRITE_OWNER and SYNCHRONIZE
    Local $sSTANDARD_RIGHTS_ALL
    If $hBitListItems[16] <> "" And $hBitListItems[17] <> "" And $hBitListItems[18] <> "" And $hBitListItems[19] <> "" And $hBitListItems[20] <> "" Then $sSTANDARD_RIGHTS_ALL = True

    ; Obtain FILE_ALL_ACCESS (0x1f01ff)
    Local $sFILE_ALL_ACCESS
    If $hBitListItems[0] <> "" And $hBitListItems[1] <> "" And $hBitListItems[2] <> "" And $hBitListItems[3] <> ""  And $hBitListItems[4] <> "" And $hBitListItems[5] <> "" And $hBitListItems[6] <> "" And $hBitListItems[7] <> "" And $hBitListItems[8] <> "" And $hBitListItems[16] <> "" And $hBitListItems[17] <> "" And $hBitListItems[18] <> "" And $hBitListItems[19] <> "" And $hBitListItems[20] <> "" Then $sFILE_ALL_ACCESS = True

    ; Obtain FILE_GENERIC_EXECUTE (0x1200a0)
    ; Requires FILE_EXECUTE, FILE_READ_ATTRIBUTES, STANDARD_RIGHTS_EXECUTE (= READ_CONTROL) and SYNCHRONIZE
    Local $sFILE_GENERIC_EXECUTE
    If $hBitListItems[5] <> "" And $hBitListItems[7] <> "" And $hBitListItems[17] <> "" And $hBitListItems[20] <> "" Then $sFILE_GENERIC_EXECUTE = True

    ; Obtain FILE_GENERIC_READ (0x120089)
    ; Requires FILE_READ_ATTRIBUTES, FILE_READ_DATA, FILE_READ_EA, STANDARD_RIGHTS_READ (= READ_CONTROL) and SYNCHRONIZE
    Local $sFILE_GENERIC_READ
    If $hBitListItems[0] <> "" And $hBitListItems[3] <> "" And $hBitListItems[7] <> "" And $hBitListItems[17] <> "" And $hBitListItems[20] <> "" Then $sFILE_GENERIC_READ = True

    ; Obtain FILE_GENERIC_WRITE (0x120116)
    ; Requires FILE_APPEND_DATA, FILE_WRITE_ATTRIBUTES, FILE_WRITE_DATA, FILE_WRITE_EA, STANDARD_RIGHTS_WRITE (= READ_CONTROL) and SYNCHRONIZE
    Local $sFILE_GENERIC_WRITE
    If $hBitListItems[1] <> "" And $hBitListItems[2] <> "" And $hBitListItems[4] <> "" And $hBitListItems[8] <> "" And $hBitListItems[17] <> "" And $hBitListItems[20] <> "" Then $sFILE_GENERIC_WRITE = True


    ; Obtain Specific rights
    Global $aSpecificRights[32]
    For $i = 0 To 15
        $aSpecificRights[$i] = $hBitListItems[$i]
    Next
    ;_ArrayDisplay($aSpecificRights, "test")
    _ArrayReverse($aSpecificRights)
    For $i = UBound($aSpecificRights) - 1 To 0 Step -1
        If $aSpecificRights[$i] = '' Or $aSpecificRights[$i] = '' Then _ArrayDelete($aSpecificRights, $i)
    Next
    $sSpecificRights = _ArrayToString($aSpecificRights, ",")
    $sSpecificRights = StringReplace($sSpecificRights, ",", @CRLF)
    If $sFILE_GENERIC_EXECUTE = True Then $sSpecificRights = _StringInsert($sSpecificRights, "FILE_GENERIC_EXECUTE" & @TAB & @TAB & "(0x1200a0)" & @CRLF, 0)
    If $sFILE_GENERIC_READ = True Then $sSpecificRights = _StringInsert($sSpecificRights, "FILE_GENERIC_READ" & @TAB & @TAB & "(0x120089)" & @CRLF, 0)
    If $sFILE_GENERIC_WRITE = True Then $sSpecificRights = _StringInsert($sSpecificRights, "FILE_GENERIC_WRITE" & @TAB & @TAB & "(0x120116)" & @CRLF, 0)
    If $sFILE_ALL_ACCESS = True Then $sSpecificRights = _StringInsert($sSpecificRights, "FILE_ALL_ACCESS" & @TAB & @TAB & @TAB & "(0x1f01ff)" & @CRLF, 0)

    If $sSpecificRights = "" Then
        $sSpecificRights = ""
    Else
        $sSpecificRights = "Specific Access Rights:" & @CRLF & @CRLF & $sSpecificRights & @CRLF & @CRLF
    EndIf

    ; Obtain Standard rights
    Global $aStandardRights[32]
    For $i = 16 To 25
        $aStandardRights[$i] = $hBitListItems[$i]
    Next
    ;_ArrayDisplay($aStandardRights, "test")
    _ArrayReverse($aStandardRights)
    For $i = UBound($aStandardRights) - 1 To 0 Step -1
        If $aStandardRights[$i] = '' Or $aStandardRights[$i] = '' Then _ArrayDelete($aStandardRights, $i)
    Next
    $sStandardRights = _ArrayToString($aStandardRights, ",")
    $sStandardRights = StringReplace($sStandardRights, ",", @CRLF)
    If $sSTANDARD_RIGHTS_READ = True Then $sStandardRights = _StringInsert($sStandardRights, "STANDARD_RIGHTS_READ" & @TAB & @TAB & "(0x20000)" & @CRLF, 0)
    If $sSTANDARD_RIGHTS_WRITE = True Then $sStandardRights = _StringInsert($sStandardRights, "STANDARD_RIGHTS_WRITE" & @TAB & @TAB & "(0x20000)" & @CRLF, 0)
    If $sSTANDARD_RIGHTS_EXECUTE = True Then $sStandardRights = _StringInsert($sStandardRights, "STANDARD_RIGHTS_EXECUTE" & @TAB & @TAB & "(0x20000)" & @CRLF, 0)
    If $sSTANDARD_RIGHTS_REQUIRED = True Then $sStandardRights = _StringInsert($sStandardRights, "STANDARD_RIGHTS_REQUIRED" & @TAB & "(0xf0000)" & @CRLF, 0)
    If $sSTANDARD_RIGHTS_ALL = True Then $sStandardRights = _StringInsert($sStandardRights, "STANDARD_RIGHTS_ALL" & @TAB & @TAB & "(0x1f0000)" & @CRLF, 0)

    If $sStandardRights = "" Then
        $sStandardRights = ""
    Else
        $sStandardRights = "Standard Access Rights:" & @CRLF & @CRLF & $sStandardRights & @CRLF & @CRLF
    EndIf

    ; Obtain Generic rights
    Global $aGenericRights[32]
    For $i = 28 To 31
        $aGenericRights[$i] = $hBitListItems[$i]
    Next
    ;_ArrayDisplay($aGenericRights, "test")
    _ArrayReverse($aGenericRights)
    For $i = UBound($aGenericRights) - 1 To 0 Step -1
        If $aGenericRights[$i] = '' Or $aGenericRights[$i] = '' Then _ArrayDelete($aGenericRights, $i)
    Next
    $sGenericRights = _ArrayToString($aGenericRights, ",")
    $sGenericRights = StringReplace($sGenericRights, ",", @CRLF)
 

    If $sGenericRights = "" Then
        $sGenericRights = ""
    Else
        $sGenericRights = "Generic Access Rights:" & @CRLF & @CRLF & $sGenericRights & @CRLF & @CRLF
    EndIf


    If $sGenericRights <> "" And $sStandardRights <> "" And $sSpecificRights <> "" Then
        $ReturnRights = $sGenericRights & $sStandardRights & $sSpecificRights
    ElseIf $sGenericRights <> "" And $sStandardRights = "" And $sSpecificRights = "" Then
        $ReturnRights = $sGenericRights
    ElseIf $sGenericRights <> "" And $sStandardRights = "" And $sSpecificRights <> "" Then
        $ReturnRights = $sGenericRights & $sSpecificRights
    ElseIf $sGenericRights = "" And $sStandardRights <> "" And $sSpecificRights <> "" Then
        $ReturnRights = $sStandardRights & $sSpecificRights
    Else
        $ReturnRights = $sGenericRights & $sStandardRights & $sSpecificRights
    EndIf

    $ReturnRights = StringStripWS($ReturnRights, $STR_STRIPLEADING + $STR_STRIPTRAILING)

    Return $ReturnRights
    
EndFunc


Func WM_NOTIFY2($hWnd, $iMsg, $iwParam, $ilParam)
	;_TLE_WM_NOTIFY($hWnd, $iMsg, $iwParam, $ilParam,$oExplorer)
    ;Local $hWnd, $iMsg, $iwParam, $ilParam
    WM_NOTIFY2backgood($hWnd, $iMsg, $iwParam, $ilParam)
    __TreeListExplorer__WinProc($hWnd, $iMsg, $iwParam, $ilParam)
	Return $GUI_RUNDEFMSG
EndFunc   ;==>_WM_NOTIFY

Func WM_NOTIFY2backgood($hWnd, $iMsg, $iwParam, $ilParam)
    ;_TLE_WM_NOTIFY($hWnd, $Msg, $wParam, $lParam,$oExplorer)
    Local $hListView, $tNMHDR, $hWndFrom, $iCode
    
    $hListView = $cListView
    If Not IsHWnd($hListView) Then $hListView = GUICtrlGetHandle($cListView)
    
    $tNMHDR = DllStructCreate($tagNMHDR, $ilParam)
    $hWndFrom = HWnd(DllStructGetData($tNMHDR, "HwndFrom"))
    $iCode = DllStructGetData($tNMHDR, "Code")
    
    Switch $hWndFrom
        Case $hListView
            Switch $iCode
                Case $LVN_ITEMCHANGED
                    Local $tInfo = DllStructCreate($tagNMLISTVIEW, $ilParam)
                    Local $iItem = DllStructGetData($tInfo, "Item")
                    ;ConsoleWrite("tInfo: " & $tInfo & @LF)
                    ;ConsoleWrite("iItem: " & $iItem & @LF)
                    ;If _GUICtrlListView_GetItemChecked($hListView, $iItem) = True Then
                        ;ConsoleWrite("---> Item " & $iItem + 1 & " has checked" & @LF)
                        ;ConsoleWrite("Text: " & _GUICtrlListView_GetItemText($cListView, $iItem, 6) & @LF)
                    ;EndIf
                    GUICtrlSetState($BlockLVLabel, $GUI_SHOW)
                    GUICtrlSetState($verboseACELabel, $GUI_SHOW)
                    GUICtrlSetState($selectACE, $GUI_HIDE)
                    GUICtrlSetState($OutputText, $GUI_HIDE)
                    ;GUICtrlSetState($OutputText, $GUI_SHOW)
                    If $isFolder Then
                        GUICtrlSetState($idListview, $GUI_SHOW)
                        GUICtrlSetState($idListview2, $GUI_SHOW)
                        GUICtrlSetState($idListview3, $GUI_SHOW)
                    Else
                        GUICtrlSetState($idListviewfile, $GUI_SHOW)
                        GUICtrlSetState($idListviewfile2, $GUI_SHOW)
                    EndIf
                    GUICtrlSetState($AccessInfoLabel, $GUI_SHOW)
                    GUICtrlSetState($AccessInfoName, $GUI_SHOW)
                    GUICtrlSetState($AccessInfoData, $GUI_SHOW)
                    ;$accessMask = _GUICtrlListView_GetItemText($cListView, $i, 6)
                    $idType = _GUICtrlListView_GetItemText($cListView, $iItem, 0)
                    $idName = _GUICtrlListView_GetItemText($cListView, $iItem, 1)
                    $idAccess = _GUICtrlListView_GetItemText($cListView, $iItem, 4)
                    If $isFolder Then
                        ;$AccessInfo2 = @TAB & 'Type:' & @TAB & @TAB & $idType & @CRLF & @TAB & 'Principal:' & @TAB & @TAB & $idName & @CRLF & @TAB & 'Applies to: ' & @TAB & $idAccess
                        ;GUICtrlSetData($AccessInfoLabel, $AccessInfo2)
                        $AccessInfo2 = $idType & @CRLF & $idName & @CRLF & $idAccess
                        GUICtrlSetData($AccessInfoData, $AccessInfo2)
                    ;    GUICtrlSetPos($AccessInfoLabel, 10, $cListViewPosV + 30, $aWinSize2[0] - 20, $AccessInfoLabelHeight)
                    Else
                        ;$AccessInfo2 = @TAB & 'Type:' & @TAB & @TAB & $idType & @CRLF & @TAB & 'Principal:' & @TAB & @TAB & $idName & @CRLF & @TAB & 'Applies to:' & @TAB & ' '
                        ;GUICtrlSetData($AccessInfoLabel, $AccessInfo2)
                        $AccessInfo2 = $idType & @CRLF & $idName & @CRLF & ' '
                        GUICtrlSetData($AccessInfoData, $AccessInfo2)
                    ;    $AccessInfoMeasure = $AccessInfoLabelHeight / 3
                    ;    GUICtrlSetPos($AccessInfoLabel, 10, $cListViewPosV + 30, $aWinSize2[0] - 20, $AccessInfoMeasure * 2)
                    EndIf
                    ;GUICtrlSetData($AccessInfoLabel, $AccessInfo2)

                    ;$AccessMaskBits = _GUICtrlListView_GetItemText($cListView, $iItem, 5)
                    $idPropagate = _GUICtrlListView_GetItemText($cListView, $iItem, 5)
                    If $idPropagate = 'True' Then
                        GUICtrlSetState($IsPropagated, $GUI_CHECKED)
                    Else
                        GUICtrlSetState($IsPropagated, $GUI_UNCHECKED)
                    EndIf
                    
                    ; Grab ACCESS_MASK from listview
                    ;$AccessMaskBits = _GUICtrlListView_GetItemText($cListView, $iItem, 6)
                    
                    ; Grab ACCESS_MASK from array
                    $AccessMaskBits = $aOldArray[$iItem][6]
                    $permoutput = ParseAccessMaskBits()
                    
                    ; folder listview acl
                    GUICtrlSetState($sFILE_ALL_ACCESS, $GUI_UNCHECKED)
                    GUICtrlSetState($sFILE_EXECUTE, $GUI_UNCHECKED)
                    GUICtrlSetState($sFILE_READ_DATA, $GUI_UNCHECKED)
                    GUICtrlSetState($sFILE_READ_ATTRIBUTES, $GUI_UNCHECKED)
                    GUICtrlSetState($sFILE_READ_EA, $GUI_UNCHECKED)
                    GUICtrlSetState($sFILE_WRITE_DATA, $GUI_UNCHECKED)
                    GUICtrlSetState($sFILE_APPEND_DATA, $GUI_UNCHECKED)
                    GUICtrlSetState($sFILE_WRITE_ATTRIBUTES, $GUI_UNCHECKED)
                    GUICtrlSetState($sFILE_WRITE_EA, $GUI_UNCHECKED)
                    GUICtrlSetState($sFILE_DELETE_CHILD, $GUI_UNCHECKED)
                    GUICtrlSetState($sFILE_DELETE, $GUI_UNCHECKED)
                    GUICtrlSetState($sREAD_CONTROL, $GUI_UNCHECKED)
                    GUICtrlSetState($sWRITE_DAC, $GUI_UNCHECKED)
                    GUICtrlSetState($sWRITE_OWNER, $GUI_UNCHECKED)
                    If StringInStr($permoutput, "WRITE_OWNER") Then
                        GUICtrlSetState($sWRITE_OWNER, $GUI_CHECKED)
                    Else
                        GUICtrlSetState($sWRITE_OWNER, $GUI_UNCHECKED)
                    EndIf
                    If StringInStr($permoutput, "WRITE_DAC") Then
                        GUICtrlSetState($sWRITE_DAC, $GUI_CHECKED)
                    Else
                        GUICtrlSetState($sWRITE_DAC, $GUI_UNCHECKED)
                    EndIf
                    If StringInStr($permoutput, "READ_CONTROL") Then
                        GUICtrlSetState($sREAD_CONTROL, $GUI_CHECKED)
                    Else
                        GUICtrlSetState($sREAD_CONTROL, $GUI_UNCHECKED)
                    EndIf
                    ;If StringInStr($permoutput, "FILE_DELETE_CHILD") Then
                    If StringInStr($permoutput, "FILE_DELETE_CHILD" & @TAB & @TAB & "(0x40)") Then
                        GUICtrlSetState($sFILE_DELETE_CHILD, $GUI_CHECKED)
                        ;$permoutput = StringReplace($permoutput, "FILE_DELETE_CHILD", "")
                    Else
                        GUICtrlSetState($sFILE_DELETE_CHILD, $GUI_UNCHECKED)
                    EndIf
                    If StringInStr($permoutput, "DELETE" & @TAB & @TAB & @TAB & @TAB & "(0x10000)") Then
                        GUICtrlSetState($sFILE_DELETE, $GUI_CHECKED)
                    Else
                        GUICtrlSetState($sFILE_DELETE, $GUI_UNCHECKED)
                    EndIf
                    If StringInStr($permoutput, "FILE_WRITE_EA") Then
                        GUICtrlSetState($sFILE_WRITE_EA, $GUI_CHECKED)
                    Else
                        GUICtrlSetState($sFILE_WRITE_EA, $GUI_UNCHECKED)
                    EndIf
                    If StringInStr($permoutput, "FILE_WRITE_ATTRIBUTES") Then
                        GUICtrlSetState($sFILE_WRITE_ATTRIBUTES, $GUI_CHECKED)
                    Else
                        GUICtrlSetState($sFILE_WRITE_ATTRIBUTES, $GUI_UNCHECKED)
                    EndIf
                    If StringInStr($permoutput, "FILE_APPEND_DATA") Then
                        GUICtrlSetState($sFILE_APPEND_DATA, $GUI_CHECKED)
                    Else
                        GUICtrlSetState($sFILE_APPEND_DATA, $GUI_UNCHECKED)
                    EndIf
                    If StringInStr($permoutput, "FILE_WRITE_DATA") Then
                        GUICtrlSetState($sFILE_WRITE_DATA, $GUI_CHECKED)
                    Else
                        GUICtrlSetState($sFILE_WRITE_DATA, $GUI_UNCHECKED)
                    EndIf
                    If StringInStr($permoutput, "FILE_READ_EA") Then
                        GUICtrlSetState($sFILE_READ_EA, $GUI_CHECKED)
                    Else
                        GUICtrlSetState($sFILE_READ_EA, $GUI_UNCHECKED)
                    EndIf
                    If StringInStr($permoutput, "FILE_READ_ATTRIBUTES") Then
                        GUICtrlSetState($sFILE_READ_ATTRIBUTES, $GUI_CHECKED)
                    Else
                        GUICtrlSetState($sFILE_READ_ATTRIBUTES, $GUI_UNCHECKED)
                    EndIf
                    If StringInStr($permoutput, "FILE_READ_DATA") Then
                        GUICtrlSetState($sFILE_READ_DATA, $GUI_CHECKED)
                    Else
                        GUICtrlSetState($sFILE_READ_DATA, $GUI_UNCHECKED)
                    EndIf
                    If StringInStr($permoutput, "FILE_EXECUTE") Then
                        GUICtrlSetState($sFILE_EXECUTE, $GUI_CHECKED)
                    Else
                        GUICtrlSetState($sFILE_EXECUTE, $GUI_UNCHECKED)
                    EndIf
                    If StringInStr($permoutput, "FILE_ALL_ACCESS") Then
                        GUICtrlSetState($sFILE_ALL_ACCESS, $GUI_CHECKED)
                    Else
                        GUICtrlSetState($sFILE_ALL_ACCESS, $GUI_UNCHECKED)
                    EndIf
                    If StringInStr($permoutput, "GENERIC_ALL") Then
                        GUICtrlSetState($sFILE_ALL_ACCESS, $GUI_CHECKED)
                        GUICtrlSetState($sFILE_EXECUTE, $GUI_CHECKED)
                        GUICtrlSetState($sFILE_READ_DATA, $GUI_CHECKED)
                        GUICtrlSetState($sFILE_READ_ATTRIBUTES, $GUI_CHECKED)
                        GUICtrlSetState($sFILE_READ_EA, $GUI_CHECKED)
                        GUICtrlSetState($sFILE_WRITE_DATA, $GUI_CHECKED)
                        GUICtrlSetState($sFILE_APPEND_DATA, $GUI_CHECKED)
                        GUICtrlSetState($sFILE_WRITE_ATTRIBUTES, $GUI_CHECKED)
                        GUICtrlSetState($sFILE_WRITE_EA, $GUI_CHECKED)
                        GUICtrlSetState($sFILE_DELETE_CHILD, $GUI_CHECKED)
                        GUICtrlSetState($sFILE_DELETE, $GUI_CHECKED)
                        GUICtrlSetState($sREAD_CONTROL, $GUI_CHECKED)
                        GUICtrlSetState($sWRITE_DAC, $GUI_CHECKED)
                        GUICtrlSetState($sWRITE_OWNER, $GUI_CHECKED)
                    EndIf
                    If StringInStr($permoutput, "GENERIC_READ") Then
                        GUICtrlSetState($sREAD_CONTROL, $GUI_CHECKED)
                        GUICtrlSetState($sFILE_READ_DATA, $GUI_CHECKED)
                        GUICtrlSetState($sFILE_READ_ATTRIBUTES, $GUI_CHECKED)
                        GUICtrlSetState($sFILE_READ_EA, $GUI_CHECKED)
                    EndIf
                    If StringInStr($permoutput, "GENERIC_WRITE") Then
                        GUICtrlSetState($sREAD_CONTROL, $GUI_CHECKED)
                        GUICtrlSetState($sFILE_WRITE_DATA, $GUI_CHECKED)
                        GUICtrlSetState($sFILE_WRITE_ATTRIBUTES, $GUI_CHECKED)
                        GUICtrlSetState($sFILE_WRITE_EA, $GUI_CHECKED)
                        GUICtrlSetState($sFILE_APPEND_DATA, $GUI_CHECKED)
                    EndIf
                    If StringInStr($permoutput, "GENERIC_EXECUTE") Then
                        GUICtrlSetState($sREAD_CONTROL, $GUI_CHECKED)
                        GUICtrlSetState($sFILE_READ_ATTRIBUTES, $GUI_CHECKED)
                        GUICtrlSetState($sFILE_EXECUTE, $GUI_CHECKED)
                    EndIf
                    ; file listview acl
                    GUICtrlSetState($sFILE_ALL_ACCESSfile, $GUI_UNCHECKED)
                    GUICtrlSetState($sFILE_EXECUTEfile, $GUI_UNCHECKED)
                    GUICtrlSetState($sFILE_READ_DATAfile, $GUI_UNCHECKED)
                    GUICtrlSetState($sFILE_READ_ATTRIBUTESfile, $GUI_UNCHECKED)
                    GUICtrlSetState($sFILE_READ_EAfile, $GUI_UNCHECKED)
                    GUICtrlSetState($sFILE_WRITE_DATAfile, $GUI_UNCHECKED)
                    GUICtrlSetState($sFILE_APPEND_DATAfile, $GUI_UNCHECKED)
                    GUICtrlSetState($sFILE_WRITE_ATTRIBUTESfile, $GUI_UNCHECKED)
                    GUICtrlSetState($sFILE_WRITE_EAfile, $GUI_UNCHECKED)
                    ;GUICtrlSetState($sFILE_DELETE_CHILDfile, $GUI_UNCHECKED)
                    GUICtrlSetState($sFILE_DELETEfile, $GUI_UNCHECKED)
                    GUICtrlSetState($sREAD_CONTROLfile, $GUI_UNCHECKED)
                    GUICtrlSetState($sWRITE_DACfile, $GUI_UNCHECKED)
                    GUICtrlSetState($sWRITE_OWNERfile, $GUI_UNCHECKED)
                    If StringInStr($permoutput, "WRITE_OWNER") Then
                        GUICtrlSetState($sWRITE_OWNERfile, $GUI_CHECKED)
                    Else
                        GUICtrlSetState($sWRITE_OWNERfile, $GUI_UNCHECKED)
                    EndIf
                    If StringInStr($permoutput, "WRITE_DAC") Then
                        GUICtrlSetState($sWRITE_DACfile, $GUI_CHECKED)
                    Else
                        GUICtrlSetState($sWRITE_DACfile, $GUI_UNCHECKED)
                    EndIf
                    If StringInStr($permoutput, "READ_CONTROL") Then
                        GUICtrlSetState($sREAD_CONTROLfile, $GUI_CHECKED)
                    Else
                        GUICtrlSetState($sREAD_CONTROLfile, $GUI_UNCHECKED)
                    EndIf
                    ;If StringInStr($permoutput, "FILE_DELETE_CHILD") Then
                    If StringInStr($permoutput, "FILE_DELETE_CHILD" & @TAB & @TAB & "(0x40)") Then
                    ;    GUICtrlSetState($sFILE_DELETE_CHILD, $GUI_CHECKED)
                        ;MsgBox($MB_SYSTEMMODAL, "Title", "We found a match!")
                        ;$permoutput = StringReplace($permoutput, "FILE_DELETE_CHILD", "")
                    ;Else
                    ;    GUICtrlSetState($sFILE_DELETE_CHILD, $GUI_UNCHECKED)
                    EndIf
                    If StringInStr($permoutput, "DELETE" & @TAB & @TAB & @TAB & @TAB & "(0x10000)") Then
                        GUICtrlSetState($sFILE_DELETEfile, $GUI_CHECKED)
                    Else
                        GUICtrlSetState($sFILE_DELETEfile, $GUI_UNCHECKED)
                    EndIf
                    If StringInStr($permoutput, "FILE_WRITE_EA") Then
                        GUICtrlSetState($sFILE_WRITE_EAfile, $GUI_CHECKED)
                    Else
                        GUICtrlSetState($sFILE_WRITE_EAfile, $GUI_UNCHECKED)
                    EndIf
                    If StringInStr($permoutput, "FILE_WRITE_ATTRIBUTES") Then
                        GUICtrlSetState($sFILE_WRITE_ATTRIBUTESfile, $GUI_CHECKED)
                    Else
                        GUICtrlSetState($sFILE_WRITE_ATTRIBUTESfile, $GUI_UNCHECKED)
                    EndIf
                    If StringInStr($permoutput, "FILE_APPEND_DATA") Then
                        GUICtrlSetState($sFILE_APPEND_DATAfile, $GUI_CHECKED)
                    Else
                        GUICtrlSetState($sFILE_APPEND_DATAfile, $GUI_UNCHECKED)
                    EndIf
                    If StringInStr($permoutput, "FILE_WRITE_DATA") Then
                        GUICtrlSetState($sFILE_WRITE_DATAfile, $GUI_CHECKED)
                    Else
                        GUICtrlSetState($sFILE_WRITE_DATAfile, $GUI_UNCHECKED)
                    EndIf
                    If StringInStr($permoutput, "FILE_READ_EA") Then
                        GUICtrlSetState($sFILE_READ_EAfile, $GUI_CHECKED)
                    Else
                        GUICtrlSetState($sFILE_READ_EAfile, $GUI_UNCHECKED)
                    EndIf
                    If StringInStr($permoutput, "FILE_READ_ATTRIBUTES") Then
                        GUICtrlSetState($sFILE_READ_ATTRIBUTESfile, $GUI_CHECKED)
                    Else
                        GUICtrlSetState($sFILE_READ_ATTRIBUTESfile, $GUI_UNCHECKED)
                    EndIf
                    If StringInStr($permoutput, "FILE_READ_DATA") Then
                        GUICtrlSetState($sFILE_READ_DATAfile, $GUI_CHECKED)
                    Else
                        GUICtrlSetState($sFILE_READ_DATAfile, $GUI_UNCHECKED)
                    EndIf
                    If StringInStr($permoutput, "FILE_EXECUTE") Then
                        GUICtrlSetState($sFILE_EXECUTEfile, $GUI_CHECKED)
                    Else
                        GUICtrlSetState($sFILE_EXECUTEfile, $GUI_UNCHECKED)
                    EndIf
                    If StringInStr($permoutput, "FILE_ALL_ACCESS") Then
                        GUICtrlSetState($sFILE_ALL_ACCESSfile, $GUI_CHECKED)
                    Else
                        GUICtrlSetState($sFILE_ALL_ACCESSfile, $GUI_UNCHECKED)
                    EndIf
                    If StringInStr($permoutput, "GENERIC_ALL") Then
                        GUICtrlSetState($sFILE_ALL_ACCESSfile, $GUI_CHECKED)
                        GUICtrlSetState($sFILE_EXECUTEfile, $GUI_CHECKED)
                        GUICtrlSetState($sFILE_READ_DATAfile, $GUI_CHECKED)
                        GUICtrlSetState($sFILE_READ_ATTRIBUTESfile, $GUI_CHECKED)
                        GUICtrlSetState($sFILE_READ_EAfile, $GUI_CHECKED)
                        GUICtrlSetState($sFILE_WRITE_DATAfile, $GUI_CHECKED)
                        GUICtrlSetState($sFILE_APPEND_DATAfile, $GUI_CHECKED)
                        GUICtrlSetState($sFILE_WRITE_ATTRIBUTESfile, $GUI_CHECKED)
                        GUICtrlSetState($sFILE_WRITE_EAfile, $GUI_CHECKED)
                        ;GUICtrlSetState($sFILE_DELETE_CHILD, $GUI_CHECKED)
                        GUICtrlSetState($sFILE_DELETEfile, $GUI_CHECKED)
                        GUICtrlSetState($sREAD_CONTROLfile, $GUI_CHECKED)
                        GUICtrlSetState($sWRITE_DACfile, $GUI_CHECKED)
                        GUICtrlSetState($sWRITE_OWNERfile, $GUI_CHECKED)
                    EndIf
                    If StringInStr($permoutput, "GENERIC_READ") Then
                        GUICtrlSetState($sREAD_CONTROLfile, $GUI_CHECKED)
                        GUICtrlSetState($sFILE_READ_DATAfile, $GUI_CHECKED)
                        GUICtrlSetState($sFILE_READ_ATTRIBUTESfile, $GUI_CHECKED)
                        GUICtrlSetState($sFILE_READ_EAfile, $GUI_CHECKED)
                    EndIf
                    If StringInStr($permoutput, "GENERIC_WRITE") Then
                        GUICtrlSetState($sREAD_CONTROLfile, $GUI_CHECKED)
                        GUICtrlSetState($sFILE_WRITE_DATAfile, $GUI_CHECKED)
                        GUICtrlSetState($sFILE_WRITE_ATTRIBUTESfile, $GUI_CHECKED)
                        GUICtrlSetState($sFILE_WRITE_EAfile, $GUI_CHECKED)
                        GUICtrlSetState($sFILE_APPEND_DATAfile, $GUI_CHECKED)
                    EndIf
                    If StringInStr($permoutput, "GENERIC_EXECUTE") Then
                        GUICtrlSetState($sREAD_CONTROLfile, $GUI_CHECKED)
                        GUICtrlSetState($sFILE_READ_ATTRIBUTESfile, $GUI_CHECKED)
                        GUICtrlSetState($sFILE_EXECUTEfile, $GUI_CHECKED)
                    EndIf

                    If $iCascadiaExists Then
                        GUICtrlSetFont($OutputText, 10, $FW_THIN, 0, "Cascadia Code")
                    Else
                        GUICtrlSetFont($OutputText, 10, $FW_NORMAL, 0, "Consolas")
                    EndIf
                    GUICtrlSetData($OutputText, $permoutput)
                    ;ConsoleWrite($permoutput & @CRLF)
            EndSwitch
    EndSwitch

    Return $GUI_RUNDEFMSG
EndFunc

Func _LVWndProc($hWnd, $iMsg, $wParam, $lParam)
    #forceref $hWnd, $iMsg, $wParam
    If $iMsg = $WM_NOTIFY Then
        Local $tNMHDR, $hWndFrom, $iCode, $iItem, $hDC
        $tNMHDR = DllStructCreate($tagNMHDR, $lParam)
        $hWndFrom = HWnd(DllStructGetData($tNMHDR, "hWndFrom"))
        $iCode = DllStructGetData($tNMHDR, "Code")
        ;Local $IDFrom = DllStructGetData($tNMHDR, "IDFrom")

        Switch $hWndFrom
            Case $hHeader
                Switch $iCode
                    Case $NM_CUSTOMDRAW
                        Local $tCustDraw = DllStructCreate($tagNMLVCUSTOMDRAW, $lParam)
                        Switch DllStructGetData($tCustDraw, "dwDrawStage")
                            Case $CDDS_PREPAINT
                                Return $CDRF_NOTIFYITEMDRAW
                            Case $CDDS_ITEMPREPAINT
                                $hDC = DllStructGetData($tCustDraw, "hDC")
                                $iItem = DllStructGetData($tCustDraw, "dwItemSpec")
                                DllCall($iDllGDI, "int", "SetTextColor", "handle", $hDC, "dword", $aCol[$iItem][0])
                                DllCall($iDllGDI, "int", "SetBkColor", "handle", $hDC, "dword", $aCol[$iItem][1])
                                Return $CDRF_NEWFONT
                                Return $CDRF_SKIPDEFAULT
                        EndSwitch
                EndSwitch
        EndSwitch
    EndIf
    ;pass the unhandled messages to default WindowProc
    Local $aResult = DllCall($iDllUSER32, "lresult", "CallWindowProcW", "ptr", $wProcOld, _
            "hwnd", $hWnd, "uint", $iMsg, "wparam", $wParam, "lparam", $lParam)
    If @error Then Return -1
    Return $aResult[0]
EndFunc   ;==>_LVWndProc

Func _BGR2RGB($iColor)
    ;Author: Wraithdu
    Return BitOR(BitShift(BitAND($iColor, 0x0000FF), -16), BitAND($iColor, 0x00FF00), BitShift(BitAND($iColor, 0xFF0000), 16))
EndFunc   ;==>_BGR2RGB


Func RefreshTV()
    ;__TreeListExplorer_FreeIconCache()
    __TreeListExplorer_Reload($hTLESystemRight, True)
EndFunc


Func ExportToCSV()
    Local Const $sMessage = "Choose a filename."
    Local $aNewArray = $aOldArray
    _ArrayColDelete($aNewArray, 7)
    _ArrayColDelete($aNewArray, 6)
    Local $sFill = "Type:|Principal:|Access:|Inherited:|Applies to:|Propagate:"
    _ArrayInsert($aNewArray, "0")
    _ArrayInsert($aNewArray, "0", $sFill)
    _ArrayInsert($aNewArray, "0")
    Local $sFill2 = "Owner Name:" & "|" & $sDisplayOwner
    _ArrayInsert($aNewArray, "0", $sFill2)
    Local $sFill3 = "Object Name:" & "|" & $newItem
    _ArrayInsert($aNewArray, "0", $sFill3)

    Local $sFileSaveDialog = FileSaveDialog($sMessage, @DesktopDir, "Comma-separated values (*.csv)", $FD_PATHMUSTEXIST + $FD_PROMPTOVERWRITE, "ExportACLView")
	If @error Then
		;MsgBox($MB_SYSTEMMODAL, "", "No file was saved.")
	Else
		Local $sFileName = StringTrimLeft($sFileSaveDialog, StringInStr($sFileSaveDialog, "\", $STR_NOCASESENSEBASIC, -1))

		Local $iExtension = StringInStr($sFileName, ".", $STR_NOCASESENSEBASIC)

		If $iExtension Then
			If Not (StringTrimLeft($sFileName, $iExtension - 1) = ".csv") Then $sFileSaveDialog &= ".csv"
		Else
			$sFileSaveDialog &= ".csv"
		EndIf

		_FileWriteFromArray($sFileSaveDialog, $aNewArray, 0, Default, ";")
		;MsgBox($MB_SYSTEMMODAL, "", "You saved the following file:" & @CRLF & $sFileSaveDialog)
	EndIf
EndFunc


Func HideAllCtrls()
    GUICtrlSetState($selectACE, $GUI_HIDE)
    GUICtrlSetState($AccessInfoLabel, $GUI_HIDE)
    GUICtrlSetState($AccessInfoName, $GUI_HIDE)
    GUICtrlSetState($AccessInfoData, $GUI_HIDE)
    GUICtrlSetState($BlockLVLabel, $GUI_HIDE)
    GUICtrlSetState($idListview, $GUI_HIDE)
    GUICtrlSetState($idListview2, $GUI_HIDE)
    GUICtrlSetState($idListview3, $GUI_HIDE)
    GUICtrlSetState($idListviewfile, $GUI_HIDE)
    GUICtrlSetState($idListviewfile2, $GUI_HIDE)
EndFunc


while True
	Local $iMsg = GUIGetMsg()
	If $iMsg=-3 Then
		__TreeListExplorer_Shutdown()
		Exit
	EndIf
    If $iMsg = $exportCSVLabel Then
        GUICtrlSetColor($exportCSVLabel, 0xFFFFFF)
        Sleep(100)
        GUICtrlSetColor($exportCSVLabel, 0x1E90FF)
        ExportToCSV()
    EndIf
    If $iMsg = $verboseACELabel Then
        GUICtrlSetColor($verboseACELabel, 0xFFFFFF)
        Sleep(100)
        GUICtrlSetColor($verboseACELabel, 0x1E90FF)
        HideAllCtrls()
        GUICtrlSetState($OutputText, $GUI_SHOW)
    EndIf
WEnd

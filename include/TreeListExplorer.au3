#include-once
#include <WinAPISysWin.au3>
#include <WinAPISys.au3>
#include <GuiImageList.au3>
#include <GuiListView.au3>
#include <GuiTreeView.au3>
#include <GuiEdit.au3>
#include <EditConstants.au3>
#include <File.au3>
#include <WindowsConstants.au3>

; #INDEX# =======================================================================================================================
; Title .........: TreeListExplorer
; AutoIt Version : 3.3.16.1
; Language ......: English
; Description ...: UDF to use a Listview or Treeview as a File/Folder Explorer
; Author(s) .....: Kanashius
; Modified by ...: WildByDesign
; Version .......: 2.8.1
; ===============================================================================================================================

; #CURRENT# =====================================================================================================================
; __TreeListExplorer_StartUp
; __TreeListExplorer_Shutdown
; __TreeListExplorer_CreateSystem
; __TreeListExplorer_DeleteSystem
; __TreeListExplorer_AddView
; __TreeListExplorer_RemoveView
; __TreeListExplorer_OpenPath
; __TreeListExplorer_Reload
; __TreeListExplorer_GetPath
; __TreeListExplorer_GetRoot
; __TreeListExplorer_GetSelected
; __TreeListExplorer_SetRoot
; ===============================================================================================================================

; #INTERNAL_USE_ONLY# ===========================================================================================================
; __TreeListExplorer__DeleteSystem
; __TreeListExplorer__OpenPath
; __TreeListExplorer__IsPathOpen
; __TreeListExplorer__GetCurrentPath
; __TreeListExplorer__GetCurrentRoot
; __TreeListExplorer__GetSelected
; __TreeListExplorer__GetSystemIDFromHandle
; __TreeListExplorer__GetHandleFromSystemID
; __TreeListExplorer__UpdateSystemViews
; __TreeListExplorer__UpdateView
; __TreeListExplorer__GetSizeString
; __TreeListExplorer__GetTimeString
; __TreeListExplorer__FileGetIconIndex
; __TreeListExplorer__ExpandTreeitem
; __TreeListExplorer__LoadTreeItemContent
; __TreeListExplorer__RemoveLastFolderFromPath
; __TreeListExplorer__GetDrives
; __TreeListExplorer__UpdateTreeViewSelection
; __TreeListExplorer__TreeViewGetRelPath
; __TreeListExplorer__TreeViewItemIsExpanded
; __TreeListExplorer__IsViewUpdating
; __TreeListExplorer__SetViewUpdating
; __TreeListExplorer__PathIsFolder
; __TreeListExplorer__PathIsFile
; __TreeListExplorer__RelPathIsFolder
; __TreeListExplorer__RelPathIsFile
; __TreeListExplorer__KeyProc
; __TreeListExplorer__WinProc
; __TreeListExplorer__ListViewOpenCurrentItem
; __TreeListExplorer__HandleViewCallback
; __TreeListExplorer__HandleSystemCallback
; __TreeListExplorer__GetPathAndLast
; __TreeListExplorer__ConsoleWriteCallbackError
; ===============================================================================================================================

; #GLOBAL CONSTANTS# ============================================================================================================
Global $__TreeListExplorer_Lang_EN = 0, $__TreeListExplorer_Lang_DE = 1
; ===============================================================================================================================

; #INTERNAL_USE_ONLY GLOBAL CONSTANTS # =========================================================================================
Global $__TreeListExplorer__Type_TreeView = 1, $__TreeListExplorer__Type_ListView = 2, $__TreeListExplorer__Type_Input = 3
Global $__TreeListExplorer__Status_UpdateView = 1, $__TreeListExplorer__Status_ExpandTree = 2
Global $__TreeListExplorer__Status_LoadTree = 4, $__TreeListExplorer__Status_ExpandTree = 8
; ===============================================================================================================================

; #INTERNAL_USE_ONLY GLOBAL VARIABLES # =========================================================================================
Global $__TreeListExplorer__Data[]
; ===============================================================================================================================

; #FUNCTION# ====================================================================================================================
; Name ..........: __TreeListExplorer_StartUp
; Description ...: StartUp of the TLE UDF initializing required variables. Must be called before using other UDF functions.
; Syntax ........: __TreeListExplorer_StartUp([$iLang = $__TreeListExplorer_Lang_EN[, $iIconSize = 16]])
; Parameters ....: $iLang               - [optional] an integer to set the language ($__TreeListExplorer_Lang_EN, $__TreeListExplorer_Lang_DE). Default is $__TreeListExplorer_Lang_EN.
;                  $iIconSize           - [optional] the size for icons in the Tree-/ListView. Default is 16.
; Return values .: True on success.
; Author ........: Kanashius
; Modified ......:
; Remarks .......:
;                 The following languages are currently awailable: $__TreeListExplorer_Lang_EN, $__TreeListExplorer_Lang_DE
;                 To add other languages, add them to the array at the beginning of this function
;                 and create the $__TreeListExplorer_Lang_?? variable.
;
;                 Errors:
;                 1 - $iLang not valid
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func __TreeListExplorer_StartUp($iLang = $__TreeListExplorer_Lang_EN, $iIconSize = 16)
	Local $arLangData = [["Filename", "Size", "Date created"], _
						 ["Dateiname", "Größe", "Erstelldatum"]]

	If $iLang<0 Or $iLang>UBound($arLangData)-1 Then Return SetError(1, 0, False)
	Local $hImageList = _GUIImageList_Create($iIconSize, $iIconSize, 5, 1)
	#cs
		_GUIImageList_AddIcon($hImageList, 'shell32.dll', 3) ; Folder-Icon
		_GUIImageList_AddIcon($hImageList, 'shell32.dll', 110) ; Folder-Icon checked
		_GUIImageList_AddIcon($hImageList, 'shell32.dll', 0) ; File-Icon
		_GUIImageList_AddIcon($hImageList, 'shell32.dll', 5) ; Disc-Icon
		_GUIImageList_AddIcon($hImageList, 'shell32.dll', 7) ; Changeableinput-Icon
		_GUIImageList_AddIcon($hImageList, 'shell32.dll', 8) ; Harddrive-Icon
		_GUIImageList_AddIcon($hImageList, 'shell32.dll', 11) ; CDROM-Icon
		_GUIImageList_AddIcon($hImageList, 'shell32.dll', 12) ; Networkdrive-Icon
		_GUIImageList_AddIcon($hImageList, 'shell32.dll', 53) ; Unknown-Icon
	#ce
	;#cs	
	If $isDarkMode = True Then
		If @Compiled = 0 Then
			_GUIImageList_AddIcon($hImageList, 'shell32.dll', 3) ; Folder-Icon
			;_GUIImageList_AddIcon($hImageList, 'shell32.dll', 110) ; Folder-Icon checked
			_GUIImageList_AddIcon($hImageList, 'shell32.dll', 3) ; Folder-Icon
			_GUIImageList_AddIcon($hImageList, 'shell32.dll', 0) ; File-Icon
			_GUIImageList_AddIcon($hImageList, 'shell32.dll', 5) ; Disc-Icon
			_GUIImageList_AddIcon($hImageList, 'shell32.dll', 7) ; Changeableinput-Icon
			_GUIImageList_AddIcon($hImageList, 'shell32.dll', 8) ; Harddrive-Icon
			_GUIImageList_AddIcon($hImageList, 'shell32.dll', 11) ; CDROM-Icon
			_GUIImageList_AddIcon($hImageList, 'shell32.dll', 12) ; Networkdrive-Icon
			_GUIImageList_AddIcon($hImageList, 'shell32.dll', 53) ; Unknown-Icon
			_GUIImageList_AddIcon($hImageList, 'shell32.dll', 0) ; File-Icon
			_GUIImageList_AddIcon($hImageList, 'shell32.dll', 8) ; Harddrive-Icon
		Else
			_GUIImageList_AddIcon($hImageList, @ScriptFullPath, 3) ; Folder-Icon
			_GUIImageList_AddIcon($hImageList, @ScriptFullPath, 7) ; Folder-Icon checked
			_GUIImageList_AddIcon($hImageList, @ScriptFullPath, 5) ; File-Icon
			_GUIImageList_AddIcon($hImageList, 'shell32.dll', 5) ; Disc-Icon
			_GUIImageList_AddIcon($hImageList, @ScriptFullPath, 6) ; Changeableinput-Icon
			_GUIImageList_AddIcon($hImageList, @ScriptFullPath, 4) ; Harddrive-Icon
			_GUIImageList_AddIcon($hImageList, 'shell32.dll', 11) ; CDROM-Icon
			_GUIImageList_AddIcon($hImageList, 'shell32.dll', 12) ; Networkdrive-Icon
			_GUIImageList_AddIcon($hImageList, 'shell32.dll', 53) ; Unknown-Icon
			_GUIImageList_AddIcon($hImageList, @ScriptFullPath, 8) ; File-Icon checked
			_GUIImageList_AddIcon($hImageList, @ScriptFullPath, 9) ; Harddrive-Icon
		EndIf
	Else
		_GUIImageList_AddIcon($hImageList, 'shell32.dll', 3) ; Folder-Icon
		;_GUIImageList_AddIcon($hImageList, 'shell32.dll', 110) ; Folder-Icon checked
		_GUIImageList_AddIcon($hImageList, 'shell32.dll', 3) ; Folder-Icon
		_GUIImageList_AddIcon($hImageList, 'shell32.dll', 0) ; File-Icon
		_GUIImageList_AddIcon($hImageList, 'shell32.dll', 5) ; Disc-Icon
		_GUIImageList_AddIcon($hImageList, 'shell32.dll', 7) ; Changeableinput-Icon
		_GUIImageList_AddIcon($hImageList, 'shell32.dll', 8) ; Harddrive-Icon
		_GUIImageList_AddIcon($hImageList, 'shell32.dll', 11) ; CDROM-Icon
		_GUIImageList_AddIcon($hImageList, 'shell32.dll', 12) ; Networkdrive-Icon
		_GUIImageList_AddIcon($hImageList, 'shell32.dll', 53) ; Unknown-Icon
		_GUIImageList_AddIcon($hImageList, 'shell32.dll', 0) ; File-Icon
		_GUIImageList_AddIcon($hImageList, 'shell32.dll', 8) ; Harddrive-Icon
	EndIf
	;#ce
	$__TreeListExplorer__Data.hIconList = $hImageList
	$__TreeListExplorer__Data.iIconIndex = _GUIImageList_GetImageCount($hImageList) ; next index, if an icon is added
	Local $mIcons[]
	$__TreeListExplorer__Data.mIcons = $mIcons
	Local $mSystems[]
	$__TreeListExplorer__Data.mSystems = $mSystems
	Local $mViews[]
	$__TreeListExplorer__Data.mViews = $mViews
	$__TreeListExplorer__Data.iLang = $iLang
	Local $mGuis[]
	$__TreeListExplorer__Data.mGuis = $mGuis
	$__TreeListExplorer__Data.hProc = DllCallbackRegister('__TreeListExplorer__WinProc', 'ptr', 'hwnd;uint;wparam;lparam')
	$__TreeListExplorer__Data.hKeyProc = DllCallbackRegister("__TreeListExplorer__KeyProc", "int", "int;ptr;ptr")
	$__TreeListExplorer__Data.hKeyPrevHook = _WinAPI_SetWindowsHookEx($WH_KEYBOARD_LL, DllCallbackGetPtr($__TreeListExplorer__Data.hKeyProc), _WinAPI_GetModuleHandle(0), 0)
	$__TreeListExplorer__Data.arLangData = $arLangData
	Return True
EndFunc

; #FUNCTION# ====================================================================================================================
; Name ..........: __TreeListExplorer_Shutdown
; Description ...: Shutdown of the TLE UDF. Must be called before closing the program. If not called, the program may not exit.
; Syntax ........: __TreeListExplorer_Shutdown()
; Parameters ....:
; Return values .: True on success.
; Author ........: Kanashius
; Modified ......:
; Remarks .......: This includes deleting all TLE systems (__TreeListExplorer_DeleteSystem).
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func __TreeListExplorer_Shutdown()
	Local $arSystems = MapKeys($__TreeListExplorer__Data.mSystems)
	For $i=0 To UBound($arSystems)-1 Step 1
		__TreeListExplorer__DeleteSystem($arSystems[$i])
	Next
	DllCallbackFree($__TreeListExplorer__Data.hProc)
	_WinAPI_UnhookWindowsHookEx($__TreeListExplorer__Data.hKeyPrevHook)
	DllCallbackFree($__TreeListExplorer__Data.hKeyProc)
	_GUIImageList_Destroy($__TreeListExplorer__Data.hIconList)
	Local $mMap[]
	$__TreeListExplorer__Data = $mMap
	Return True
EndFunc

; #FUNCTION# ====================================================================================================================
; Name ..........: __TreeListExplorer_CreateSystem
; Description ...: Create a new TLE System. This is used to manage the views by settings the root folder, the current folder,...
;                  Multiple views (TreeView/ListView) can be added, all managed by this system.
; Syntax ........: __TreeListExplorer_CreateSystem($hGui[, $sRootFolder = ""[, $sCallbackFolder = Default[, $sCallbackSelect = Default
;                  [, $iLineNumber = @ScriptLineNumber]]]])
; Parameters ....: $hGui                - the window handle for all views used by this system.
;                  $sRootFolder         - [optional] the root folder as string. Default is "", making the drive overview the root
;                  $sCallbackFolder     - [optional] callback function as string. Using Default will not call any function.
;                  $sCallbackSelect     - [optional] callback function as string. Using Default will not call any function.
;                  $iLineNumber         - [optional] linenumber of the function call. Default is @ScriptLineNumber.
;                                         (Automatic, no need to change; only used for error messages)
; Return values .: The system handle $hSystem, used by the other functions
; Author ........: Kanashius
; Modified ......:
; Remarks .......: When $sRootFolder = "", there is no root directory, enabling all drives to be accessed. Otherwise the User can
;                  only select child folders of the root folder.
;                  The $sCallbackFolder calls the provided function, which must have 4 parameters ($hSystem, $sRoot, $sFolder, $sSelected) and
;                  is called, when the root folder or the current folder changes. If the parameter number is wrong an error
;                  message will be written to the console at runtime (using $iLineNumber to find it better).
;                  $sCallbackSelect must be a function with 4 parameters ($hSystem, $sRoot, $sFolder, $sSelected)
;                  and is called, when an item in the Tree-/ListView is selected (Mouse/Keyboard)
;
;                  Errors:
;                  1 - Parameter is invalid (@extended 1 - $hGui, 3 - $sCallbackFolder, 4 - $sCallbackSelect, 5 - $iLineNumber)
;                  2 - Setting WinProc for $hGui failed
;                  3 - TLE system could not be added to map
;                  4 - TLE system ID could not be converted to TLE system handle
;                  5 - $sRootFolder is invalid and could not be set (try __TreeListExplorer_SetRoot for details)
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func __TreeListExplorer_CreateSystem($hGui, $sRootFolder = "", $sCallbackFolder = Default, $sCallbackSelect = Default, $iLineNumber = @ScriptLineNumber)
	If Not IsHWnd($hGui) Then Return SetError(1, 1, -1)
	If $sCallbackFolder <> Default And Not IsFunc(Execute($sCallbackFolder)) Then Return SetError(1, 3, -1)
	If $sCallbackSelect <> Default And Not IsFunc(Execute($sCallbackSelect)) Then Return SetError(1, 4, -1)
	If Not IsInt($iLineNumber) Then Return SetError(1, 5, False)
	Local $mSystem[], $mViews[]
	$mSystem.mViews = $mViews
	$mSystem.sRootOld = -1
	$mSystem.sRoot = ""
	$mSystem.sFolderOld = -1
	$mSystem.sFolder = ""
	$mSystem.sSelected = ""
	$mSystem.sSelectedOld = -1
	$mSystem.bReloadFolder = False
	$mSystem.bReloadAllFolders = False
	$mSystem.hGui = $hGui
	$mSystem.sCallbackFolder = $sCallbackFolder
	$mSystem.sCallbackSelect = $sCallbackSelect
	$mSystem.iLineNumber = $iLineNumber
	If MapExists($__TreeListExplorer__Data.mGuis, $hGui) Then
		$__TreeListExplorer__Data["mGuis"][$hGui]["count"] += 1
	Else
		Local $mGui[]
		$mGui["count"] = 1
		$mGui["hPrevProc"] = _WinAPI_SetWindowLong($hGui, -4, DllCallbackGetPtr($__TreeListExplorer__Data.hProc))
		If @error Then Return SetError(2, 0, -1)
		$__TreeListExplorer__Data["mGuis"][$hGui] = $mGui
	EndIf
	Local $iSystem = MapAppend($__TreeListExplorer__Data.mSystems, $mSystem)
	If @error Then ; Revert gui changes and return error
		$__TreeListExplorer__Data["mGuis"][$hGui]["count"] -= 1
		If $__TreeListExplorer__Data.mGuis[$hGui].count = 0 Then _WinAPI_SetWindowLong($hGui, -4, $__TreeListExplorer__Data.mGuis[$hGui].hPrevProc)
		MapRemove($__TreeListExplorer__Data.mGuis, $hGui)
		Return SetError(3, 0, -1)
	EndIf
	Local $hSystem = __TreeListExplorer__GetHandleFromSystemID($iSystem)
	If @error Then
		__TreeListExplorer__DeleteSystem($iSystem)
		Return SetError(4, 0, -1)
	EndIf
	If $sRootFolder<>"" Then
		__TreeListExplorer_SetRoot($hSystem, $sRootFolder)
		If @error Then
			__TreeListExplorer_DeleteSystem($hSystem)
			Return SetError(5, 0, -1)
		EndIf
	EndIf
	Return $hSystem
EndFunc

; #FUNCTION# ====================================================================================================================
; Name ..........: __TreeListExplorer_DeleteSystem
; Description ...: Delete the TLE System connected to the $hSystem handle and cleans up the system resources
; Syntax ........: __TreeListExplorer_DeleteSystem($hSystem)
; Parameters ....: $hSystem             - the system handle.
; Return values .: None
; Author ........: Kanashius
; Modified ......:
; Remarks .......: Errors:
;                  1 - $hSystem is not a valid TLE system
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func __TreeListExplorer_DeleteSystem($hSystem)
	Local $iSystem = __TreeListExplorer__GetSystemIDFromHandle($hSystem)
	If @error Then Return SetError(1, @error, 0) ; $iSystem not valid/startup not called
	Return __TreeListExplorer__DeleteSystem($iSystem)
EndFunc

; #FUNCTION# ====================================================================================================================
; Name ..........: __TreeListExplorer_AddView
; Description ...: Add a view (TreeView/ListView) to a TLE system.
; Syntax ........: __TreeListExplorer_AddView($hSystem, $hView[, $bShowFolders = Default[, $bShowFiles = Default[, $sCallbackOnSelect = Default[,
;                  $sCallbackOnDoubleClick = Default[, $sCallbackLoading = Default[, $iLineNumber = @ScriptLineNumber]]]]])
; Parameters ....: $hSystem             - the system handle.
;                  $hView               - the view to add (must be a TreeView or ListView).
;                  $bShowFolders        - [optional] a boolean defining, if folders will be shown in the view. Default is Default.
;                  $bShowFiles          - [optional] a boolean defining, if files will be shown in the view. Default is Default.
;                  $sCallbackOnClick    - [optional] callback function as string. Using Default will not call any function.
;                  $sCallbackOnDoubleClick - [optional] callback function as string. Using Default will not call any function.
;                  $sCallbackLoading    - [optional] callback function as string. Using Default will not call any function.
;                  $iLineNumber         - [optional] an integer value. Default is @ScriptLineNumber.
; Return values .: True on success
; Author ........: Kanashius
; Modified ......:
; Remarks .......: Default for $bShowFolders is True for TreeViews and ListViews.
;                  Default for $bShowFiles is True for ListViews and False for TreeViews.
;                  $sCallbackOnClick must be a function with 6 parameters ($hSystem, $hView, $sRoot, $sFolder, $sSelected, $iIndex (ListView)/$hItem (TreeView))
;                  and is called, when an element in the view is clicked once.
;                  The $sCallbackOnDoubleClick must be a function with 6 parameters ($hSystem, $hView, $sRoot, $sFolder, $sSelected, $iIndex (ListView)/$hItem (TreeView))
;                  and is called, when an element in the view is double clicked.
;                  The $sCallbackLoading must be a function with 7 parameters ($hSystem, $hView, $sRoot, $sFolder, $sSelected, $sLoadingFolder, $bLoading)
;                  and is called, when a some folders or files are loading (when root/folder changes or an element in a
;                  TreeView is extended). $bLoading is True if loading starts and False, when it is done. $sLoadingFolder is relative
;                  to $sRoot and may be different then $sFolder, when the user is expanding a folder manually.
;
;                  Errors:
;                  1 - $hSystem is not a valid TLE system
;                  2 - $hView is not a (valid) control handle (@extended 50: Not a TreeView/ListView)
;                  3 - $hView is already part of a TLE system
;                  4 - Parameter is invalid (@extended 1 - $bShowFolders, 2 - $bShowFiles, 3 - $sCallbackOnSelect,
;                      4 - $sCallbackOnDoubleClick, 5 - $sCallbackLoading, 6 - $iLineNumber)
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func __TreeListExplorer_AddView($hSystem, $hView, $bShowFolders = Default, $bShowFiles = Default, $sCallbackOnClick = Default, $sCallbackOnDoubleClick = Default, $sCallbackLoading = Default, $iLineNumber = @ScriptLineNumber)
	Local $iSystem = __TreeListExplorer__GetSystemIDFromHandle($hSystem)
	If @error Then Return SetError(1, @error, False) ; $iSystem not valid/startup not called
	If Not IsHWnd($hView) Then
		$hView = GUICtrlGetHandle($hView)
		If @error Then Return SetError(2, @error, False) ; $hView is not a control
	EndIf
	If MapExists($__TreeListExplorer__Data.mViews, $hView) Then Return SetError(3, @error, False) ; $hView is already part of a system
	Local $sClass = _WinAPI_GetClassName($hView)
	Local $iType = 0
	If StringInStr($sClass, "TreeView") Then
		$iType = $__TreeListExplorer__Type_TreeView
	ElseIf StringInStr($sClass, "ListView") Then
		$iType = $__TreeListExplorer__Type_ListView
	ElseIf StringInStr($sClass, "Edit") And (Not BitAND(_WinAPI_GetWindowLong($hView, $GWL_STYLE), $ES_MULTILINE)) Then ; check if control is input
		$iType = $__TreeListExplorer__Type_Input
	Else
		Return SetError(2, 50, False) ; $hView is not a valid control (wrong control type)
	EndIf
	If $bShowFolders <> Default And Not IsBool($bShowFolders) Then Return SetError(4, 1, False)
	If $bShowFiles <> Default And Not IsBool($bShowFiles) Then Return SetError(4, 2, False)
	If $sCallbackOnClick <> Default And Not IsFunc(Execute($sCallbackOnClick)) Then Return SetError(4, 3, False)
	If $sCallbackOnDoubleClick <> Default And Not IsFunc(Execute($sCallbackOnDoubleClick)) Then Return SetError(4, 4, False)
	If $sCallbackLoading <> Default And Not IsFunc(Execute($sCallbackLoading)) Then Return SetError(4, 5, False)
	If Not IsInt($iLineNumber) Then Return SetError(4, 6, False)
	Switch $iType
		Case $__TreeListExplorer__Type_TreeView
			If $bShowFolders = Default Then $bShowFolders=True
			If $bShowFiles = Default Then $bShowFiles=False
			_GUICtrlTreeView_SetNormalImageList($hView, $__TreeListExplorer__Data.hIconList)
		Case $__TreeListExplorer__Type_ListView
			If $bShowFolders = Default Then $bShowFolders=True
			If $bShowFiles = Default Then $bShowFiles=True
			_GUICtrlListView_SetImageList($hView, $__TreeListExplorer__Data.hIconList, 1)
			_GUICtrlListView_SetExtendedListViewStyle($hView, BitOR( $LVS_EX_FULLROWSELECT, $LVS_EX_SUBITEMIMAGES))
			GUICtrlSetStyle($hView, BitOR($LVS_SHOWSELALWAYS, $LVS_NOSORTHEADER, $LVS_REPORT))
			For $i=0 To _GUICtrlListView_GetColumnCount($hView)+1 Step 1
				_GUICtrlListView_DeleteColumn($hView, 0)
			Next
			Local $iListWidth = _WinAPI_GetWindowWidth($hView)
			Local $iColWidth = $iListWidth*0.3
			If $iColWidth>140 Then $iColWidth = 140
			_GUICtrlListView_AddColumn($hView, $__TreeListExplorer__Data.arLangData[$__TreeListExplorer__Data.iLang][0], $iListWidth-$iColWidth*2-5) ; filename
			_GUICtrlListView_AddColumn($hView, $__TreeListExplorer__Data.arLangData[$__TreeListExplorer__Data.iLang][1], $iColWidth, 1) ; size
			_GUICtrlListView_AddColumn($hView, $__TreeListExplorer__Data.arLangData[$__TreeListExplorer__Data.iLang][2], $iColWidth) ; date created
		Case $__TreeListExplorer__Type_Input
			$bShowFolders=False
			$bShowFiles=False
			GUICtrlSetData($hView, "")
	EndSwitch
	Local $mView[]
	$mView.hWnd = $hView
	$mView.iType = $iType
	$mView.iSystem = $iSystem
	$mView.bShowFolders = $bShowFolders
	$mView.bShowFiles = $bShowFiles
	$mView.sRoot = -1
	$mView.sFolder = -1
	$mView.sSelected = -1
	$mView.iUpdating = 0
	$mView.sCallbackClick = $sCallbackOnClick
	$mView.sCallbackDBClick = $sCallbackOnDoubleClick
	$mView.sCallbackLoading = $sCallbackLoading
	$mView.iLineNumber = $iLineNumber
	$__TreeListExplorer__Data["mViews"][$hView] = $mView
	$__TreeListExplorer__Data["mSystems"][$iSystem]["mViews"][$hView] = 1
	__TreeListExplorer__UpdateView($hView)
	Return True
EndFunc

; #FUNCTION# ====================================================================================================================
; Name ..........: __TreeListExplorer_RemoveView
; Description ...: Remove a view from its TLE system
; Syntax ........: __TreeListExplorer_RemoveView($hView)
; Parameters ....: $hView               - the TreeView/ListView handle.
; Return values .: True on success
; Author ........: Kanashius
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func __TreeListExplorer_RemoveView($hView)
	If Not IsHWnd($hView) Then
		$hView = GUICtrlGetHandle($hView)
		If @error Then Return SetError(2, @error, False) ; $hView is not a control
	EndIf
	If Not IsHWnd($hView) Or Not MapExists($__TreeListExplorer__Data.mViews, $hView) Then Return SetError(1, 0, False)
	Local $mView = $__TreeListExplorer__Data.mViews[$hView]
	Local $iSystem = $mView.iSystem
	Local $iType = $mView.iType

	; Remove from maps first, to prevent events (WinProc) from being handled during deletion
	MapRemove($__TreeListExplorer__Data.mViews, $hView)
	MapRemove($__TreeListExplorer__Data["mSystems"][$iSystem]["mViews"], $hView)

	Switch $iType
		Case $__TreeListExplorer__Type_TreeView
			_GUICtrlTreeView_BeginUpdate($hView)
			_GUICtrlTreeView_DeleteAll($hView)
			_GUICtrlTreeView_SetNormalImageList($hView, 0)
			_GUICtrlTreeView_EndUpdate($hView)
		Case $__TreeListExplorer__Type_ListView
			_GUICtrlListView_BeginUpdate($hView)
			_GUICtrlListView_DeleteAllItems($hView)
			While _GUICtrlListView_GetColumnCount($hView)>0
				_GUICtrlListView_DeleteColumn($hView, 0)
			WEnd
			_GUICtrlListView_SetImageList($hView, 0)
			_GUICtrlListView_EndUpdate($hView)
	EndSwitch
	Return True
EndFunc

; #FUNCTION# ====================================================================================================================
; Name ..........: __TreeListExplorer_OpenPath
; Description ...: Set the current folder for the TLE system
; Syntax ........: __TreeListExplorer_OpenPath($hSystem[, $sPath = ""[, $sSelect = ""]])
; Parameters ....: $hSystem             - the system handle.
;                  $sPath               - [optional] a folder relative to root as string value. Default is "".
;                                         If the begin of $sPath is equal to the root directory, that part is removed.
;                                         If $sPath=Default, then the folder is not changed (for easy use of $sSelect).
;                  $sSelect             - [optional] a folder/file to select. Default is "".
; Return values .: True on success
; Author ........: Kanashius
; Modified ......:
; Remarks .......: Errors:
;                  1 - $hSystem is not a valid TLE system
;                  2 - Normalizing $sPath with _PathFull failed (@extended contains the error from _PathFull)
;                  3 - $sPath does not point to a valid existing file or folder
;                  4 - Something is wrong with $sPath or $sSelect
;                      @extended=1: $sPath Folder path and Filename coult not be split
;                      @extended=2: The Folder/File to select does not exist
;                  Others: See __TreeListExplorer__OpenPath
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func __TreeListExplorer_OpenPath($hSystem, $sPath = "", $sSelect = "")
	Local $iSystem = __TreeListExplorer__GetSystemIDFromHandle($hSystem)
	If @error Then Return SetError(1, @error, False)
	If $sPath=Default Then $sPath = __TreeListExplorer__GetCurrentPath($iSystem)
	If $sPath<>"" Then
		$sPath = _PathFull($sPath)
		If @error Then Return SetError(2, @error, False)
		; Remove root folder, if its at the beginning of $sPath
		Local $sRoot = __TreeListExplorer__GetCurrentRoot($iSystem)
		If $sRoot<>"" And StringInStr($sPath, $sRoot)=1 Then $sPath = StringTrimLeft($sPath, StringLen($sRoot))
	EndIf
	Local $bRes = __TreeListExplorer__OpenPath($iSystem, $sPath, $sSelect)
	If @error Then Return SetError(@error, @extended, False)
	Return $bRes
EndFunc

; #FUNCTION# ====================================================================================================================
; Name ..........: __TreeListExplorer_Reload
; Description ...: Reloads the folders and files in all views of the system.
; Syntax ........: __TreeListExplorer_Reload($hSystem[, $bAllFoldersOnPath = False])
; Parameters ....: $hSystem             - the TLE system handle.
;                  $bAllFoldersOnPath   - [optional] if false, only the current folder is reloaded.
;                                         If true, all folders in the view will be reloaded.
;                                         Default is False.
; Return values .: None
; Author ........: Kanashius
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func __TreeListExplorer_Reload($hSystem, $bAllFoldersOnPath = False)
	Local $iSystem = __TreeListExplorer__GetSystemIDFromHandle($hSystem)
	If @error Then Return SetError(1, @error, False)

	$__TreeListExplorer__Data["mSystems"][$iSystem]["bReloadFolder"] = True
	If $bAllFoldersOnPath Then $__TreeListExplorer__Data["mSystems"][$iSystem]["bReloadAllFolders"] = True

	__TreeListExplorer__UpdateSystemViews($iSystem)

	$__TreeListExplorer__Data["mSystems"][$iSystem]["bReloadFolder"] = False
	If $bAllFoldersOnPath Then $__TreeListExplorer__Data["mSystems"][$iSystem]["bReloadAllFolders"] = False
EndFunc

; #FUNCTION# ====================================================================================================================
; Name ..........: __TreeListExplorer_GetPath
; Description ...: Get the current folder, relative to the root folder.
; Syntax ........: __TreeListExplorer_GetPath($hSystem)
; Parameters ....: $hSystem             - the system handle.
; Return values .: The folder
; Author ........: Kanashius
; Modified ......:
; Remarks .......: Errors:
;                  1 - $hSystem is not a valid TLE system
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func __TreeListExplorer_GetPath($hSystem)
	Local $iSystem = __TreeListExplorer__GetSystemIDFromHandle($hSystem)
	If @error Then Return SetError(1, @error, 0)
	Return __TreeListExplorer__GetCurrentPath($iSystem)
EndFunc

; #FUNCTION# ====================================================================================================================
; Name ..........: __TreeListExplorer_GetSelected
; Description ...: Get the currently selected filename (Tree-/ListView) or foldername (ListView).
; Syntax ........: __TreeListExplorer_GetSelected($hSystem)
; Parameters ....: $hSystem             - the system handle.
; Return values .: The file-/foldername. "" if nothing is selected.
; Author ........: Kanashius
; Modified ......:
; Remarks .......: The TreeView does not have a foldername selection, because if a folder is selected in the TreeView,
;                  it becomes the current folder.
;                  Errors:
;                  1 - $hSystem is not a valid TLE system
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func __TreeListExplorer_GetSelected($hSystem)
	Local $iSystem = __TreeListExplorer__GetSystemIDFromHandle($hSystem)
	If @error Then Return SetError(1, @error, 0)
	Return __TreeListExplorer__GetSelected($iSystem)
EndFunc

; #FUNCTION# ====================================================================================================================
; Name ..........: __TreeListExplorer_GetRoot
; Description ...: Get the current root folder.
; Syntax ........: __TreeListExplorer_GetRoot($hSystem)
; Parameters ....: $hSystem             - the system handle.
; Return values .: The root folder
; Author ........: Kanashius
; Modified ......:
; Remarks .......: Errors:
;                  1 - $hSystem is not a valid TLE system
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func __TreeListExplorer_GetRoot($hSystem)
	Local $iSystem = __TreeListExplorer__GetSystemIDFromHandle($hSystem)
	If @error Then Return SetError(1, @error, 0)
	Return __TreeListExplorer__GetCurrentRoot($iSystem)
EndFunc

; #FUNCTION# ====================================================================================================================
; Name ..........: __TreeListExplorer_SetRoot
; Description ...: Set the current root folder.
; Syntax ........: __TreeListExplorer_SetRoot($hSystem[, $sPath = ""])
; Parameters ....: $hSystem             - the system handle.
;                  $sPath               - [optional] a path as string. Default is "" (All Drives).
; Return values .: True on success
; Author ........: Kanashius
; Modified ......:
; Remarks .......: Errors:
;                  1 - $hSystem is not a valid TLE system
;                  2 - Normalizing $sPath with _PathFull failed (@extended contains the error from _PathFull)
;                  3 - $sPath does not point to a valid existing folder
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func __TreeListExplorer_SetRoot($hSystem, $sPath = "")
	Local $iSystem = __TreeListExplorer__GetSystemIDFromHandle($hSystem)
	If @error Then Return SetError(1, @error, False)
	If $sPath <> "" Then
		$sPath = _PathFull($sPath)
		If @error Then Return SetError(2, @error, False)
	EndIf
	If Not ($sPath = "" Or __TreeListExplorer__PathIsFolder($sPath)) Then Return SetError(3, @error, False)
	If $sPath<>"" And StringRight($sPath, 1)<>"\" Then $sPath&="\" ; Making sure, sFolder always ends with \
	$__TreeListExplorer__Data["mSystems"][$iSystem]["sRoot"] = $sPath
	__TreeListExplorer__UpdateSystemViews($iSystem)
	Return True
EndFunc

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name ..........: __TreeListExplorer__DeleteSystem
; Description ...: Delete the TLE system and release all resources.
; Syntax ........: __TreeListExplorer__DeleteSystem($iSystem)
; Parameters ....: $iSystem             - the system ID.
; Return values .: True on success
; Author ........: Kanashius
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func __TreeListExplorer__DeleteSystem($iSystem)
	Local $hGui = $__TreeListExplorer__Data["mSystems"][$iSystem]["hGui"]
	$__TreeListExplorer__Data["mGuis"][$hGui]["count"] -= 1
	If $__TreeListExplorer__Data.mGuis[$hGui].count=0 Then
		_WinAPI_SetWindowLong($hGui, -4, $__TreeListExplorer__Data.mGuis[$hGui].hPrevProc)
		If @error Then ConsoleWrite('Error restoring the previous WinProc callback for gui "'&$hGui&'". This may be the reason for the program not exiting.'&@crlf)
		MapRemove($__TreeListExplorer__Data.mGuis, $hGui)
	EndIf
	Local $arViews = MapKeys($__TreeListExplorer__Data.mSystems[$iSystem].mViews)
	For $i=0 To UBound($arViews)-1 Step 1
		__TreeListExplorer_RemoveView(HWnd($arViews[$i]))
	Next
	MapRemove($__TreeListExplorer__Data.mSystems, $iSystem)
	Return True
EndFunc

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name ..........: __TreeListExplorer__OpenPath
; Description ...: Open the provided path.
; Syntax ........: __TreeListExplorer__OpenPath($iSystem[, $sPath = ""[, $sSelect = ""]])
; Parameters ....: $iSystem             - the system ID.
;                  $sPath               - [optional] a folder or file relative to root as string value. Default is "".
;                                         If $sPath=Default, the current path is used.
;                  $sSelect             - [optional] a folder/file to select as string value. Default is "".
; Return values .: True on success
; Author ........: Kanashius
; Modified ......:
; Remarks .......: Errors:
;                  3 - $sPath does not point to a valid existing file or folder
;                  4 - Something is wrong with $sPath or $sSelect
;                      @extended=1: $sPath Folder path and Filename coult not be split
;                      @extended=2: The Folder/File to select does not exist
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func __TreeListExplorer__OpenPath($iSystem, $sPath = "", $sSelect = "")
	If $sPath=Default Then $sPath = __TreeListExplorer__GetCurrentPath($iSystem)
	If $sPath<>"" And Not FileExists(__TreeListExplorer__GetCurrentRoot($iSystem) & $sPath) Then Return SetError(3, 0, False)
	If $sPath<>"" And Not __TreeListExplorer__RelPathIsFolder($iSystem, $sPath) Then ; handle file paths
		Local $arFolder = StringRegExp($sPath, "^(.*?\\?)([^\\]*?)$", 1) ; split path and filename
		If @error Or UBound($arFolder)<2 Then Return SetError(4, 1, False)
		$sPath = $arFolder[0]
		$sSelect = $arFolder[1]
	EndIf
	If $sPath<>"" And StringRight($sPath, 1)<>"\" Then $sPath&="\" ; Making sure, sFolder always ends with \
	Local $sPathAbs = __TreeListExplorer__GetCurrentRoot($iSystem) & $sPath & $sSelect
	If $sPathAbs<>"" And Not FileExists($sPathAbs) Then Return SetError(4, 2, False)
	$__TreeListExplorer__Data["mSystems"][$iSystem]["sSelected"] = $sSelect
	$__TreeListExplorer__Data["mSystems"][$iSystem]["sFolder"] = $sPath
	__TreeListExplorer__UpdateSystemViews($iSystem)
	Return True
EndFunc

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name ..........: __TreeListExplorer__IsPathOpen
; Description ...: Check if a path is currently open
; Syntax ........: __TreeListExplorer__IsPathOpen($iSystem, $sPath)
; Parameters ....: $iSystem             - the system ID.
;                  $sPath               - the path to test.
; Return values .: True if $sPath equals the current TLE system folder
; Author ........: Kanashius
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func __TreeListExplorer__IsPathOpen($iSystem, $sPath)
	Return (__TreeListExplorer__GetCurrentPath($iSystem) = $sPath)
EndFunc

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name ..........: __TreeListExplorer__GetCurrentPath
; Description ...: Get the current TLE system folder
; Syntax ........: __TreeListExplorer__GetCurrentPath($iSystem)
; Parameters ....: $iSystem             - the system ID.
; Return values .: The folder
; Author ........: Kanashius
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func __TreeListExplorer__GetCurrentPath($iSystem)
	Return $__TreeListExplorer__Data.mSystems[$iSystem].sFolder
EndFunc

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name ..........: __TreeListExplorer__GetCurrentRoot
; Description ...: Get the current TLE system root folder
; Syntax ........: __TreeListExplorer__GetCurrentRoot($iSystem)
; Parameters ....: $iSystem             - the system ID.
; Return values .: The root folder
; Author ........: Kanashius
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func __TreeListExplorer__GetCurrentRoot($iSystem)
	Return $__TreeListExplorer__Data.mSystems[$iSystem].sRoot
EndFunc

; #INTERNAL_USE_ONLY# ====================================================================================================================
; Name ..........: __TreeListExplorer__GetSelected
; Description ...: Get the currently selected filename (Tree-/ListView) or foldername (ListView).
; Syntax ........: __TreeListExplorer__GetSelected($iSystem)
; Parameters ....: $iSystem             - the system ID.
; Return values .: The file-/foldername
; Author ........: Kanashius
; Modified ......:
; Remarks .......: The TreeView does not have a foldername selection, because if a folder is selected in the TreeView,
;                  it becomes the current folder.
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func __TreeListExplorer__GetSelected($iSystem)
	Return $__TreeListExplorer__Data.mSystems[$iSystem].sSelected
EndFunc

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name ..........: __TreeListExplorer__GetSystemIDFromHandle
; Description ...: Convert a TLE system handle to a TLE system ID
; Syntax ........: __TreeListExplorer__GetSystemIDFromHandle($hSystem)
; Parameters ....: $hSystem             - the system handle.
; Return values .: The system ID.
; Author ........: Kanashius
; Modified ......:
; Remarks .......: Errors:
;                  1 - mSystems Map does not exists. Make sure to call __TreeListExplorer_StartUp.
;                  2 - No TLE system with the handle $hSystem exists
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func __TreeListExplorer__GetSystemIDFromHandle($hSystem)
	If Not MapExists($__TreeListExplorer__Data, "mSystems") Then Return SetError(1, 0, False)
	Local $iSystem = $hSystem-1
	If $iSystem<0 Then Return SetError(2, 0, False) ; negative key crashes autoit for some reason (and is not valid anyway)
	If Not MapExists($__TreeListExplorer__Data.mSystems, $iSystem) Then Return SetError(2, 0, False)
	Return $iSystem
EndFunc

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name ..........: __TreeListExplorer__GetHandleFromSystemID
; Description ...: Convert a TLE system ID to a TLE system handle
; Syntax ........: __TreeListExplorer__GetHandleFromSystemID($iSystem)
; Parameters ....: $iSystem             - the system ID.
; Return values .: The system handle.
; Author ........: Kanashius
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func __TreeListExplorer__GetHandleFromSystemID($iSystem)
	return $iSystem+1
EndFunc

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name ..........: __TreeListExplorer__UpdateSystemViews
; Description ...: Update all views of the given TLE system
; Syntax ........: __TreeListExplorer__UpdateSystemViews($iSystem)
; Parameters ....: $iSystem             - the system ID.
; Return values .: True on success
; Author ........: Kanashius
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func __TreeListExplorer__UpdateSystemViews($iSystem)
	Local $arViews = MapKeys($__TreeListExplorer__Data["mSystems"][$iSystem]["mViews"])
	For $i=0 To UBound($arViews)-1 Step 1
		__TreeListExplorer__UpdateView(HWnd($arViews[$i]))
	Next
	Return True
EndFunc

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name ..........: __TreeListExplorer__UpdateView
; Description ...: Update a view to match a TLE systems root folder and current folder
; Syntax ........: __TreeListExplorer__UpdateView($hView)
; Parameters ....: $hView               - the control handle.
; Return values .: None
; Author ........: Kanashius
; Modified ......:
; Remarks .......: Main function to handle all updates. Changes to the view mainly happen here. Only exceptions are the
;                  initialization (__TreeListExplorer_AddView) and the user expanding a folder (__TreeListExplorer__WinProc)
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func __TreeListExplorer__UpdateView($hView)
	Local $mView = $__TreeListExplorer__Data.mViews[$hView]
	Local $mSystem = $__TreeListExplorer__Data.mSystems[$mView.iSystem]
	Switch $mView.iType
		Case $__TreeListExplorer__Type_TreeView
			_GUICtrlTreeView_BeginUpdate($hView)
		Case $__TreeListExplorer__Type_ListView
			_GUICtrlListView_BeginUpdate($hView)
	EndSwitch
	Local $bReload = False
	; Root different
	If $mView.sRoot<>$mSystem.sRoot Or $mSystem.bReloadAllFolders Or ($mView.sRoot="" And $mSystem.sFolder="" And $mSystem.bReloadFolder) Then
		If $mView.iType<>$__TreeListExplorer__Type_Input Then
			__TreeListExplorer__HandleViewCallback($hView, "sCallbackLoading", "$sCallbackLoading", $mSystem.sRoot, True)
			If $mSystem.sRoot <> $mSystem.sRootOld Then
				$__TreeListExplorer__Data["mSystems"][$mView.iSystem]["sRootOld"] = $mSystem.sRoot
				__TreeListExplorer__HandleSystemCallback($mView.iSystem, "sCallbackFolder", "$sCallbackFolder")
			EndIf
			$__TreeListExplorer__Data["mViews"][$hView]["sRoot"] = $mSystem.sRoot
			Switch $mView.iType
				Case $__TreeListExplorer__Type_TreeView
					__TreeListExplorer__SetViewUpdating($hView, True, $__TreeListExplorer__Status_UpdateView)
					_GUICtrlTreeView_DeleteAll($hView)
					If $mSystem.sRoot = "" Then
						Local $arDrives = __TreeListExplorer__GetDrives()
						For $i=0 To UBound($arDrives)-1 Step 1
							;Local $hRoot =  _GUICtrlTreeView_Add($hView, 0, StringUpper($arDrives[$i][0]), $arDrives[$i][1], $arDrives[$i][1])
							Local $hRoot =  _GUICtrlTreeView_Add($hView, 0, StringUpper($arDrives[$i][0]), 5, 10)
							__TreeListExplorer__LoadTreeItemContent($hView, $hRoot)
						Next
					Else
						Local $arFolder = StringRegExp($mSystem.sRoot, "([^\\]*)\\$", 1) ; get the last folder/drive name
						If UBound($arFolder)>0 Then ; Should always be true
							Local $hRoot = _GUICtrlTreeView_Add($hView, 0, $arFolder[0], 0, 0)
							__TreeListExplorer__LoadTreeItemContent($hView, $hRoot)
						EndIf
					EndIf
					__TreeListExplorer__SetViewUpdating($hView, False, $__TreeListExplorer__Status_UpdateView)
					$bReload = True
				Case $__TreeListExplorer__Type_ListView
					 ; (edge case) do not display ".." at root folder => remove if its there and its not fixed in the "folder different" code below (Cannot be a normal folder, because ".." is not allowed as folder name in windows)
					If $mView.sFolder=$mSystem.sFolder And $mSystem.sFolder="" And _GUICtrlListView_GetItemCount($hView)>0 And _GUICtrlListView_GetItemText($hView, 0, 1)=".." Then _GUICtrlListView_DeleteItem($hView, 0)
					$bReload = True
			EndSwitch
			__TreeListExplorer__HandleViewCallback($hView, "sCallbackLoading", "$sCallbackLoading", $mSystem.sRoot, False)
		EndIf
	EndIf
	; callback folder changed
	If $mSystem.sFolder <> $mSystem.sFolderOld Then
		$__TreeListExplorer__Data["mSystems"][$mView.iSystem]["sFolderOld"] = $mSystem.sFolder
		__TreeListExplorer__HandleSystemCallback($mView.iSystem, "sCallbackFolder", "$sCallbackFolder")
	EndIf
	If $mSystem.sSelected <> $mSystem.sSelectedOld Then
		$__TreeListExplorer__Data["mSystems"][$mView.iSystem]["sSelectedOld"] = $mSystem.sSelected
		__TreeListExplorer__HandleSystemCallback($mView.iSystem, "sCallbackSelect", "$sCallbackSelect")
	EndIf
	If $mView.sFolder <> $mSystem.sFolder Or $mView.sSelected<>$mSystem.sSelected Or $mSystem.bReloadFolder Or $bReload Then
		Local $bFolderChanged = $mView.sFolder <> $mSystem.sFolder
		Local $bUpdateFolder = $bFolderChanged Or $mSystem.bReloadFolder Or $bReload
		$__TreeListExplorer__Data["mViews"][$hView]["sFolder"] = $mSystem.sFolder
		$__TreeListExplorer__Data["mViews"][$hView]["sSelected"] = $mSystem.sSelected
		Switch $mView.iType
			Case $__TreeListExplorer__Type_TreeView
				Local $sFolder = $mSystem.sFolder & $mSystem.sSelected
				Local $arFolders = StringSplit($sFolder, "\", BitOR(1, 2))
				Local $hItem = _GUICtrlTreeView_GetFirstItem($hView)
				__TreeListExplorer__HandleViewCallback($hView, "sCallbackLoading", "$sCallbackLoading", $mSystem.sFolder, True)
				If $mSystem.sRoot <> "" Then ; Root item is not part of $mSystem.sFolder
					If $mSystem.sFolder<>"" Then ; expand the root item
						__TreeListExplorer__ExpandTreeitem($hView, $hItem, $mSystem.bReloadAllFolders)
					Else
						__TreeListExplorer__ExpandTreeitem($hView, $hItem, $mSystem.bReloadFolder Or $bReload)
					EndIf
					$hItem = _GUICtrlTreeView_GetFirstChild($hView, $hItem)
				EndIf
				; expand all items on the path below the current one
				For $i=0 To UBound($arFolders)-3 Step 1 ; last field is always empty, second to last will only be selected
					While _GUICtrlTreeView_GetText($hView, $hItem)<>$arFolders[$i]
						$hItem = _GUICtrlTreeView_GetNextSibling($hView, $hItem)
						If $hItem=0 Then ExitLoop
					WEnd
					If $hItem<>0 Then
						If $i<>UBound($arFolders)-3 Then
							__TreeListExplorer__ExpandTreeitem($hView, $hItem, $mSystem.bReloadAllFolders)
							$hItem = _GUICtrlTreeView_GetFirstChild($hView, $hItem)
						Else
							__TreeListExplorer__ExpandTreeitem($hView, $hItem, $mSystem.bReloadFolder Or $bReload)
						EndIf
					EndIf
				Next
				; select the current item (or selected item if applicable)
				If UBound($arFolders)>=1 Then
					Local $sSelected = $arFolders[UBound($arFolders)-1] ; selection changed
					If UBound($arFolders)>=2 Then $sSelected = $arFolders[UBound($arFolders)-2] ; folder changed = last folder should be selected
					If $sSelected<>"" Then
						Local $hChild = _GUICtrlTreeView_GetFirstChild($hView, $hItem)
						If UBound($arFolders)<=2 Then $hChild = $hItem ; handle root items
						While $hChild<>0 ; search and select the item if possible
							If _GUICtrlTreeView_GetText($hView, $hChild)=$sSelected Then
								; select the item of the selected file/folder, if the opened folder is expanded
								If _GUICtrlTreeView_GetExpanded($hView, $hChild) And $arFolders[UBound($arFolders)-1]<>"" Then ; enable folder/file selection, if folder is expanded
									$sSelected = $arFolders[UBound($arFolders)-1]
									$hChild = _GUICtrlTreeView_GetFirstChild($hView, $hChild)
									ContinueLoop
								Else ; otherwise select the opened folder
									_GUICtrlTreeView_EnsureVisible($hView, $hChild)
									_GUICtrlTreeView_SelectItem($hView, $hChild)
									ExitLoop
								EndIf
							EndIf
							$hChild = _GUICtrlTreeView_GetNextSibling($hView, $hChild)
						WEnd
						If $sSelected<>"" Then __TreeListExplorer__HandleSystemCallback($mView.iSystem, "sCallbackSelect", "$sCallbackSelect", $sSelected)
					EndIf
				Else ; handle root item selection
					Local $hItem = _GUICtrlTreeView_GetFirstItem($hView)
					If _GUICtrlTreeView_GetNextSibling($hView, $hItem)=0 Then
						_GUICtrlTreeView_SelectItem($hView, $hItem)
					Else
						Local $hItem = _GUICtrlTreeView_GetSelection($hView)
						If $hItem<>0 Then  _GUICtrlTreeView_SetSelected($hView, $hItem, False)
					EndIf
					__TreeListExplorer__HandleSystemCallback($mView.iSystem, "sCallbackSelect", "$sCallbackSelect")
				EndIf
				__TreeListExplorer__HandleViewCallback($hView, "sCallbackLoading", "$sCallbackLoading", $mSystem.sFolder, False)
			Case $__TreeListExplorer__Type_ListView
				If $bUpdateFolder Then
					__TreeListExplorer__HandleViewCallback($hView, "sCallbackLoading", "$sCallbackLoading", $mSystem.sFolder, True)
					$__TreeListExplorer__Data["mViews"][$hView]["iIndex"] = -1
					__TreeListExplorer__SetViewUpdating($hView, True, $__TreeListExplorer__Status_UpdateView)
					_GUICtrlListView_DeleteAllItems($hView)
					; do not display .. folder in root directory
					If $mSystem.sFolder<>"" Then
						_GUICtrlListView_AddItem($hView, "..", 0, 0)
					EndIf
					Local $sPath = $mSystem.sRoot & $mSystem.sFolder
					If $sPath = "" Then ; list drives at root level
						Local $arDrives = __TreeListExplorer__GetDrives()
						For $i=0 To UBound($arDrives)-1 Step 1
							_GUICtrlListView_AddItem($hView, StringUpper($arDrives[$i][0]), $arDrives[$i][1], $arDrives[$i][1])
						Next
					Else
						If $mView.bShowFolders Then
							Local $arFolders = _FileListToArray($sPath, "*", 2)
							For $i=1 To UBound($arFolders)-1 Step 1
								Local $iIndex = _GUICtrlListView_AddItem($hView, $arFolders[$i], 0, 0)
								_GUICtrlListView_SetItemText($hView, $iIndex, __TreeListExplorer__GetTimeString($sPath & $arFolders[$i]), 2)
							Next
						EndIf
						If $mView.bShowFiles Then
							Local $arFiles = _FileListToArray($sPath, "*", 1)
							For $i=1 To UBound($arFiles)-1 Step 1
								Local $sFilePath = $sPath & $arFiles[$i]
								Local $iIconIndex = __TreeListExplorer__FileGetIconIndex($sFilePath)
								Local $iIndex = _GUICtrlListView_AddItem($hView, $arFiles[$i], $iIconIndex, $iIconIndex)
								_GUICtrlListView_SetItemText($hView, $iIndex, __TreeListExplorer__GetSizeString($sFilePath), 1)
								_GUICtrlListView_SetItemText($hView, $iIndex, __TreeListExplorer__GetTimeString($sFilePath), 2)
							Next
						EndIf
					EndIf
					__TreeListExplorer__SetViewUpdating($hView, False, $__TreeListExplorer__Status_UpdateView)
					__TreeListExplorer__HandleViewCallback($hView, "sCallbackLoading", "$sCallbackLoading", $mSystem.sFolder, False)
				EndIf
				If $mSystem.sSelected<>"" Then
					Local $sSelected = $mSystem.sSelected
					For $i=0 To _GUICtrlListView_GetItemCount($hView)
						If _GUICtrlListView_GetItemText($hView, $i, 0)=$sSelected Then
							_GUICtrlListView_EnsureVisible($hView, $i)
							Local $arSel = _GUICtrlListView_GetSelectedIndices($hView, True)
							For $j=1 To UBound($arSel)-1 Step 1
								_GUICtrlListView_SetItemSelected($hView, $arSel[$j], False)
							Next
							_GUICtrlListView_SetSelectionMark($hView, $i)
							_GUICtrlListView_SetItemSelected($hView, $i)
							ExitLoop
						EndIf
					Next
				EndIf
			Case $__TreeListExplorer__Type_Input
				If $bFolderChanged Then _GUICtrlEdit_SetText($hView, $mSystem.sFolder)
		EndSwitch
	EndIf
	Switch $mView.iType
		Case $__TreeListExplorer__Type_TreeView
			_GUICtrlTreeView_EndUpdate($hView)
			$mView.bUpdating = False
		Case $__TreeListExplorer__Type_ListView
			_GUICtrlListView_EndUpdate($hView)
	EndSwitch
EndFunc

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name ..........: __TreeListExplorer__GetSizeString
; Description ...: Get the size of a file formatted to the nearest magnitude (B, KB, MB, GB, TB, PB, EB).
; Syntax ........: __TreeListExplorer__GetSizeString($sPath)
; Parameters ....: $sPath               - the path of the file.
; Return values .: The file size.
; Author ........: Kanashius
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func __TreeListExplorer__GetSizeString($sPath)
    Local Static $arSizeName = [" B", "KB", "MB", "GB", "TB", "PB", "EB"]

	Local $iSize = FileGetSize($sPath)
    For $i = UBound($arSizeName) To 1 Step -1
        If $iSize >= 1024 ^ $i Then Return Round($iSize/(1024^$i), 2) & " " & $arSizeName[$i]
    Next
    Return $iSize & " " & $arSizeName[0]
EndFunc

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name ..........: __TreeListExplorer__GetTimeString
; Description ...: Get the formatted file creation date (YYYY/MM/DD HH:MM:SS)
; Syntax ........: __TreeListExplorer__GetTimeString($sPath)
; Parameters ....: $sPath               - the path of the file.
; Return values .: The creation date
; Author ........: Kanashius
; Modified ......:
; Remarks .......: Errors:
;                  1 - Error calling FileGetTime (@extended contains the error from FileGetTime)
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func __TreeListExplorer__GetTimeString($sPath)
	Local $arTime = FileGetTime($sPath, 1)
	If @error Then Return SetError(1, @error, "")
	Return StringFormat("%u/%02u/%02u %02u:%02u:%02u", $arTime[0], $arTime[1], $arTime[2], $arTime[3], $arTime[4], $arTime[5])
EndFunc

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name ..........: __TreeListExplorer__FileGetIconIndex
; Description ...: Get the index of an icon in $__TreeListExplorer__Data.hIconList for a given extension and add missing icons.
; Syntax ........: __TreeListExplorer__FileGetIconIndex($sPath)
; Parameters ....: $sPath               - the absolute path.
; Return values .: The index
; Author ........: Kanashius
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func __TreeListExplorer__FileGetIconIndex($sPath)
	Local $arExt = StringRegExp($sPath, "^.*[^\\](\.[^\\]*?)$", 1)
	If @error Or UBound($arExt)<>1 Then Return 2 ; Default file icon
	Local $sExt = $arExt[0]
	If MapExists($__TreeListExplorer__Data.mIcons, $sExt) Then Return $__TreeListExplorer__Data.mIcons[$sExt]

	Local $sRegData = RegRead("HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\" & $sExt, "ProgID")
	If @error Then
		$sRegData = RegRead("HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\" & $sExt & "\UserChoice", "ProgID")
		If @error Then
			$sRegData = RegRead("HKCR\" & $sExt, "")
			If @error Then Return 2 ; Default file icon
		EndIf
	EndIf
	$sRegData = RegRead("HKCR\" & $sRegData & "\DefaultIcon", "")
	If @error Then Return 2 ; Default file icon
	Local $arParts = StringSplit($sRegData, ",", BitOR(1, 2))
	If @error Or UBound($arParts)<>2 Then Return 2 ; Default file icon

	_GUIImageList_AddIcon($__TreeListExplorer__Data.hIconList, $arParts[0], $arParts[1])
	If @error Then Return 2 ; Default file icon

	Local $iIndex = $__TreeListExplorer__Data.iIconIndex
	$__TreeListExplorer__Data["iIconIndex"] = $iIndex + 1
	$__TreeListExplorer__Data["mIcons"][$sExt] = $iIndex
	Return $iIndex
EndFunc

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name ..........: __TreeListExplorer__ExpandTreeitem
; Description ...: Expand a TreeItem and load the content of all childs (Show the extend button, if they have childs)
; Syntax ........: __TreeListExplorer__ExpandTreeitem($hView, $hItem[, $bReload = False])
; Parameters ....: $hView               - the TreeView handle.
;                  $hItem               - the item handle.
;                  $bReload             - [optional] if true the childs of the item are reloaded
; Return values .: True on success
; Author ........: Kanashius
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func __TreeListExplorer__ExpandTreeitem($hView, $hItem, $bReload = False)
	If __TreeListExplorer__TreeViewItemIsExpanded($hView, $hItem) And Not $bReload Then Return True
	__TreeListExplorer__SetViewUpdating($hView, True, $__TreeListExplorer__Status_ExpandTree)
	__TreeListExplorer__LoadTreeItemContent($hView, $hItem)
	; DO NOT USE _GUICtrlTreeView_Expand IT EXPANDS ALL CHILDREN
	_SendMessage($hView, $TVM_EXPAND, $TVE_EXPAND, $hItem, 0, "wparam", "handle")
	Local $mView = $__TreeListExplorer__Data.mViews[$hView]
	Local $sRoot = __TreeListExplorer__GetCurrentRoot($mView.iSystem)
	Local $hChildItem = _GUICtrlTreeView_GetFirstChild($hView, $hItem)
	While $hChildItem<>0
		Local $sChildPath = $sRoot & __TreeListExplorer__TreeViewGetRelPath($mView.iSystem, $hView, $hChildItem)
		If __TreeListExplorer__PathIsFolder($sChildPath) Then
			Local $hSearch = FileFindFirstFile($sChildPath & "\" & "*")
			If $hSearch<>-1 Then
				FileClose($hSearch)
				_GUICtrlTreeView_AddChild($hView, $hChildItem, "HasChilds")
			EndIf
		EndIf
		$hChildItem=_GUICtrlTreeView_GetNextChild($hView, $hChildItem)
	WEnd
	__TreeListExplorer__SetViewUpdating($hView, False, $__TreeListExplorer__Status_ExpandTree)
	Return True
EndFunc

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name ..........: __TreeListExplorer__LoadTreeItemContent
; Description ...: Load the children of the TreeView item.
; Syntax ........: __TreeListExplorer__LoadTreeItemContent($hView, $hItem)
; Parameters ....: $hView               - the TreeView handle.
;                  $hItem               - the item handle.
; Return values .: True on success
; Author ........: Kanashius
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func __TreeListExplorer__LoadTreeItemContent($hView, $hItem)
	Local $mView = $__TreeListExplorer__Data.mViews[$hView]
	__TreeListExplorer__SetViewUpdating($hView, True, $__TreeListExplorer__Status_LoadTree)
	Local $mSystem = $__TreeListExplorer__Data.mSystems[$mView.iSystem]
	Local $sRoot = __TreeListExplorer__RemoveLastFolderFromPath($mSystem.sRoot)
	Local $sPath = $sRoot & StringReplace(_GUICtrlTreeView_GetTree($hView, $hItem), "|", "\") & "\"
	_GUICtrlTreeView_DeleteChildren($hView, $hItem)
	If $mView.bShowFolders Then
		Local $arFolders = _FileListToArray($sPath, "*", 2)
		For $i=1 To UBound($arFolders)-1 Step 1
			_GUICtrlTreeView_AddChild($hView, $hItem, $arFolders[$i], 0, 1)
		Next
	EndIf
	If $mView.bShowFiles Then
		Local $arFiles = _FileListToArray($sPath, "*", 1)
		For $i=1 To UBound($arFiles)-1 Step 1
			;Local $iIconIndex = __TreeListExplorer__FileGetIconIndex($sPath & "\" & $arFiles[$i])
			;_GUICtrlTreeView_AddChild($hView, $hItem, $arFiles[$i], $iIconIndex, $iIconIndex)
			_GUICtrlTreeView_AddChild($hView, $hItem, $arFiles[$i], 2, 9)
		Next
	EndIf
	__TreeListExplorer__SetViewUpdating($hView, False, $__TreeListExplorer__Status_LoadTree)
	Return True
EndFunc

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name ..........: __TreeListExplorer__RemoveLastFolderFromPath
; Description ...: Get the path without the last folder, e.g. C:\Users\User\ => C:\Users\
; Syntax ........: __TreeListExplorer__RemoveLastFolderFromPath($sPath)
; Parameters ....: $sPath               - the path to change.
; Return values .: The shortened path
; Author ........: Kanashius
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func __TreeListExplorer__RemoveLastFolderFromPath($sPath)
	Local $arFolder = StringRegExp($sPath, "^(.*?\\?)[^\\]*\\$", 1) ; remove last folder (it is already as root in the treeview)
	If Not @error And UBound($arFolder)>0 Then Return $arFolder[0]
	Return ""
EndFunc

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name ..........: __TreeListExplorer__GetDrives
; Description ...: Get all drives and their type
; Syntax ........: __TreeListExplorer__GetDrives()
; Parameters ....:
; Return values .: An Array with all drives. $arDrives[N][0] = Drive name, $arDrives[N][1] = Id of the type
; Author ........: Kanashius
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func __TreeListExplorer__GetDrives()
	Local $arDrives = DriveGetDrive('ALL'), $iType
	Local $arResult[UBound($arDrives)-1][2]
	For $i = 1 To UBound($arDrives)-1
		$arResult[$i-1][0] = $arDrives[$i]
		Switch DriveGetType($arDrives[$i])
			Case 'Fixed'
				$arResult[$i-1][1] = 5
			Case 'CDROM'
				$arResult[$i-1][1] = 6
			Case 'RAMDisk'
				$arResult[$i-1][1] = 7
			Case 'Removable'
				$arResult[$i-1][1] = 4
				If StringLower(StringLeft($arDrives[$i], 2)) = "a:" Or StringLower(StringLeft($arDrives[$i], 2)) = "b:" Then $arResult[$i-1][1] = 3
			Case Else
				$arResult[$i-1][1] = 8
		EndSwitch
	Next
	Return $arResult
EndFunc

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name ..........: __TreeListExplorer__UpdateTreeViewSelection
; Description ...: Handle the selection of a TreeView item (extending/collapsing the item)
; Syntax ........: __TreeListExplorer__UpdateTreeViewSelection($hView, $hItem)
; Parameters ....: $hView               - the TreeView handle.
;                  $hItem               - the item handle.
; Return values .: True on success
; Author ........: Kanashius
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func __TreeListExplorer__UpdateTreeViewSelection($hView, $hItem)
	If MapExists($__TreeListExplorer__Data.mViews, $hView) Then
		Local $iSystem = $__TreeListExplorer__Data.mViews[$hView].iSystem
		Local $sPath = __TreeListExplorer__TreeViewGetRelPath($iSystem, $hView, $hItem)
		If __TreeListExplorer__RelPathIsFolder($iSystem, $sPath) Then
			If Not __TreeListExplorer__TreeViewItemIsExpanded($hView, $hItem) Or Not __TreeListExplorer__IsPathOpen($iSystem, $sPath) Then
				$__TreeListExplorer__Data["mSystems"][$iSystem]["bReloadFolder"] = True
				__TreeListExplorer__OpenPath($iSystem, $sPath)
				$__TreeListExplorer__Data["mSystems"][$iSystem]["bReloadFolder"] = False
			Else
				_SendMessage($hView, $TVM_EXPAND, $TVE_COLLAPSE, $hItem, 0, "wparam", "handle")
			EndIf
		ElseIf __TreeListExplorer__RelPathIsFile($iSystem, $sPath) Then
			__TreeListExplorer__OpenPath($iSystem, $sPath)
		EndIf
	EndIf
	Return True
EndFunc

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name ..........: __TreeListExplorer__TreeViewGetRelPath
; Description ...: Get the path of the TreeView item, relative to the TLE system root
; Syntax ........: __TreeListExplorer__TreeViewGetRelPath($iSystem, $hView, $hItem)
; Parameters ....: $iSystem             - the system ID.
;                  $hView               - the TreeView handle.
;                  $hItem               - the item handle.
; Return values .: The path
; Author ........: Kanashius
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func __TreeListExplorer__TreeViewGetRelPath($iSystem, $hView, $hItem)
	Local $sPath = StringReplace(_GUICtrlTreeView_GetTree($hView, $hItem), "|", "\")
	If $__TreeListExplorer__Data.mSystems[$iSystem].sRoot <> "" Then
		$arPath = StringRegExp($sPath, "[^\\]*\\?(.*)$", 1) ; remove first element (root)
		If UBound($arPath)>0 Then $sPath = $arPath[0]
	EndIf
	If $sPath<>"" And StringRight($sPath, 1)<>"\" And __TreeListExplorer__RelPathIsFolder($iSystem, $sPath) Then $sPath &= "\"
	Return $sPath
EndFunc

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name ..........: __TreeListExplorer__TreeViewItemIsExpanded
; Description ...: Check if a TreeView item is expanded
; Syntax ........: __TreeListExplorer__TreeViewItemIsExpanded($hView, $hItem)
; Parameters ....: $hView               - the TreeView handle.
;                  $hItem               - the item handle.
; Return values .: True if expanded, False otherwise
; Author ........: Kanashius
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func __TreeListExplorer__TreeViewItemIsExpanded($hView, $hItem)
	Return BitAND(_GUICtrlTreeView_GetState($hView, $hItem), $TVIS_EXPANDED)>0
EndFunc

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name ..........: __TreeListExplorer__IsViewUpdating
; Description ...: Check if a View is currently updated (used to prevent events from propagating during view changes)
; Syntax ........: __TreeListExplorer__IsViewUpdating($hView)
; Parameters ....: $hView               - the view handle value.
;                  $iStatus             - [optional] an integer value, specifying which update status should be set.
;                                         Possible: $__TreeListExplorer__Status_UpdateView, $__TreeListExplorer__Status_ExpandTree,
;                                         $__TreeListExplorer__Status_LoadTree, $__TreeListExplorer__Status_ExpandTree
;                                         Using Default is checking if any Status is set => anything is updating.
; Return values .: True if the view is being updated
; Author ........: Kanashius
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func __TreeListExplorer__IsViewUpdating($hView, $iStatus = Default)
	If $iStatus=Default Then Return $__TreeListExplorer__Data.mViews[$hView].iUpdating>0
	Return BitAND($__TreeListExplorer__Data.mViews[$hView].iUpdating, $iStatus)>0
EndFunc

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name ..........: __TreeListExplorer__SetViewUpdating
; Description ...: Set the update status of a View. Differentiates between different update parts.
; Syntax ........: __TreeListExplorer__SetViewUpdating($hView[, $bUpdating = False[, $iStatus = $__TreeListExplorer__Status_UpdateView]])
; Parameters ....: $hView               - a view handle value.
;                  $bUpdating           - [optional] a boolean value. If True the View is updating, if False, the update is done. Default is False.
;                  $iStatus             - [optional] an integer value, specifying which update status should be set.
;                                         Possible: $__TreeListExplorer__Status_UpdateView, $__TreeListExplorer__Status_ExpandTree,
;                                         $__TreeListExplorer__Status_LoadTree, $__TreeListExplorer__Status_ExpandTree
;                                         Default is $__TreeListExplorer__Status_UpdateView.
; Return values .: None
; Author ........: Kanashius
; Modified ......:
; Remarks .......: Used to set different update states, which can occour at the same time. This is why it is not a simple boolean
;                  value. Each Bit represents a different type of update that is currently running.
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func __TreeListExplorer__SetViewUpdating($hView, $bUpdating = False, $iStatus = $__TreeListExplorer__Status_UpdateView)
	If $bUpdating Then
		$__TreeListExplorer__Data["mViews"][$hView]["iUpdating"] = BitOR($__TreeListExplorer__Data.mViews[$hView].iUpdating, $iStatus) ; add $iStatus
	Else
		$__TreeListExplorer__Data["mViews"][$hView]["iUpdating"] = BitAND($__TreeListExplorer__Data.mViews[$hView].iUpdating, BitNOT($iStatus)) ; remove $iStatus
	EndIf
EndFunc

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name ..........: __TreeListExplorer__PathIsFolder
; Description ...: Check if the provided path is a folder
; Syntax ........: __TreeListExplorer__PathIsFolder($sPath)
; Parameters ....: $sPath               - the path to check.
; Return values .: True if $sPath is a folder
; Author ........: Kanashius
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func __TreeListExplorer__PathIsFolder($sPath)
	Return StringInStr(FileGetAttrib($sPath), "D")
EndFunc

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name ..........: __TreeListExplorer__PathIsFile
; Description ...: Check if the provided path is a folder
; Syntax ........: __TreeListExplorer__PathIsFile($sPath)
; Parameters ....: $sPath               - the path to check.
; Return values .: True if $sPath is a file
; Author ........: Kanashius
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func __TreeListExplorer__PathIsFile($sPath)
	Return FileExists($sPath) And (Not StringInStr(FileGetAttrib($sPath), "D"))
EndFunc

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name ..........: __TreeListExplorer__RelPathIsFolder
; Description ...: Check if the provided relative path is a folder
; Syntax ........: __TreeListExplorer__RelPathIsFolder($iSystem, $sPath)
; Parameters ....: $iSystem             - the system ID.
;                  $sPath               - the path to check.
; Return values .: True if $sPath is a folder
; Author ........: Kanashius
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func __TreeListExplorer__RelPathIsFolder($iSystem, $sPath)
	Return __TreeListExplorer__PathIsFolder($__TreeListExplorer__Data.mSystems[$iSystem].sRoot & $sPath)
EndFunc

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name ..........: __TreeListExplorer__RelPathIsFile
; Description ...: Check if the provided relative path is a file
; Syntax ........: __TreeListExplorer__RelPathIsFile($iSystem, $sPath)
; Parameters ....: $iSystem             - the system ID.
;                  $sPath               - the path to check.
; Return values .: True if $sPath is a folder
; Author ........: Kanashius
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func __TreeListExplorer__RelPathIsFile($iSystem, $sPath)
	Return __TreeListExplorer__PathIsFile($__TreeListExplorer__Data.mSystems[$iSystem].sRoot & $sPath)
EndFunc

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name ..........: __TreeListExplorer__KeyProc
; Description ...: KeyProc message handler
; Syntax ........: __TreeListExplorer__KeyProc($nCode, $wParam, $lParam)
; Parameters ....: $nCode               - the nCode.
;                  $wParam              - wParam.
;                  $lParam              - lParam.
; Return values .: Result of the message processing
; Author ........: Kanashius
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func __TreeListExplorer__KeyProc($nCode, $wParam, $lParam)
	If $nCode < 0 Then Return _WinAPI_CallNextHookEx($__TreeListExplorer__Data.hKeyPrevHook, $nCode, $wParam, $lParam)
	Local $tKEYHOOKS = DllStructCreate($tagKBDLLHOOKSTRUCT, $lParam)
	Local $vkCode = DllStructGetData($tKEYHOOKS, "vkCode")
	Switch $wParam
		Case $WM_KEYUP, $WM_SYSKEYUP
			Local $hGui = WinGetHandle("[active]")
			If MapExists($__TreeListExplorer__Data.mGuis, $hGui) Then
				Local $sControl = ControlGetFocus($hGui)
				Local $hView = ControlGetHandle($hGui, "", $sControl)
				Local $arHwnds = MapKeys($__TreeListExplorer__Data.mViews)
				For $i=0 To UBound($arHwnds)-1 Step 1
					If $arHwnds[$i]<>$hView Then ContinueLoop
					Local $mView = $__TreeListExplorer__Data.mViews[$hView]
					Local $iSystem = $mView.iSystem
					Switch $__TreeListExplorer__Data.mViews[$hView].iType
						Case $__TreeListExplorer__Type_Input
							If $vkCode=13 Then __TreeListExplorer_OpenPath(__TreeListExplorer__GetHandleFromSystemID($iSystem), _GUICtrlEdit_GetText($hView))
						Case $__TreeListExplorer__Type_ListView
							If $vkCode=13 Then
								__TreeListExplorer__ListViewOpenCurrentItem($iSystem, $hView)
							EndIf
					EndSwitch
				Next
			EndIf
	EndSwitch
	Return _WinAPI_CallNextHookEx($__TreeListExplorer__Data.hKeyPrevHook, $nCode, $wParam, $lParam)
EndFunc

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name ..........: __TreeListExplorer__WinProc
; Description ...: WinProc gui message handler
; Syntax ........: __TreeListExplorer__WinProc($hWnd, $iMsg, $iwParam, $ilParam)
; Parameters ....: $hWnd                - the gui handle.
;                  $iMsg                - iMsg.
;                  $iwParam             - iwParam.
;                  $ilParam             - ilParam.
; Return values .: Result of the message processing
; Author ........: Kanashius
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func __TreeListExplorer__WinProc($hWnd, $iMsg, $iwParam, $ilParam)
    If $iMsg=$WM_NOTIFY Then
		Local $hView, $iIDFrom, $iCode, $tNMHDR
		$tNMHDR = DllStructCreate($tagNMHDR, $ilParam)
		$hView = HWnd(DllStructGetData($tNMHDR, "hWndFrom"))
		$iIDFrom = DllStructGetData($tNMHDR, "IDFrom")
		$iCode = DllStructGetData($tNMHDR, "Code")
		Local $arHwnds = MapKeys($__TreeListExplorer__Data.mViews)
		For $i=0 To UBound($arHwnds)-1 Step 1
			If $arHwnds[$i]<>$hView Then ContinueLoop
			Local $mView = $__TreeListExplorer__Data.mViews[$hView]
			Local $iSystem = $mView.iSystem
			Switch $__TreeListExplorer__Data.mViews[$hView].iType
				Case $__TreeListExplorer__Type_TreeView
					Switch $iCode
						Case $TVN_ITEMEXPANDINGA, $TVN_ITEMEXPANDINGW
							Local $tNMTREEVIEW = DllStructCreate($tagNMTREEVIEW, $ilParam)
							Local $hItem = DllStructGetData($tNMTREEVIEW, 'NewhItem')
							If $hItem<>0 Then
								Switch DllStructGetData($tNMTREEVIEW, 'Action')
									Case $TVE_EXPAND
										If Not __TreeListExplorer__IsViewUpdating($hView, $__TreeListExplorer__Status_ExpandTree) Then
											__TreeListExplorer__SetViewUpdating($hView, True, $__TreeListExplorer__Status_ExpandTree)
											Local $sPath = __TreeListExplorer__TreeViewGetRelPath($iSystem, $hView, $hItem)
											__TreeListExplorer__HandleViewCallback($hView, "sCallbackLoading", "$sCallbackLoading", $sPath, True)
											_GUICtrlTreeView_BeginUpdate($hView)
											__TreeListExplorer__ExpandTreeitem($hView, $hItem)
											_GUICtrlTreeView_EndUpdate($hView)
											__TreeListExplorer__HandleViewCallback($hView, "sCallbackLoading", "$sCallbackLoading", $sPath, False)
											__TreeListExplorer__SetViewUpdating($hView, False, $__TreeListExplorer__Status_ExpandTree)
										EndIf
								EndSwitch
							EndIf
						Case $NM_CLICK
							Local $iX =_WinAPI_GetMousePosX(True, $hView)
							Local $iY =_WinAPI_GetMousePosY(True, $hView)
							Local $hItem =_GUICtrlTreeView_HitTestItem($hView, $iX, $iY)
							Local $iHitStat =_GUICtrlTreeView_HitTest($hView, $iX, $iY)
							If $hItem<>0 And (BitAND($iHitStat, 4) Or BitAND($iHitStat, 2)) Then
								Local $sPath = __TreeListExplorer__TreeViewGetRelPath($iSystem, $hView, $hItem)
								__TreeListExplorer__OpenPath($iSystem, $sPath)
								__TreeListExplorer__HandleViewCallback($hView, "sCallbackClick", "$sCallbackOnClick", $hItem)
							EndIf
						Case $NM_DBLCLK
							Local $iX =_WinAPI_GetMousePosX(True, $hView)
							Local $iY =_WinAPI_GetMousePosY(True, $hView)
							Local $hItem =_GUICtrlTreeView_HitTestItem($hView, $iX, $iY)
							Local $iHitStat =_GUICtrlTreeView_HitTest($hView, $iX, $iY)
							If $hItem<>0 And (BitAND($iHitStat, 4) Or BitAND($iHitStat, 2)) Then
								__TreeListExplorer__HandleViewCallback($hView, "sCallbackDBClick", "$sCallbackOnDoubleClick", $hItem)
							EndIf
						Case $TVN_SELCHANGEDA, $TVN_SELCHANGEDW
							Local $tNMTREEVIEW = DllStructCreate($tagNMTREEVIEW, $ilParam)
							Switch DllStructGetData($tNMTREEVIEW, 'Action')
								Case $TVC_BYKEYBOARD
									Local $hItem = _GUICtrlTreeView_GetSelection($hView)
									If $hItem<>0 And Not __TreeListExplorer__IsViewUpdating($hView) Then
										Local $sPath = __TreeListExplorer__TreeViewGetRelPath($iSystem, $hView, $hItem)
										__TreeListExplorer__OpenPath($iSystem, $sPath)
									EndIf
							EndSwitch
					EndSwitch
				Case $__TreeListExplorer__Type_ListView
					Switch $iCode
						Case $NM_CLICK, $LVN_KEYDOWN
							Local $iIndex = _GUICtrlListView_GetSelectionMark($hView)
							Local $bKeyPressed = False
							If $iCode=$LVN_KEYDOWN Then
								Local $tLVKeyDown = DllStructCreate($tagNMLVKEYDOWN, $ilParam)
								Local $iVKey = DllStructGetData($tLVKeyDown, "VKey")
								$bKeyPressed = ($iVKey=40) Or ($iVKey=38) ; Key pressed: UP or DOWN
								If $iIndex<>-1 Then
									If $iVKey=40 Then ; Down
										$iIndex = $iIndex + 1
										If $iIndex>=_GUICtrlListView_GetItemCount($hView) Then $iIndex = -1
									ElseIf $iVKey=38 Then ; Up
										$iIndex = $iIndex - 1
										If $iIndex<0 Then $iIndex=0
									EndIf
								EndIf
							EndIf
							If $bKeyPressed And $iIndex=-1 And _GUICtrlListView_GetItemCount($hView)>0 Then
								$iIndex = 0
								If _GUICtrlListView_GetItemCount($hView)>1 And _GUICtrlListView_GetItemText($hView, 0)=".." Then $iIndex = 1
							EndIf
							If $NM_CLICK Or $bKeyPressed Then
								If $iIndex<>-1 Then
									Local $arPath = __TreeListExplorer__GetPathAndLast(__TreeListExplorer__GetCurrentPath($iSystem) & _GUICtrlListView_GetItemText($hView, $iIndex, 0))
									__TreeListExplorer__OpenPath($iSystem, $arPath[0], $arPath[1])
									__TreeListExplorer__HandleViewCallback($hView, "sCallbackClick", "$sCallbackOnClick", $iIndex)
								EndIf
							EndIf
							If $NM_CLICK Then Return 1 ; required, otherwise some events are sent, where the icon index is the event id => random GuiGetMsg events triggered
						Case $NM_DBLCLK
							__TreeListExplorer__ListViewOpenCurrentItem($iSystem, $hView)
							Local $iIndex = _GUICtrlListView_GetSelectionMark($hView)
							If $iIndex<>-1 Then __TreeListExplorer__HandleViewCallback($hView, "sCallbackDBClick", "$sCallbackOnDoubleClick", $iIndex)
					EndSwitch
			EndSwitch
			ExitLoop
		Next
	EndIf
	If MapExists($__TreeListExplorer__Data.mGuis, $hWnd) Then Return _WinAPI_CallWindowProc($__TreeListExplorer__Data.mGuis[$hWnd].hPrevProc, $hWnd, $iMsg, $iwParam, $ilParam)
EndFunc

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name ..........: __TreeListExplorer__ListViewOpenCurrentItem
; Description ...: Get the selected item in the listview and open the folder (go back if it is ".."). Files are ignored.
; Syntax ........: __TreeListExplorer__ListViewOpenCurrentItem($iSystem, $hView)
; Parameters ....: $iSystem             - an integer value.
;                  $hView               - a handle value.
; Return values .: None
; Author ........: Kanashius
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func __TreeListExplorer__ListViewOpenCurrentItem($iSystem, $hView)
	Local $iIndex = _GUICtrlListView_GetSelectionMark($hView)
	If $iIndex=0 And _GUICtrlListView_GetItemText($hView, $iIndex, 0) = ".." Then
		Local $sPath = __TreeListExplorer__GetCurrentPath($iSystem)
		If $sPath <> "" Then
			$sPath = __TreeListExplorer__RemoveLastFolderFromPath($sPath)
			__TreeListExplorer__OpenPath($iSystem, $sPath)
		EndIf
	ElseIf $iIndex<>-1 Then
		Local $sPath = __TreeListExplorer__GetCurrentPath($iSystem) & _GUICtrlListView_GetItemText($hView, $iIndex, 0)
		__TreeListExplorer__OpenPath($iSystem, $sPath)
	EndIf
EndFunc

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name ..........: __TreeListExplorer__HandleViewCallback
; Description ...:Handle callbacks attached to a view
; Syntax ........: __TreeListExplorer__HandleViewCallback($hView, $sFunc, $sVarName[, $param1 = Default[, $param2 = Default[,
;                  $param3 = Default[, $param4 = Default[, $param5 = Default[, $param6 = Default[, $param7 = Default]]]]]]])
; Parameters ....: $hView               - the view handle.
;                  $sCallbackName       - the name of the function variable in the $mView map.
;                  $sVarName            - the variable name given to __TreeListExplorer_CreateSystem.
;                  $param1              - [optional] additional parameter to pass to the callback. Default is None.
;                  $param2              - [optional] additional parameter to pass to the callback. Default is None.
;                  $param3              - [optional] additional parameter to pass to the callback. Default is None.
;                  $param4              - [optional] additional parameter to pass to the callback. Default is None.
;                  $param5              - [optional] additional parameter to pass to the callback. Default is None.
;                  $param6              - [optional] additional parameter to pass to the callback. Default is None.
;                  $param7              - [optional] additional parameter to pass to the callback. Default is None.
; Return values .: None
; Author ........: Kanashius
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func __TreeListExplorer__HandleViewCallback($hView, $sCallbackName, $sVarName, $param1=Default, $param2=Default, $param3=Default, $param4=Default, $param5=Default, $param6=Default, $param7=Default)
	Local $mView = $__TreeListExplorer__Data.mViews[$hView]
	If $mView[$sCallbackName]<>Default Then
		Local $iSystem = $mView.iSystem
		Local $arParams[@NumParams-3+6]
		$arParams[0] = "CallArgArray"
		$arParams[1] = __TreeListExplorer__GetHandleFromSystemID($iSystem)
		$arParams[2] = $hView
		$arParams[3] = __TreeListExplorer__GetCurrentRoot($iSystem)
		$arParams[4] = __TreeListExplorer__GetCurrentPath($iSystem)
		$arParams[5] = __TreeListExplorer__GetSelected($iSystem)
		For $i=1 To @NumParams-3 Step 1
			$arParams[5+$i] = Eval("param"&$i)
		Next
		Call($mView[$sCallbackName], $arParams)
		If @error = 0xDEAD And @extended = 0xBEEF Then __TreeListExplorer__ConsoleWriteCallbackError($mView[$sCallbackName], $sVarName, $mView.iLineNumber)
	EndIf
EndFunc

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name ..........: __TreeListExplorer__HandleSystemCallback
; Description ...: Handle callbacks attached to a TLE system
; Syntax ........: __TreeListExplorer__HandleSystemCallback($iSystem, $sFunc, $sVarName[, $param1 = Default[, $param2 = Default[,
;                  $param3 = Default[, $param4 = Default[, $param5 = Default[, $param6 = Default[, $param7 = Default]]]]]]])
; Parameters ....: $iSystem             - the TLE system ID.
;                  $sFunc               - the name of the function variable in the $mSystem map.
;                  $sVarName            - the variable name given to __TreeListExplorer_CreateSystem.
;                  $param1              - [optional] additional parameter to pass to the callback. Default is None.
;                  $param2              - [optional] additional parameter to pass to the callback. Default is None.
;                  $param3              - [optional] additional parameter to pass to the callback. Default is None.
;                  $param4              - [optional] additional parameter to pass to the callback. Default is None.
;                  $param5              - [optional] additional parameter to pass to the callback. Default is None.
;                  $param6              - [optional] additional parameter to pass to the callback. Default is None.
;                  $param7              - [optional] additional parameter to pass to the callback. Default is None.
; Return values .: None
; Author ........: Kanashius
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func __TreeListExplorer__HandleSystemCallback($iSystem, $sCallbackName, $sVarName, $param1=Default, $param2=Default, $param3=Default, $param4=Default, $param5=Default, $param6=Default, $param7=Default)
	Local $iNumParams = @NumParams, $bCallbackSplit = False
	If $sCallbackName="sCallbackSelect" And @NumParams>3 Then
		$bCallbackSplit = True
		$iNumParams = 3
		$param1 = Default
	EndIf
	Local $mSystem = $__TreeListExplorer__Data.mSystems[$iSystem]
	If $mSystem[$sCallbackName]<>Default Then
		Local $arParams[$iNumParams-3+5]
		$arParams[0] = "CallArgArray"
		$arParams[1] = __TreeListExplorer__GetHandleFromSystemID($iSystem)
		$arParams[2] = __TreeListExplorer__GetCurrentRoot($iSystem)
		$arParams[3] = __TreeListExplorer__GetCurrentPath($iSystem)
		$arParams[4] = __TreeListExplorer__GetSelected($iSystem)
		If $bCallbackSplit Then
			Local $arPath = __TreeListExplorer__GetPathAndLast(__TreeListExplorer__GetCurrentPath($iSystem) & __TreeListExplorer__GetSelected($iSystem))
			$arParams[3] = $arPath[0]
			$arParams[4] = $arPath[1]
		EndIf
		For $i=1 To $iNumParams-3 Step 1
			$arParams[4+$i] = Eval("param"&$i)
		Next
		Call($mSystem[$sCallbackName], $arParams)
		If @error = 0xDEAD And @extended = 0xBEEF Then __TreeListExplorer__ConsoleWriteCallbackError($mSystem[$sCallbackName], $sVarName, $mSystem.iLineNumber, "__TreeListExplorer_CreateSystem")
	EndIf
EndFunc

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name ..........: __TreeListExplorer__GetPathAndLast
; Description ...: Split the given path in the parent folder and the last file/folder part
; Syntax ........: __TreeListExplorer__GetPathAndLast($iSystem, $sPath)
; Parameters ....: $sPath               - the path as string.
; Return values .: Array with $ar[0] = First part and $ar[1] = last folder/file
; Author ........: Kanashius
; Modified ......:
; Remarks .......: May fail, if the RegExp could not parse the path to split it. Then it returns ["", ""].
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func __TreeListExplorer__GetPathAndLast($sPath)
	Local $arFolder = StringRegExp($sPath, "^(.*?\\?)([^\\]*?)\\?$", 3) ; split path and last file/folder
	If @error Or UBound($arFolder)<>2 Then
		Local $arResult = ["", ""]
		Return $arResult
	EndIf
	Return $arFolder
EndFunc

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name ..........: __TreeListExplorer__ConsoleWriteCallbackError
; Description ...: Write an error to the console, providing information about a wrong callback function
; Syntax ........: __TreeListExplorer__ConsoleWriteCallbackError($sFunc, $sVarName, $iLineNumber[, $sLineFunc = "__TreeListExplorer_AddView"])
; Parameters ....: $sFunc               - the function that should be called.
;                  $sVarName            - the parameter name, where the function was provided to the UDF.
;                  $iLineNumber         - the line number, where the function was provided to the UDF.
;                  $sLineFunc           - [optional] the function name, of the function, where the callback function was provided
;                                         to the UDF. Default is "__TreeListExplorer_AddView".
; Return values .: None
; Author ........: Kanashius
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func __TreeListExplorer__ConsoleWriteCallbackError($sFunc, $sVarName, $iLineNumber, $sLineFunc = "__TreeListExplorer_AddView")
	ConsoleWrite('Error calling callback function "'&$sFunc&'" provided as '&$sVarName&' to "'&$sLineFunc&'" in Line: '&$iLineNumber& _
	". The function probably has the wrong number of parameters."&@crlf)
EndFunc

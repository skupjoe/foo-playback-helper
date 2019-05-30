#Include, %A_ScriptDir%\lib\func.ahk

#MaxHotkeysPerInterval 500
#WinActivateForce
#InstallKeybdHook
#NoEnv

Global old_dir := "Z:\scrap"
Global temp_dir_0 := "Z:\temp0"
Global temp_dir_1 := "Z:\temp1\_" ; pattern for your genre folders (eg. "Z:\temp1\_rock")
Global B_Toggle := 1


; Speed triggers 0-9. Must be at top.
loop, 10
{
    Hotkey, % "~^" A_Index-1, Trigger_a
    Hotkey, % "~^Numpad" A_Index-1, Trigger_b
}

Trigger_a:
Trigger_b:
    i := SubStr(A_ThisHotkey, 0, 1)
    Toggle%i% := !Toggle%i%
    if (i or (i == 0))
    {
        if (Toggle%i%)
        {
            loop, 10
                if (A_Index != i)
                    SetTimer, Speed%i%, Off
            SetTimer, Speed%i%, 200
            msgbox, , , % "Speed " i " : On", 2
        }
        else
        {
            SetTimer, % "Speed" . i, Off
            msgbox, , , % "Speed " i " : Off", 1
        }
    }
    return

~^Del::
~^End::
~^Home::
~^Space::
~Media_Stop::
~Media_Play_Pause::
    Gosub, DisableSpeed
    return

; Scroll pause
~WheelUp::
~WheelDown::
    Global time_scrl := A_TickCount
    return

; Pause the loop for blacklisted titles
~^!b::
    B_Toggle := !B_Toggle
    if B_Toggle
        msgbox, , , % "Blacklist : On", 1
    else
        msgbox, , , % "Blacklist : Off", 1
    return

; Move album
~^!m::
    GetSongInfo(name,, p_dir)
    if (name == "foobar2000") {
        Send {CtrlDown} {Home} {CtrlUp}
        Sleep, 3500
        GetSongInfo(name)
        if (name == "foobar2000") {
            msgbox, , , % "Foorbar2000 must be playing for move album to work!", 2
            Exit
        }
    }
    LoopGenres(genres)
    Gosub, DisableSpeed
    Sleep, 1000
    Send {CtrlDown} {End} {CtrlUp}
    Sleep, 1000
    Send {CtrlDown} {AltDown} {o} {AltUp} {CtrlUp}
    Sleep, 2000
    Gosub, GenreGui
    return

; --- Gui Subroutines -------------

GenreGui:
    Gui -MaximizeBox -MinimizeBox
    Gui, Add, Edit, W150 R1 vSearchFor gSearch
    Gui, Add, DropDownList, W150 H250 Sort vChosen, % "none||" genres
    Gui, Add, Button, default gGo, Go
    Gui, Show, AutoSize, Select Genre
    return

Search:
    Gui, Submit, NoHide
    GuiControl, ChooseString, Chosen, %SearchFor%
    SearchFor := {}
    return

Go:
    Gui, Submit, NoHide
    Gui, Destroy
    msgbox, 1, Confirm Genre, % "Genre: " chosen,
    IfMsgBox, Cancel
        Exit
    Gosub, GoSeq
    return

GoSeq:
    dest := GetGenreFolder(Chosen)
    RunWait, %A_AhkPath% "%A_ScriptDir%\script\move_files.ahk" "%p_dir%" "%dest%" "%old_dir%" "%temp_dir_0%"
    Sleep, 5000
    Send {CtrlDown} {ShiftDown} {Space} {ShiftUp} {CtrlUp}
    Sleep, 2500
    Send {CtrlDown} {Home} {CtrlUp}
    return

GuiClose:
    Gui, Destroy
    Exit

; --- Subroutines -----------------

Speed0:
    CheckBlacklist()
    if (Toggle0)
        AND isPlaying() AND !(endSec() < 55)
        AND !kbActive() AND !scrollActive()
    {
        Send, {CtrlDown}{ShiftDown}{Right}{CtrlUp}{ShiftUp}
        Sleep, 10000
    }
    return

Speed1:
    CheckBlacklist()
    if (Toggle1)
        AND isPlaying() AND !(endSec() < 85)
        AND !kbActive() AND !scrollActive()
    {
        Send, {CtrlDown}{ShiftDown}{Up}{CtrlUp}{ShiftUp}
        Sleep, 6000
    }
    return

Speed2:
    CheckBlacklist()
    if (Toggle2)
        AND isPlaying() AND !(endSec() < 85)
        AND !kbActive() AND !scrollActive()
    {
        Send, {CtrlDown}{ShiftDown}{Up}{CtrlUp}{ShiftUp}
        Sleep, 3000
    }
    return

DisableSpeed:
    for i in range(0, 3) 
    {
        Toggle%i% := 0
        SetTimer, Speed%i%, Off
    }
    msgbox, , , % "Speed : Off", 1
    return

; --- Functions -------------------

WinGetAll(InType:="", In:="", OutType:="") {
    WinGet, wParam, List
    Window := {}
    loop %wParam% {
        Counta += 1
        WinGetTitle, WinName%A_Index%, % "ahk_id " wParam%A_Index%
        WinGet, Proc%A_index%, ProcessName, % "ahk_id " wParam%A_Index%
        Window[ Counta , "Name" ]	:= WinName%A_index%
        Window[ Counta , "Proc" ]	:= Proc%A_Index%
        if (WinName%A_index% = "") OR (WinName%A_Index% = "Start")
            OR (WinName%A_Index% = "Program Manager")
            continue
        if (InType) AND (In) AND (OutType)
            if (Window[A_index, InType] = In)
            return % Window[a_index, OutType]
    }
    if (InType) AND (In) AND (OutType)
        return "Error, InType, or in not found."
    return % Window
}

GetSongInfo(ByRef name, ByRef time:="", ByRef p_dir_nosp:="") {
    name := WinGetAll("Proc", "foobar2000.exe", "Name")
    name_a := StrSplit(name, "` -:- ")
    title_a := StrSplit(name_a[1], A_Space)
    time := SubStr(title_a[title_a.MaxIndex()], 2, StrLen(title_a[title_a.MaxIndex()])-2)
    path := name_a[2]
    p_dir := GetParentDir(path)
    p_dir_nosp := StrReplace(p_dir, A_Space, "\\\")
    return
}

endSec() {
    ctr := 0
    GetSongInfo(name, time)
    time_a := StrSplit(time, "`/")
    time_curr_a := StrSplit(time_a[1], "`:")
    time_end_a := StrSplit(time_a[2], "`:")
    time_curr_sec := (60*time_curr_a[1]+time_curr_a[2])
    time_end_sec := (60*time_end_a[1]+time_end_a[2])
    while (time_end_sec == "" OR time_curr_sec == "") {
        ctr++
        GetSongInfo(name, time)
        msgbox, , , % "Cannot get time!", 1
        Sleep, 5500
        if (ctr == 5) {
            msgbox, , , % "Time has remained empty. Exiting!", 2
            Gosub DisableSpeed
            return 0
        }
    }
    return (time_end_sec - time_curr_sec)
}

LoopGenres(ByRef genres) {
    genres := {}
    Loop, Files, % temp_dir_1 . "*", D
    if A_LoopFileAttrib contains D
        if SubStr(A_LoopFileName, 1, 1) = "_"
        genres .= SubStr(A_LoopFileName, 2) . "|"
    return
}

GetGenreFolder(genre) {
    if (genre == "") {
        msgbox, , , % "No genre specified!", 2
        return 0
    }
    return temp_dir_1 . genre
}

CheckBlacklist() {
    blacklist := ["vmware", "notepad++"]
    WinGetActiveTitle, title_win
    if B_Toggle {
        for i, v in blacklist {
            if (title_win == "vmware") {
                sleep, 2000
                WinGetActiveTitle, title_win ; Refresh
                return
            }
            while inStr(title_win, v, 0) {
                Pause, On, 1
                Sleep, 2000
                Pause, Off, 1
                WinGetActiveTitle, title_win ; Refresh
            }
        }
    }
    return
}

isPlaying() {
    ctr := 0
    GetSongInfo(name)
    while (name == "foobar2000") {
        ctr++
        GetSongInfo(name)
        Sleep, 5500
        if (ctr not in 1,2)
            msgbox, , , % "Foobar2000 is not playing!", 1
        if (ctr == 5) {
            msgbox, , , % "Foobar2000 is still not playing. Exiting!", 2
            Gosub DisableSpeed
            return 0
        }
    }
    return 1
}

scrollActive() {
    if time_scrl {
        time_elapsed := A_TickCount - time_scrl
        if (time_elapsed < 2000) 
            return 1
    }
    return 0
}

kbActive() {
    if (A_TimeIdleKeyboard < 2000)
        return 1
    return 0
}


F9::Reload
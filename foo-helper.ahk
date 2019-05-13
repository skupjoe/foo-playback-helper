#WinActivateForce
#InstallKeybdHook
#NoEnv

Global bToggle := 1
Global Toggle0
Global Toggle1
Global Toggle2
Global name
Global path
Global title
Global time
Global curr_timeSec
Global end_timeSec

; For testing
~^!i::
GetSongInfo()
msgbox, , , % "Name is " name, 3
return

~^Del::
~^End::
~^Home::
~^Space::
~Media_Stop::
~Media_Play_Pause::
Gosub, disableSpeed
return

; Scroll pause
~WheelUp::
~WheelDown::
Pause, On, 1
Sleep, 2000
Pause, Off, 1
return

; Implement feature for when song gets deleted
; (In-progress)
~^+a::
return

; Pause the loop for blacklisted titles
~^!b::
bToggle := !bToggle
if bToggle
    msgbox, , , % "Blacklist Toggle : On", 1
else
    msgbox, , , % "Blacklist Toggle : Off", 1
return

; Escape the blacklist when VMware escape seq is hit
; (In-progress)
~^+LAlt::
~^!LShift::
~+!LCtrl::
return

~^0::
~^Numpad0::
Toggle0 := !Toggle0
if Toggle1 {
    Toggle1 := !Toggle1
}
if Toggle0 {
    SetTimer, Speed0, 200
    msgbox, , , % "Speed 0 : On", 2
}
else {
    SetTimer, Speed0, Off
    SetTimer, Speed1, Off
    msgbox, , , % "Speed 0 : Off", 2
}
return

~^1::
~^Numpad1::
Toggle1 := !Toggle1 
if Toggle0 {
    Toggle0 := !Toggle0
}
if Toggle1 {
    SetTimer, Speed1, 200
    msgbox, , , % "Speed 1 : On", 1
}
else {
    SetTimer, Speed0, Off
    SetTimer, Speed1, Off
    msgbox, , , % "Speed 1 : Off", 1
}
return

~^2::
~^Numpad2::
Toggle2 := !Toggle2
if Toggle0 {
    Toggle0 := !Toggle0
}
if Toggle1 {
    Toggle1 := !Toggle1
}
if Toggle2 {
    SetTimer, Speed1, 200
    msgbox, , , % "Speed 2 : On", 1
}
else {
    SetTimer, Speed0, Off
    SetTimer, Speed1, Off
    msgbox, , , % "Speed 2 : Off", 1
}
return

; ############   Subroutines    ############

Speed0:
CheckBlacklist()
if Toggle0
    AND isPlaying() AND !(EndSec() < 55)
    AND !kbActive() {
    Send, {Ctrl down}{Shift down}{Right}{Ctrl up}{Shift up}
    Sleep, 10000
}
return

Speed1:
CheckBlacklist()
if Toggle1
    AND isPlaying() AND !(EndSec() < 85)
    AND !kbActive() {
    Send, {Ctrl down}{Shift down}{Up}{Ctrl up}{Shift up}
    Sleep, 6000
}
return

Speed2:
CheckBlacklist()
if Toggle1
    AND isPlaying() AND !(EndSec() < 85)
    AND !kbActive() {
    Send, {Ctrl down}{Shift down}{Up}{Ctrl up}{Shift up}
    Sleep, 6000
}
return

disableSpeed:
Toggle0 := 0
Toggle1 := 0
SetTimer, Speed0, Off
SetTimer, Speed1, Off
msgbox, , , % "Speed : Off", 1
exit

; ############   Functions    ############

WinGetAll(InType = "", In = "", OutType = "") {
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

GetSongInfo() {
    name := WinGetAll("Proc", "foobar2000.exe", "Name")
    name_a := StrSplit(name, "` -:- ")
    title_a := StrSplit(name_a[1], A_Space)
    time := SubStr(title_a[title_a.MaxIndex()], 2, StrLen(title_a[title_a.MaxIndex()])-2)
    time_a := StrSplit(time, "`/")
    curr_a := StrSplit(time_a[1], "`:")
    end_a := StrSplit(time_a[2], "`:")
    curr_timeSec := (60*curr_a[1]+curr_a[2])
    end_timeSec := (60*end_a[1]+end_a[2])
    path := name_a[2]
}

CheckBlacklist() {
    blacklist := ["vmware", "notepad++"]
    WinGetActiveTitle, currWinTitle
    if bToggle {
        for i, v in blacklist {
            if (currWinTitle == "vmware") {
                sleep, 2000
                ; Refresh active title 
                WinGetActiveTitle, currWinTitle ; Refresh
                return
            }
            while inStr(currWinTitle, v, 0) {
                Pause, On, 1
                Sleep, 2000
                Pause, Off, 1
                ; Refresh active title
                WinGetActiveTitle, currWinTitle ; Refresh
            }
        }
    }
    return
}

EndSec() {
    ctr := 0
    GetSongInfo()
    while (end_timeSec == "" OR curr_timeSec == "") {
        ctr++
        GetSongInfo()
        msgbox, , , % "Cannot get time!", 1
        Sleep, 5500
        if (ctr == 5) {
            msgbox, , , % "Time has remained empty. Exiting!", 2
            Gosub disableSpeed
            return 0
        }
    }
    return (end_timeSec - curr_timeSec)
}

isPlaying() {
    ctr := 0
    GetSongInfo()
    while (name == "foobar2000") {
        ctr++
        GetSongInfo()
        Sleep, 5500
        if (ctr not in 1,2)
            msgbox, , , % "Foobar2000 is not playing!", 1
        if (ctr == 5) {
            msgbox, , , % "Foobar2000 is still not playing. Exiting!", 2
            Gosub disableSpeed
            return 0
        }
    }
    return 1
}

kbActive() {
    if (A_TimeIdleKeyboard < 3000)
        return 1
    return 0
}

; If name has "[Skit, Intro, Outro, Interlude, Acapella]" deliver notification
; (In-progress)
isSkitIntro ()
    return 

F9::Reload
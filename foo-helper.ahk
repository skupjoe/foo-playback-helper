#InstallKeybdHook
#NoEnv

; SuperGlobals 
Global bToggle := 1
Global Toggle0
Global Toggle1
Global name
Global title
Global time
Global curr_timeSec
Global end_timeSec

;####   Triggers    ####

~^!i::
  return

~^Del::
~^End::
~^Home::
~^Space::
~Media_Stop::
~Media_Play_Pause::
  Gosub, disableSpeed
  return

; Escape blacklist VMware escape seq is hit (in-progress)
~^+LAlt::
~^!LShift::
~+!LCtrl::
  msgbox, , , % "Whoa", 1
  return

~^+a::
  return
  
~^!b::
  bToggle := !bToggle
  if bToggle
    msgbox, , , % "Blacklist Toggle : On", 1
  else
    msgbox, , , % "Blacklist Toggle : Off", 1    
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

; ####   Subroutines    ####

Speed0:
  checkBlacklist()
  if Toggle0 AND !kbActive() AND isPlaying() AND !(endSec() < 55) {
    Send, {Ctrl down}{Shift down}{Right}{Ctrl up}{Shift up}
    Sleep, 10000
  }
  return
  
Speed1:
  checkBlacklist()
  if Toggle1 AND !kbActive() AND isPlaying() AND !(endSec() < 85) {
    Send, {Ctrl down}{Shift down}{Up}{Ctrl up}{Shift up}
    Sleep, 6000
  }
  return

Speed2:
  checkBlacklist()
  if Toggle2 AND !kbActive() AND isPlaying() AND !(endSec() < 85) {
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
  ;retrurn
  exit
	
; ####   Functions    ####

test() {
}

testSpeed() {
; test if speed is enabled
if (Toggle0 == 1 OR Toggle1 == 1 OR Toggle2 == 1)
  msgbox, , , % "Speed is On", 2
else
  ;Toggle0 := 0; Toggle1 := 0
  msgbox, , , % "Speed is Off.", 2
}

WinGetAll(InType = "", In = "", OutType = "") {
  WinGet, wParam, List
  Window := {}
  loop %wParam% {
      Counta += 1
      WinGetTitle, WinName%A_Index%, % "ahk_id " wParam%A_Index%
      WinGet, Proc%A_index%, ProcessName, % "ahk_id " wParam%A_Index%
      Window[ Counta , "Name" ]	:= WinName%A_index%
      Window[ Counta , "Proc" ]	:= Proc%A_Index%
      if (WinName%A_index% = "") OR (WinName%A_Index% = "Start") OR (WinName%A_Index% = "Program Manager")
        continue
      if (InType) AND (In) AND (OutType)
        if (Window[A_index, InType] = In)
          return % Window[a_index, OutType]
    }
    if (InType) AND (In) AND (OutType)
      return "Error, InType, or in not found."
  return % Window
}

getSongInfo() {
  name := WinGetAll("Proc", "foobar2000.exe", "Name")
  name_a := StrSplit(name, A_Space)
  For i in name_a
    title .= name_a[A_Index] . " "
  Until A_Index == (name_a.MaxIndex() - 1)
  time := SubStr(name_a[name_a.MaxIndex()], 2, StrLen(name_a[name_a.MaxIndex()])-2)
  time_a := StrSplit(time, "`/")
  curr_a := StrSplit(time_a[1], "`:")
  end_a := StrSplit(time_a[2], "`:")
  curr_timeSec := (60*curr_a[1]+curr_a[2])
  end_timeSec := (60*end_a[1]+end_a[2])
}

; Pause the loop if any of these process titles are running in the foreground
checkBlacklist() {
  blacklist := ["vmware", "notepad++"]
  WinGetActiveTitle, currWinTitle
    if bToggle {
      for i, v in blacklist {
        ;/*
        if (currWinTitle == "vmware") {
          ;send {Ctrl Alt Shift}
          ;send {Ctrl} {Alt} {Shift}
          ;send {Ctrl} {Alt}
          ;Send, {Ctrl down}{Alt down}{Shift down}{Ctrl up}{Alt up}{Shift up}
          Send {Ctrl down}
          Send {Alt down}
          Send {Ctrl up} {Alt up}
          ;Send ^!+
          sleep, 2000
          ; Refresh active title 
          WinGetActiveTitle, currWinTitle
          return
        }
        ;*/
        while inStr(currWinTitle, v, 0) {
          Pause, On, 1
          ;msgbox, , , % "Current window is blacklisted!", 1
          Sleep, 2000
          Pause, Off, 1
          ; Refresh active title
          WinGetActiveTitle, currWinTitle
        }
      }
    }
  return
}

isPlaying() {
  ctr := 0
  getSongInfo()
  while (name == "foobar2000") AND !kbActive() {
    ctr++
    getSongInfo()
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

endSec() {
  ctr := 0
  getSongInfo()
  while (end_timeSec == "" OR curr_timeSec == "") AND !kbActive() {
    ctr++
    getSongInfo()
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

; If name has "[Skit, Intro, Outro, Interlude, Acapella]" in it, notify (in-progress)
isSkitIntro ()
  return 

kbActive() {
  ; https://autohotkey.com/docs/Variables.htm#TimeIdle
  if (A_TimeIdleKeyboard < 3000)
    return 1
  return 0
}


F9::Reload
#SingleInstance, Force
#Include, %A_ScriptDir%\..\class\CircleProgressClass.ahk
#Include, %A_ScriptDir%\..\lib\Gdip.ahk
#Include, %A_ScriptDir%\..\lib\func.ahk

global InDir = FixSpaces(A_Args[1])
global OutDir = FixSpaces(A_Args[2])
global OldDir = FixSpaces(A_Args[3])
global ParentDir = FixSpaces(A_Args[4])

if (A_Args.MaxIndex() != 3) AND (A_Args.MaxIndex() != 4)
{
	MsgBox, Invalid number of arguments!
	ExitApp
}

CheckDirs() {
	IfNOTExist, %InDir%
		ErrorLevel = 1
	IfNOTExist, %OutDir%
		FileCreateDir, %OutDir%
	IfNOTExist, %OldDir%
		FileCreateDir, %OldDir%
	if (ErrorLevel)
	{
		UpdateCircle("Dir is not valid.")
		ExitApp
	}
	return
}

Move(index, Src, Des) {
	global
	FileSize := File%index%Size
	Total += FileSize
	CircleProgress.Update(((index * 100) / Count), "Index: " index "`r`nFilesize:" Filesize "kb`r`nTotal: " Total "kb")
	try {
		FileMove, %Src%, %Des%
	} catch e {
		MsgBox, FileMoveError :: %e%
		ExitApp
	}
	return
}

UpdateCircle(msg) {
	global
	loop 3
		if (A_index = 1)
			loop 255
				CircleProgress.Update(100, msg)
		else if (A_index = 2)
			loop 255
				CircleProgress.Update(100, msg, (255 - A_index))
		else if (A_index = 3)
			return
}

main() {
	global
	ExtList := "mp3,flac,m4a,ogg,jpg,jpeg,png,bmp,bin,exe"
	SetWorkingDir, %InDir%
	SysGet, VirtualWidth, 78
	SysGet, VirtualHeight, 79

	CircleProgress := new CircleProgressClass({x: VirtualWidth-200, y: VirtualHeight-220, TextStyle: "Bold", BarThickness: 10, BarDiameter: 140})
	CircleProgress.Update(0, setting environment)

	CheckDirs()

	; Scan for matches & create File pseudo-array
	Loop, Files, *, R
	{
		if A_LoopFileExt in %ExtList%
		{
			Count+=1
			CircleProgress.Update(0, "Gathering Information..`r`nCount: " Count)
			FileGetSize, File%Count%Size, %A_LoopFileFullPath%, K
			File%Count%Name := A_LoopFileName
			File%Count%Dir := A_LoopFileLongPath
			File%Count% := A_LoopFileFullPath
			if ParentDir !=
				File%Count%ParentDir := GetParentDir(A_LoopFileLongPath)
				File%Count%Parent := StrReplace(File%Count%ParentDir, ParentDir . "\")
		}
	}

	; Process files
	if (Count)
	{
		; Add destination to File pseudo-array
		Loop, %Count%
		{
			CircleProgress.Update(0, "Checking destinations.." A_Index)
			n := File%A_Index%Name
			d := File%A_Index%Parent
			IfNOTExist, %OutDir%\%d%\%n% 
				File%A_Index%Des = %OutDir%\%d%\%n%
			else
			{
				t := A_Index
				i = 1
				loop
					IfNOTExist, %OutDir%\%d%\%i%-%n%
					{
						File%t%Des = %OutDir%\%d%\%i%-%n%
						break
					}
					else
						i++
			}
		}
		; Create missing directories
		loop %Count%
		{
			d := File%A_Index%Parent
			out := OutDir . "\" . d
			old := OldDir . "\" . d
			if !(InStr(FileExist(out), "D"))
			{
				CircleProgress.Update(((A_index * 100) / Count), "Creating required`n`ndirectories.." )
				FileCreateDir, %out%
			}
			; Move files
			Move(A_Index, File%A_index%, File%A_Index%Des)
		}
		if (IsEmpty(ParentDir . "\" . d))
		{
			CircleProgress.Update(((A_index * 100) / Count), "Removing empty directories.." )
			try {
				FileRemoveDir, %ParentDir%\%d%, 1 ; Bug: Must use recurse even non-empty
			} catch e {
				MsgBox, FileRemoveDirError :: %e%
			}
		}
		else
		{
			try {
				CircleProgress.Update(((A_index * 100) / Count), "Moving leftovers.." )
				FileMoveDir, %ParentDir%\%d%, %old%, 2
			} catch e {
				MsgBox, FileMoveDirError :: %e%
			}
		 }
	}
	else
	{
		UpdateCircle("No files to move!")
		ExitApp
	}

	sleep 100
	ControlSend,, {F5}, ahk_class Progman
	ExitApp
}

main()
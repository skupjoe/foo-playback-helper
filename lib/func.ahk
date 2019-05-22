; General functions for import

FixSpaces(Str) {
	if (InStr(Str, "\\\"))
		Str := StrReplace(Str, "\\\", A_Space)
	Return Str
}

IsEmpty(Dir) {
	Loop, Files, %Dir%\*.*, FR
      return 0
    return 1
}

GetParentDir(Path, Count=1, Delimiter="\") {
	while (InStr(Path, Delimiter) <> 0 && Count <> A_Index - 1)
		Path := SubStr(Path, 1, InStr(Path, Delimiter, 0, 0) - 1)
	return Path
}
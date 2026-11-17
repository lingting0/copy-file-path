' CopyFilePath.vbs - silent launcher for the "Copy file path" context menu.
' wscript.exe is a GUI-subsystem host, so Explorer will not flash a console window.
' The path is passed to PowerShell through process environment variables, so
' the command line contains no paths at all: %, quotes, ampersands, spaces and
' non-ASCII characters are never reinterpreted. No Base64/MSXML dependency.

Option Explicit

If WScript.Arguments.Count < 1 Then
    WScript.Quit 1
End If

Dim targetPath
targetPath = WScript.Arguments(0)

Dim scriptDir
scriptDir = Left(WScript.ScriptFullName, InStrRev(WScript.ScriptFullName, "\") - 1)

Dim fso
Set fso = CreateObject("Scripting.FileSystemObject")
Dim psScript
psScript = fso.BuildPath(scriptDir, "CopyFilePath.ps1")

If Not fso.FileExists(psScript) Then
    WScript.Quit 2
End If

Dim shell
Set shell = CreateObject("WScript.Shell")

' Environment values are UTF-16: immune to % expansion and command-line parsing.
shell.Environment("PROCESS")("WB_CFP_TARGET") = targetPath
shell.Environment("PROCESS")("WB_CFP_SCRIPT") = psScript

' Static command line - no path text appears here.
Dim cmdLine
cmdLine = "powershell.exe -NoProfile -NonInteractive -WindowStyle Hidden -ExecutionPolicy Bypass -Command ""& ([Environment]::GetEnvironmentVariable('WB_CFP_SCRIPT'))"""

WScript.Quit shell.Run(cmdLine, 0, True)

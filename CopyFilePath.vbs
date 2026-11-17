' CopyFilePath.vbs - silent launcher for the "Copy file path" context menu.
' wscript.exe is a GUI-subsystem host, so Explorer will not flash a console window.

Option Explicit

If WScript.Arguments.Count < 1 Then
    WScript.Quit 1
End If

Dim targetPath
targetPath = WScript.Arguments(0)

Dim scriptDir
scriptDir = Left(WScript.ScriptFullName, InStrRev(WScript.ScriptFullName, "\") - 1)

Dim psScript, cmdLine
psScript = scriptDir & "CopyFilePath.ps1"

cmdLine = "powershell.exe -NoProfile -NonInteractive -WindowStyle Hidden -ExecutionPolicy Bypass -File """ & psScript & """ """ & targetPath & """"

Dim shell
Set shell = CreateObject("WScript.Shell")
shell.Run cmdLine, 0, True

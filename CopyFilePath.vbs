' CopyFilePath.vbs - silent launcher for the "Copy file path" context menu.
' wscript.exe is a GUI-subsystem host, so Explorer will not flash a console window.
' The target path is Base64-encoded and the whole PowerShell command is sent via
' -EncodedCommand, so %, quotes, spaces and non-ASCII characters are never
' reinterpreted by WScript.Shell.Run's variable expansion.

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

' Base64 (UTF-8) of the original path - keeps every character intact.
Dim encPath
encPath = BytesToBase64(Utf8Bytes(targetPath))

' Inside single quotes PowerShell treats % and $ as literal characters.
Dim psCmd
psCmd = "& '" & Replace(psScript, "'", "''") & "' -EncodedPath '" & encPath & "'"

' Base64 (UTF-16LE, no BOM) of the command for -EncodedCommand.
Dim encCmd
encCmd = BytesToBase64(Utf16LeBytes(psCmd))

Dim cmdLine
cmdLine = "powershell.exe -NoProfile -NonInteractive -WindowStyle Hidden -ExecutionPolicy Bypass -EncodedCommand " & encCmd

Dim shell
Set shell = CreateObject("WScript.Shell")
WScript.Quit shell.Run(cmdLine, 0, True)

' ---------- helper functions ----------

Function Utf8Bytes(ByVal s)
    Dim out(), i, n, c, k
    n = Len(s)
    If n = 0 Then
        ReDim out(0)
        Utf8Bytes = out
        Exit Function
    End If
    ReDim out(n * 3 - 1)
    k = 0
    For i = 1 To n
        c = AscW(Mid(s, i, 1))
        If c < 0 Then c = c + 65536
        If c < 128 Then
            out(k) = c
            k = k + 1
        ElseIf c < 2048 Then
            out(k) = 192 Or (c \ 64)
            out(k + 1) = 128 Or (c And 63)
            k = k + 2
        Else
            out(k) = 224 Or (c \ 4096)
            out(k + 1) = 128 Or ((c \ 64) And 63)
            out(k + 2) = 128 Or (c And 63)
            k = k + 3
        End If
    Next
    ReDim Preserve out(k - 1)
    Utf8Bytes = out
End Function

Function Utf16LeBytes(ByVal s)
    Dim out(), i, n, c
    n = Len(s)
    If n = 0 Then
        ReDim out(0)
        Utf16LeBytes = out
        Exit Function
    End If
    ReDim out(n * 2 - 1)
    For i = 1 To n
        c = AscW(Mid(s, i, 1))
        If c < 0 Then c = c + 65536
        out((i - 1) * 2) = c And 255
        out((i - 1) * 2 + 1) = (c \ 256) And 255
    Next
    Utf16LeBytes = out
End Function

Function BytesToBase64(ByVal bytes)
    Dim xml, node
    Set xml = CreateObject("MSXML2.DOMDocument")
    Set node = xml.createElement("b64")
    node.dataType = "bin.base64"
    node.nodeTypedValue = bytes
    BytesToBase64 = Replace(Replace(node.Text, vbLf, ""), vbCr, "")
End Function

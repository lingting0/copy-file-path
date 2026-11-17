# 文件右键菜单：复制文件路径

一个极简的 Windows 右键菜单小工具：右键任意文件，点击「复制文件路径」，即可把该文件的完整路径写入剪贴板。

## 效果

右键 `D:\文档\报告.pdf` 或右键文件夹 `D:\文档` → 「复制文件路径」，剪贴板得到：

```
D:\文档\报告.pdf
```
或
```
D:\文档
```

- 文件和文件夹都支持；不带引号，不带尾部换行
- 中文、空格、特殊字符均正常
- 执行过程完全静默，不闪控制台窗口

## 文件说明

| 文件 | 作用 |
|---|---|
| `CopyFilePath.ps1` | 核心脚本，用 `Set-Clipboard` 写入路径 |
| `CopyFilePath.vbs` | 静默启动器，`wscript.exe` 是 GUI 子系统程序，不会闪 cmd 窗口 |
| `install.ps1` | 安装脚本，自动写入当前用户注册表（无需管理员权限） |
| `uninstall.ps1` | 卸载脚本，删除菜单项 |

## 安装

在本目录打开 PowerShell（或用 `powershell -ExecutionPolicy Bypass -File .\install.ps1`）：

```powershell
powershell -ExecutionPolicy Bypass -File .\install.ps1
```

安装后如果菜单没有立刻出现，重启资源管理器或注销重登即可。

> 安装脚本会把本目录的绝对路径写进注册表。**不要移动或删除本目录**，否则菜单会失效；需要换位置时，先运行卸载脚本，移动后再重新安装。

## 卸载

```powershell
powershell -ExecutionPolicy Bypass -File .\uninstall.ps1
```

## 实现原理

- 注册表位置：`HKCU\Software\Classes\*\shell\CopyFilePath`（文件）和 `HKCU\Software\Classes\Directory\shell\CopyFilePath`（文件夹），均为当前用户，不需要管理员
- 菜单命令：`wscript.exe "<本目录>\CopyFilePath.vbs" "%1"`
- `wscript.exe` 属于 GUI 子系统，由资源管理器启动时不会创建控制台窗口；VBS 再以隐藏窗口方式调用 PowerShell 完成剪贴板写入。这样避免了直接启动 `powershell.exe` 时 `conhost` 一闪而过的问题。
- 路径不拼进命令行，而是通过 **进程环境变量** 传给 PowerShell；命令行是固定的，不含任何路径文本。因此文件名含 `%变量%`、`'`、空格、中文、`&` 等字符时都能原样复制，不会被环境变量展开或命令行解析改写，也不依赖 Base64/MSXML 编码。
- VBS 用 `WScript.Quit` 回传 PowerShell 的退出码，脚本失败时不再是静默的「假成功」。
- `install.ps1` 保存为 UTF-8 with BOM，保证 Windows PowerShell 5.1 下中文菜单名不乱码。

## 适用范围

- Windows 10 / 11（依赖 PowerShell 5.1 的 `Set-Clipboard`）
- 对**文件和文件夹**生效；文件夹空白处右键暂不添加
- 纯本地操作，不联网、不收集任何数据

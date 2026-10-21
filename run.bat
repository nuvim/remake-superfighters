@echo off
set "DOTNET_ROOT=%LOCALAPPDATA%\Microsoft\dotnet"
set "PATH=%LOCALAPPDATA%\Microsoft\dotnet;%PATH%"
"%LOCALAPPDATA%\Microsoft\dotnet\dotnet.exe" run --project "%~dp0superfighters-csharp\src\Superfighters.Client\Superfighters.Client.csproj" %*

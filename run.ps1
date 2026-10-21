$env:DOTNET_ROOT = "$env:LOCALAPPDATA\Microsoft\dotnet"
$env:PATH = "$env:LOCALAPPDATA\Microsoft\dotnet;$env:PATH"
& "$env:LOCALAPPDATA\Microsoft\dotnet\dotnet.exe" run --project "$PSScriptRoot\superfighters-csharp\src\Superfighters.Client\Superfighters.Client.csproj" @args

# BlueShell
```
                                                      __                _
                                                     /. }             _/ |
                                                  ,-'/ \ \         _./   /\
      ____  __   __  ________                   .'  /   \/       ./     / |
     / __ \/ /  / / / / ____/         ._       /__-''''-.\_    ./      ' /\
    / __  / /  / / / / __/             \ ''--:'   '\_______.\./         ' |
   / /_/ / /__/ /_/ / /___           ___\     |    / .''''.\/           _/|
  /_____/_____\____/_____/           \  /\__,-'   /  |  ' ||           _./
       _____ __  __________    __    .\/-----..-''\   '--' |          '/
      / ___// / / / ____/ /   / /   |          ''--\,       \_____..-'
      \__ \/ /_/ / __/ / /   / /    |   ,.._         ''---./...\-   |
     ___/ / __  / /___/ /___/ /___   '-| |   |'--._                .'
    /____/_/ /_/_____/_____/_____/      \ \_/ ,' |  '';--.______.-'
                                         '---'    ';''    /   /./
                                           '-.___.'     ,* ,.''
                                               ''------'-''
```
BlueShell is a PowerShell environment that facilitates the creation of 
**do-nothing scripts**. It contains functions used to interact with and display
information to the operator and to automatically load scripts into the 
PowerShell environment.

For more information on do-nothing scripting, see: [Do-nothing scripting: the key to gradual automation](https://blog.danslimmon.com/2019/07/15/do-nothing-scripting-the-key-to-gradual-automation/)

## Blueshell Set Up
### MacOS Prerequisites.
* Install Homebrew
  ```
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  ```
* Install PowerShell
  ```
  brew install --cask powershell
  ```
  or
  ```
  /opt/homebrew/bin/brew install --cask powershell
  ```

### Download and Install BlueShell
* Clone the BlueShell repository
  ```
  git clone https://github.com/StarCruiseStudios/BlueShell.git
  ```
* Manually import the BlueShell module
  ```
  Import-Module .\BlueShell\src\BlueShell.psm1
  ```
* Add BlueShell to your PowerShell profile to automatically launch it with 
  PowerShell.
  ```
  Install-BlueShell
  ```
## Configure a BlueShell extension.
A BlueShell extension can be created from any folder that contains one or more `*.blueshell.ps1` scripts. Once the extension is created, these scripts will automatically get loaded when BlueShell starts.

To create an extension, use the `New-BlueShellExtension` function
```
New-BlueShellExtension [-ExtensionName] <String> [[-ExtensionPath] <String>]
```
If `ExtensionPath` is omitted, the current directory will be used.

## BlueShell Functions
### Invoke-BlueShellCommand
`Invoke-BlueShellCommand` is used to print a command to the console, then 
execute it. It is useful for displaying a command that is executed automatically
so it can be audited or copied.
```
> Invoke-BlueShellCommand 'Write-Host "Hello"'
----------
Write-Host "Hello"
----------
Hello
```
### Set-ReadOnly
`Set-ReadOnly` is used to define a readonly value that can be accessed, but not
modified.
```
> Set-ReadOnly "MyVar" 10
MyVar: 10
> Write-Host $MyVar
10
> $MyVar = 12
WriteError: Cannot overwrite variable MyVar because it is read-only or constant.
```
The `-silent` switch can be used to set the readonly value without printing it.
```
Set-ReadOnly "MyVar2" 15 -silent
```
### Test-CommandExists
`Test-CommandExists` is used to determine if a function has been specified or if
a program is installed. This can be used in an `if` statement when checking for
and installing prerequisites.
```
> Test-CommandExists "git"
True
```

### Write-KeyValue
`Write-KeyValue` is used to print a key and value pair. This is useful for 
showing the values of variables or constants that are defined.
```
> $MyVar = 10
> Write-KeyValue "MyVar" $MyVar
MyVar: 10
```

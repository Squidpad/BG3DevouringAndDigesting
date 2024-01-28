# BG3DevouringAndDigesting
A comprehensive vore mod for Baldur's Gate 3

## Development
### Setting up development environment
1. Install [Visual Studio Code](https://code.visualstudio.com).
2. Clone this repository and open it with Visual Studio Code.
3. Install [Lua](https://marketplace.visualstudio.com/items?itemName=sumneko.lua) plugin by sumneko.
4. Install [vscode-lua-format](https://marketplace.visualstudio.com/items?itemName=Koihik.vscode-lua-format) plugin by Koihik.
#### Modding tools
1. Install [Python](https://www.python.org/downloads/) version 3.10 or newer.
2. Install tools: run [InstallTools.bat](InstallTools.bat).
#### Setting up and usage of Lua debugger
1. Install modding tools.
2. Create symlink (run CMD as Admin):
    ```shell
    mklink /D "<BG3 Install Path>\Data\Mods\DevouringAndDigesting" "<This Repo Path>\Mods\DevouringAndDigesting\Mods\DevouringAndDigesting"
    ```
3. Add `"EnableLuaDebugger": true` in the script extender configuration file `ScriptExtenderSettings.json`
in the `bin` folder of your game.
4. Download the BG3 Lua Debugger extension for VSCode: https://bg3se-updates.norbyte.dev/Stuff/bg3-lua-debugger-1.0.0.vsix.
In VSCode open File -> Preferences -> Extensions and drag the VSIX file to the extension pane to install.
5. Launch the game.
6. Press F5 in VSCode.
7. See also: https://github.com/Norbyte/bg3se/blob/main/Docs/Debugger.md

### Lua code style
* Pretty much http://lua-users.org/wiki/LuaStyleGuide, but:
  * 4 spaces indentation;
  * camelCase variables;
  * capitalized CamelCase functions with "SP_" prefix;
  * comments on a separate line, short comments may be an exception;
  * use annotations to describe functions: https://luals.github.io/wiki/annotations/;
* Format Lua files with "Format Document" (Shift+Alt+F), vscode-lua-format does not fork with "Format Selection" for some reason.

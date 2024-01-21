# BG3DevouringAndDigesting
A comprehensive vore mod for Baldur's Gate 3

## Development
### Setting up development environment
1. Use [Visual Studio Code](https://code.visualstudio.com).
2. Clone this repository and open it with Visual Studio Code.
3. Install [Lua](https://marketplace.visualstudio.com/items?itemName=sumneko.lua) plugin by sumneko.
4. Install [vscode-lua-format](https://marketplace.visualstudio.com/items?itemName=Koihik.vscode-lua-format) plugin by Koihik.

### Lua code style
* Pretty much http://lua-users.org/wiki/LuaStyleGuide, but:
  * 4 spaces indentation;
  * camelCase variables;
  * capitalized CamelCase functions with "SP_" prefix;
  * comments on a separate line, short comments may be an exception;
  * use annotations to describe functions: https://luals.github.io/wiki/annotations/;
* Format Lua files with "Format Document" (Shift+Alt+F), vscode-lua-format does not fork with "Format Selection" for some reason.

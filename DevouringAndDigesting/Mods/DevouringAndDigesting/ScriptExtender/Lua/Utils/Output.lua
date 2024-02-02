local LOG_PREFIX = "Devouring | "

local IsDeveloperMode = Ext.Debug.IsDeveloperMode()

---Printing info to the stdout. "Print". Overrides BG3SE's _P().
---@param s string
_P = function (s)
    Ext.Utils.Print(LOG_PREFIX .. s)
end

---Printing error to the stderr. "Fail", since _E is already defined.
---@param s string
_F = function (s)
    Ext.Utils.PrintError(LOG_PREFIX .. s)
end

---Printing debug info to the stdout. "Verbose", since _D is already defined.
---@param s string
_V = function (s)
    if not IsDeveloperMode then return end
    Ext.Utils.Print(LOG_PREFIX .. "DEBUG | " .. s)
end

---Show message box with mod name as a title.
---Currently can display up to 231 characters (excluding the title),
---the rest gets cut off.
---@param message string
function SP_ShowMessageBox(message)
    message = (
        "<b>" ..
        Ext.Loca.GetTranslatedString("h086643dege15eg42acga7c3gc0f596312163") ..
        "</b>\n\n" ..
        message
    )
    -- 1. See bug: https://github.com/Norbyte/bg3se/issues/248
    -- 2. Looks like <b></b> (7 chars) gets converted into some 16-chars
    --    sequence under the hood, because subtracting 9 fixes crash (16-7=9).
    --    There's no such problem if you use encoded HTML in localization strings.
    local maxLen = 263 - 9
    if string.len(message) > maxLen then
        message = string.sub(message, 0, maxLen - 3) .. "..."
    end
    --MessageBox doesn't show up when called immediately after
    --the LevelGameplayStarted event, so we're adding a delay of a certain
    --number of ticks. LevelGameplayStarted is the latter event I found.
    --If you know a more suitable event, let me know.
    SP_ExecOnGameplayStarted(75, function ()
        Osi.OpenMessageBox(Osi.GetHostCharacter(), message)
    end)
end

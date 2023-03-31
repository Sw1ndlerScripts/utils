getgenv().getTime = function()
    local currentTime = os.date("*t")
    local month = currentTime.month
    local day = currentTime.day
    local year = currentTime.year
    local hour = currentTime.hour
    local min = currentTime.min
    return string.format("%02d/%02d/%04d %02d:%02d", month, day, year, hour, min)
end

if filtergc then
    getgenv().ansiFromColors = function(text, textColor, bgColor)
        local textColorRgb = {math.floor(textColor.R * 255), math.floor(textColor.G * 255), math.floor(textColor.B * 255)}
        local bgColorRgb = {math.floor(bgColor.R * 255), math.floor(bgColor.G * 255), math.floor(bgColor.B * 255)}
        
        local textColorCode = "38;2;" .. table.concat(textColorRgb, ";")
        local bgColorCode = "48;2;" .. table.concat(bgColorRgb, ";")
        
        return string.format("\x1b[%s;%sm%s\x1b[0m", textColorCode, bgColorCode, text)
    end
else
    getgenv().ansiFromColors = function(text, textColor, bgColor)
        local textColorCode = ("\27[38;2;%d;%d;%dm"):format(textColor.r*255, textColor.g*255, textColor.b*255)
        local bgColorCode = ("\27[48;2;%d;%d;%dm"):format(bgColor.r*255, bgColor.g*255, bgColor.b*255)
        local resetColorCode = "\27[0m"
        return textColorCode..bgColorCode..text..resetColorCode
    end
end

getgenv().color3FromHex = function(hex)
    hex = hex:gsub("#", "")
    
    local r = tonumber(hex:sub(1, 2), 16) / 255
    local g = tonumber(hex:sub(3, 4), 16) / 255
    local b = tonumber(hex:sub(5, 6), 16) / 255
    
    return Color3.new(r, g, b)
end

getgenv().rcolorprint = function(text, textColor, bgColor)
    textColor = textColor or Color3.new(1,1,1)
    bgColor = bgColor or "0c0c0c"

    if typeof(textColor) ~= 'Color3' then
        textColor = color3FromHex(textColor)
    end

    if typeof(bgColor) ~= 'Color3' then
        bgColor = color3FromHex(bgColor)
    end

    rconsoleprint(ansiFromColors(text, textColor, bgColor))
    rconsoleprint(' ')
end

getgenv().rconsolelog = function(option, text)
    local bgText

    rcolorprint(" " .. getTime() .. " ", "9ea6c9", "16161f")

    if option == 'loading' then
        rcolorprint(" ... ", "878eac","16161f")
        bgText = "9ea6b0"
    end

    if option == 'success' then
        rcolorprint(" success ", "a5db69", "16161f")
        bgText = "a5db69"
    end

    if option == 'error' then
        rcolorprint(" error ", "db4b4b", "16161f")
        bgText = "db4b4b"
    end

    if option == 'warn' then
        rcolorprint(" warn ", "ffff91", "16161f")
        bgText = "ffff91"
    end
    
    if option == 'info' then
        rcolorprint(" info ", "9ea6c9", "16161f")
        bgText = "9ea6c9"
    end

    rcolorprint(text, bgText)
    rconsoleprint("\n")
end

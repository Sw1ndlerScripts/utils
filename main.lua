local plr = game:GetService("Players").LocalPlayer
local mouse = plr:GetMouse()
local camera = game:GetService("Workspace").CurrentCamera

--- bypass detections !!!
if cloneref then
  local oldGetService
  oldGetService = hookmetamethod(game, "__namecall", function(self, ...)
      local args = {...}
      if checkcaller() and getnamecallmethod() == 'GetService' then
          return cloneref(game.GetService(game, args[1]))
      end    
      return oldGetService(self, ...)
  end)
end

setreadonly(table, false)
getgenv().table.reverse = function(tbl)
  local len = #tbl
  local reversed = {}
  for i = 1, len do
    reversed[i] = tbl[len - i + 1]
  end
  return reversed
end

getgenv().teleportTo = function(destination)
  
   if typeof(destinationCFrame) == "Instance" then
       destination = destination.CFrame 
   elseif typeof(destinationCFrame) == "Vector3" then
       destination = CFrame.new(destination)
   end
  
    plr.Character.HumanoidRootPart.CFrame = destination
end

getgenv().tweenTo = function(destinationCFrame, studsPerSecond)
    if destinationCFrame == nil then
        return warn("TweenTo: No destination")
    end

    if studsPerSecond == nil then
        return warn("TweenTo: No speed")
    end

   local humanoidRootPart = plr.Character.HumanoidRootPart
   
   if typeof(destinationCFrame) == "Instance" then
       destinationCFrame = destinationCFrame.CFrame 
   elseif typeof(destinationCFrame) == "Vector3" then
       destinationCFrame = CFrame.new(destinationCFrame)
   end
   
   local offsetCFrame = CFrame.new(0, 0, 0)
   local destinationPosition = destinationCFrame.Position

   local travelTime = (humanoidRootPart.Position - destinationPosition).magnitude / studsPerSecond
   local tween = game.TweenService:Create(humanoidRootPart, TweenInfo.new(travelTime, Enum.EasingStyle.Linear), {CFrame = (destinationCFrame) * offsetCFrame})
   tween:Play()
   tween.Completed:Wait()
end


getgenv().getClosestPlayerToMouse = function(fov, teamcheck)
    local teamcheck = teamcheck or false    
    local closestDistance = fov or math.huge
    local closestPlayer
    
    for _, player in next, game:GetService("Players"):GetPlayers() do
        local onTeam = false
        if teamcheck and player.Team == plr.Team then
            onTeam = true
        end
        
        if player ~= plr and not(onTeam) then
            local character = player.Character
            if character and character:FindFirstChild("Humanoid") and character:FindFirstChild("HumanoidRootPart") and character.Humanoid.Health > 0 then
                local screenPosition, isVisibleOnViewport = camera:WorldToViewportPoint(character.HumanoidRootPart.Position)
                if isVisibleOnViewport then
                    local mouseDistance = (Vector2.new(mouse.X, mouse.Y) - Vector2.new(screenPosition.X, screenPosition.Y)).Magnitude
                    if mouseDistance < closestDistance then
                        closestPlayer = player
                        closestDistance = mouseDistance
                    end
                end
            end
        end
    end
    return closestPlayer, closestDistance
end

getgenv().getClosestPlayer = function()
    local closestDistance = math.huge
    local closestPlayer = nil
    
    for _, player in pairs(game.Players:GetPlayers()) do
        if player ~= plr and player.Character then
            local distance = distanceTo(player.Character.HumanoidRootPart)
            if distance < closestDistance then
                closestDistance = distance
                closestPlayer = player
            end
        end
    end
    
    return closestPlayer
end

getgenv().printFunc = function(func)
    for i,v in pairs(getconstants(func)) do
        if type(v) == 'function' then
            if islclosure(v) then
                printFunc(v)
            else
                print(i, getinfo(v).name)
            end
        elseif type(v) == 'table' then
            printTable(v)
        else
            print(i, v)
        end
    end
end

getgenv().distanceTo = function(pos)
    if typeof(pos) ~= "Vector3" then
        pos = pos.Position
    end
    
    return (plr.Character.HumanoidRootPart.Position - pos).magnitude
end

getgenv().clipdecompile = function(path)
    setclipboard(decompile(path))
    print("Done")
end


getgenv().findConsts = function(func, list)
    local matches = 0
    local consts = getconstants(func)

    for i, const in pairs(consts) do
        if type(const) == "string" then
            consts[i] = const:lower()
        end
    end
  
    for i, item in pairs(list) do
        if type(item) == "string" then
            list[i] = item:lower()
        end
    end

    for i,v in pairs(list) do
        if table.find(consts, v) then
            matches = matches + 1
        end
    end

    if matches == #list then
        return true
    end
    return false
end

getgenv().isBehindWall = function(position)
    local ray = Ray.new(Workspace.CurrentCamera.CFrame.Position, (position - Workspace.CurrentCamera.CFrame.Position).Unit * 500)
    local hitPart, hitPosition = Workspace:FindPartOnRay(ray, nil, false, true)

    if hitPart and hitPart.Transparency < 1 then
        return true
    end
    return false
end

getgenv().getScreenCenter = function()
    local viewportSize = Workspace.CurrentCamera.ViewportSize
    return Vector2.new(viewportSize.X/2, viewportSize.Y/2)
end

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

getgenv().isvalidfunction = function(func)
    return type(func) == 'function' and islclosure(func) and not is_synapse_function(func)
end

getgenv().functiongc = function(func)
    for i,v in pairs(getgc()) do
        if isvalidfunction(v) then
            local result = func(v)
            if result then
                return result
            end
        end
    end
end

getgenv().tablegc = function(func)
    for i,v in pairs(getgc(true)) do
        if type(v) == 'table' then
            local result = func(v)
            if result then
                return result
            end
        end
    end
end

local cases = {
    ['string'] = function(value)
        return '"' .. value .. '"'
    end,
    ['function'] = function(value)
        local funcName = getinfo(value).name or 'nil'
        local name = 'function ' .. funcName .. '()'

        local pointer = tostring(value)
        pointer = pointer:sub(11, -1)

        return name .. ", " .. pointer
    end,
    ['CFrame'] = function(value)
        local x = math.round(value.X)
        local y = math.round(value.Y)
        local z = math.round(value.Z)
        return 'CFrame.new(' .. tostring(x) .. ", " .. tostring(y) .. ", " .. tostring(z) .. ")"
    end,
    ['Vector3'] = function(value)
        local x = math.round(value.X)
        local y = math.round(value.Y)
        local z = math.round(value.Z)
        return 'Vector3.new(' .. tostring(x) .. ", " .. tostring(y) .. ", " .. tostring(z) .. ")"  
    end,
    ['Instance'] = function(value)
        return value.Name .. " | "  .. value:GetFullName()
    end,
    ['nil'] = function(value)
        return "nil"
    end
}

function stringify(value)
    local case = typeof(value)
    if cases[case] then
        return cases[case](value)
    end
    return tostring(value)
end

function stringifyTable(index, value)
    local newIndex = stringify(index)
    local newValue = stringify(value)

    if typeof(newIndex) == 'string' then
        newIndex = "[" .. newIndex .. "]"
    end

    if typeof(newValue) == 'string' then
        return newIndex .. " = " .. newValue
    elseif tostring(newIndex):find(":") == nil then
        return newIndex .. " = " .. tostring(newValue)
    else
        return newIndex .. " = " .. typeof(newValue) .. ": " .. tostring(newValue)
    end
end

local iterations = 0
getgenv().printTable = function(tbl, indent)
    local firstIteration = indent == nil

    if typeof(tbl) ~= 'table' then
        return print(stringify(tbl))
    end

    if firstIteration then
        iterations = 0
    else
        iterations = iterations + 1
    end


    if firstIteration then
        print("{")
    end
    local indent = indent or 4
    local spaces = string.rep(" ", indent)

    for i, value in pairs(tbl) do
        if typeof(value) == 'table' then
            if tostring(i) ~= '__index' then
                print(spaces .. '["' .. i .. '"]' .. " = { ")
                printTable(value, indent + 4)
            end
        else
            local result = spaces .. stringifyTable(i, value)

            if i == #tbl then
                print(result)
            else
                print(result .. ",")
            end
        end
    end

    if firstIteration == false then
        print(string.rep(" ", indent - 4) ..  "},")
    else
        print("}")
    end
end

getgenv().antinamesetter = function()
    syn.queue_on_teleport([[
        local function isgood(self)
            return self:IsA("ModuleScript") or self:IsA("Folder") or self:IsA("LocalScript") or self:IsA("RemoteEvent") or self:IsA("RemoteFunction")
        end
        local old
        old = hookmetamethod(game, '__newindex', function(self, key, val)
            if not checkcaller() and key == "Name" and isgood(self) then
                return
            end
            return old(self, key, val)
        end)
        local old
        old = hookmetamethod(game, '__newindex', function(self, key, val)
            if not checkcaller() and key == 'Parent' and val == nil and isgood(self) then
                val = self.Parent
            end
            return old(self, key, val)
        end)
        local old
        old = hookmetamethod(game, '__namecall', function(self, ...)
            if not checkcaller() and getnamecallmethod() == 'Destroy' and isgood(self) then
                return
            end
            return old(self, ...)
        end)
    ]])
end

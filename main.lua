local plr = game:GetService("Players").LocalPlayer
local mouse = plr:GetMouse()
local camera = game:GetService("Workspace").CurrentCamera

loadstring(game:HttpGet("https://github.com/Sw1ndlerScripts/utils/blob/main/PrintTable.lua?raw=true"))
loadstring(game:HttpGet("https://github.com/Sw1ndlerScripts/utils/blob/main/ColorPrint.lua?raw=true"))

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

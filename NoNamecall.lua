getgenv().getClosestPlayerNoNamecall = function()
    local closestDistance = math.huge
    local closestPlayer = nil
    
    for _, player in pairs(game.Players.GetPlayers(game.Players)) do
        if player ~= plr and player.Character and game.FindFirstChild(player.Character, 'HumanoidRootPart') then
            local distance = distanceTo(player.Character.HumanoidRootPart)
            if distance < closestDistance then
                closestDistance = distance
                closestPlayer = player
            end
        end
    end
    
    return closestPlayer
end

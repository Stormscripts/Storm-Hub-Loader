local PlaceId = game.PlaceId

if PlaceId == 131623223084840 then
    loadstring(game:HttpGet("https://raw.githubusercontent.com/Stormscripts/Storm-Hub-Loader/main/Escape%20Tsunami%20For%20Brainrots%20Storm%20Hub%20stormscripts"))()

elseif PlaceId == 142823291 then
    loadstring(game:HttpGet("https://raw.githubusercontent.com/Stormscripts/Storm-Hub-Loader/main/MM2%20Storm%20Hub%20stormscripts"))()

elseif PlaceId == 3082002798 then
    loadstring(game:HttpGet("https://raw.githubusercontent.com/Stormscripts/Storm-Hub-Loader/main/T-Titans%20Battlegrounds%20Storm%20Hub%20stormscripts"))()

elseif PlaceId == 16560655288 then
    loadstring(game:HttpGet("https://raw.githubusercontent.com/Stormscripts/Storm-Hub-Loader/main/Pillar%20Chase%202%20Storm%20Hub%20stormscripts"))()

elseif PlaceId == 109629391874197 then
    loadstring(game:HttpGet("https://raw.githubusercontent.com/Stormscripts/Storm-Hub-Loader/main/Marvel%20Omega%20Storm%20Hub%20stormscripts"))()

elseif PlaceId == 15131312477 then
    loadstring(game:HttpGet("https://raw.githubusercontent.com/Stormscripts/Storm-Hub-Loader/main/Ultimate%20Soccer%20Storm%20Hub%20stormscripts"))()

elseif PlaceId == 9224601490 then
    loadstring(game:HttpGet("https://raw.githubusercontent.com/Stormscripts/Storm-Hub-Loader/main/Fruit%20Battlegrounds%20Storm%20Hub%20stormscripts"))()

else
    game:GetService("Players").LocalPlayer:Kick("\n⛔ Storm Hub\n\nEste jogo Não é Suportado.\nPlaceId: " .. tostring(PlaceId))
end

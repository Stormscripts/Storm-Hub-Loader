local PlaceId = game.PlaceId

local games = {
    [131623223084840] = "https://raw.githubusercontent.com/Stormscripts/Storm-Hub-Loader/main/Escape%20Tsunami%20For%20Brainrots%20Storm%20Hub%20stormscripts",
    [142823291]       = "https://raw.githubusercontent.com/Stormscripts/Storm-Hub-Loader/main/MM2%20Storm%20Hub%20stormscripts",
    [3082002798]      = "https://raw.githubusercontent.com/Stormscripts/Storm-Hub-Loader/main/T-Titans%20Battlegrounds%20Storm%20Hub%20stormscripts",
    [16560655288]     = "https://raw.githubusercontent.com/Stormscripts/Storm-Hub-Loader/main/Pillar%20Chase%202%20Storm%20Hub%20stormscripts",
    [109629391874197] = "https://raw.githubusercontent.com/Stormscripts/Storm-Hub-Loader/main/Marvel%20Omega%20Storm%20Hub%20stormscripts%20alphax%20project",
    [15131312477]     = "https://raw.githubusercontent.com/Stormscripts/Storm-Hub-Loader/main/Ultimate%20Soccer%20Storm%20Hub%20stormscripts",
    [9224601490]      = "https://raw.githubusercontent.com/Stormscripts/Storm-Hub-Loader/main/Fruit%20Battlegrounds%20Storm%20Hub%20stormscripts",
}

local url = games[PlaceId]

if url then
    loadstring(game:HttpGet(url))()
else
    game:GetService("Players").LocalPlayer:Kick("\n⛔ Storm Hub\n\nEste jogo não é suportado.\nPlaceId: " .. tostring(PlaceId))
end

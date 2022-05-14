local TeleportService = game:GetService("TeleportService")
local CoreGui = game:GetService("CoreGui")

local Server = {}
Server.__index = Server

function Server.new(id, maxPlayers, playing, fps, ping, placeId)
    local This = {}
    This.id = id or ''
    This.maxPlayers = maxPlayers or 24
    This.playing = playing or 24
    This.fps = fps or 60
    This.ping = ping or 0
    This.placeId = placeId or game.PlaceId
    return setmetatable(This, Server)
end

function Server:Join(Options)
    if not Options then
        Options = {}
        Options.RetryOnError = true
        Options.Recursive = true
    end
    if not Options.Attempt then
        Options.Attempt = 1
    end
    if Options.RetryOnError then
        local RobloxPromptGui = CoreGui:WaitForChild("RobloxPromptGui")
        local PromptOverlay = RobloxPromptGui:WaitForChild("promptOverlay")
        PromptOverlay.ChildAdded:Connect(function(Child)
            if Child.Name == 'ErrorPrompt' then
                Print("Got ErrorPrompt, Retrying")
                return self:Join(Options)
            end
        end)
    end
    local Success, Return = pcall(TeleportService.TeleportToPlaceInstance, TeleportService, self.placeId, self.id)
    if not Success then
        if Options.Recursive then
            Options.Attempt += 1
            task.wait(1.5 * Options.Attempt)
            return self:Join(Options)
        else
            return false
        end
    else
        return true
    end
end

return Server
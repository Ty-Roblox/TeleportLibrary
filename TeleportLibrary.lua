local TeleportLibrary = {}
TeleportLibrary.__index = TeleportLibrary
TeleportLibrary.User = 'Ty-Roblox'
TeleportLibrary.Name = 'TeleportLibrary'

local function Print(...)
    local Str = ''
    local Idx = 0
    for i,v in pairs({...}) do
        if Idx == 0 then
            Str = string.format('%s', tostring(v))
        else

            Str = string.format('%s   %s', Str, tostring(v))
        end
        Idx = Idx + 1
    end
    rconsoleprint(string.format('%s\n', Str))
end

local function RecursiveHTTPGet(Site, Attempt) 
    if not Attempt then
        Attempt = 0
    end
    local Success, Return = pcall(function()
        local Request = syn.request({
            Url = Site,
            Method = 'GET',
        })
        if Request.Success then
            return Request.Body
        else
            Attempt += 1
            if Attempt > 12 then
                return 'Failed Attempt > 12'
            end
            task.wait(1)
            return RecursiveHTTPGet(Site, Attempt) 
        end
    end)
    if not Success then
        Attempt += 1
        if Attempt > 12 then
            return 'Failed Attempt > 12'
        end
        task.wait(1)
        return RecursiveHTTPGet(Site, Attempt) 
    else
        return Return
    end
    return 'Failed End Of Function'
end

local function GithubFetch(User, Repo, File)
    return RecursiveHTTPGet(string.format('https://raw.githubusercontent.com/%s/%s/main/%s', User, Repo, File))
end

function TeleportLibrary.new(Options)
    local This = {}
    if not Options then
        Options = {}
    end
    getgenv().Print = Print
    getgenv().RecursiveHTTPGet = RecursiveHTTPGet
    getgenv().GithubFetch = GithubFetch
    getgenv().Server = loadstring(GithubFetch(TeleportLibrary.User, TeleportLibrary.Name, 'Server.lua'))()
    getgenv().ServerManager = loadstring(GithubFetch(TeleportLibrary.User, TeleportLibrary.Name, 'ServerManager.lua'))()
    This.Settings = {}
    This.Settings.FastMode = Options.FastMode or false
    This.Settings.PlaceId = Options.PlaceId or game.PlaceId
    This.Settings.Method = Options.Method or 'Asc'
    This.Settings.FreeSlots = Options.FreeSlots or 1
    This.Settings.RequestInterval = Options.RequestInterval or .25
    This.Manager = ServerManager.new(This.Settings)
    return setmetatable(This, TeleportLibrary)
end

function TeleportLibrary:GetServers()    
    local ServersRaw = self.Manager:GetAllServers()
    local Filtered = {}
    for i,v in ipairs(ServersRaw) do
        if v.maxPlayers and v.id and v.playing and (v.playing + self.Settings.FreeSlots) < v.maxPlayers and v.id ~= game.JobId then
            table.insert(Filtered, v)
        end
    end
    table.sort(Filtered, function(First, Second)
        if Method=='Asc' then
            return First.playing < Second.playing
        elseif Method=='Desc' then
            return First.playing > Second.playing
        else 
            return First.playing > Second.playing
        end
    end)
    local Servers = {}
    for i,v in ipairs(Filtered) do
        local ServerInstance = Server.new(v.id, v.maxPlayers, v.playing, v.fps, v.ping, self.Settings.PlaceId)
        if (not ServerInstance:IsBlacklisted()) then
            table.insert(Servers, ServerInstance)
        end
    end
    return Servers
end

--[[
    local TeleportLib = TeleportLibrary.new()
    warn(#TeleportLib:GetServers())
]]

return TeleportLibrary
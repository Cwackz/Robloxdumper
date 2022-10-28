-- Check Required Functions
local requiredfunctions = {
    rconsolewarn,
    rconsoleerr,
    getgc,
    decompile,
    rawget,
    hookfunction,
    newcclosure,
    writefile,
    is_synapse_function,
    tostring,
    getrawmetatable,
    isfolder,
    makefolder
}
for i,v in next, requiredfunctions do
    assert(v, "Exploit Not Supported")
end

-- Prepare Folders
rconsolewarn("[WARNING]: Initiating...")
if not isfolder('Disassambler') then makefolder('Disassambler') end
local function makepath(name)
    if not isfolder("Disassambler"..name) then
        makefolder("Disassambler"..name)
        rconsolewarn("[WARNING]: Created New Folder For, ".."Disassambler"..name)
    end
end
makepath('/'..game.PlaceId)
rconsolewarn("[WARNING]: Initiating Complete\n")

-- Upvalue Dumper
rconsolewarn("[WARNING]: Obtaining Upvalues")
local upvaluelogs = {}
local function upvaluelog(path, idx, val)
    table.insert(upvaluelogs, path.." | "..typeof(idx).." | "..tostring(idx).." / "..tostring(val).." | "..getfenv(2).script:GetFullName())
end
for a,b in next, getgc() do
    if type(b) == 'function' and not is_synapse_function(b) then
        upvaluelog("function", a, b)
        for c,d in next, debug.getupvalues(b) do
        upvaluelog("function", c, d)
            if type(d) == 'function' then
                upvaluelog("function, function", c, d)
                for e,f in next, debug.getupvalues(d) do
                    if type(f) == 'table' then
                        upvaluelog("function, function, table", e, f)
                        for g,h in next, f do
                            upvaluelog("function, function, table", g, h)
                        end
                    end
                    if type(f) == 'function' then
                        upvaluelog("function, function, function", e, f)
                        for g,h in next, debug.getupvalues(f) do
                            upvaluelog("function, function, function", g, h)
                        end
                    end
                end
            end
            if type(d) == 'table' then
                upvaluelog("function, table", c, d)
                for e,f in next, d do
                    if type(f) == 'table' then
                        upvaluelog("function, table, table", e, f)
                        for g,h in next, f do
                            upvaluelog("function, table, table", g, h)
                       end
                    end
                    if type(f) == 'function' then
                        upvaluelog("function, table, function", e, f)
                        for g,h in next, debug.getupvalues(f) do
                            upvaluelog("function, table, function", g, h)
                        end
                    end
                 end
            end
        end
    end
end
rconsolewarn("[WARNING]: Succeed Obtained Upvalues\n")
makepath('/'..game.PlaceId..'/UpValues')
rconsolewarn("[WARNING]: Saving Upvalues")
writefile('Disassambler/'..game.PlaceId..'/UpValues/output.lua',table.concat(upvaluelogs,'\n'))
rconsolewarn("[WARNING]: Succeed Saved Upvalues\n")

-- LocalScript Dumper + Module Requires Dumper
local dumper = {}
local reqmodule = {}
local Players = game:GetService('Players')
local LocalPlayer = Players.LocalPlayer 
local StarterPlayer = game:GetService('StarterPlayer')
local Services = {
    ['Workspace'] = game:GetService('Workspace'),
    ['PlayerScripts'] = LocalPlayer.PlayerScripts,
    ['PlayerGui'] = LocalPlayer.PlayerGui,
    ['Backpack'] = LocalPlayer.Backpack,
    ['ReplicatedFirst'] = game:GetService('ReplicatedFirst'),
    ['StarterPlayerScripts'] = StarterPlayer.StarterPlayerScripts,
    ['StarterGui'] = game:GetService('StarterGui'),
    ['Lighting'] = game:GetService('Lighting'),
    ['ReplicatedStorage'] = game:GetService('ReplicatedStorage'),
    ['NIL'] = getnilinstances()
}
local Dumps = {
    LocalScripts = 0,
    ModuleScripts = 0
}
function dumper:setup()
    for i,v in pairs(Services) do
        makepath('/'..game.PlaceId..'/'..i)
        makepath('/'..game.PlaceId..'/'..i..'/LocalScripts')
        makepath('/'..game.PlaceId..'/'..i..'/ModuleScripts')
        rconsolewarn('[WARNING]: '..i..' folder created.\n')
    end
end
function dumper:startDump()
    for i,v in pairs(Services) do
        local LocalScriptsPath = 'Disassambler/'..game.PlaceId..'/'..i..'/LocalScripts'
        local ModuleScriptsPath = 'Disassambler/'..game.PlaceId..'/'..i..'/ModuleScripts'
        pcall(function()
            for z,b in pairs(v:GetDescendants()) do     
                if b:IsA('LocalScript') then 
                    local File = decompile(b)
                    if string.match(File, "Fire") or string.match(File, "Invoke") then
                        rconsoleerr("[IMPORTANT]: Potential Exploitable, From: "..b:GetFullName())
                    end
                    writefile(LocalScriptsPath..'/game.'..b:GetFullName()..'.lua', File) 
                    rconsolewarn('LocalScript Found | game.'..b:GetFullName()..'\n')
                    Dumps.LocalScripts = Dumps.LocalScripts + 1
                    rconsolename('[DEBUG] Game Dumper | {LocalScripts: '..Dumps.LocalScripts..' | ModuleScripts: '..Dumps.ModuleScripts..'}')
                end
                if b:IsA('ModuleScript') then
                    if not string.find(b:GetFullName(), 'PlayerModule') and not string.find(b:GetFullName(), 'ChatScript') then
                        local File = decompile(b)
                        if string.match(File, "Fire") or string.match(File, "Invoke") then
                            rconsoleerr("[IMPORTANT]: Potential Exploitable, From: "..b:GetFullName())
                        end
                        writefile(ModuleScriptsPath..'/game.'..b:GetFullName()..'.lua', File) 
                        rconsolewarn('ModuleScript Found | game.'..b:GetFullName()..'\n')
                        Dumps.ModuleScripts = Dumps.ModuleScripts + 1
                        for c,d in next, require(b) do
                            table.insert(reqmodule, b:GetFullName().." | "..c.." / "..d)
                        end
                        rconsolename('[DEBUG] Game Dumper | {LocalScripts: '..Dumps.LocalScripts..' | ModuleScripts: '..Dumps.ModuleScripts..'}')
                    end
                end 
            end
        end)
    end
    writefile('Disassambler/'..game.PlaceId..'/RequiresModule/output.lua',table.concat(reqmodule,'\n'))
    rconsolewarn('Dumping Finished\nLocalScripts: '..Dumps.LocalScripts..'\nModuleScripts: '..Dumps.ModuleScripts)
end
function dumper:initiate()
    dumper:setup()
    dumper:startDump()
end
dumper:initiate()

-- Anti Cheat Finder
local acfunctions = {
    game.Players.LocalPlayer.Remove,
    game.Players.LocalPlayer.Kick,
    game.Players.LocalPlayer.Destroy
}
table.foreach(acfunctions, function(i,v)
    local acfinder; acfinder = hookfunction(v, function(...)
        rconsoleerr("[IMPORTANT]: ".."Kick Attempt, ".."From: "..getfenv(2).script:GetFullName())
        return nil
    end)
end)

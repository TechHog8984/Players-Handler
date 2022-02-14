local PlayerService = game:GetService'Players'
local EventManager = loadstring(game:HttpGet'https://raw.githubusercontent.com/TechHog8984/TechHub-V3/main/script/misc/events.lua')()
local PlayersHandler = {Connections = {}, Players = {}, PlayerAdded = EventManager:CreateEvent('PlayerAdded'), PlayerRemoving = EventManager:CreateEvent('PlayerRemoving')} do 
    local function PlayerAdded(Player)
        if Player then
            local Handle = {}

            Handle.CharacterAdded = EventManager:CreateEvent(Player.Name .. ' - CharacterAdded')
            Handle.CharacterRemoved = EventManager:CreateEvent(Player.name .. ' - CharacterRemoved')
            Handle.HumanoidAdded = EventManager:CreateEvent(Player.Name .. ' - HumanoidAdded')
            Handle.HumanoidRemoved = EventManager:CreateEvent(Player.Name .. ' - HumanoidRemoved')
            Handle.HumanoidRootPartAdded = EventManager:CreateEvent(Player.Name .. ' - HumanoidRootPartAdded')
            Handle.HumanoidRootPartRemoved = EventManager:CreateEvent(Player.Name .. ' - HumanoidRootPartRemoved')

            function PartRemoved(Part)
                if Part then
                    local Name = Part.Name or Part
                    if Name == 'Humanoid' then
                        Handle.HumanoidRemoved:Fire()
                    elseif Name == 'HumanoidRootPart' then
                        Handle.HumanoidRootPartRemoved:Fire()
                    end
                end
            end

            function PartAdded(Part)
                if Part then
                    local Name = Part.Name or Part
                    if Name == 'Humanoid' then
                        Handle.HumanoidAdded:Fire()
                    elseif Name == 'HumanoidRootPart' then
                        Handle.HumanoidRootPartAdded:Fire()
                    end
                end
            end

            function CharacterRemoved()
                PartRemoved('Humanoid')
                PartRemoved('HumanoidRootPart')
                if Handle.CharacterRemoved then
                    Handle.CharacterRemoved:Fire()
                end
                Handle.Character = nil
                if Handle.CharacterRemovedConnection then
                    Handle.CharacterRemovedConnection:Disconnect()
                end
                if Handle.PartAddedConnection then
                    Handle.PartAddedConnection:Disconnect()
                end
                if Handle.PartRemovedConnection then
                    Handle.PartRemovedConnection:Disconnect()
                end
            end

            function CharacterAdded(Character)
                if Character then
                    Handle.Character = Character
                    Handle.CharacterAdded:Fire(Character)

                    CharacterRemovedConnection = Character:WaitForChild'Humanoid'.Died:Connect(CharacterRemoved)
                    PartAddedConnection = Character.ChildAdded:Connect(PartAdded)
                    PartRemovedConnection = Character.ChildRemoved:Connect(PartRemoved)

                    Handle.CharacterRemovedConnection = CharacterRemovedConnection
                    Handle.PartAddedConnection = PartAddedConnection
                    Handle.PartRemovedConnection = PartRemovedConnection

                    PartAdded(Character:FindFirstChild'Humanoid' or nil)
                    PartAdded(Character:FindFirstChild'HumanoidRootPart' or nil)

                    table.insert(PlayersHandler.Connections, CharacterRemovedConnection)
                    table.insert(PlayersHandler.Connections, PartAddedConnection)
                    table.insert(PlayersHandler.Connections, PartRemovedConnection)
                end
            end

            function Handle.GetCharacter()
                return Handle.Character or Player.Character or Player.CharacterAdded:Wait()
            end

            function Handle.GetPart(part)
                local Character = Handle.GetCharacter()
                return (Character and (Character:FindFirstChild(part))) or nil
            end
            function Handle.GetParts(...)
                local parts = {}

                for I, part in next, ({...}) do
                    parts[I] = Handle.GetPart(part)
                end

                return unpack(parts)
            end
            function Handle.GetChildWhichIsA(ClassName)
                local Character = Handle.GetCharacter()
                if Character then
                    for I, Child in next, Character:GetDescendants() do
                        if Child and Child:IsA(ClassName) then
                            return Child;
                        end
                    end
                end
            end

            function Handle:Stop()
                Handle.CharacterAdded:DisconnectAll()
                Handle.CharacterRemoved:DisconnectAll()
                Handle.HumanoidAdded:DisconnectAll()
                Handle.HumanoidRemoved:DisconnectAll()
                Handle.HumanoidRootPartAdded:DisconnectAll()
                Handle.HumanoidRootPartRemoved:DisconnectAll()
            end

            CharacterAdded(Handle.GetCharacter())

            local CharacterAddedConnection = Player.CharacterAdded:connect(CharacterAdded)
            CharacterAddedConnection = CharacterAddedConnection

            table.insert(PlayersHandler.Connections, CharacterAddedConnection)

            PlayersHandler.Players[Player] = Handle

            Handle.Loaded = true

            PlayersHandler.PlayerAdded:Fire(Player, Handle)
        end
    end
    local function PlayerRemoved(Player)
        if Player and Player ~= LocalPlayer and PlayersHandler.Players[Player] then
            local Handle = PlayersHandler.Players[Player]

            PlayersHandler.PlayerRemoving:Fire(Player, Handle)

            PlayersHandler.Players[Player] = nil
            Handle = nil
        end
    end

    for Index, Player in next, PlayerService:GetPlayers() do
        PlayerAdded(Player)
    end

    table.insert(PlayersHandler.Connections, PlayerService.PlayerAdded:Connect(PlayerAdded))
    table.insert(PlayersHandler.Connections, PlayerService.PlayerRemoving:Connect(PlayerRemoved))

    function PlayersHandler.Stop()
        for I, Connection in next, PlayersHandler.Connections do
            if Connection then
                Connection:Disconnect()
            end
        end

        for Player, Handle in next, PlayersHandler.Players do
            Handle:Stop()
        end

        PlayersHandler.Players = {}

        PlayersHandler.PlayerAdded:DisconnectAll()
        PlayersHandler.PlayerRemoving:DisconnectAll()
    end
end

return PlayersHandler

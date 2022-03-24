local FindFirstChild = workspace.FindFirstChild;
local sub = string.sub;

local Handler = {Players = {}, Holders = {}};
local PlayerService = game:GetService("Players");
local LocalPlayer = PlayerService.LocalPlayer;

local PlayerMT; do
    PlayerMT = {
        __newindex = function(Self, Index, Value)
            local Holder = type(Self) == "userdata" and Handler.Holders[Self];
            if type(Holder) == "table" then
                if sub(Index, 1, 2) == "__" then
                    Holder[Index] = Value;
                    return;
                end;
                local PlayerObject = Holder.__object;
                if type(PlayerObject) == "userdata" then
                    PlayerObject[Index] = Value;
                    return;
                else
                    return error("Failed to get playerobject", 2);
                end;
            else
                return error("Failed to get holder", 2);
            end;
        end,
        __index = function(Self, Index)
            local Holder = type(Self) == "userdata" and Handler.Holders[Self];
            if type(Holder) == "table" then
                if sub(Index, 1, 2) == "__" then
                    return Holder[Index];
                end;
                local PlayerObject = Holder.__object;
                if type(PlayerObject) == "userdata" then
                    return PlayerObject[Index];
                else
                    return error("Failed to get playerobject", 2);
                end;
            else
                return error("Failed to get holder", 2);
            end;
        end,
        __tostring = function(Self)
            return Self.Name;
        end,
    };
    Handler.PlayerMT = PlayerMT;
end;

local Properties; do
    Properties = {
        "Archivable",
        "AutoJumpEnabled",
        "Character",
        "CharacterAppearanceId",
        "DisplayName",
        "Name",
        "Parent",
        "ReplicationFocus",
        "RespawnLocation",
        "UserId",

        "CanLoadCharacterAppearance",
        "GameplayPaused",

        "CameraMaxZoomDistance",
        "CameraMinZoomDistance",
        "CameraMode",
        "DevCameraOcclusionMode",
        "DevComputerCameraMode",
        "DevEnableMouseLock",
        "DevTouchCameraMode",
        "HealthDisplayDistance",
        "NameDisplayDistance",

        "DevComputerMovementMode",
        "DevTouchMovementMode",

        "Neutral",
        "Team",
        "TeamColor",
    };
end;

local PlayerFunctions = {};
do --playerfunctions
    PlayerFunctions.GetPart = function(Self, Part)
        return type(Self.Character) == "userdata" and FindFirstChild(Self.Character, Part);
    end;
    PlayerFunctions.GetParts = function(Self, ...)
        local Parts;
        if type((...)) == "table" then
            Parts = (...);
        else
            Parts = {...};
        end;

        local RealParts = {};
        for I, Part in next, Parts do
            table.insert(RealParts, PlayerFunctions.GetPart(Self, Part));
        end;

        return unpack(RealParts);
    end;

    PlayerFunctions.IsPlayerFriendly = function(Self, Player)
        
    end;
end;

local function CreatePlayer(Inst)
    --create new userdata with a metatable & a holder for storing values
    local Player = newproxy(true);
    local Holder = {__object = Inst, __connections = {}};
    Handler.Holders[Player] = Holder;

    --loop through Player properties and set each one the same as the Player Instance
    for I, Property in next, Properties do
        Holder[Property] = Inst[Property];
    end;
    --connect the Changed event so that every time a property of the Player Instance is changed, it will change it on the holder too
    Holder.__connections.Changed = Inst.Changed:Connect(function(Property)
        if table.find(Properties, Property) then
            Holder[Property] = Inst[Property];
        end;
    end);

    --set the cusotm functions
    for Name, Function in next, PlayerFunctions do
        Holder[Name] = Function;
    end;

    --get the metatable of Player and set each function to be the same as in PlayerMT (setting the metatable)
    local mT = getmetatable(Player);
    for mM, Func in next, PlayerMT do
        mT[mM] = Func;
    end;

    return Player;
end;

function Handler:AddPlayer(Inst)
    local Player = CreatePlayer(Inst);
    if LocalPlayer and Inst == LocalPlayer then
        Handler.LocalPlayer = Player;
        Handler.Players.LocalPlayer = Player;
    end;

    Handler.Players[Inst.Name] = Player;

    return Player;
end;
function Handler:RemovePlayer(Inst)
    local Handle = Handler.Players[Inst.Name];
    for I, Connection in next, Handle.__connections do
        Connection:Disconnect();
    end;
    rawset(Handler.Players, Inst.Name, nil);
end;

local function PlayerAdded(Player)
    if type(Player) == "userdata" then Handler:AddPlayer(Player);end;
end;
local function PlayerRemoving(Player)
    if type(Player) == "userdata" then Handler:RemovePlayer(Player);end;
end;

for I, Player in next, PlayerService:GetPlayers() do
    PlayerAdded(Player);
end;
PlayerService.PlayerAdded:Connect(PlayerAdded);
PlayerService.PlayerRemoving:Connect(PlayerRemoving);

return Handler;

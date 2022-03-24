local FindFirstChild = workspace.FindFirstChild;
local sub = string.sub;
local find = table.find;

local Handler = {Players = {}, Holders = {}};
local PlayerService = game:GetService("Players");
local LocalPlayer = PlayerService.LocalPlayer;

local Properties, Functions; do
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
    Functions = {
        "AddToBlockList",
        "ClearCharacterAppearance",
        "DistanceFromCharacter",
        "GetFriendStatus",
        "GetFriendsOnline",
        "GetGameSessionID",
        "GetJoinData",
        "GetMouse",
        "GetNetworkPing",
        "GetRoleInGroup",
        "GetUnder13",
        "HasAppearanceLoaded",
        "IsFriendsWith",
        "IsInGroup",
        "Kick",
        "LoadCharacter",
        "LoadCharacterBlocking",
        "LoadCharacterWithHumanoidDescription",
        "Move",
        "RemoveCharacter",
        "RequestFriendship",
        "RequestStreamAroundAsync",
        "SetAccountAge",
        "SetCharacterAppearanceJson",
        "SetMemberShipType",
        "SetSuperSafeChat",
        "UpdatePlayerBlocked",

        "ClearAllChildren",
        "Clone",
        "Destroy",
        "FindFirstAncestor",
        "FindFirstAncestorOfClass",
        "FindFirstAncestorWhichIsA",
        "FindFirstChild",
        "FindFirstChildOfClass",
        "FindFirstChildWhichIsA",
        "FindFirstDescendant",
        "GetActor",
        "GetAttribute",
        "GetAttributeChangedSignal",
        "GetAttributes",
        "GetChildren",
        "GetDebugId",
        "GetDescendants",
        "GetFullName",
        "GetPropertyChangedSignal",
        "IsA",
        "IsAncestorOf",
        "IsDescendantOf",
        "SetAttribute",
        "WaitForChild",
    };
end;

local CustomFunctions = {};
do
    CustomFunctions.GetPart = function(Self, Part)
        return type(Self.Character) == "userdata" and FindFirstChild(Self.Character, Part);
    end;
    CustomFunctions.GetParts = function(Self, ...)
        local Parts;
        if type((...)) == "table" then
            Parts = (...);
        else
            Parts = {...};
        end;

        local RealParts = {};
        for I, Part in next, Parts do
            table.insert(RealParts, CustomFunctions.GetPart(Self, Part));
        end;

        return unpack(RealParts);
    end;

    CustomFunctions.IsPlayerFriendly = function(Self, Player)
        
    end;
end;

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
                if find(Functions, Index) then
                    return Holder.__functions[Index];
                end;
                if CustomFunctions[Index] then
                    return CustomFunctions[Index];
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

local function CreatePlayer(Inst)
    --create new userdata with a metatable & a holder for storing values
    local Player = newproxy(true);
    local Holder = {__object = Inst, __connections = {}, __functions = {}};
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

    for I, Name in next, Functions do
        Holder.__functions[Name] = function(Self, ...)
            local Inst = Holder.__object;
            if Inst then
                if (...) == Inst then
                    return Inst[Name](...);
                end;
                return Inst[Name](Inst, ...);
            end;
        end;
    end;
    --set the custom functions
    for Name, Function in next, CustomFunctions do
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

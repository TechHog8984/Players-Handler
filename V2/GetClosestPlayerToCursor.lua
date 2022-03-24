local Config = {
    HealthCheck = true,
    TeamCheck = true,
};

local spawn = task.spawn;

local PlayersHandler = loadstring(game:HttpGet"https://raw.githubusercontent.com/TechHog8984/Players-Handler/main/V2/src.lua")();
local Players = PlayersHandler.Players;
local LocalPlayer = Players.LocalPlayer;
local Mouse = LocalPlayer:GetMouse();

local Camera = workspace.CurrentCamera;
local IsDescendantOf = workspace.IsDescendantOf;
local FindFirstChild = workspace.FindFirstChild;
local WorldToViewportPoint = Camera.WorldToViewportPoint;

local UIS = game:GetService("UserInputService");
local GetMouseLocation = UIS.GetMouseLocation;
local Vector2new = Vector2.new;

local GetClosestPlayerToCursor; do
    local function GetPlayerFromPart(Part)
        for I, Player in next, Players do
            local Character = type(Player) == "userdata" and Player ~= LocalPlayer and Player.Character;
            if type(Character) == "userdata" and IsDescendantOf(Part, Character) then
                return Player;
            end;
        end;
    end;
    local function GetHealth(Inst)
        if type(Config) == "table" and Config.HealthCheck == false then return 1 end;
        local Character;
        local Class = Inst.ClassName;
        if Class == "Model" then
            Character = Inst;
        elseif Class == "Player" then
            Character = Inst.Character;
        end;
        local Humanoid = type(Character) == "userdata" and FindFirstChild(Character, "Humanoid");
        if type(Humanoid) == "userdata" then
            return Humanoid.Health;
        end;
    end;
    local function AllowedTeam(Player)
        if type(Config) == "table" and Config.TeamCheck == false then return true end;
        if Player.Team and LocalPlayer.Team then
            return Player.Team ~= LocalPlayer.Team;
        end;
        return true;
    end;
    local function FlipVector(Vector)
        return Vector2new(Vector.X, Vector.Y);
    end;

    GetClosestPlayerToCursor = function()
        local LHealth = GetHealth(LocalPlayer);
        local LHealthC = LHealth and LHealth > 0;
        if Mouse.Target then
            local Player = GetPlayerFromPart(Mouse.Target);
            if Player and AllowedTeam(Player) and LHealthC then return Player end;
        end;
        
        local ClosestPlayer;
        local MaxDist = math.huge;

        for I, Player in next, Players do
            spawn(function()
                if Player and Player ~= LocalPlayer and AllowedTeam(Player) and LHealthC then
                    local LocalHumanoidRootPart = LocalPlayer:GetPart("HumanoidRootPart");
                    local HumanoidRootPart = Player:GetPart("HumanoidRootPart");
                    local PHealth = GetHealth(Player);
                    local PHealthC = PHealth and PHealth > 0;
                    if LocalHumanoidRootPart and HumanoidRootPart and PHealthC then
                        if ClosestPlayer then
                            local ScreenPos, OnScreen = WorldToViewportPoint(Camera, HumanoidRootPart.Position);
                            
                            if OnScreen then
                                local MousePos = GetMouseLocation(UIS);
                                local Distance = (MousePos - FlipVector(ScreenPos)).Magnitude;

                                if Distance < MaxDist then
                                    MaxDist = Distance;
                                    ClosestPlayer = Player;
                                end;
                            end;
                        else
                            ClosestPlayer = Player;
                        end;
                    end;
                end;
            end);
        end;

        return ClosestPlayer, MaxDist;
    end;
end;

return GetClosestPlayerToCursor;

print("Stopping Power is installed :)")

CreateConVar("stoppower_enable", 1, FCVAR_NOTIFY, "When 1, taking damage will slow down players. Turn off with 0.", 0, 1)
local enabled = GetConVar("stoppower_enable"):GetBool()
cvars.AddChangeCallback("stoppower_enable", function()
    enabled = GetConVar("stoppower_enable"):GetBool()

    if not enabled then
        resetAllPlayers()
    end
end)

CreateConVar("stoppower_dmg_mult", 0.08, FCVAR_NOTIFY, "The slowdown amount per damage taken.")
local dmgMult = GetConVar("stoppower_dmg_mult"):GetFloat()
cvars.AddChangeCallback("stoppower_dmg_mult", function()
    dmgMult = GetConVar("stoppower_dmg_mult"):GetFloat()
end)

CreateConVar("stoppower_minimum_speed_mult", 0.1, FCVAR_NOTIFY, "The slowest slowdown amount allowed.")
local multMin = GetConVar("stoppower_minimum_speed_mult"):GetFloat()
cvars.AddChangeCallback("stoppower_minimum_speed_mult", function()
    multMin = GetConVar("stoppower_minimum_speed_mult"):GetFloat()
end)

CreateConVar("stoppower_recovery_speed", 0.75, FCVAR_NOTIFY, "The slowdown recovered every second.")
local recovAmt = GetConVar("stoppower_recovery_speed"):GetFloat()
cvars.AddChangeCallback("stoppower_recovery_speed", function()
    recovAmt = GetConVar("stoppower_recovery_speed"):GetFloat()
end)

CreateConVar("stoppower_recovery_delay", 0.5, FCVAR_NOTIFY, "The number of seconds before recovery starts.")
CreateConVar("stoppower_autoreset_type", 1, FCVAR_NOTIFY, "0=no auto-reset, 1=on spawn, 2=on death")

hook.Add("PlayerHurt", "StoppingPowerSlowdown", function(ply, attacker, hpRemain, dmgTaken)
    if enabled then
        ply:ChangeStopPowerSlowdownMult(-dmgMult * dmgTaken, multMin)
        ply:SetRecoveryTime(CurTime() + GetConVar("stoppower_recovery_delay"):GetFloat())
    end
end)

hook.Add("PostPlayerDeath", "StoppingPowerDeathReset", function(ply)
    if enabled and GetConVar("stoppower_recovery_delay"):GetInt() == 2 then
        resetPlayer(ply)
    end
end)

hook.Add("PlayerSpawn", "StoppingPowerSpawnReset", function(ply, transition)
    if enabled and GetConVar("stoppower_recovery_delay"):GetInt() == 1 then
        resetPlayer(ply)
    end
end)

local lastRecovTick = 0.0
local recovTickDur = 0.05
hook.Add("Tick", "StoppingPowerSpeedup", function()
    if enabled then
        local delta = CurTime() - lastRecovTick

        if delta >= recovTickDur then
            lastRecovTick = CurTime()
            local recov = delta * recovAmt

            for _, ply in ipairs(player.GetAll()) do
                if ply:Alive() then
                    ply:ApplyStopPowerSlowdownMult(multMin)

                    local pRecovTick = ply:GetRecoveryTime()
                    if pRecovTick and lastRecovTick >= pRecovTick then
                        ply:ChangeStopPowerSlowdownMult(recov, multMin)
                    end
                end
            end
        end
    end
end)

function resetPlayer(ply)
    ply:ResetStopPowerMult()
    ply:ApplyStopPowerSlowdownMult(1.0)
end

function resetAllPlayers()
    for _, ply in ipairs(player.GetAll()) do
        resetPlayer(ply)
    end
end

concommand.Add("stoppower_reset_all_players", function(ply, cmd, args)
    resetAllPlayers()
end)

concommand.Add("stoppower_reset_all_players_slowwalk_to", function(ply, cmd, args)
    for _, ply in ipairs(player.GetAll()) do
        ply:SetSlowWalkSpeed(args[1])
    end
end)

concommand.Add("stoppower_reset_all_players_walk_to", function(ply, cmd, args)
    for _, ply in ipairs(player.GetAll()) do
        ply:SetWalkSpeed(args[1])
    end
end)

concommand.Add("stoppower_reset_all_players_run_to", function(ply, cmd, args)
    for _, ply in ipairs(player.GetAll()) do
        ply:SetRunSpeed(args[1])
    end
end)

concommand.Add("stoppower_reset_all_players_jump_to", function(ply, cmd, args)
    for _, ply in ipairs(player.GetAll()) do
        ply:SetJumpPower(args[1])
    end
end)

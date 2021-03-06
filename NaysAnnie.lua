local version = "0.04"

--[[          Auto Update          ]]
local autoupdateenabled = true
local UPDATE_SCRIPT_NAME = "Nay's Annie"
local UPDATE_HOST = "raw.github.com"
local UPDATE_PATH = "/Nayhorrorn/Nay-s-Github/master/Nays Annie"
local UPDATE_FILE_PATH = SCRIPT_PATH..GetCurrentEnv().FILE_NAME
local UPDATE_URL = "https://"..UPDATE_HOST..UPDATE_PATH

local ServerData
if autoupdateenabled then
    GetAsyncWebResult(UPDATE_HOST, UPDATE_PATH, function(d) ServerData = d end)
    function update()
        if ServerData ~= nil then
            local ServerVersion
            local send, tmp, sstart = nil, string.find(ServerData, "local version = \"")
            if sstart then
                send, tmp = string.find(ServerData, "\"", sstart+1)
            end
            if send then
                ServerVersion = tonumber(string.sub(ServerData, sstart+1, send-1))
            end

            if ServerVersion ~= nil and tonumber(ServerVersion) ~= nil and tonumber(ServerVersion) > tonumber(version) then
                DownloadFile(UPDATE_URL.."?nocache"..myHero.charName..os.clock(), UPDATE_FILE_PATH, function () print("<font color=\"#FF0000\"><b>"..UPDATE_SCRIPT_NAME..":</b> successfully updated. Reload (double F9) Please. ("..version.." => "..ServerVersion..")</font>") end)     
            elseif ServerVersion then
                print("<font color=\"#FF0000\"><b>"..UPDATE_SCRIPT_NAME..":</b> You have got the latest version: <u><b>"..ServerVersion.."</b></u></font>")
            end     
            ServerData = nil
        end
    end
    AddTickCallback(update)
end
----------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------

if myHero.charName ~="Annie" then return end
local MyMinionManager
local enemyMinions = minionManager(MINION_ENEMY, 900, myHero.visionPos, MINION_SORT_HEALTH_ASC)
local ts
local Qready, Wready, Rready, Eready = false
----------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------

function OnLoad()
    enemyMinions = minionManager(MINION_ENEMY, 650)
    ts = TargetSelector(TARGET_LESS_CAST_PRIORITY, 650, DAMAGE_MAGIC)
    Config = scriptConfig("Nay's Annie", "Nay's Annie")
    Config:addParam("drawCircle", "Draw Circle", SCRIPT_PARAM_ONOFF, true)
    Config:addParam("combo", "Combo mode", SCRIPT_PARAM_ONKEYDOWN, false, 32) 
    Config:addParam("AutoQFarm", "Auto farm Q", SCRIPT_PARAM_ONKEYDOWN, false, 67)
    Config:addParam("harass", "Harass", SCRIPT_PARAM_ONKEYDOWN, false, 97)
    Config:addTS(ts)
end
----------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------     
    
function OnTick()
    Cooldowncheck()
    if Config.AutoQFarm then
      AutoQFarm() --if auto farm Q is enabled by button press then use AutoQFarm function
    end
    if Config.combo then
        ts:update()
        if ts.target then
            Combo(ts.target)
        end
    end
           if Config.harass then
            ts:update()
            if ts.target then
                harass(ts.target)
            end
end
end
----------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------


 function AutoQFarm() --our farm function
    if not Qready then return end
    enemyMinions:update()
        for i, minion in pairs(enemyMinions.objects) do 
            if minion ~= nil and minion.valid and minion.team ~= myHero.team and not minion.dead and minion.visible and minion.health < getDmg("Q", minion, myHero) then --we check if we can kill it
                if Qready then
                CastSpell(_Q, minion) --and if we can, we kill it
            end
        end 
end
end
----------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------

function Cooldowncheck() -- Checks for your Cooldowns
    Qready = (myHero:CanUseSpell(_Q) == READY)
    Wready = (myHero:CanUseSpell(_W) == READY)
    Rready = (myHero:CanUseSpell(_R) == READY)
    Eready = (myHero:CanUseSpell(_E) == READY)
end
----------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------

function Combo(unit) -- This function handles our combo
       if Qready then
        CastSpell(_Q, unit)
      elseif Wready then 
        CastSpell(_W, unit.x, unit.z)
       elseif Rready then
        CastSpell(_R, unit.x, unit.z)
    end
end
----------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------
function harass(unit)
    if Qready then
        CastSpell(_Q, unit)
        elseif Wready then
            CastSpell(_W, unit.x, unit.z)
            elseif Eready then
                CastSpell(_W)
            end
        end
----------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------

function OnDraw()
    if Config.drawCircle then
        DrawCircle(myHero.x, myHero.y, myHero.z, 650, 0x0101DF)
    end
end

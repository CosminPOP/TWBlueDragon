local TWBD = CreateFrame('Frame')

local TWWingsAnimation = CreateFrame("Frame")

TWBD:RegisterEvent("COMBAT_TEXT_UPDATE")
TWBD:RegisterEvent("PLAYER_REGEN_DISABLED")
TWBD:RegisterEvent("PLAYER_REGEN_ENABLED")
TWBD.combat = false

--TWBD.icon = 'Interface\\Icons\\Spell_Holy_Renew'
TWBD.icon = 'Interface\\Icons\\INV_Misc_Head_Dragon_Blue'
--TWBD.icon = 'Interface\\Icons\\Spell_Nature_Rejuvenation'
--TWBD.DB_Name = 'Renew'
TWBD.DB_Name = 'Aura of the Blue Dragon'
--TWBD.DB_Name = 'Rejuvenation'

TWBD.lastTimeLeft = 2000
TWBD.lastTime = 2000

TWBD.animFrame = 0
TWBD.maxAnimFrames = 40
TWBD.animate = false

TWBD:SetScript("OnUpdate", function()
    if not TWBD.combat then
        if getglobal('TWBlueDragon'):IsVisible() then
            getglobal('TWBlueDragon'):Hide()
        end
        return false
    end
    if TWBD.lastTime == GetTime() then
        return
    end
    for j = 0, 31 do
        local timeleft = GetPlayerBuffTimeLeft(GetPlayerBuff(j, "HELPFUL"))
        local texture = GetPlayerBuffTexture(GetPlayerBuff(j, "HELPFUL"))

        if texture then
            if texture == TWBD.icon then

                --proc during proc detection
                if math.floor(timeleft) > TWBD.lastTimeLeft then
                    TWBD.combatProcs = TWBD.combatProcs + 1
                    TWBD.animate = true
                end

                if TWBD.animate then
                    if TWBD.animFrame < TWBD.maxAnimFrames then
                        TWBD.animFrame = TWBD.animFrame + 1
                        getglobal('TWBlueDragonIcon'):SetWidth(64 + 16 * (TWBD.animFrame / TWBD.maxAnimFrames));
                        getglobal('TWBlueDragonIcon'):SetHeight(64 + 16 * (TWBD.animFrame / TWBD.maxAnimFrames));
                    else
                        TWBD.animate = false
                        TWBD.animFrame = 0
                        getglobal('TWBlueDragonIcon'):SetWidth(64);
                        getglobal('TWBlueDragonIcon'):SetHeight(64);
                    end
                end

                getglobal('TWBlueDragonTimeLeft'):SetText(math.floor(timeleft))
                getglobal('TWBlueDragonProcsPerCombat'):SetText(TWBD.combatProcs)

                TWBD.lastTimeLeft = math.floor(timeleft)
                TWBD.lastTime = GetTime()
            end
        end
    end
end)

TWBD.combatProcs = 0

TWBD:SetScript("OnEvent", function()
    if event then
        if event == "PLAYER_REGEN_ENABLED" then
            --left combat
            if TWBD.combatProcs > 0 then
                DEFAULT_CHAT_FRAME:AddMessage("|cff0070de[TWBlueDragon]" .. FONT_COLOR_CODE_CLOSE .. ": " .. TWBD.combatProcs .. ' time(s) last fight.', 0, 1, 0)
            end
            TWBD.combatProcs = 0
            TWBD.combat = false
            TWBD.lastTimeLeft = 2000
        end
        if event == "PLAYER_REGEN_DISABLED" then
            --entered combat
            TWBD.combatProcs = 0
            TWBD.combat = true
        end
        if event == "COMBAT_TEXT_UPDATE" and arg1 == "AURA_START" and arg2 == TWBD.DB_Name then
            if not TWBD.combat then
                return false
            end
            --getglobal('TWBlueDragon'):Show()
            getglobal('TWBlueDragon'):SetAlpha(0.5)
            TWBD.combatProcs = TWBD.combatProcs + 1
            TWWingsAnimation.blueDragon = true
            TWWingsAnimation:Show()
        end
        if event == "COMBAT_TEXT_UPDATE" and arg1 == "AURA_END" and arg2 == TWBD.DB_Name then
            getglobal('TWBlueDragon'):Hide()
            TWBD.lastTimeLeft = 2000

            TWWingsAnimation.blueDragon = false
            TWWingsAnimation:Hide()
        end
    end
end)

TWWingsAnimation:Hide()
TWWingsAnimation.innerFocus = false
TWWingsAnimation.blueDragon = false

TWWingsAnimation.scale = 1
TWWingsAnimation.direction = 1

TWWingsAnimation:SetScript("OnShow", function()
    this.startTime = GetTime()
    if TWWingsAnimation.innerFocus then
        getglobal('TWBDWingsTTop'):Show()
    else
        getglobal('TWBDWingsTTop'):Hide()
    end
    if TWWingsAnimation.blueDragon then
        getglobal('TWBDWingsTLeft'):Show()
        getglobal('TWBDWingsTRight'):Show()
    else
        getglobal('TWBDWingsTLeft'):Hide()
        getglobal('TWBDWingsTRight'):Hide()
    end
end)

TWWingsAnimation:SetScript("OnHide", function()
    TWWingsAnimation.scale = 1
    TWWingsAnimation.direction = 1

    getglobal('TWBDWingsTTop'):Hide()
    getglobal('TWBDWingsTLeft'):Hide()
    getglobal('TWBDWingsTRight'):Hide()
end)

TWWingsAnimation:SetScript("OnUpdate", function()
    local plus = 0.02 --seconds
    local gt = GetTime() * 1000
    local st = (this.startTime + plus) * 1000
    if gt >= st then
        TWWingsAnimation.scale = TWWingsAnimation.scale + 0.005 * TWWingsAnimation.direction

        if TWWingsAnimation.scale >= 1.1 then
            TWWingsAnimation.direction = -1
        end
        if TWWingsAnimation.scale <= 1 then
            TWWingsAnimation.direction = 1
        end
        getglobal('TWBDWings'):SetScale(TWWingsAnimation.scale)
        getglobal('TWBDWings'):SetAlpha(TWWingsAnimation.scale - 0.5)
        this.startTime = GetTime()
    end
end)

function start_wings_anim()
    TWWingsAnimation:Show()
end

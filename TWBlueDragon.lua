local TWBD = CreateFrame('Frame')


TWBD:RegisterEvent("UNIT_AURA")
TWBD:RegisterEvent("PLAYER_REGEN_DISABLED")
TWBD:RegisterEvent("PLAYER_REGEN_ENABLED")

--local icon = 'Interface\\Icons\\Spell_Holy_Renew'
local icon = 'Interface\\Icons\\INV_Misc_Head_Dragon_Blue'

local TBD_TimerFrame = CreateFrame('Frame')
TBD_TimerFrame:Hide()
TBD_TimerFrame:SetScript("OnUpdate", function()
    for j = 0, 31 do
        local timeleft = GetPlayerBuffTimeLeft(GetPlayerBuff(j, "HELPFUL"))
        local texture = GetPlayerBuffTexture(GetPlayerBuff(j, "HELPFUL"))

        if texture then
            if texture == icon then
                getglobal('TWBlueDragonTimeLeft'):SetText(math.floor(timeleft))
            end
        end
    end
end)

TBD_TimerFrame.combatProcs = 0
TBD_TimerFrame.hasBlueDragon = false

TWBD:SetScript("OnEvent", function()
    if event then
        if event == "PLAYER_REGEN_ENABLED" then --left combat
            if TBD_TimerFrame.combatProcs > 0 then
                DEFAULT_CHAT_FRAME:AddMessage("|cff0070de[TWBlueDragon]" .. FONT_COLOR_CODE_CLOSE .. ": " .. TBD_TimerFrame.combatProcs .. ' time(s) last fight.', 0, 1, 0)
            end
            TBD_TimerFrame.combatProcs = 0
        end
        if event == "PLAYER_REGEN_DISABLED" then --entered combat
            TBD_TimerFrame.combatProcs = 0
        end
        if event == "UNIT_AURA" then
            if arg1 == 'player' then
                for j = 0, 31 do
                    local B = UnitBuff("player", j);
                    local foundBD = false
                    if B then
                        if B == icon then
                            foundBD = true
                            getglobal('TWBlueDragon'):Show()
                            getglobal('TWBlueDragon'):SetAlpha(0.5)
                            TBD_TimerFrame:Show()
                            if not TBD_TimerFrame.hasBlueDragon then
                                TBD_TimerFrame.combatProcs = TBD_TimerFrame.combatProcs + 1
                                TBD_TimerFrame.hasBlueDragon = true
                            end
                            getglobal('TWBlueDragonProcsPerCombat'):SetText(TBD_TimerFrame.combatProcs)
                            return false
                        end
                    end
                    if not foundBD then
                        TBD_TimerFrame.hasBlueDragon = false
                    end
                end
                if getglobal('TWBlueDragon'):IsVisible() then
                    getglobal('TWBlueDragon'):Hide()
                    TBD_TimerFrame:Hide()
                end
            end
        end
    end
end)

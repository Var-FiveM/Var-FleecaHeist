Fleeca.BanksRobbed = {}

print("^2[FLEECA] - Var-Fleeca started successfully^7")

if Fleeca.Framework.ESX then
    ESX = exports["es_extended"]:getSharedObject()
elseif Fleeca.Framework.QBCore then
    QBCore = exports['qb-core']:GetCoreObject()
end

local function OpenDoor(getObjdoor, doorpos)
    TriggerClientEvent("Fleeca:OpenDoor", -1, getObjdoor, doorpos)
end

local function CloseDoor(getObjdoor, doorpos)
    TriggerClientEvent("Fleeca:CloseDoor", -1, getObjdoor, doorpos)
end

local function SetCooldown(id)
    Fleeca.BanksRobbed[id] = os.time()
end

local function GetCoolDown(id)
    if Fleeca.Framework.ESX then
        local Player = ESX.GetPlayerFromId(source)
        if Fleeca.BanksRobbed[id] then
            if (os.time() - Fleeca.CoolDown) > Fleeca.BanksRobbed[id] then
                TriggerClientEvent("Fleeca:BinginDrill", source)
            else
                TriggerClientEvent("esx:showNotification", source, Fleeca.Locale.BankCoolDown)
            end
        else
            if Fleeca.RemoveItem then
                Player.removeInventoryItem(Fleeca.ItemDrill, 1)
            end
            TriggerClientEvent("Fleeca:BinginDrill", source)
        end
    elseif Fleeca.Framework.QBCore then
        local Player = QBCore.Functions.GetPlayer(source)
        if Fleeca.BanksRobbed[id] then
            if (os.time() - Fleeca.CoolDown) > Fleeca.BanksRobbed[id] then
                TriggerClientEvent("Fleeca:BinginDrill", source)
            else
                TriggerClientEvent('QBCore:Notify', source, Fleeca.Locale.BankCoolDown, 'error')
            end
        else
            if Fleeca.RemoveItem then
                Player.Functions.RemoveItem(Fleeca.ItemDrill, 1, 1)
            end
            TriggerClientEvent("Fleeca:BinginDrill", source)
        end
    end
end

local function GiveMoney(money)
    if Fleeca.Framework.ESX then
        local Player = ESX.GetPlayerFromId(source)
        if Player then
            Player.addAccountMoney(Fleeca.MoneyType, money)
        end
    elseif Fleeca.Framework.QBCore then
        local Player = QBCore.Functions.GetPlayer(source)
        if Player then
            Player.Functions.AddMoney(Fleeca.MoneyType, money)
        end
    end
end

local function CheckCopsOnDuty(source)
    if Fleeca.Framework.ESX then
        local Players = ESX.GetPlayers()
        local CopsOnDuty = Fleeca.CopsOnDuty
    
        for i = 1, #Players do
            local player = ESX.GetPlayerFromId(Players[i])
            if player.job.name == Fleeca.CopsJobName then
                CopsOnDuty = CopsOnDuty + 1
            end
        end
    
        if CopsOnDuty >= Fleeca.RequiredCops then
            TriggerClientEvent("Fleeca:StartDrill", source)
        else
            TriggerClientEvent("esx:showNotification", source, Fleeca.Locale.NoCops)
        end
    elseif Fleeca.Framework.QBCore then
        local Players = QBCore.Functions.GetPlayers()
        local CopsOnDuty = Fleeca.CopsOnDuty
    
        for i = 1, #Players do
            local Player = QBCore.Functions.GetPlayer(Players[i])
            if Player.Player.job.name == Fleeca.CopsJobName then
                CopsOnDuty = CopsOnDuty + 1
            end
        end
    
        if CopsOnDuty >= Fleeca.RequiredCops then
            TriggerClientEvent("Fleeca:StartDrill", source)
        else
            TriggerClientEvent('QBCore:Notify', source, Fleeca.Locale.NoCops, 'error')
        end
    end
end

RegisterServerEvent("Fleeca:OpenDoor")
AddEventHandler("Fleeca:OpenDoor", OpenDoor)

RegisterServerEvent("Fleeca:CloseDoor")
AddEventHandler("Fleeca:CloseDoor", CloseDoor)

RegisterServerEvent("Fleeca:SetCooldown")
AddEventHandler("Fleeca:SetCooldown", SetCooldown)

RegisterServerEvent("Fleeca:GetCoolDown")
AddEventHandler("Fleeca:GetCoolDown", GetCoolDown)

RegisterServerEvent("Fleeca:GiveMoney")
AddEventHandler("Fleeca:GiveMoney", GiveMoney)


if Fleeca.Framework.ESX then
    ESX.RegisterUsableItem(Fleeca.ItemDrill, function(source)
        CheckCopsOnDuty(source)
    end)
elseif Fleeca.Framework.QBCore then
    QBCore.Functions.CreateUseableItem(Fleeca.ItemDrill, function(source, item)
        local Player = QBCore.Functions.GetPlayer(source)
        if not Player.Functions.GetItemByName(item.name) then return end

        CheckCopsOnDuty(source)
    end)
end
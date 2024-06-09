if Fleeca.Framework.ESX then
    ESX = exports["es_extended"]:getSharedObject()
elseif Fleeca.Framework.QBCore then
    QBCore = exports['qb-core']:GetCoreObject()
end

Fleeca.dict = "anim@heists@fleeca_bank@drilling"
Fleeca.getVaria = 0
Fleeca.prEffect = "FM_Mission_Controler"
Fleeca.moove = 0
Fleeca.nFleeca = 0
Fleeca.ObjectDrill = nil
Fleeca.ObjectTel = nil
Fleeca.SynchroS = nil
Fleeca.ScalformMoov = nil
Fleeca.netScal = nil
Fleeca.ObjectBag = nil
Fleeca.ObjectDoorid = nil 
Fleeca.ObjectDooridPos = nil
Fleeca.OpenDoor = false 

RegisterNetEvent("Fleeca:OpenDoor")
AddEventHandler("Fleeca:OpenDoor", function(prop, doorpos)
    if prop ~= nil then
        local playerCoords = GetEntityCoords(PlayerPedId())
        local maxDistance = 10.0

        if Vdist(playerCoords, doorpos) <= maxDistance then
            PlaySoundFromCoord(-1, "vault", doorpos.x, doorpos.y, doorpos.z, "HACKING_DOOR_UNLOCK_SOUNDS", 1, 30, 0)
        end

        local rotationCount = 1800
        local rotationStep = 0.05

        Citizen.Wait(800)

        for count = 1, rotationCount do
            local newRotation = GetEntityHeading(prop) - rotationStep
            SetEntityHeading(prop, newRotation)
            Citizen.Wait(3)
        end

        FreezeEntityPosition(prop, true)
        Fleeca.OpenDoor = true
    end
end)

RegisterNetEvent("Fleeca:CloseDoor")
AddEventHandler("Fleeca:CloseDoor", function(prop, doorpos)
    if prop ~= nil and Fleeca.OpenDoor then
        local playerCoords = GetEntityCoords(PlayerPedId())
        local maxDistance = 10.0

        if Vdist(playerCoords, doorpos) <= maxDistance then
            PlaySoundFromCoord(-1, "vault", doorpos.x, doorpos.y, doorpos.z, "HACKING_DOOR_UNLOCK_SOUNDS", 1, 30, 0)
        end

        local rotationCount = 1800
        local rotationStep = 0.05

        Citizen.Wait(800)

        for count = 1, rotationCount do
            local newRotation = GetEntityHeading(prop) + rotationStep
            SetEntityHeading(prop, newRotation)
            Citizen.Wait(3)
        end

        FreezeEntityPosition(prop, true)
        Fleeca.OpenDoor = false
    end
end)

RegisterNetEvent("Fleeca:StartDrill")
AddEventHandler("Fleeca:StartDrill", function()
    Fleeca:StartFleecaHeist()
end)

RegisterNetEvent("Fleeca:BinginDrill")
AddEventHandler("Fleeca:BinginDrill", function()
    TriggerServerEvent("Var:NotifPoliceHeist", GetEntityCoords(PlayerPedId()))
    Fleeca:StartCallScal()
    TriggerServerEvent("Fleeca:SetCooldown", Fleeca.nFleeca.id)
end)

RegisterNetEvent("Fleeca:ClientBankHeist")
AddEventHandler("Fleeca:ClientBankHeist", function(action, data)
    if action == 1 then
        Fleeca.nFleeca = data
        TriggerServerEvent("Fleeca:GetCoolDown", Fleeca.nFleeca.id)
    elseif action == 2 then
        if data then
            local pPed = PlayerPedId()
            local pCoords, pRot = GetEntityCoords(pPed), GetEntityRotation(pPed)
            local animDict = 'anim@heists@ornate_bank@hack'
        
            for k, v in pairs(LaptopAnimation['objects']) do
                LoadModel(v)
                LaptopAnimation['sceneObjects'][k] = CreateObject(GetHashKey(v), pCoords, 1, 1, 0)
            end
        
            for i =1, #LaptopAnimation['animations'] do
                LaptopAnimation['scenes'][i] = NetworkCreateSynchronisedScene(pCoords.xy, pCoords.z + 0.4, pRot, 2, true, false, 1065353216, 0, 1.3)
                NetworkAddPedToSynchronisedScene(pPed, LaptopAnimation['scenes'][i], animDict, LaptopAnimation['animations'][i][1], 1.5, -4.0, 1, 16, 1148846080, 0)
                NetworkAddEntityToSynchronisedScene(LaptopAnimation['sceneObjects'][1], LaptopAnimation['scenes'][i], animDict, LaptopAnimation['animations'][i][3], 4.0, -8.0, 1)
            end
        
            NetworkStartSynchronisedScene(LaptopAnimation['scenes'][2])
            Wait(3000)
            StartHotwire(function(status)
                if status then
                    Fleeca:OpenDoorFl(data.id)
                end
            end)
            DeleteObject(LaptopAnimation['sceneObjects'][1])
        end
    elseif action == 3 then
        local minAmount = data.min
        local maxAmount = data.max
        local moneyToGive = math.random(minAmount, maxAmount)
        TriggerServerEvent("Fleeca:GiveMoney", moneyToGive)

        if Fleeca.Framework.ESX then
            ESX.ShowNotification(Fleeca.Locale.GiveMoney..moneyToGive)
        elseif Fleeca.Framework.QBCore then
            QBCore.Functions.Notify(Fleeca.Locale.GiveMoney..moneyToGive, 'success', 5000)
        end

        Wait(15 * 60 * 1000)
        
        if Fleeca.ObjectDoorid ~= nil and Fleeca.ObjectDooridPos ~= nil then
            TriggerServerEvent("Fleeca:CloseDoor", Fleeca.ObjectDoorid, Fleeca.ObjectDooridPos)
        end
    end
end)
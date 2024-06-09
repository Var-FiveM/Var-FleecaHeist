function Fleeca:SetScaleformParams(scaleform, data)
	data = data or {}
	for k,v in pairs(data) do
		PushScaleformMovieFunction(scaleform, v.name)
		if v.param then
			for _,par in pairs(v.param) do
				if math.type(par) == "integer" then
					PushScaleformMovieFunctionParameterInt(par)
				elseif type(par) == "boolean" then
					PushScaleformMovieFunctionParameterBool(par)
				elseif math.type(par) == "float" then
					PushScaleformMovieFunctionParameterFloat(par)
				elseif type(par) == "string" then
					PushScaleformMovieFunctionParameterString(par)
				end
			end
		end
		if v.func then v.func() end
		PopScaleformMovieFunctionVoid()
	end
end

function Fleeca:DrawTopNotification(txt, beep)
	SetTextComponentFormat("jamyfafi")
	AddTextComponentString(txt)
	if string.len(txt) > 99 and AddLongString then
		AddLongString(txt)
	end
	DisplayHelpTextFromStringLabel(0, 0, beep, -1)
end

function Fleeca:TaskSynchronizedTasks(ped, animData, clearTasks)
	for _,v in pairs(animData) do
		if not HasAnimDictLoaded(v.anim[1]) then
			RequestAnimDict(v.anim[1])
			while not HasAnimDictLoaded(v.anim[1]) do Citizen.Wait(0) end
		end
	end

	local _, sequence = OpenSequenceTask(0)
	for _,v in pairs(animData) do
		TaskPlayAnim(0, v.anim[1], v.anim[2], 2.0, -2.0, math.floor(v.time or -1), v.flag or 48, 0, 0, 0, 0)
	end

	CloseSequenceTask(sequence)
	if clearTasks then ClearPedTasks(ped) end
	TaskPerformSequence(ped, sequence)
	ClearSequenceTask(sequence)

	for _,v in pairs(animData) do
		RemoveAnimDict(v.anim[1])
	end

	return sequence
end

function Fleeca:CreateScaleform(name, data)
	if not name or string.len(name) <= 0 then return end
	local scaleform = RequestScaleformMovie(name)

	while not HasScaleformMovieLoaded(scaleform) do
		Citizen.Wait(0)
	end

	Fleeca:SetScaleformParams(scaleform, data)
	return scaleform
end

function Fleeca:RequestAndWaitDict(dictName)
	if dictName and DoesAnimDictExist(dictName) and not HasAnimDictLoaded(dictName) then
		RequestAnimDict(dictName)
		while not HasAnimDictLoaded(dictName) do 
            Citizen.Wait(100) 
        end
	end
end

function Fleeca:RequestAndWaitModel(modelName)
	if modelName and IsModelInCdimage(modelName) and not HasModelLoaded(modelName) then
		RequestModel(modelName)
		while not HasModelLoaded(modelName) do
            Citizen.Wait(100) 
        end
	end
end

function Fleeca:PlayerHasBag()
    return GetPedDrawableVariation(PlayerPedId(), 5) ~= 0 
end

function Fleeca:FinFleeca()
    local pPed1 = GetPlayerPed(-1)
    local nuFleeca = Fleeca.posFleeca[Fleeca.nFleeca.id]
    local fReward = nuFleeca.rewardAnim
    local fMoneyWin = nuFleeca.moneywin
    local posReward = vec3(fReward.x, fReward.y, fReward.z)

    DetachEntity(Fleeca.ObjectBag, 1, 1)
    StopEntityAnim(Fleeca.ObjectBag, "bag_drill_straight_idle", "anim@heists@fleeca_bank@drilling", 3)

    Fleeca.moove = 3

    Fleeca.SynchroS = NetworkCreateSynchronisedScene(posReward, 0.0, 0.0, fReward.a, 2, true, false, 1065353216, 0, 1065353216)
    NetworkAddPedToSynchronisedScene(pPed1, Fleeca.SynchroS, Fleeca.dict, "outro", 1000.0, -8.0, 3341, 16, 1148846080, 0)
    NetworkAddEntityToSynchronisedScene(Fleeca.ObjectBag, Fleeca.SynchroS, Fleeca.dict, "bag_outro", 1000.0, -1.5, 0)
    NetworkForceLocalUseOfSyncedSceneCamera(Fleeca.SynchroS, Fleeca.dict, "outro_cam")
    N_0xc9b43a33d09cada7(Fleeca.SynchroS)
    NetworkStartSynchronisedScene(Fleeca.SynchroS)

    Citizen.Wait(0)
    local NetCSy = NetworkConvertSynchronisedSceneToSynchronizedScene(Fleeca.SynchroS)
    
    while IsSynchronizedSceneRunning(NetCSy) and GetSynchronizedScenePhase(NetCSy) <= 0.9 do
        Citizen.Wait(0)
    end

    if GetSynchronizedScenePhase(NetCSy) < 0.9 then
        Citizen.Wait(5000)
    end

    NetworkStopSynchronisedScene(Fleeca.SynchroS)
    SetPedComponentVariation(pPed1, 5, Fleeca.getVaria or 0, 0, 2)
    FreezeEntityPosition(pPed1, false)

    Fleeca:AnimStartFin()
    TriggerEvent("Fleeca:ClientBankHeist", 3, fMoneyWin)
end

function Fleeca:StartFleecaHeist()
    local pedpeds, pedPos = PlayerPedId(), GetEntityCoords(PlayerPedId())
    local FleecaIn

    for k, v in pairs(Fleeca.posFleeca) do
        local distanceF = GetDistanceBetweenCoords(v.hackPos, pedPos)
        if distanceF < 3 and (not FleecaIn or distanceF <= GetDistanceBetweenCoords(Fleeca.posFleeca[FleecaIn].hackPos, pedPos)) then
            FleecaIn = k
        end
    end

    if not FleecaIn then
        if Fleeca.Framework.ESX then
            ESX.ShowNotification(Fleeca.Locale.NotInFleeca)
        elseif Fleeca.Framework.QBCore then
            QBCore.Functions.Notify(Fleeca.Locale.NotInFleeca, 'error', 5000)
        end
        return
    end

    if not Fleeca:PlayerHasBag() and Fleeca.NeedBag then
        if Fleeca.Framework.ESX then
            ESX.ShowNotification(Fleeca.Locale.NeedBag)
        elseif Fleeca.Framework.QBCore then
            QBCore.Functions.Notify(Fleeca.Locale.NeedBag, 'info', 5000)
        end
        return
    end

    TriggerEvent("Fleeca:ClientBankHeist", 1, {id = FleecaIn})
end

function Fleeca:StartCallScal()
    RequestScriptAudioBank([[DLC_MPHEIST\HEIST_FLEECA_DRILL]], false)
    RequestScriptAudioBank([[DLC_MPHEIST\HEIST_FLEECA_DRILL_2]], false)
    RequestScriptAudioBank("Vault_Door", false)
    TriggerEvent("Fleeca:ClientBankHeist", 2, Fleeca.nFleeca)
    Fleeca.moove = 1
    Citizen.CreateThread(function()
        local Scal1 = 0.0
        local Scal2 = 0.0
        local Scal3 = 0.0
        local Scal4 = 0.0
        local RaterScal = false
        local SoundScal = false
        local SoundId = 1.0
        while Fleeca.nFleeca ~= 0 do
            Citizen.Wait(0)
            local FleecaIds = Fleeca.posFleeca[Fleeca.nFleeca.id]
            local pedPDpos = GetEntityCoords(PlayerPedId())
            if IsEntityDead(PlayerPedId()) or not FleecaIds or GetDistanceBetweenCoords(pedPDpos, FleecaIds.hackPos) > 30 then
                Fleeca:AnimStartFin(2)
                return
            end
            if Fleeca.moove == 1 then
                DrawMarker(25, FleecaIds.rewardPos, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.4, 0.4, 0.25, 0, 141, 255, 70, 0, 0, 2, 0,0, 0, 0)
                local disTance = GetDistanceBetweenCoords(pedPDpos, FleecaIds.rewardPos)
                if disTance < 1.3 then
                    Fleeca:DrawTopNotification(Fleeca.Locale.UseDrill)
                    
                    if IsControlJustReleased(0, 51) then
                        Fleeca:StartScalform()
                    end
                end
            elseif Fleeca.moove == 2 and Fleeca.ScalformMoov and HasScaleformMovieLoaded(Fleeca.ScalformMoov) then
                DrawScaleformMovieFullscreen(Fleeca.ScalformMoov, 255, 255, 255, 255)
                DrawScaleformMovieFullscreen(helpScaleform, 255, 255, 255, 255)
                HideHudAndRadarThisFrame()
                DisableControlAction(0, 24, true)
                DisableControlAction(0, 25, true)
                local Press237, Press238 = IsControlPressed(0, 237), IsControlPressed(0, 238)
                local StartSca = false
                if Press237 and ((Scal4 >= 0.225 and Scal4 <= 0.325 and Scal1 <= 0.325) or (Scal4 >= 0.35 and Scal4 <= 0.45 and Scal1 <= 0.45) or (Scal4 >= 0.5 and Scal4 <= 0.6 and Scal1 <= 0.6) or (Scal4 >= 0.625 and Scal4 <= 0.725 and Scal1 <= 0.725)) then
                    StartSca = true;
                    if SoundId ~= 0.5 then
                        SoundId = 0.5
                        SetVariableOnSound(drillSoundID, "DrillState", 0.5)
                    end
                end
                if not StartSca and SoundId == 0.5 then
                    SoundId = 0.0
                    SetVariableOnSound(drillSoundID, "DrillState", 0.0)
                end
                if IsControlJustPressed(0, 51) and not RaterScal then
                    SoundScal = not SoundScal;
                    Fleeca:stopsoundandparticle(SoundScal)
                end
                if SoundScal and Scal2 < 0.5 then
                    Scal2 = math.max(0, math.min(0.5, Scal2 + 0.005))
                elseif not SoundScal and Scal2 > 0.0 then
                    Scal2 = math.max(0, math.min(0.5, Scal2 - 0.005))
                end
                if not RaterScal and Press237 and SoundScal then
                    Scal4 = math.max(0, math.min(1.0, Scal4 + 0.001 * (StartSca and 0.5 or 1.0)))
                    if Scal4 > Scal1 then
                        Scal1 = math.max(0, math.min(1.0, Scal1 + 0.001))
                    end
                    if Scal1 > 0.1 and Scal1 - Scal4 <= 0.01 then
                        Scal3 = math.max(0, math.min(1.0, Scal3 + (StartSca and 0.005 or 0.002)))
                    end
                end
                if not RaterScal and Press238 and SoundScal then
                    Scal4 = math.max(0, math.min(1.0, Scal4 - 0.0025))
                end
                if not Press238 and not Press237 and Scal3 > 0.0 then
                    Scal3 = math.max(0, math.min(1.0, Scal3 - 0.0015))
                end
                if Scal3 > 0.7 and not RaterScal then
                    RaterScal = true
                    PlaySoundFrontend(-1, "Drill_Pin_Break", "DLC_HEIST_FLEECA_SOUNDSET", true)
                    Fleeca:stopsoundandparticle()
                elseif RaterScal then
                    if Scal3 < 0.1 then
                        RaterScal = false
                    end
                    Scal2 = 0.0
                    Scal4 = math.max(0, math.min(1.0, Scal4 - 0.0075))
                end
                if Scal1 >= 0.96 then
                    PlaySoundFromEntity(-1, "Drill_Jam", PlayerPedId(), "DLC_HEIST_FLEECA_SOUNDSET", 1, 20)
                    SetScaleformMovieAsNoLongerNeeded(Fleeca.ScalformMoov)
                    Fleeca.ScalformMoov = nil
                    Fleeca:stopsoundandparticle()
                    Fleeca:FinFleeca()
                end
                CallScaleformMovieFunctionFloatParams(Fleeca.ScalformMoov, "SET_SPEED", Scal2 * (StartSca and 0.5 or 1.0), -1082130432,-1082130432, -1082130432, -1082130432)
                CallScaleformMovieFunctionFloatParams(Fleeca.ScalformMoov, "SET_HOLE_DEPTH", Scal1, -1082130432, -1082130432,-1082130432, -1082130432)
                CallScaleformMovieFunctionFloatParams(Fleeca.ScalformMoov, "SET_DRILL_POSITION", Scal4, -1082130432, -1082130432,-1082130432, -1082130432)
                CallScaleformMovieFunctionFloatParams(Fleeca.ScalformMoov, "SET_TEMPERATURE", Scal3, -1082130432, -1082130432,-1082130432, -1082130432)
            end
        end
    end)
end

function Fleeca:OpenDoorFl(id)
    local idFleeca = Fleeca.posFleeca[id]
    local doorpos = idFleeca.vaultPos
    local getObjdoor = GetClosestObjectOfType(doorpos.x, doorpos.y, doorpos.z, 8.0, GetHashKey(idFleeca.vaultdoor))

    if getObjdoor and DoesEntityExist(getObjdoor) then
        local dict = "anim@heists@fleeca_bank@bank_vault_door"
        Fleeca:RequestAndWaitDict(dict)
        PlayEntityAnim(getObjdoor, "bank_vault_door_opens", dict, 4.0, false, true, false, 0.0, 8)
        Fleeca.ObjectDoorid = getObjdoor
        Fleeca.ObjectDooridPos = doorpos
        TriggerServerEvent("Fleeca:OpenDoor", getObjdoor, doorpos)
    end
end

function Fleeca:StartScalform()
    local pPed2 = GetPlayerPed(-1)
    local numFleeca = Fleeca.posFleeca[Fleeca.nFleeca.id]
    Fleeca:RequestAndWaitDict(Fleeca.dict)
    RequestNamedPtfxAsset(Fleeca.prEffect)
    while not HasNamedPtfxAssetLoaded(Fleeca.prEffect) do
        Citizen.Wait(0)
    end
    Fleeca.moove = 2
    local PosRewards = numFleeca.rewardAnim
    local posRewarvec = vec3(PosRewards.x, PosRewards.y, PosRewards.z)

    Fleeca:RequestAndWaitModel("hei_prop_heist_drill")
    Fleeca:RequestAndWaitModel("hei_p_m_bag_var22_arm_s")
    local secur, getTime5 = false, GetGameTimer()
    while not secur and getTime5 + 3000 > GetGameTimer() do
        Wait(1000)
    end
    Fleeca.ObjectDrill = CreateObject(GetHashKey("hei_prop_heist_drill"), GetEntityCoords(pPed2), true)
    SetNetworkIdCanMigrate(ObjToNet(Fleeca.ObjectDrill), false)
    AttachEntityToEntity(Fleeca.ObjectDrill, pPed2, GetPedBoneIndex(pPed2, 28422), 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, false, false, false,false, 2, true)
    Fleeca.ObjectBag = CreateObject(GetHashKey("hei_p_m_bag_var22_arm_s"), GetEntityCoords(pPed2), true)
    SetNetworkIdCanMigrate(ObjToNet(Fleeca.ObjectBag), false)
    SetEntityVisible(Fleeca.ObjectBag, 0, 0)
    TaskMoveNetworkAdvanced(pPed2, "minigame_drilling", posRewarvec, 0.0, 0.0, PosRewards.a, 2, 0.5, 0, Fleeca.dict, 4)
    FreezeEntityPosition(pPed2, true)
    N_0x2208438012482a1a(pPed2, 0, 1)
    SetEntityVisible(Fleeca.ObjectBag, 1, 1)
    FreezeEntityPosition(Fleeca.ObjectBag, 0)
    Fleeca.getVaria = GetPedDrawableVariation(pPed2, 5)
    SetPedComponentVariation(pPed2, 5, 0, 0, 2)
    Fleeca.SynchroS = NetworkCreateSynchronisedScene(posRewarvec, 0.0, 0.0, PosRewards.a, 2, true, false, 1065353216, 0, 1065353216)
    NetworkAddEntityToSynchronisedScene(Fleeca.ObjectBag, Fleeca.SynchroS, Fleeca.dict, "bag_intro", 1000.0, -1.5, 0)
    NetworkForceLocalUseOfSyncedSceneCamera(Fleeca.SynchroS, Fleeca.dict, "intro_cam")
    N_0xc9b43a33d09cada7(Fleeca.SynchroS)
    NetworkStartSynchronisedScene(Fleeca.SynchroS)
    Citizen.Wait(0)
    local network = NetworkConvertSynchronisedSceneToSynchronizedScene(Fleeca.SynchroS)
    while IsSynchronizedSceneRunning(network) and GetSynchronizedScenePhase(network) <= 0.9 do
        Citizen.Wait(0)
    end
    if GetSynchronizedScenePhase(network) < 0.9 then
        Fleeca:AnimStartFin(2)
    end
    NetworkStopSynchronisedScene(Fleeca.SynchroS)
    Fleeca.SynchroS = nil
    AttachEntityToEntity(Fleeca.ObjectBag, pPed2, GetPedBoneIndex(pPed2, 60309), 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0, 0, 0, 0, 2, 1)
    ClearPedTasks(pPed2)
    TaskPlayAnim(pPed2, Fleeca.dict, "drill_straight_idle", 1000.0, -1.5, -1, 1)
    PlayEntityAnim(Fleeca.ObjectBag, "bag_drill_straight_idle", "anim@heists@fleeca_bank@drilling", 1000.0, true, 0, 0, 0, 0)
    ForceEntityAiAndAnimationUpdate(Fleeca.ObjectBag)
    Fleeca.ScalformMoov = Fleeca:CreateScaleform("drilling", {{name = "SET_SPEED",param = {0.1}},{name = "SET_HOLE_DEPTH",param = {0.6}},{name = "SET_DRILL_POSITION",param = {0.3}},{name = "SET_TEMPERATURE",param={0.0}}})
    helpScaleform = Fleeca:CreateScaleform("INSTRUCTIONAL_BUTTONS", 
    {
        {name = "CLEAR_ALL", param = {}},
        {name = "TOGGLE_MOUSE_BUTTONS", param = {0}},
        {name = "CREATE_CONTAINER", param = {}},
        {name = "SET_DATA_SLOT", param = {0, GetControlInstructionalButton(2, 51, 0), "Turn on/off"}}, 
        {name = "SET_DATA_SLOT", param = {1, GetControlInstructionalButton(2, 237, 0), "Push"}},
        {name = "SET_DATA_SLOT", param = {2, GetControlInstructionalButton(2, 238, 0), "Pull"}}, 
        {name = "DRAW_INSTRUCTIONAL_BUTTONS", param = {-1}}
    })
    Fleeca.moove = 2
end

function Fleeca:AnimStartFin(Ped)
    local pPed = GetPlayerPed(-1)

    local cleanupEntities = {
        Fleeca.ObjectTel,
        Fleeca.SynchroS,
        Fleeca.ObjectDrill,
        Fleeca.ObjectBag,
        Fleeca.ScalformMoov,
        helpScaleform,
        drillSoundID,
        Fleeca.netScal,
    }

    for _, entity in pairs(cleanupEntities) do
        if DoesEntityExist(entity) then
            DeleteEntity(entity)
        end
    end

    local animDicts = {
        "anim@heists@humane_labs@emp@hack_door",
        "anim@heists@fleeca_bank@bank_vault_door",
        Fleeca.dict,
    }

    for _, animDict in pairs(animDicts) do
        RemoveAnimDict(animDict)
    end

    local audioBanks = {
        [[DLC_MPHEIST\HEIST_FLEECA_DRILL]],
        [[DLC_MPHEIST\HEIST_FLEECA_DRILL_2]],
        "Vault_Door",
    }

    for _, audioBank in pairs(audioBanks) do
        ReleaseScriptAudioBank(audioBank, false)
    end

    if Fleeca.getVaria ~= 0 then
        SetPedComponentVariation(pPed, 5, Fleeca.getVaria, 0, 2)
    end

    if Fleeca.netScal then
        StopParticleFxLooped(Fleeca.netScal, 0)
        Fleeca.netScal = nil
        RemoveNamedPtfxAsset(Fleeca.prEffect)
    end

    SetModelAsNoLongerNeeded("prop_v_m_phone_01")
    TriggerEvent("Fleeca:HackingMinigame", 2)

    Fleeca.nFleeca = 0
    Fleeca.moove = 0
    Fleeca.getVaria = 0
end

function Fleeca:stopsoundandparticle(bool)
    if bool then
        UseParticleFxAssetNextCall(Fleeca.prEffect)
        Fleeca.netScal = StartNetworkedParticleFxLoopedOnEntity("scr_drill_debris", Fleeca.ObjectDrill, 0.0, -0.55, 0.01, -90.0, 0.0, 0.0, 0.5,1065353216, 1065353216, 0)
        SetParticleFxLoopedEvolution(Fleeca.netScal, "power", 0.3, 0)
        drillSoundID = GetSoundId()
        PlaySoundFromEntity(drillSoundID, "Drill", Fleeca.ObjectDrill, "DLC_HEIST_FLEECA_SOUNDSET", 1, 0)
    else
        StopSound(drillSoundID)
        drillSoundID = nil
        StopParticleFxLooped(Fleeca.netScal, 0)
        Fleeca.netScal = nil
    end
end

function LoadModel(model)
    if type(model) == 'number' then
        model = model
    else
        model = GetHashKey(model)
    end
    while not HasModelLoaded(model) do
        RequestModel(model)
        Citizen.Wait(0)
    end
end
Fleeca = {}

Fleeca.Framerwork = {
    ESX = true,
    QBCore = false
}

Fleeca.RemoveItem = true -- Remove Item when using
Fleeca.MoneyType = "black_money"
Fleeca.CopsOnDuty = 0
Fleeca.RequiredCops = 0
Fleeca.ItemDrill = "drill_1"
Fleeca.CopsJobName = "police"
Fleeca.CoolDown = 600

Fleeca.NeedBag = false -- If you need to have a bag to start Fleeca Heist

Fleeca.posFleeca = {
    {
        hackPos = vec3(146.84, -1046.07, 28.37),
        vaultPos = vec4(148.03, -1044.36, 29.51, -110.15),
        rewardPos = vector3(150.22, -1050.13, 28.35),
        vaultdoor = "v_ilev_gb_vauldr",
        moneywin = {
            min = 15000,
            max = 25000,
        },
        rewardAnim = {
            x = 150.9,
            y = -1049.9,
            z = 29.6,
            a = 250.0
        }
    },
    {
        hackPos = vector3(-1210.83, -336.52, 36.78),
        vaultPos = vec4(-1211.26, -344.56, 37.92, -63.14),
        rewardPos = vector3(-1205.39, -336.79, 36.76),
        vaultdoor = "v_ilev_gb_vauldr",
        moneywin = {
            min = 15000,
            max = 25000,
        },
        rewardAnim = {
            x = -1205.23,
            y = -336.26,
            z = 38.0,
            a = 296.42
        }
    },
    {
        hackPos = vector3(311.2, -284.43, 53.16),
        vaultPos = vec4(312.36, -282.73, 54.3, -110.13),
        rewardPos = vector3(314.83, -288.41, 53.14),
        vaultdoor = "v_ilev_gb_vauldr",
        moneywin = {
            min = 15000,
            max = 25000,
        },
        rewardAnim = {
            x = 315.22,
            y = -288.3,
            z = 54.37,
            a = 246.55
        }
    },
    {
        hackPos = vector3(-353.86, -55.3, 48.04),
        vaultPos = vec4(-352.74, -53.57, 49.18, -109.14),
        rewardPos = vector3(-350.19, -59.44, 48.02),
        vaultdoor = "v_ilev_gb_vauldr",
        moneywin = {
            min = 15000,
            max = 25000,
        },
        rewardAnim = {
            x = -349.76,
            y = -59.05,
            z = 49.25,
            a = 248.0
        }
    },
    {
        hackPos = vector3(1176.08, 2712.88, 37.09),
        vaultPos = vec4(1175.54, 2710.86, 38.23, 90.0),
        rewardPos = vector3(1171.31, 2715.73, 37.07),
        vaultdoor = "v_ilev_gb_vauldr",
        moneywin = {
            min = 15000,
            max = 25000,
        },
        rewardAnim = {
            x = 1170.98,
            y = 2715.07,
            z = 38.325,
            a = 90.0
        }
    },
    {
        hackPos = vector3(253.24, 228.44, 101.68),
        vaultPos = vec4(254.04, 225.16, 101.88, 90.0),
        rewardPos = vector3(265.76, 213.52, 101.68-0.98),
        vaultdoor = "v_ilev_bk_vaultdoor",
        moneywin = {
            min = 200000,
            max = 400000,
        },
        rewardAnim = {
            x = 266.25,
            y = 213.0,
            z = 102.1,
            a = 249.73
        }
    },
    {
        hackPos = vector3(-2957.4316, 480.4534, 15.7068),
        vaultPos = vec4(-2958.71, 481.95, 14.69, 44.4),
        rewardPos = vector3(-2954.0500, 486.0248, 14.6754),
        vaultdoor = "hei_prop_heist_sec_door",
        moneywin = {
            min = 75000,
            max = 80000,
        },
        rewardAnim = { 
            x =  -2953.98, 
            y = 486.36,
            z = 15.67,
            a = 360.0
        }
    },
    {
        hackPos = vector3(-105.52, 6470.84, 31.64),
        vaultPos = vec4(-105.28, 6472.92, 31.64, 90.0),
        rewardPos = vector3(-105.72, 6478.16, 31.64-0.98),
        vaultdoor = "v_ilev_cbankvaulgate01",
        moneywin = {
            min = 200000,
            max = 400000,
        },
        rewardAnim = {
            x = -105.88,
            y = 6478.95,
            z = 32.10,
            a = 45.17
        }
    }
}

Fleeca.Locale = {
    NotInFleeca = "You are not at a ~r~Fleeca Bank~s~.",
    NeedBag = "You ~r~must~s~ have a ~r~bag~s~.",
    UseDrill = "Press ~INPUT_CONTEXT~ to use your ~b~drill~s~.",
    BankCoolDown = "This bank has already been robbed.",
    NoCops = "The Brinks has just passed, there is no more money.",
    GiveMoney = "You got ~r~ $"
}

RegisterNetEvent("Var:NotifPoliceHeist") -- Server Event to notify the police (if you dont want it,dont edit this event)
AddEventHandler("Var:NotifPoliceHeist", function(Coords)
    print(Coords)
end)
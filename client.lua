local playerdataLoaded = false
local controlGround = false
local inGround = false

function playerLoaded()
    playerdataLoaded = true
end

CreateThread(function()
    while true do
        if NetworkIsPlayerActive(PlayerId()) then
            playerLoaded()
            break
        end
        Wait(1)
    end
end)

CreateThread(function()
    while true do
        local sleep = 2000
        if playerdataLoaded then
            sleep = 1000
            local ped = PlayerPedId()
            local coords = GetEntityCoords(ped)
            local pedInVeh = IsPedInAnyVehicle(ped, false)

            if pedInVeh then
                local veh = GetVehiclePedIsIn(ped, false)
                local seat = GetPedInVehicleSeat(veh, -1)
                local vehArmor = GetVehicleMod(veh, 16)
                local vehClass = GetVehicleClass(veh) == 15 and true or GetVehicleClass(veh) == 16 and true or GetVehicleClass(veh) == 8 and true or false

                if not vehClass then
                    if seat then
                        sleep = 25
                        local vehHeight = GetEntityHeightAboveGround(veh)
                        local vehFly = IsEntityInAir(veh)

                        if not controlGround then
                            if vehHeight >= Config.ExplosionHeight and vehFly then
                                local retval, groundz = GetGroundZFor_3dCoord(coords.x, coords.y, coords.z, 0)
                                local ground = GetEntityCoords(veh).z
                                if retval then
                                    if ground > groundz then
                                        controlGround = true
                                    end
                                else
                                    controlGround = true
                                end
                            end
                        else
                            sleep = 1
                            vehHeight = GetEntityHeightAboveGround(veh)
                            vehFly = IsEntityInAir(veh)
                            inGround = vehHeight < 2 and true or false
    
                            if inGround then
                                controlGround = false
                                SetVehicleEngineHealth(veh, 0)
                                SetVehiclePetrolTankHealth(veh, 0)
                                DetachVehicleWindscreen(veh)
                                SmashVehicleWindow(veh, 0)
                                AddExplosion(GetEntityCoords(veh), 7, 50.0, true, false, 5.0)
                                sleep = 500
                            end
                        end
                    end
                end
            else
                controlGround = false
                inGround = false
            end

        end
        Wait(sleep)
    end
end)
local noteDisplay = false
local morseDisplay = false
local autoWalk = false


if Config.Game == "RedM" then
    Citizen.CreateThread(function()
        while true do
            if IsControlJustPressed(0, 0x3C3DD371) then -- PgDwn
                if Config.Debug then
                    print("Command autowalk toggle executed")
                end
                ExecuteCommand("autowalk")
            end

            if IsControlJustPressed(0, 0x156F7119) then -- Backspace
                if Config.Debug then
                    print("Command removelast executed")
                end
                ExecuteCommand("removelast")
            end

            -- if IsControlPressed(0, 0x4AF4D473) or IsControlReleased(0, 0x4AF4D473) then -- Canc
            --     if Config.Debug then
            --         print("Command notepad executed")
            --     end
            --     ExecuteCommand("notepad")
            -- end
            Wait(0)
        end
    end)
end

if Config.AutoWalk then
    if Config.Game == "FiveM" then
        RegisterKeyMapping('autowalk', "Enable/Disable Autowalk", "keyboard", "F12")
    end
    RegisterCommand("autowalk", function()
        if autoWalk then
            autoWalk = false
        else
            autoWalk = true
        end
    end, false)
end

Citizen.CreateThread(function()
    while true do
        Wait(0)
        if autoWalk then
            if Config.Game == "FiveM" then
                SetControlNormal(0, 31, -1.0)
                if IsControlJustPressed(0, 129) then
                    autoWalk = false
                end
            else
                SetControlValueNextFrame(0, 0x8FD015D8, -1.0) -- W

                if Config.Debug then
                    print("Im autowalking")
                end

                if IsControlJustPressed(0, 0x8FD015D8) or IsControlJustPressed(0, 0x3C3DD371) then -- W or PgDwn
                    autoWalk = false
                    if Config.Debug then
                        print("Stops autowalking")
                    end
                end
            end
        end
    end
end)

function IsAllowed()
    local allowed = lib.callback.await("rt_notepad:checkAllowedPlayer", false)
    return allowed
end

if Config.Game == "FiveM" then
    RegisterKeyMapping('removeLast', "Delete older notepad paper", "keyboard", "BACK")
end

RegisterNetEvent("rt_notepad:addNote")
RegisterNetEvent("rt_notepad:setMorse")
RegisterNetEvent("main")

RegisterNetEvent("confirmSend")

RegisterCommand('v', function(source, args)
    local message = table.concat(args, " ", 1)
    SendNote(message)
end)

if Config.MorseEnabled then
    RegisterCommand('r', function(source, args)
        local message = table.concat(args, " ", 1)
        SendMorse(message)
    end)
end

function SendNote(message)
    local distance = 10
    if Config.VoiceChat == "SALTY" then
        distance = exports.saltychat:GetVoiceRange()
    elseif Config.VoiceChat == "PMA" then
        distance = MumbleGetTalkerProximity()
    end

    local nearbyPlayers, n = lib.getNearbyPlayers(GetEntityCoords(cache.ped), distance, true), 0

    for i = 1, #nearbyPlayers do
        local option = nearbyPlayers[i]
        local ped = GetPlayerPed(option.id)

        if ped > 0 then
            option.id = GetPlayerServerId(option.id)
            n = n + 1
            nearbyPlayers[n] = option
        end
    end

    lib.callback.await('rt_notepad:sendNote', false, nearbyPlayers, message, Config.Theme)
end

function SendMorse(message)   
    if Config.MorseEnabled then 
        local freq = 0
        local players = {}

        if Config.VoiceChat == "SALTY" then
            freq = exports.saltychat:GetRadioChannel(true)
        elseif Config.VoiceChat == "PMA" then
            freq = Player(-1).state.radioChannel  
        end

        players = lib.callback.await('rt_notepad:getRadioPlayers',false,  freq)

        local nearbyPlayers = {}

        local n = 0
        for source, isTalking in pairs(players) do
            n = n + 1
            nearbyPlayers[n] = source
        end

        lib.callback.await('rt_notepad:sendMorse', false, nearbyPlayers, message, Config.RadioTheme)
    end
end

RegisterCommand('removeLast', function()
    SendNUIMessage({ action = "removeNote" })
end, false)



AddEventHandler("rt_notepad:addNote", function(text, _theme)
    if Config.Debug then
        print("Note received")
    end
    SendNUIMessage({
        text = text,
        action = "newNote",
        bgcolor = _theme.bgcolor,
        ftcolor = _theme.fontcolor,
        align = Config.AlignTo
    })
end)

AddEventHandler("rt_notepad:setMorse", function(text, _theme)
    if Config.Debug then
        print("Morse received")
    end
    SendNUIMessage({
        text = text,
        action = "newMorse",
        bgcolor = _theme.bgcolor,
        ftcolor = _theme.fontcolor
    })
end)

AddEventHandler("confirmSend", function()
    SendNUIMessage({ action = "clear" })
end)

RegisterNUICallback("exit", function(data)
    SetNoteDisplay(false)
    SetMorseDisplay(false)
end
)

RegisterNUICallback("open", function(data)
    print("Open from nui")
    SetNoteDisplay(data.notepad)
    SetMorseDisplay(data.morse)
end
)

RegisterNUICallback("main", function(data)
    if data.mode == "notepad" then    
        SendNote(data.text)
    elseif data.mode == "morse" then
        SendMorse(data.text)
    end
end)

RegisterNUICallback("error", function(data)
    -- SetNoteDisplay(false)
end)

RegisterCommand('notepad', function(source)
    SetNoteDisplay(not noteDisplay)
end)

RegisterCommand("morse", function(source)
    SetMorseDisplay(not morseDisplay)
end)

function SetNoteDisplay(bool)
    noteDisplay = bool
    SetNuiFocus(bool, false)
    SendNUIMessage({
        type = "notepad",
        status = bool
    })
end

function SetMorseDisplay(bool)
    morseDisplay = bool
    SetNuiFocus(bool, false)
    SendNUIMessage({
        type = "morse",
        status = bool
    })
end

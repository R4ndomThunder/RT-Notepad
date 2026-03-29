lib.callback.register('rt_notepad:sendNote', function(source, Players, text, theme)
    local src = source
    TriggerClientEvent("confirmSend", src)
    if Players then
        for i = 1, #Players do
            if Players[i].id then
            TriggerClientEvent("rt_notepad:addNote", Players[i].id, text,theme)
            end
        end
    end
end)
lib.callback.register('rt_notepad:sendMorse', function(source, Players, text, theme)
    local src = source

    TriggerClientEvent("confirmSend", src)
    if Players then
        for i = 1, #Players do
            if Players[i] then
            TriggerClientEvent("rt_notepad:setMorse", Players[i], text,theme)
            end
        end
    end
end)

lib.callback.register('rt_notepad:checkAllowedPlayer', function(source)
    local src = source
    for _, license in ipairs(Config.AllowedPlayers) do
        if GetPlayerIdentifierByType(src, "license") == license then
            return true
        end
    end
    return false
end)

lib.callback.register('rt_notepad:getRadioPlayers', function(source, freq)
    local players = {}
    
    if Config.VoiceChat == "SALTY" then
        players = exports.saltychat:GetPlayersInRadioChannel(freq)
    elseif Config.VoiceChat == "PMA" then
        players = exports["pma-voice"]:getPlayersInRadioChannel(freq)           
    end

    return players
end)
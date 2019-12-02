function robotresultCallback(~, message)
global stop_cue

    if message.Status.Status == 3
        stop_cue = 1
    end
    
end
function robotstatecueCallback(~, message)
global state_cue

    if message.Motion == 1 || message.Motion == 2
        state_cue = 7;
    end
    
end
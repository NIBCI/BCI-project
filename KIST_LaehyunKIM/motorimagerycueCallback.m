function motorimagerycueCallback(~, message)
global MI_cue
global MI_cue_sec;
global MI_cue_nsec;
global MI_cue_dir;
global MI_cue_dir1;


        if message.Dist > 4
            MI_cue = 9
            MI_cue_dir = [message.Right message.Left message.Forward message.Backward]
        elseif message.Dist < 4
            MI_cue = 10
            MI_cue_sec = message.Header.Stamp.Sec;
            MI_cue_nsec = message.Header.Stamp.Nsec;
            MI_cue_dir1 = [message.Right message.Left message.Forward message.Backward]
    end

end
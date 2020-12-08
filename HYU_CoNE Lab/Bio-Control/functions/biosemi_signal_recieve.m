function segment = biosemi_signal_recieve()
global info;
% myStop;
Channels = 8;             %set to the same value as in Actiview "Channels sent by TCP"
Samples = 16;               %set to the same value as in Actiview "TCP samples/channel"
%variable%
words = Channels*Samples;
loop = 4;
%pre allocate segment 
segment = zeros(Samples*loop, Channels);


% myStop;
% biosemi online input
for L = 0 : loop-1
    %read tcp block
    [rawData,count,msg] = fread(info.tcpipClient,[3 words],'uint8');
    if count ~= 3*words
        disp(msg);
        disp('Is Actiview running with the same settings as this example?');
        break
    end
    %reorder bytes from tcp stream into 32bit unsigned words%
    normaldata = rawData(3,:)*(256^3) + rawData(2,:)*(256^2) + rawData(1,:)*256 + 0;
    %!reorder bytes from tcp stream into 32bit unsigned words%

    %reorder the channels into a array [samples channels]%
    j = 1+(L*Samples) : Samples+(L*Samples);
    i = 0 : Channels : words-1;%words-1 because the vector starts at 0
    for d = 1 : Channels;
        segment(j,d) = typecast(uint32(normaldata(i+d)),'int32'); %puts the data directly into the display buffer at the correct place
    end
    %!reorder the channels into a array [samples channels]%
end
% myStop;

% try
%     segment = biosemix([13 0]);
% catch me
%     if strfind(me.message,'BIOSEMI device')
%         set(g_handles.system_message, 'String', ...
%             strrep([me.message 'Recalling the BIOSEMI device again.'],...
%             newline,'. '));
%         clear biosemix;
%         segment = biosemix([13 0]);
%     else
%         rethrow(me);
%     end
% end
% segment = single(segment(2:end,:)) * 0.262 / 2^31;
% segment = 10^6.*double(segment);
% end
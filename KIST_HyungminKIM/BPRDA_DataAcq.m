%% ***********************************************************************
% Brain Product actiCHamp data acquisition function and Band Pass + Stop(60Hz)
% filter by Junhyuk Choi (3rd order)

% function [EEGData_raw, EEGData_bpf, EMGData_raw, MarkerData] = BPRDA_DataAcq_USETHIS()
function [EEGData_raw, EMGData_raw, MarkerData] = BPRDA_DataAcq()
trialcounter = 0;
finishtime = 60*3; % termination time in second. default: 30 minutes
EEGchannumb = 31; % 32 EEG channel - 1 reference channel
EMGchannumb = 0;

recorderip = '127.0.0.1';

% Establish connection to BrainVision Recorder Software 32Bit RDA-Port
% (use 51234 to connect with 16Bit Port)
con = pnet('tcpconnect', recorderip, 51244);

% Check established connection and display a message
stat = pnet(con,'status');
if stat > 0
    disp('connection established');
end

% for PRE-REQUISITE parameters JH FILTER DESIGN
% iirbp = designfilt('bandpassiir', 'StopbandFrequency1', 0.002, 'PassbandFrequency1', 3, 'PassbandFrequency2', 40, 'StopbandFrequency2', 100, 'StopbandAttenuation1', 25, 'PassbandRipple', 3, 'StopbandAttenuation2', 25, 'SampleRate', 500, 'MatchExactly', 'passband');
% [Bb, Ba] = sos2tf(iirbp.Coefficients);
% iirbs = designfilt('bandstopiir', 'PassbandFrequency1', 55, 'StopbandFrequency1', 59, 'StopbandFrequency2', 61, 'PassbandFrequency2', 65, 'PassbandRipple1', 1, 'StopbandAttenuation', 25, 'PassbandRipple2', 1, 'SampleRate', 500);
% [Nb, Na] = sos2tf(iirbs.Coefficients);
% isstable(iirbp.Coefficients)
% fvtool(iirbp); % visualize
% iirbp = designfilt('bandpassiir', 'StopbandFrequency1', 0.01, 'PassbandFrequency1', 3, 'PassbandFrequency2', 30, 'StopbandFrequency2', 60, 'StopbandAttenuation1', 25, 'PassbandRipple', 1, 'StopbandAttenuation2', 25, 'SampleRate', 500, 'DesignMethod', 'cheby1', 'MatchExactly', 'stopband');
% [Bb, Ba] = sos2tf(iirbp.Coefficients);

% buffer1 = zeros(EEGchannumb,6)'; % Initial buffer
% buffer0 = zeros(EEGchannumb,6)'; % Initial buffer
% preallocation for speed?!
EEGData_raw = zeros(EEGchannumb,500*finishtime);
% EEGData_bpf = [];
EMGData_raw = zeros(EMGchannumb,500*finishtime);
MarkerData = zeros(1,500*finishtime);
markers = [];

counter_main = 1;
% counter_plot = 1; % for plot
% figure;
% buffersize = 100;
% countersize = 25; % buffersize * countersize = 2500 = 500 dp * 5 second

% --- Main reading loop ---
header_size = 24;
finish = false;
while ~finish
    try
        % check for existing data in socket buffer
        tryheader = pnet(con, 'read', header_size, 'byte', 'network', 'view', 'noblock');
        while ~isempty(tryheader)
            
            % Read header of RDA message
            hdr = ReadHeader(con);
            
            % Perform some action depending of the type of the data package
            switch hdr.type
                case 1       % Start, Setup information like EEG properties
                    disp('Start');
                    % Read and display EEG properties
                    props = ReadStartMessage(con, hdr);
                    disp(props);
                    
                    % Reset block counter to check overflows
                    lastBlock = -1;
                    
                case 4       % 32Bit Data block
                    % Read data and markers from message
                    [datahdr, data, markers] = ReadDataMessage(con, hdr, props);
                    
                    % check tcpip buffer overflow
                    if lastBlock ~= -1 && datahdr.block > lastBlock + 1
                        disp(['******* Overflow with ' int2str(datahdr.block - lastBlock) ' blocks ******']);
                    end
                    lastBlock = datahdr.block;
                    
                    % print marker info to MATLAB console
                    if datahdr.markerCount > 0
                        for m = 1:datahdr.markerCount
                            disp(markers(m));
                        end
                    end
                    
                    % Process EEG data,
                    % in this case extract last recorded second,
                    InData = reshape(data, props.channelCount, length(data) / props.channelCount);
                    EEGData = InData(1:EEGchannumb,:);
                    EMGData = InData(EEGchannumb+1:end,:);
                    
                    % check if marker in and make marker line
                    if datahdr.markerCount <= 0 % MUST set only for RISING active!!
                        MarkerData_temp = zeros(1,10);
                    else
                        trialcounter = trialcounter+1;
                        disp(trialcounter);
                        MarkerData_temp1 = zeros(1,markers.position);
                        MarkerData_temp2 = ones(1,10-markers.position);
                        if markers.type == 'A'
                            MarkerData_temp2 = MarkerData_temp2*1;
                        elseif markers.type == 'B'
                            MarkerData_temp2 = MarkerData_temp2*2;
                        elseif markers.type == 'C'
                            MarkerData_temp2 = MarkerData_temp2*3;
                        elseif markers.type == 'D'
                            MarkerData_temp2 = MarkerData_temp2*4;
                        elseif markers.type == 'E'
                            MarkerData_temp2 = MarkerData_temp2*5;
                        elseif markers.type == 'F'
                            MarkerData_temp2 = MarkerData_temp2*6;
                        elseif markers.type == 'G'
                            MarkerData_temp2 = MarkerData_temp2*7;
                        elseif markers.type == 'H'
                            MarkerData_temp2 = MarkerData_temp2*8;
                        end
                        MarkerData_temp = [MarkerData_temp1 MarkerData_temp2];
                        markers = [];
                    end
                    
                    % collect(nope! replace preallocated data) raw and band pass filtered data
                    EEGData_raw(:,((counter_main-1)*10+1):(counter_main*10))= EEGData;
                    EMGData_raw(:,((counter_main-1)*10+1):(counter_main*10))= EMGData;
                    MarkerData(:,((counter_main-1)*10+1):(counter_main*10))= MarkerData_temp;
                    counter_main = counter_main + 1;
                    
%                     [EEGData2,buffer1] = filter(Bb,Ba,EEGData,buffer1,2);
%                     [filterdata,buffer0] = filter(Nb,Na,EEGData2,buffer0,2);
                    
%                     EEGData_bpf = [EEGData_bpf filterdata];
                    
                    % plot before 5 seconds, after 5 seconds
%                     if mod(length(EEGData_bpf),buffersize) == 0 % buffer size
%                         clf
%                         if counter_plot < countersize
%                             temp = zeros(EEGchannumb,2500-(counter_plot*buffersize));
%                             plotdata = [temp EEGData_bpf];
%                             counter_plot = counter_plot + 1;
%                         else
%                             plotdata = EEGData_bpf(:,end-2499:end);
%                         end
%                         plotdata2 = bsxfun(@minus, downsample(plotdata',5)', plotdata(:,1));
%                         plotdata2 = bsxfun(@plus, plotdata2, (45000:-1500:0)'); % make span between channels
%                         plot(1:size(plotdata2,2),plotdata2)
%                         axis([1 500 -1000 46000])
%                     end
                    
                case 3       % Stop message
                    disp('Stop');
                    data = pnet(con, 'read', hdr.size - header_size);
                    finish = true;
                    
                otherwise    % ignore all unknown types, but read the package from buffer
                    data = pnet(con, 'read', hdr.size - header_size);
            end
            tryheader = pnet(con, 'read', header_size, 'byte', 'network', 'view', 'noblock');
        end
    catch
        er = lasterror;
        disp(er.message);
    end
end % Main loop

% Close all open socket connections
pnet('closeall');

% Display a message
disp('connection closed');




%% ***********************************************************************
% Read the message header
function hdr = ReadHeader(con)
% con    tcpip connection object

% define a struct for the header
hdr = struct('uid',[],'size',[],'type',[]);

% read id, size and type of the message
% swapbytes is important for correct byte order of MATLAB variables
% pnet behaves somehow strange with byte order option
hdr.uid = pnet(con,'read', 16);
hdr.size = swapbytes(pnet(con,'read', 1, 'uint32', 'network'));
hdr.type = swapbytes(pnet(con,'read', 1, 'uint32', 'network'));


%% ***********************************************************************
% Read the start message
function props = ReadStartMessage(con, hdr)
% con    tcpip connection object
% hdr    message header
% props  returned eeg properties

% define a struct for the EEG properties
props = struct('channelCount',[],'samplingInterval',[],'resolutions',[],'channelNames',[]);

% read EEG properties
props.channelCount = swapbytes(pnet(con,'read', 1, 'uint32', 'network'));
props.samplingInterval = swapbytes(pnet(con,'read', 1, 'double', 'network'));
props.resolutions = swapbytes(pnet(con,'read', props.channelCount, 'double', 'network'));
allChannelNames = pnet(con,'read', hdr.size - 36 - props.channelCount * 8);
props.channelNames = SplitChannelNames(allChannelNames);


%% ***********************************************************************
% Read a data message
function [datahdr, data, markers] = ReadDataMessage(con, hdr, props)
% con       tcpip connection object
% hdr       message header
% props     eeg properties
% datahdr   data header with information on datalength and number of markers
% data      data as one dimensional arry
% markers   markers as array of marker structs

% Define data header struct and read data header
datahdr = struct('block',[],'points',[],'markerCount',[]);

datahdr.block = swapbytes(pnet(con,'read', 1, 'uint32', 'network'));
datahdr.points = swapbytes(pnet(con,'read', 1, 'uint32', 'network'));
datahdr.markerCount = swapbytes(pnet(con,'read', 1, 'uint32', 'network'));

% Read data in float format
data = swapbytes(pnet(con,'read', props.channelCount * datahdr.points, 'single', 'network'));

% Define markers struct and read markers
markers = struct('size',[],'position',[],'points',[],'channel',[],'type',[],'description',[]);
for m = 1:datahdr.markerCount
    marker = struct('size',[],'position',[],'points',[],'channel',[],'type',[],'description',[]);
    
    % Read integer information of markers
    marker.size = swapbytes(pnet(con,'read', 1, 'uint32', 'network'));
    marker.position = swapbytes(pnet(con,'read', 1, 'uint32', 'network'));
    marker.points = swapbytes(pnet(con,'read', 1, 'uint32', 'network'));
    marker.channel = swapbytes(pnet(con,'read', 1, 'int32', 'network'));
    
    % type and description of markers are zero-terminated char arrays
    % of unknown length
    c = pnet(con,'read', 1);
    while c ~= 0
        marker.type = [marker.type c];
        c = pnet(con,'read', 1);
    end
    
    c = pnet(con,'read', 1);
    while c ~= 0
        marker.description = [marker.description c];
        c = pnet(con,'read', 1);
    end
    
    % Add marker to array
    markers(m) = marker;
end


%% ***********************************************************************
% Helper function for channel name splitting, used by function
% ReadStartMessage for extraction of channel names
function channelNames = SplitChannelNames(allChannelNames)
% allChannelNames   all channel names together in an array of char
% channelNames      channel names splitted in a cell array of strings

% cell array to return
channelNames = {};

% helper for actual name in loop
name = [];

% loop over all chars in array
for i = 1:length(allChannelNames)
    if allChannelNames(i) ~= 0
        % if not a terminating zero, add char to actual name
        name = [name allChannelNames(i)];
    else
        % add name to cell array and clear helper for reading next name
        channelNames = [channelNames {name}];
        name = [];
    end
end


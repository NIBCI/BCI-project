function sigout = eeg_interp_MJ(sigin,badch,method)

EEG.data = sigin;
EEG.chanlocs = readlocs('D:\[1]EEGBCI\[2]Research\Code&Algorithm\BP_channelLocs.locs');
EEG.nbchan = size(sigin,1);
EEG.trials = 1;
EEG.pnts = size(sigin,2);
EEG.srate = 500;
EEG.xmin = 1;
EEG.xmax = size(sigin,2);




EEG.setname =  '';
EEG.filename = '';
EEG.filepath = '';
EEG.subject = '';
EEG.group = '';
EEG.condition = '';
EEG.session = [];
EEG.comments = '';
EEG.times= [];
EEG.icaact= [];
EEG.icawinv= [];
EEG.icasphere= [];
EEG.icaweights= [];
EEG.icachansind= [];
EEG.urchanlocs= [];
EEG.chaninfo= [];
EEG.event= [];
EEG.urevent= [];
EEG.eventdescription= {};
EEG.epoch= [];
EEG.epochdescription= {};
EEG.reject= [];
EEG.stats= [];
EEG.specdata= [];
EEG.specicaact= [];
EEG.splinefile= '';
EEG.icasplinefile= '';
EEG.dipfit= [];
EEG.history= '';
EEG.saved= 'no';
EEG.etc= [];


EEGout  = eeg_interp(EEG,badch,method);
sigout = EEGout.data;


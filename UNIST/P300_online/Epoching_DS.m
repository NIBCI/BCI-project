function EP     = Epoching_DS(sig, trig,param)
try
latency         = find(trig ~= 0); % Find latency of triggers
type            = trig(trig ~= 0); % Find triggers

target          = type(find(type == param.Sys(1)) -1)';  % The trigger before 'S 12' is target trigger

start_t         = find(type == 12) + 1;

numTr           = length(start_t);

if numTr > param.NumTrTrial  %%updated 180818
   difference = diff(start_t);
   removeind =  find(difference ~= param.NumStims*param.repeat + 4);
   start_t(removeind) = [];
   numTr = length(start_t);
   target(removeind) = [];
end

tar                 = zeros(param.NumCh, param.Totalepoc, numTr);
nar                 = zeros(param.NumCh, param.Totalepoc, param.NumStims-1, numTr);
if ~strcmp(param.decoder.mode,'training')
nar                 = zeros(param.NumCh, param.Totalepoc, param.NumStims, numTr);
end
for b = 1 : numTr
    epoc_ind            = latency(start_t(b) : end);
    stim_type           = type(start_t(b) : end);
    erp                 = zeros(param.NumCh, param.Totalepoc, param.NumStims);
    for s = 1 : param.NumStims
        ind             = stim_type == param.Stims(s);
        trials          = epoc_ind(ind);
        tmp             = 0; 
        if param.repeat > length(trials) 
            param.repeat = length(trials); %180703
        end
        for t = 1 : length(trials)
            ind_sig     = trials(t) - param.Baseline : trials(t) + param.Epocline - 1;
            tmp         = tmp + sig(:,ind_sig);
        end
        erp_tmp         = tmp ./ length(trials);
        erp(:,:,s)      = (erp_tmp - repmat(mean(erp_tmp(:, 1 : param.Baseline),2), 1, size(erp_tmp,2)))./repmat(std(erp_tmp(:, 1 : param.Baseline),[],2), 1, size(erp_tmp,2));
    end
    if ~strcmp(param.decoder.mode,'training')
        nar(:,:,:,b)    = erp;
    else
        tar(:,:,b)      = erp(:,:,(target(b) == param.Stims));
        nar(:,:,:,b)    = erp(:,:,~(target(b) == param.Stims));

    end
end


for k = 1:param.NumCh
    set(param.h(k,1), 'XData', param.Time,'YData', squeeze(mean(tar(k,:,:),3)), 'Color','r','LineWidth',2);
    set(param.h(k,2), 'XData', param.Time,'YData', squeeze(mean(nar(k,:,1,:),4)),'Color','g');
    set(param.h(k,3), 'XData', param.Time,'YData', squeeze(mean(nar(k,:,2,:),4)),'Color','b');
    set(param.h(k,4), 'XData', param.Time,'YData', squeeze(mean(nar(k,:,3,:),4)),'Color','k');
    ylim(param.SH(k),[-2 2]);
    if ~strcmp(param.decoder.mode,'training')
        set(param.h(k,1), 'XData', param.Time,'YData', squeeze(mean(nar(k,:,4,:),4)),'Color','m');
           ylim(param.SH(k),[-5 5]);
    end
   title(param.SH(k),param.Ch{k});
   xlim(param.SH(k),[-0.2 0.6])
end

EP.tar = tar;
EP.nar = nar;
EP.target = target;
EP.badch = param.badch;

% clearvars -except EP
catch
    keyboard
end
function [hitLabel, param] = FeatureExt(EP, param)
% try
NumBlocks                   = size(EP.tar,3);
if strcmp(param.decoder.mode,'training')
    hitLabel                    = [];
    param.good_ch_tval          = [];
    param.tmp_t                 = [];
    for ch = 1 : param.NumCh
        H                       = mean(squeeze(EP.tar(ch,:,:)),2);
        tar_tmp             = squeeze(EP.tar(ch,:,:)) .* repmat(H, 1, NumBlocks);
        nar_tmp             = squeeze(EP.nar(ch,:,:,:)) .* repmat(H, [1, 3, NumBlocks]);
        
        good_t      = [];
        for t = 1 : param.Totalepoc
            y               = [tar_tmp(t,:)' ; squeeze(nar_tmp(t,1,:)) ; squeeze(nar_tmp(t,2,:)) ; squeeze(nar_tmp(t,3,:))];
            LB              = [zeros(NumBlocks,1) ; ones(NumBlocks,1) ; 2*ones(NumBlocks,1);3*ones(NumBlocks,1)];
            [p,tbl,stats]   = anovan(y, LB, 'display','off');
            C               = multcompare(stats,'Display','off' );
            if sum(C(1:3,end) < 0.01) == 3
                good_t      = [good_t ; t];
            end
        end
        param.good_ch_tval(ch)    = length(good_t);
        if param.good_ch_tval(ch) ~= 0
            param.tmp_t           = [param.tmp_t ; good_t];
        end
        fprintf('*');
    end
    fprintf('\n');
    
    param.trD.ind_t             = min(param.tmp_t) : max(param.tmp_t);
    param.sel_ch                = find(param.good_ch_tval);
    try
    if ~isempty(param.sel_ch)
        fprintf('Selected channel: %d\n', param.sel_ch);
        fprintf('Significant duration: %.2f ~ %.2f [sec]\n', param.Time(param.trD.ind_t(1)), param.Time(param.trD.ind_t(end)))
        
        tar_feat                    = [];
        nar_feat                    = [];
        
        param.trD.H   = [];
        param.trD.mu  = [];
        param.trD.w = {};
        for ch = 1 : length(param.sel_ch)
            param.trD.H(:,ch)   = mean(squeeze(EP.tar(param.sel_ch(ch),:,:)),2);
            
            tar_tmp                 = squeeze(EP.tar(param.sel_ch(ch),:,:)) .* repmat(param.trD.H(:,ch), 1, NumBlocks);
            nar_tmp                 = squeeze(EP.nar(param.sel_ch(ch),:,:,:)) .* repmat(param.trD.H(:,ch), [1, 3, NumBlocks]);
            
            
            param.trD.mu(ch,:)  = param.trD.H(param.trD.ind_t,ch)';
            tar_adj             = tar_tmp(param.trD.ind_t,:)' - repmat(param.trD.mu(ch,:), NumBlocks,1);
            [U,V]               = eig(cov(tar_adj));
            param.trD.w(ch)     =  {U(:,end-5:end)'};
            
            nar_adj                 = nar_tmp(param.trD.ind_t,:,:) - repmat(param.trD.mu(ch,:)', [1, 3, NumBlocks]);
            nar_adj                 = reshape(nar_adj, length(param.trD.ind_t),NumBlocks*3)';
            tar_feat                = [tar_feat (param.trD.w{ch}*tar_adj')'];
            nar_feat                = [nar_feat (param.trD.w{ch}*nar_adj')'];
        end
        
        tr_label                = [ones(size(tar_feat,1),1); -ones(size(nar_feat,1),1)];
        param.trD.mdl           = fitcdiscr([tar_feat ; nar_feat], tr_label);
        param.decoder.mode      = 'testing';
        
    else
        fprintf('training is failed\n');
        hitLabel = -1;
    end
    catch 
        fprintf('training is failed\n');
        hitLabel = -1;
    end
else
    try
    feat                = [];
    for ch = 1 : length(param.sel_ch)
        erp_tmp         = squeeze(EP.nar(param.sel_ch(ch),:,:)) .* repmat(param.trD.H(:,ch),  [1, 4, NumBlocks]);
        erp_adj         = erp_tmp(param.trD.ind_t,:) - repmat(param.trD.mu(ch,:)',1,size(erp_tmp,2));
        feat            = [feat (param.trD.w{ch}*erp_adj)'];
    end
    [C,sc] = predict(param.trD.mdl, feat);
    [~,hit_id] = max(sc(:,end));
    hitLabel = param.Stims(hit_id);
    param.True_Tar      = EP.target;
    catch
        hitLabel=-1;
    end
end
clearvars -except hitLabel param

% catch
%     keyboard
% end
function [hitLabel, param] = FeatureExt_basic(EP, param)
% try
NumBlocks                   = size(EP.tar,3);
Win = 1;
ind = param.Baseline+0.2*param.Fs+1:Win:param.Totalepoc;
MovAvgWin = 5;
MovAvgDS = fix(MovAvgWin/2);
if strcmp(param.decoder.mode,'training')
    try
        tar_temp                = permute(EP.tar(:,ind,:),[2,1,3]);
         tar_temp = movmean(tar_temp,MovAvgWin,1);
        tar_temp = tar_temp(1:MovAvgDS:end,:,:);
        tar_temp2                = reshape(tar_temp,size(tar_temp,1)*size(tar_temp,2),size(tar_temp,3));
        tar_feat = tar_temp2';
        
        nar_temp = permute(EP.nar(:,ind,:,:),[2,1,3,4]);
        nar_temp = movmean(nar_temp,MovAvgWin,1);
        nar_temp = nar_temp(1:MovAvgDS:end,:,:,:);
        nar_temp2 = reshape(nar_temp,size(nar_temp,1)*size(nar_temp,2),size(nar_temp,3)*size(nar_temp,4));
        nar_feat= nar_temp2';
        
        
        tr_label                = [ones(size(tar_feat,1),1); -ones(size(nar_feat,1),1)];
        
        Feature = [tar_feat; nar_feat];
        
        
        
        
        param.trD.mdl           = fitcsvm(Feature, tr_label);
        
        
%         Cvind =      crossvalind('Kfold',tr_label,5);
hit = 0;
        for r = 1:NumBlocks
            teind = [r; NumBlocks + [1:3]' + (param.NumStims-1)*(r-1)]; 
            
            trind = setdiff(1:NumBlocks*param.NumStims,teind);
            mdl=  fitcsvm(Feature(trind,:),tr_label(trind));
          
            [~, score] = predict(mdl,Feature(teind,:));
             [~,hit_id] = max(score(:,end));
              result = param.Stims(hit_id);
              if result == 1; 
                  hit = hit+1;
              end
        end
       acc = hit/NumBlocks;

        CVAcc = acc;
        fprintf('CV accuracy: %.2f\n',CVAcc);
        param.CVAcc = CVAcc;
%         
        
        param.decoder.mode      = 'testing';
        hitLabel = [];
    catch
        fprintf('Training failed..!')
        hitLabel = -1;
    end
else
    try
        feat_temp = permute(EP.nar(:,ind,:,:),[2,1,3,4]);
        feat_temp = movmean(feat_temp,MovAvgWin,1);
        feat_temp = feat_temp(1:MovAvgDS:end,:,:,:);
        feat_temp2 = reshape(feat_temp,size(feat_temp,1)*size(feat_temp,2),size(feat_temp,3)*size(feat_temp,4));
        feat= feat_temp2';
        

        
        [C,sc] = predict(param.trD.mdl, feat);
        [~,hit_id] = max(sc(:,end));
        hitLabel = param.Stims(hit_id);
        param.True_Tar      = EP.target;
        
        % If iteration end but block not end
        % accumulate classifier output
        if isfield(param.decoder,'data')
        if (~param.switch_on) || isfield(param,'switch_on_iter')
            param.decoder.data = [param.decoder.data; sc(:,end)];
        end
        end
        
    catch
        hitLabel=-1;
    end
end
clearvars -except hitLabel param
function [hitLabel, param] = FeatureExt_basic(EP, param)
% try
NumBlocks                   = size(EP.tar,3);
Win = 1;
ind = param.Baseline+0.15*param.Fs+1:Win:param.Totalepoc;

if strcmp(param.decoder.mode,'training')
    try
        tar_temp                = permute(EP.tar(:,ind,:),[2,1,3]);
        tar_temp2                = reshape(tar_temp,size(tar_temp,1)*size(tar_temp,2),size(tar_temp,3));
        tar_feat = tar_temp2';
        
        nar_temp = permute(EP.nar(:,ind,:,:),[2,1,3,4]);
        nar_temp2 = reshape(nar_temp,size(nar_temp,1)*size(nar_temp,2),size(nar_temp,3)*size(nar_temp,4));
        nar_feat= nar_temp2';
        
        
        tr_label                = [ones(size(tar_feat,1),1); -ones(size(nar_feat,1),1)];
        
        Feature = [tar_feat; nar_feat];
        
        
        
        
        param.trD.mdl           = fitcsvm(Feature, tr_label);
        
        
        Cvind =      crossvalind('Kfold',tr_label,5);
        for r = 1:5
            trind = Cvind ~=r ;
            mdl=  fitcsvm(Feature(trind,:),tr_label(trind));
            teind = Cvind == r;
            [result, score] = predict(mdl,Feature(teind,:));
            acc(r) = length(find(result == tr_label(teind)))/length(result);
        end
        CVAcc = mean(acc(r));
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
        feat_temp2 = reshape(feat_temp,size(feat_temp,1)*size(feat_temp,2),size(feat_temp,3)*size(feat_temp,4));
        feat= feat_temp2';
        
%         Feature = feat(:,DownSampleInd);
        
        [C,sc] = predict(param.trD.mdl, feat);
        [~,hit_id] = max(sc(:,end));
        hitLabel = param.Stims(hit_id);
        param.True_Tar      = EP.target;
    catch
        hitLabel=-1;
    end
end
clearvars -except hitLabel param
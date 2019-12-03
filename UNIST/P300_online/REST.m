function [sig,G] = REST(dat,G,Gfilepath,ch,CalG)

% dat : EEG data to REST reference. average referenced. channel*sample point
% G : Lead field matrix
% Gfilepath : filepath of lead field matrix
% CalG : [0/1] Whether calculate lead field matrix or not. 1 for calculate
% ch: number of channel to use

if isempty(G)
    if CalG == 1
        system('D:\[1]EEGBCI\[2]Research\Code&Algorithm\REST\LeadField.exe');
        Gfilepath = 'D:\[1]EEGBCI\[2]Research\Code&Algorithm\Lead_Field.dat'; % folder with channel location file
        G = load(Gfilepath);
        
        NewGfilepath = [Gfilepath(1:end-4) ,'_',num2str(ch), 'ch.dat'];
        movefile(Gfilepath, NewGfilepath);
        
    elseif CalG == 0
        G = load(Gfilepath);
        
    end
end

sig = rest_refer(dat,G);



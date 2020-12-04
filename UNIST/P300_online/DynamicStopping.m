classdef DynamicStopping
    
    properties
        data;
        pval;
        threshold = 0.0001;
    end
    
    methods
        function obj = DynamicStopping(data,pval,threshold)
            obj.data = data;
            obj.pval = pval;
            obj.threshold = threshold;
        end
        
        function obj = getpval(obj)
            
            Nclass = size(obj.data,1);
            Niter = size(obj.data,2);
            Nsample = size(obj.data,3);
            p = zeros(Nclass,Nsample);
            for n = 1:Nclass
                D1 = squeeze(obj.data(n,:,:));
                D2 = squeeze(reshape(obj.data(setdiff(1:Nclass,n),:,:),(Nclass-1)*Niter,Nsample));
                [~,P]=ttest2(D1,D2);
                p(n,:) = P;
            end
            
            obj.pval = p;
        end
        
        function [Decision,class] = decidestopping(obj)
            c = obj.getclass();
            if c~= -1
                Decision = 1;
                class = c;
            else
                Decision = -1;
                class = -1;
            end
        end
        
        function c= getclass(obj)
            cInd = find(obj.pval < obj.threshold);
            
            if isempty(cInd)
                c = -1;
            else
                [~,c] = min(obj.pval);
            end
        end
    end
end

function [Decision,class] = decidestopping(pvalue, alpha)
% decided not to quit -> Decision: -1, class: -1
% decided to quit -> Decision: 1, class: classification output (class)

c = getclass(pvalue,alpha);
if c~= -1
    Decision = 1;
    class = c;
else
    Decision = -1;
    class = -1;
end
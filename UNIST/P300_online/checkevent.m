function result = checkevent(trigger)

% Check trigger event
% whether all trigger types (e.g. 1,2,3,4) appeared


Count(1) = length(find(trigger==1));
Count(2) = length(find(trigger==2));
Count(3) = length(find(trigger==3));
Count(4) = length(find(trigger==4));


if sum(Count) ~= 0
    if mod(sum(Count),4) == 0
        result = true;
    else
        result = false; 
    end
else
    result = false; 
end

% 화면 display 를 위한 함수
%----------------------------------------------------------------------
% by Won-Du Chang, ph.D,
% Research Professor @  Department of Biomedical Engineering, Hanyang University
% contact: 12cross@gmail.com
%---------------------------------------------------------------------
function onPaint(  )
%ONPAINT 이 함수의 요약 설명 위치
%   그림 담당 함수
%tic
global info;
global dataqueue;
global pd;
% global pos;
% global output;
% global EMG_online;
try
if dataqueue.datasize>10
    aaa=3;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%draw second axes
%data_tmp = pd.EOG.data;szProcessedData

if pd.EOG.datasize<=0
%     myStop;
%     keyboard;
    return;
end

% curval = get(info.handles.listbox_pd, 'value');
% if curval ==1
    data_tmp = pd.EOG.data(1:pd.EOG.datasize,:);
% elseif curval==2
%     data_tmp = pd.EOG_ebRemoved.data(1:pd.EOG_ebRemoved.datasize,:);
% elseif curval==3
%     data_tmp = pd.EOG_saccade.data(1:pd.EOG_saccade.datasize,:);
% end
% myStop;
baseline = -data_tmp(1,:);
for i=1:size(data_tmp,2);
    if isnan(baseline(i))
        baseline(:,i) = 0;
    end
end
offset = 100;
for i=1:size(data_tmp,2);
    baseline(i) = baseline(i) - (i-1)*offset;
    data_tmp(:,i) = data_tmp(:,i)+baseline(i);
end

% myStop;
plot(info.handles.axes1, data_tmp); 
xlim(info.handles.axes1, [0 pd.EOG.length]);
line([pd.EOG.index_end, pd.EOG.index_end],get(info.handles.axes1,'ylim'),'parent',info.handles.axes1);

%label 조정
set(info.handles.axes1,'xtick',[0:info.Fc:info.queuelength_time*info.Fc]);
szXTicks = cell(1,info.queuelength_time+1);
for i=1:10
    szXTicks{i} = char('0' + i-1);
end
szXTicks{11} = char('10');
set(info.handles.axes1,'xticklabel',szXTicks);
drawnow;
catch e
   myStop;
   keyboard;
end
    



%% MotorImagery.m
% Data acquisition of motor imagery tasks
% Using the BBCI toolbox and Psychtoolbox

clc; clear all; close all;

global IO_ADDR IO_LIB;
IO_ADDR=hex2dec('E010');
IO_LIB=which('inpoutx64.dll');

Screen('Preference', 'SkipSyncTests', 1);

%% Image load
right_arrow=imread('Images\forward.jpg');
left_arrow=imread('Images\grasp.jpg');
up_arrow=imread('Images\twist.png');
cross=imread('Images\fixationcross.jpg');


%% interval setting
RepeatTimes = 90;
sti_Times = 5;       % per/S 10
sti_Interval = 5;    % per/S

%% find
while(1)
    sti_task=randi([1 3], RepeatTimes, 1);
    if length(find(sti_task(:,1)==1))==length(find(sti_task(:,1)==2))
        if length(find(sti_task(:,1)==1))==length(find(sti_task(:,1)==3))
            break;
        end
    end
end

%% screen setting (gray)
screens=Screen('Screens');
screenNumber=max(screens);
gray=GrayIndex(screenNumber);
[w, wRect]=Screen('OpenWindow', 1, gray);

%% Wait for mouse click
Screen('TextSize',w, 24);
DrawFormattedText(w, 'Mouse click to start MI experiment', 'center', 'center', [0 0 0]);
Screen('Flip', w);
GetClicks(w);
ppTrigger(5) % start

for i=1:RepeatTimes
    i
    tex=Screen('MakeTexture', w, fixationcross);
    Screen('DrawTexture', w, tex);
    Screen('Close',tex)
    [VBLTimestamp startrt]=Screen('Flip', w);
    WaitSecs(sti_Interval);
    
    
    switch sti_task(i,1)
        case 1
            tex=Screen('MakeTexture', w, forward);
            Screen('DrawTexture', w, tex);
            Screen('Close',tex)
            [VBLTimestamp startrt]=Screen('Flip', w);
            ppTrigger(1);
            WaitSecs(sti_Times);
            ppTrigger(4);
            
        case 2
            tex=Screen('MakeTexture', w, grasp);
            Screen('DrawTexture', w, tex);
            Screen('Close',tex)
            [VBLTimestamp startrt]=Screen('Flip', w);
            ppTrigger(2);
            WaitSecs(sti_Times);
            ppTrigger(4);
            
        case 3
            tex=Screen('MakeTexture', w, twist);
            Screen('DrawTexture', w, tex);
            Screen('Close',tex)
            [VBLTimestamp startrt]=Screen('Flip', w);
            ppTrigger(3);
            WaitSecs(sti_Times);
            ppTrigger(4);
             
    end  
    
end

WaitSecs(2);

%% finish
ppTrigger(6) % end
Screen('TextSize',w, 24);
DrawFormattedText(w, 'Thank you.', 'center', 'center', [0 0 0]);
Screen('Flip', w);
WaitSecs(3);


Screen('CloseAll');
ShowCursor;
fclose('all');
Priority(0);
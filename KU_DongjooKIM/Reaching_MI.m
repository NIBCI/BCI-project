function [ Total_count, Trigger_Info] = Reaching_Task_MI()
%%
clc; clear all; tic

global IO_ADDR IO_LIB;
IO_ADDR=hex2dec('2FF8');
IO_LIB=which('inpoutx64.dll');

Screen('Preference', 'SkipSyncTests', 1);
%%
%image load
forward_arrow=imread('MotorImagery Stimulation Images\forward.jpg');
backward_arrow=imread('MotorImagery Stimulation Images\backward.jpg');
movement_imagery=imread('MotorImagery Stimulation Images\MI.jpg');
cross=imread('MotorImagery Stimulation Images\cross.jpg');
%%
%interval setting
RepeatTimes = 100;

sti_Times = 3;       % cue time
sti_Interval = 4;   %cross time
sti_robotTime = 4;

foward_count = 0;
backward_count = 0;
up_count = 0;
down_count = 0;
left_count = 0;
right_count = 0;

%% class
sti_task(1:50,1) = 1;sti_task(51:100,1) = 2;
sti_task(101:150,1) = 3; sti_task(151:200,1) = 4;
sti_task(201:250,1) = 5; sti_task(251:300,1) = 6;
sti_task=sti_task(randperm(length(sti_task)));
%%
screens=Screen('Screens');
screenNumber=max(screens);
gray=GrayIndex(screenNumber);
[w, wRect]=Screen('OpenWindow', 1, gray);

% Wait for mouse click:
Screen('TextSize',w, 32);
DrawFormattedText(w, 'Mouse click to start motor imagery experiment', 'center', 'center', [0 0 0]);
Screen('Flip', w);
GetClicks(w);
ppTrigger(13) % START


%%
for trial=1:RepeatTimes
    trial
    tex=Screen('MakeTexture', w, cross);
    Screen('DrawTexture', w, tex);
    Screen('Close',tex)
    [VBLTimestamp startrt]=Screen('Flip', w);
    WaitSecs(sti_Interval);

% rest
    if trial == round((RepeatTimes/2));  % pause for subject rest 
        
        Screen('TextSize',w, 50);
        DrawFormattedText(w,'Rest\n\n(Pause the brain vision. Click 1/3)','center','center',[0 0 0]);
        Screen('Flip', w);
        GetClicks(w);
        
        DrawFormattedText(w,'(Resume recording. Click 2/3)','center','center',[0 0 0]);
        Screen('Flip', w);
        GetClicks(w);
        
        DrawFormattedText(w,'Click to continue the experiment. Click 3/3','center','center',[0 0 0]);
        Screen('Flip', w);
        GetClicks(w);
    end
    
    switch sti_task(trial,1)
        case 1
            tex=Screen('MakeTexture', w, forward_arrow);
            Screen('DrawTexture', w, tex);
            Screen('Close',tex)
            [VBLTimestamp startrt]=Screen('Flip', w);
            ppTrigger(1);
            WaitSecs(sti_Times);
            
            disp(sprintf('Data transmission'));
            disp(sprintf('Command: Forward\n'));
            
            ppTrigger(11);
            
            tex=Screen('MakeTexture', w, movement_imagery);
            Screen('DrawTexture', w, tex);
            Screen('Close',tex);
            [VBLTimestamp startrt]=Screen('Flip', w);
            WaitSecs(sti_robotTime);
            
            ppTrigger(8);            
            foward_count = foward_count+1;
            
        case 2
            tex=Screen('MakeTexture', w, backward_arrow);
            Screen('DrawTexture', w, tex);
            Screen('Close',tex)
            [VBLTimestamp startrt]=Screen('Flip', w);
            ppTrigger(2);
            WaitSecs(sti_Times);
            
            disp(sprintf('Data transmission'))
            disp(sprintf('Command: Backward\n'))
            ppTrigger(21);
            
            tex=Screen('MakeTexture', w, movement_imagery);
            Screen('DrawTexture', w, tex);
            Screen('Close',tex)
            [VBLTimestamp startrt]=Screen('Flip', w);
            WaitSecs(sti_robotTime);
            ppTrigger(8);            
            backward_count = backward_count+1;
    end
    
end

WaitSecs(2);

% finish
ppTrigger(14) % END
Screen('TextSize',w, 24);
DrawFormattedText(w, 'Thank you.', 'center', 'center', [0 0 0]);
Screen('Flip', w);
WaitSecs(3);

Screen('CloseAll');
ShowCursor;
Priority(0);

Total_count = cell(3,2);
Total_count = [{'Forward'}, foward_count;...
    {'Backward'},backward_count;...
    {'Total Count'}, foward_count+backward_count];

Trigger_Info = cell(6,2);
Trigger_Info = [{'Forward'}, '1';...
    {'Backward'},'2';...
    {'Forward start'}, '11';...
    {'Forward end'}, '12';...
    {'Backward start'}, '21';...
    {'Backward end'}, '22';...
    ];

toc

end

function [ Total_count, Trigger_Info ] = Grasping_practice()
%%
clc; clear all; tic

global IO_ADDR IO_LIB;
IO_ADDR=hex2dec('2FF8');
IO_LIB=which('inpoutx64.dll');

Screen('Preference', 'SkipSyncTests', 1);

%% Load cue files 
% image load
grasp_arrow=imread('MotorImagery Stimulation Images\grasp.png'); % grasp
spread_arrow=imread('MotorImagery Stimulation Images\spread.png'); % spread
motor_execution=imread('MotorImagery Stimulation Images\ME.png'); 
cross=imread('MotorImagery Stimulation Images\cross.jpg');

%%
%interval setting
RepeatTimes = 6; % 50 trials for each class 
sti_Times = 3;       % cue time
sti_Interval = 3;   %cross time
sti_responseTime = 4;

grasp_count = 0;
spread_count = 0; 

%% class
sti_task=[1 2 1 2]';

%%
%screen setting (gray)
screens=Screen('Screens');
screenNumber=max(screens);
gray=GrayIndex(screenNumber);
[w, wRect]=Screen('OpenWindow', 1, gray);

% Wait for mouse click:
Screen('TextSize',w, 32);
DrawFormattedText(w, 'Mouse click to start motor imagery experiment', 'center', 'center', [0 0 0]);
Screen('Flip', w);
GetClicks(w);
ppTrigger(13)%START

%%
for trial=1:RepeatTimes
    trial
       
    tex=Screen('MakeTexture', w, cross);
    Screen('DrawTexture', w, tex);
    Screen('Close',tex)
    [VBLTimestamp startrt]=Screen('Flip', w);
    WaitSecs(sti_Interval);

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
            tex=Screen('MakeTexture', w, grasp_arrow);
            Screen('DrawTexture', w, tex);
            Screen('Close',tex)
            [VBLTimestamp startrt]=Screen('Flip', w);
            ppTrigger(1);
            WaitSecs(sti_Times);
            
            disp(sprintf('Data transmission'))
            disp(sprintf('Command: Grasp\n'))
            
            ppTrigger(11);

            tex=Screen('MakeTexture', w, motor_execution);
            Screen('DrawTexture', w, tex);
            Screen('Close',tex)
            [VBLTimestamp startrt]=Screen('Flip', w);
            WaitSecs(sti_responseTime);       
            
            ppTrigger(8);            
            grasp_count = grasp_count+1;

        case 2
            tex=Screen('MakeTexture', w, spread_arrow);
            Screen('DrawTexture', w, tex);
            Screen('Close',tex)
            [VBLTimestamp startrt]=Screen('Flip', w);
            ppTrigger(2);
            WaitSecs(sti_Times);
           
            disp(sprintf('Data transmission'))
            disp(sprintf('Command: spread\n'))
            
            ppTrigger(21);
            
            tex=Screen('MakeTexture', w, motor_execution);
            Screen('DrawTexture', w, tex);
            Screen('Close',tex)
            [VBLTimestamp startrt]=Screen('Flip', w);
            WaitSecs(sti_responseTime);
            
            ppTrigger(8);
            spread_count = spread_count+1;      
    end
    
end

disp(sprintf('Data transmission'))
disp(sprintf('Command: Quit\n'))

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

Total_count = cell(3, 2);
Total_count = [{'grasp'}, grasp_count;...
    {'spread'},spread_count;...
    {'Total Count'}, grasp_count+spread_count];

Trigger_Info = cell(6, 2);
Trigger_Info = [{'grasp'}, '1';...
    {'spread'},'2';...
    {'grasp start'}, '11';...
    {'grasp end'}, '12';...
    {'spread start'}, '21';...
    {'spread end'}, '22';...
     ];

toc

end
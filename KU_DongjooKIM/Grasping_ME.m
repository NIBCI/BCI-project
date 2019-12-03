function [ Total_count, Trigger_Info ] = Grasping_ME()
%%
clc; clear all; tic

global IO_ADDR IO_LIB;
IO_ADDR=hex2dec('2FF8');
IO_LIB=which('inpoutx64.dll');

Screen('Preference', 'SkipSyncTests', 1);

%% Load cue files 
% image load
cylindrical_arrow=imread('MotorImagery Stimulation Images\grasp.png'); % CUP
spherical_arrow=imread('MotorImagery Stimulation Images\spread.png'); % BALL
motor_execution=imread('MotorImagery Stimulation Images\ME.jpg'); 
cross=imread('MotorImagery Stimulation Images\cross.jpg');
%%
%interval setting
RepeatTimes = 100; % 50 trials for each class 
sti_Times = 3;       % cue time
sti_Interval = 3;   %cross time
sti_responseTime = 4;

grasp_count = 0;
spread_count = 0; 

%% class random하게 분배
sti_task(1:50,1) = 1;sti_task(51:100,1) = 2;
sti_task(101:150,1) = 3; 

sti_task=sti_task(randperm(length(sti_task)));

%%

%screen setting (gray)
screens=Screen('Screens');
screenNumber=max(screens);
gray=GrayIndex(screenNumber);
[w, wRect]=Screen('OpenWindow', 1, gray);

% Wait for mouse click:
Screen('TextSize',w, 32);
DrawFormattedText(w, 'Mouse click to start motor execution experiment', 'center', 'center', [0 0 0]);
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
            disp(sprintf('Command: Spread \n'))
            
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
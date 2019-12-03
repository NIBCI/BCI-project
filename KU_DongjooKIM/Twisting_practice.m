function [Total_count, Trigger_Info] = Twisting_practice()

% initializing
clc; clear all; 

tic

global IO_ADDR IO_LIB;
IO_ADDR=hex2dec('2FF8');
IO_LIB=which('inpoutx64.dll');

Screen('Preference', 'SkipSyncTests', 1);

% image load
Pronation_arrow=imread('Images\left.png'); % Pronation
Supination_arrow=imread('Images\right.png'); % Supination 
movement_execution=imread('Images\ME.jpg');
cross=imread('Images\cross.jpg');

%interval setting
RepeatTimes = 4;
sti_Times = 3;      % cue time
sti_Interval = 3;   % cross time
sti_responseTime = 4;

left_count = 0;
right_count = 0;
Flexion_count = 0;
Extension_count = 0; 

%% class random하게 분배
sti_task=[1 2 1 2]';

%%
%screen setting (gray)
screens=Screen('Screens');
screenNumber=max(screens);
gray=GrayIndex(screenNumber);
[w, wRect]=Screen('OpenWindow', 1, gray);

% Wait for mouse click:
Screen('TextSize',w, 32);
DrawFormattedText(w, 'Mouse click to start Real movement experiment', 'center', 'center', [0 0 0]);
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
            tex=Screen('MakeTexture', w, left_arrow);
            Screen('DrawTexture', w, tex);
            Screen('Close',tex)
            [VBLTimestamp startrt]=Screen('Flip', w);
            ppTrigger(9);
            WaitSecs(sti_Times);
            
            disp(sprintf('Data transmission'))
            disp(sprintf('Command: Left\n'))
            
            ppTrigger(91);

            tex=Screen('MakeTexture', w, movement_execution);
            Screen('DrawTexture', w, tex);
            Screen('Close',tex)
            [VBLTimestamp startrt]=Screen('Flip', w);
            WaitSecs(sti_responseTime);
            
            ppTrigger(8);
            left_count = left_count+1;

        case 2
            
            tex=Screen('MakeTexture', w, right_arrow);
            Screen('DrawTexture', w, tex);
            Screen('Close',tex)
            [VBLTimestamp startrt]=Screen('Flip', w);
            ppTrigger(10);
            WaitSecs(sti_Times);
            
            disp(sprintf('Data transmission'))
            disp(sprintf('Command: Right\n'));
            
            ppTrigger(101);            
            
            tex=Screen('MakeTexture', w, movement_execution);
            Screen('DrawTexture', w, tex);
            Screen('Close',tex)
            [VBLTimestamp startrt]=Screen('Flip', w);
            WaitSecs(sti_responseTime);
            
            ppTrigger(8);            
            right_count = right_count+1;
             
    end
     
end

disp(sprintf('Data transmission'))
disp(sprintf('Command: Quit\n'))

WaitSecs(2);

% finish
ppTrigger(14) % end
Screen('TextSize',w, 24);
DrawFormattedText(w, 'Thank you.', 'center', 'center', [0 0 0]);
Screen('Flip', w);
WaitSecs(3);

Screen('CloseAll');
ShowCursor;

Priority(0);

Total_count = cell(3,2);
Total_count = [{'left'}, left_count;...
    {'right'},right_count;....
    {'Total Count'}, left_count+right_count];

Trigger_Info = cell(6,2);
Trigger_Info = [{'left'}, '9';...
    {'right'},'10';...
    {'left start'},'91';...
    {'left end'},'92';...
    {'right start'},'101';...
    {'right end'},'102';...
    ];

toc

end
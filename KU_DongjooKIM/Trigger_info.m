function mrk = Trigger_info( mrko, varargin )
%% Reaching
stimDef= {'S 11', 'S 21', 'S  8';
         'Forward', 'Backworkd', 'Rest'};

%% Grasping
% stimDef= {'S 11', 'S 21', 'S  8';
%     'grasp', 'spread', 'Rest'};

%% Twisting
%  stimDef= {'S 91',  'S101' 'S 92' ;
%            'Left',  'Right' 'Rest'};

%% Default
miscDef= {'S 13',    'S 14';
    'Start',   'End'};

opt= propertylist2struct(varargin{:});
opt= set_defaults(opt, 'stimDef', stimDef, ...
    'miscDef', miscDef);

mrk= mrk_defineClasses(mrko, opt.stimDef);
mrk.misc= mrk_defineClasses(mrko, opt.miscDef);
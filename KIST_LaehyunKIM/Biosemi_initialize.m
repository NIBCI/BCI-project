%  Biosmi cfg setting

% The source of the data, i.e. where it comes from, is configured as
%   cfg.dataset       = string
% or alternatively to obtain more low-level control as
%   cfg.datafile      = string
%   cfg.headerfile    = string
%   cfg.eventfile     = string
%   cfg.dataformat    = string, default is determined automatic
%   cfg.headerformat  = string, default is determined automatic
%   cfg.eventformat   = string, default is determined automatic
%
% The target for the data, i.e. where it goes to, is configured as
%   cfg.export.dataset    = string with the output file name
%   cfg.export.dataformat = string describing the output file format, see FT_WRITE_DATA
%
% Some notes about skipping data and catching up with the data stream:
%
% cfg.jumptoeof='yes' causes the realtime function to jump to the end
% when the function _starts_. It causes all data acquired prior to
% starting the realtime function to be skipped.
%
% cfg.bufferdata='last' causes the realtime function to jump to the last
% available data while _running_. If the realtime loop is not fast enough,
% it causes some data to be dropped.
%
% If you want to skip all data that was acquired before you start the
% RT function, but don't want to miss any data that was acquired while
% the realtime function is started, then you should use jumptoeof=yes and
% bufferdata='first'. If you want to analyse data from a file, then you
% should use cfg.jumptoeof='no' and cfg.bufferdata='first'.
%
% To stop this realtime function, you will have have to press Ctrl-C.

% Copyright (C) 2012, Robert Oostenveld

% set the default configuration options
    addpath(['fieldtrip-20180724/utilities/']);
    addpath(['fieldtrip-20180724/forward/']);
cfg = [];

if ~isfield(cfg, 'dataformat'),     cfg.dataformat = [];      end % default is detected automatically
if ~isfield(cfg, 'headerformat'),   cfg.headerformat = [];    end % default is detected automatically
if ~isfield(cfg, 'eventformat'),    cfg.eventformat = [];     end % default is detected automatically
if ~isfield(cfg, 'blocksize'),      cfg.blocksize =1;        end % in seconds
if ~isfield(cfg, 'overlap'),        cfg.overlap = 0;          end % in seconds
if ~isfield(cfg, 'channel'),        cfg.channel = 'all';      end % 
if ~isfield(cfg, 'bufferdata'),     cfg.bufferdata = 'first'; end % first or last
if ~isfield(cfg, 'jumptoeof'),      cfg.jumptoeof = 'yes';    end % jump to end of file at initialization
if ~isfield(cfg, 'readevent'),      cfg.readevent = 'yes';    end
if ~isfield(cfg, 'offset'),         cfg.offset = '[]';        end % in units of the data, e.g. uV for the OpenBCI board
if ~isfield(cfg, 'dataset') && ~isfield(cfg, 'header') && ~isfield(cfg, 'datafile')
  cfg.dataset = 'buffer://localhost:1972';
end


% translate dataset into datafile+headerfile
cfg = ft_checkconfig(cfg, 'dataset2files', 'yes');
cfg = ft_checkconfig(cfg, 'required', {'datafile' 'headerfile'});

% ensure that the persistent variables related to caching are cleared
clear ft_read_header

% start by reading the header from the realtime buffer
hdr = ft_read_header(cfg.headerfile, 'headerformat', cfg.headerformat, 'retry', true);

% define a subset of channels for reading
cfg.channel = ft_channelselection(cfg.channel, hdr.label);
chanindx    = match_str(hdr.label, cfg.channel);
nchan       = length(chanindx);
if nchan==0
  ft_error('no channels were selected');
end

if numel(cfg.offset)==0
  % it will be determined on the first data segment
elseif numel(cfg.offset)==1
  cfg.offset = repmat(cfg.offset, size(cfg.channel));
end

% determine the size of blocks to process
blocksize = round(cfg.blocksize * hdr.Fs);
overlap   = round(cfg.overlap*hdr.Fs);
count = 0;
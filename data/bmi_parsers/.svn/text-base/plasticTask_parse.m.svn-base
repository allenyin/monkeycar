%% Plasticity Task parser
% plasticTask_parse(f)
%   f - filename of .mat file produced by bmi_parse

function plasticTask_parse(f)

%% Strip date
date = regexp(f,'-(\d\d\d\d\d\d\d\d)-','tokens');
if (isempty(date))
    warning('DATE IMPROPERLY PARSED! Assume DATE=INF');
    date = Inf;             % Hack for now: "The Session at the End of the Universe"
else    % Proper date parse
    date = str2num(char(date{1}));
end
% Determine state based on version of the code
if (date>20110300)
    %% STATE enumeration (POST-20110215 ONLY!!!)
    ST_NULL             = 0;
    ST_DEFAULT          = 1;    % default state (button not pressed)
    ST_INTERTRIAL       = 2;	% intertrial interval
    ST_PRE_CENTER       = 3;	% cursor moves to the center target
    ST_HOLD_PRE_TARGET  = 4;    % cursor enters the center target and holds (without peripheral target on screen)
    ST_HOLD_POST_TARGET = 5;    % is in center target and holding (while peripheral target is on screen)
    ST_REACH            = 6;	% moves from center target to peripheral target
    ST_IN_TARGET        = 7;	% in peripheral target
    ST_REWARD           = 8;	% reward
    ST_ERR_PREMATURE    = 9;	% premature reach
    ST_ERR_TIMEOUT      =10;	% monkey takes too long
    ST_ERR_CANCELED     =11;	% monkey cancels the trial
    outcomeOffset       = 0;    % Offset of outcome before final trial state
else
    %% STATE enumeration (PRE-20110215 ONLY!!!)
    ST_NULL             = 0;
    ST_DEFAULT          = 1;    % default state (button not pressed)
    ST_PRE_CENTER       = 2;	% cursor moves to the center target
    ST_HOLD_PRE_TARGET  = 3;    % cursor enters the center target and holds (without peripheral target on screen)
    ST_HOLD_POST_TARGET = 4;    % is in center target and holding (while peripheral target is on screen)
    ST_REACH            = 5;	% moves from center target to peripheral target
    ST_IN_TARGET        = 6;	% in peripheral target
    ST_REWARD           = 7;	% reward
    ST_ERR_PREMATURE    = 8;	% premature reach
    ST_ERR_TIMEOUT      = 9;	% monkey takes too long
    ST_ERR_CANCELED     =10;	% monkey cancels the trial
    ST_INTERTRIAL       =11;	% intertrial interval
    outcomeOffset       = 1;    % Offset of outcome before final trial state    
end

%% Load variables from *.out file
load(f, 'state', 'cursor_x');

%% Make fake cursor_y if one does not exist
if (~exist('cursor_y','var'))
    if (~exist('cursor_x','var'))
        cursor_x = [0 0];
    end
    cursor_y = [zeros(size(cursor_x,1),1), cursor_x(:,2)];
end

%% Find all trial start/end points
trial_start = find(state(:,1) == ST_DEFAULT);	
trial_end   = trial_start(2:end,1) - 1;
trial_start = trial_start(1:end-1);     % Eliminate final trial start

%% Get number of trials
ntrials = length(trial_start);
if (ntrials == 0)
    warning('plasticTask_parse:no_trials','No completed trials in session!'); 
    return;
end

%% Preallocate trial structure and then build
trial(ntrials) = struct( ...
    'outcome', [], ...
    'outcome_t', [], ...
    'start_t', [], ...      % ST_DEFAULT
    'end_t', [], ...        % state right before each ST_DEFAULT
    'len', [], ...
    'states', [], ...       % the states for this trial
    'states_t', [] ...      % time of these states
);
% Calculate variables
outcome         = state(trial_end-outcomeOffset,1); % whatever comes before ST_DEFAULT
outcome_time    = state(trial_end-outcomeOffset,2); % time of outcome state
start_time      = state(trial_start,2);  
end_time        = state(trial_end,2);
trial_len       = end_time - start_time;
% Fill the trial structure
for i=1:ntrials
   trial(i).outcome = outcome(i);
   trial(i).outcome_t = outcome_time(i);
   trial(i).start_t = start_time(i);
   trial(i).end_t = end_time(i);
   trial(i).len = trial_len(i);
   trial(i).states = state(trial_start(i):trial_end(i),1);
   trial(i).states_t = state(trial_start(i):trial_end(i),2);
end
clear i outcome outcome_time start_time end_time trial_len;

%% Other other necessary variables
load(f,	'js*', ...
	'*target_*', ...
	'cursor_*', ...
	'use_*', ...
	'*_time', ...
    'button_state', '*_auto_button', '*control', '*trans*');

%% Fix js_y
if (size(js_y,1)<size(js_x,1))
    js_y = [zeros(size(js_x,1),1) js_x(:,2)];
end

%% Call basicTask parser
basicTask_parse;
clear cursor_y;

%% Add new fields (based on need)
% Center and peripheral target size/location and trial times
load(f, 'center_*', '*_time', 'timeout');
[trial.cursor_radius]           = dealify([trial.outcome_t],d2r(cursor_size),'previous');
[trial.center_radius]           = dealify([trial.outcome_t],d2r(center_size),'previous');
[trial.center_hold_pre_target]  = dealify([trial.outcome_t],center_home_hold_pre_target,'previous');
[trial.center_hold_post_target] = dealify([trial.outcome_t],center_home_hold_post_target,'previous');
[trial.target_radius]           = dealify([trial.outcome_t],d2r(target_size),'previous');
[trial.target_dist]             = dealify([trial.outcome_t],target_R,'previous');
[trial.target_hold]             = dealify([trial.outcome_t],target_hold_time,'previous');
[trial.reward_time]             = dealify([trial.outcome_t],reward_time,'previous');
[trial.intertrial_time]         = dealify([trial.outcome_t],intertrial_time,'previous');
[trial.timeout_time]            = dealify([trial.outcome_t],timeout,'previous');
[trial.error_time]              = dealify([trial.outcome_t],error_time,'previous');
% Trial-specific target parameters
[trial.use_correction_trials]   = dealify([trial.outcome_t],use_correction_trials,'previous');
if (~exist('target_location_angle','var') || (date<=20110415))
    target_location_angle       = [round(180/pi*angle(target_pos_x(:,1) + sqrt(-1)*target_pos_y(:,1))), target_pos_x(:,2)];
end
[trial.target_location_angle]   = dealify([trial.outcome_t],target_location_angle,'previous');
[trial.target_pos_x]            = dealify([trial.outcome_t],target_pos_x,'previous');
[trial.target_pos_y]            = dealify([trial.outcome_t],target_pos_y,'previous');
% Cue time for each trial (NaN if no reach started), also save
% whether trial is valid
for i=1:ntrials,
    % Find time index for the start of the reach state (cue)
    tI = find(trial(i).states==ST_REACH,1);
    if (~isempty(tI))
        trial(i).cue_t = trial(i).states_t(find(trial(i).states==ST_REACH,1));
    else
        % If no reach is found, mark -1 as the start of the reach time
        trial(i).cue_t = -1;
    end
    trial(i).reward = (trial(i).outcome==ST_REWARD);
    trial(i).valid  = (trial(i).outcome==ST_REWARD);
end
nValid = sum([trial.valid]);     % Count # of valid trials
% Stimulation
load(f, 'icms_*');
if (date>20110501)                  % Newer version of data processing script
    for i=0:3,
        eval(sprintf('[trial.use_stim_chan_%d]              = dealify([trial.outcome_t],use_stim_chan_%d,''previous'');',i,i));
        eval(sprintf('[trial.icms_chan_%d_wait]             = dealify([trial.outcome_t],icms_chan_%d_wait,''previous'');',i,i));
        eval(sprintf('[trial.icms_chan_%d_current]          = dealify([trial.outcome_t],icms_chan_%d_current,''previous'');',i,i));
        eval(sprintf('[trial.icms_chan_%d_pulse_width]      = dealify([trial.outcome_t],icms_chan_%d_ancat,''previous'');',i,i));
        eval(sprintf('[trial.icms_chan_%d_biphasic_delay]   = dealify([trial.outcome_t],icms_chan_%d_delay,''previous'');',i,i));
        eval(sprintf('[trial.icms_chan_%d_freqA]            = dealify([trial.outcome_t],icms_chan_%d_freq,''previous'');',i,i));
        eval(sprintf('[trial.icms_chan_%d_n_pulses]         = dealify([trial.outcome_t],icms_chan_%d_pulses,''previous'');',i,i));
        eval(sprintf('[trial.icms_chan_%d_freqB]            = dealify([trial.outcome_t],icms_chan_%d_freqB,''previous'');',i,i));
        eval(sprintf('[trial.icms_chan_%d_n_groups]         = dealify([trial.outcome_t],icms_chan_%d_groups,''previous'');',i,i));
        eval(sprintf('[trial.icms_trig_time_chan_%d]        = dealify([trial.outcome_t],icms_trig_time_chan_%d,''previous'');',i,i));
        eval(sprintf('[trial.icms_trig_angle_chan_%d]       = dealify([trial.outcome_t],icms_trig_angle_chan_%d,''previous'');',i,i));
    end
    [trial.icms_trig_time_first]    = dealify([trial.outcome_t],icms_trig_time_first,'previous');
else
    % Old-style capturing of icms params
    [trial.use_stimulator]          = dealify([trial.outcome_t],use_stimulator,'previous');
    [trial.icms_current]            = dealify([trial.outcome_t],icms_chan_0_current,'previous');
    [trial.icms_wait]               = dealify([trial.outcome_t],icms_chan_0_wait,'previous');
    [trial.icms_pulse_width]        = dealify([trial.outcome_t],icms_chan_0_ancat,'previous');
    [trial.icms_biphasic_delay]     = dealify([trial.outcome_t],icms_chan_0_delay,'previous');
    [trial.icms_freqA]              = dealify([trial.outcome_t],icms_chan_0_freq,'previous');
    [trial.icms_n_pulses]           = dealify([trial.outcome_t],icms_chan_0_pulses,'previous');
    [trial.icms_freqB]              = dealify([trial.outcome_t],icms_chan_0_freqB,'previous');
    [trial.icms_n_groups]           = dealify([trial.outcome_t],icms_chan_0_groups,'previous');
    [trial.icms_trig_time]          = dealify([trial.outcome_t],icms_trig_time,'previous');
    [trial.icms_trig_angle]         = dealify([trial.outcome_t],icms_trig_angle,'previous');
end

% Misc params
load(f,'stim_trial*','record_trial_num','rev_angle*','trial_group_ctr','task2d','n_reward');
load(f,'stim_delay*','delay_trial');
if (~exist('stim_trial_ratio','var'))
    stim_trial_ratio = [0.5 0];     % Backwards compatibility
end
[trial.stim_trial_ratio]        = dealify([trial.outcome_t],stim_trial_ratio,'previous');
if (~exist('stim_delay_ratio','var'))
    stim_delay_ratio = [nan 0];     % Backwards compatibility
end
[trial.stim_delay_ratio]        = dealify([trial.outcome_t],stim_delay_ratio,'previous');
if (~exist('stim_delay','var'))
    stim_delay = [nan 0];     % Backwards compatibility
end
[trial.stim_delay]              = dealify([trial.outcome_t],stim_delay,'previous');
if (~exist('delay_trial','var'))
    delay_trial = [nan 0];     % Backwards compatibility
end
[trial.delay_trial]             = dealify([trial.outcome_t],delay_trial,'previous');
if (exist('task2d','var'))
    [trial.task2d]              = dealify([trial.outcome_t],task2d,'previous');
end
if (exist('n_reward','var'))
    [trial.n_reward]            = dealify([trial.outcome_t],n_reward,'previous');
end

% Previously these were combined, now they are separated by channel
if (date>20110501)
    for i=0:3,
        eval(sprintf('[trial.stim_trial_chan_%d]        = dealify([trial.outcome_t],stim_trial_chan_%d,''previous'');',i,i));
        eval(sprintf('[trial.icms_ok_to_stim_chan_%d]   = dealify([trial.outcome_t],icms_ok_to_stim_chan_%d,''previous'');',i,i));
    end
    [trial.icms_ok_to_stim]         = dealify([trial.outcome_t],icms_ok_to_stim,'previous');
    [trial.record_trial_num]        = dealify([trial.outcome_t],record_trial_num,'previous');
    [trial.rev_angle_every_n_groups]= dealify([trial.outcome_t],rev_angle_every_n_groups,'previous');
    [trial.rev_angle_group_ctr]     = dealify([trial.outcome_t],rev_angle_group_ctr,'previous');
    [trial.rev_angle_stim]          = dealify([trial.outcome_t],rev_angle_stim,'previous');
    [trial.stim_trial_num]          = dealify([trial.outcome_t],stim_trial_num,'previous');
    [trial.stim_trial_group_type]   = dealify([trial.outcome_t],stim_trial_group_type,'previous');
    [trial.trial_group_ctr]         = dealify([trial.outcome_t],trial_group_ctr,'previous');
else
    %% Old style
    if (~exist('icms_stim_trial','var'))
        % Date-specific hack
        if (date==20110415)
            icms_stim_trial = [-1 0];   % -1 is to indicate unknown
        else
            icms_stim_trial = [0 0];
        end
    end
    [trial.icms_stim_trial]         = dealify([trial.outcome_t],icms_stim_trial,'previous');
    if (~exist('icms_ok_to_stim','var'))
        % Date-specific hack: 04/15/2011 is only pre-proper-reporting date w/ stimulation
        if (date==20110415)
            % CALL SCRIPT THAT LOADS STIM INFORMATION - SHOULD BE IN SAME
            % DIRECTORY AS DATA FILE
            determine_stim;
            icms_ok_to_stim = num2cell(icms_ok_to_stim);
            [trial.icms_ok_to_stim]     = deal(icms_ok_to_stim{:});
        else
            [trial.icms_ok_to_stim]     = dealify([trial.outcome_t],[0 0],'previous');
        end
    else
        [trial.icms_ok_to_stim]         = dealify([trial.outcome_t],icms_ok_to_stim,'previous');
    end
end

if (~exist('icms_triggered','var'))
    if (date==20110415)
        icms_triggered = [-1 0];   % -1 is to indicate unknown
    else
        icms_triggered = [0 0];
    end
end
[trial.icms_triggered]          = dealify([trial.outcome_t],icms_triggered,'previous');
    
%% Look for bad trials (manually marked)
% Initially set markBad field to all zeros
[trial.markBad]                 = deal(0);
% Check for trials marked bad
fMarkBad = './markbadtrials.conf';
if (exist(fMarkBad,'file'))
    % Load data
    [rawData{1:2}]      = textread(fMarkBad,'%d%d','commentstyle','matlab');
    badTrialRangeAry    = [rawData{:}];
else
    badTrialRangeAry    = [];
end
% Iterate over rows in the data file
for i=1:size(badTrialRangeAry,1),
    badLo = badTrialRangeAry(i,1);
    badHi = min(ntrials,badTrialRangeAry(i,2));
    % Mark these trials as bad
    [trial(badLo:badHi).markBad]    = deal(1);
    % Mark these trials as invalid
    [trial(badLo:badHi).valid]      = deal(0);
end    

%% Organize trial structure
trial = orderfields(trial); % make it pretty

%% Save in new parsed file - WHAT IS CATCH FOR?
[pstr,fstr,estr] = fileparts(f);
try
  save(fullfile(pstr,[fstr,'_parsed',estr]), ...
  'trial', 'nValid', 'ST_*');
catch
  save(fullfile(pstr,[fstr,'_parsed',estr]), ...
  'trial', 'nValid', 'ST_*');
end

end

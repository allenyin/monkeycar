% TEXTUREFEEDBACK_PARSE 
%
% $Id: sensationFeedbackRandFreqB_parse.m 1041 2011-01-30 08:44:57Z joey $
% 
% this function reads in a textureFeedback behavior file
% processes the data and saves a _parsed file to speed up
% subsequent analysis

function textureFeedback_parse(f)

% DEFINE THE STROBES
ST_NULL = 0;
ST_READY = 1;
ST_PRE_CENTER = 2; 
ST_IN_CENTER = 3;
ST_EXPLORE = 4;
ST_IN_CORRECT_TARGET = 5;
ST_IN_WRONG_TARGET = 6;	
ST_REWARD = 7;
ST_ERR_GENERIC = 8;
ST_ERR_TIMEOUT = 9;
ST_ERR_CANCELED = 10;
ST_INTERTRIAL = 11;

disp(f);

load(f, 'state', 'cursor_x', 'cursor_y');

common_parse;
[msgid,msgid] = lastwarn;
if (strcmp(msgid,'common_parse:no_trials'))
	lastwarn('','');
	return;
end

load(f,	'js*', ...
	'*target_*', ...
	'cursor_*', ...
	'reach_radius', ...
	'use_*', ...
	'*_time', '*_timeout', ...
	'button_state', '*_auto_button', '*control', '*trans*');

basicTask_parse;

parse = make_parser([trial.outcome_t],'previous');

load(f, 'icms_*', 'no_penalty_for_picking_wrong', ...
	'*_texture_*', ...
	'stim*', 'rotate_targets');

[trial.cursor_radius] = parse(d2r(cursor_size));
[trial.target_radius] = parse(d2r(target_size));
[trial.center_target_radius] ...
	= parse(d2r(center_target_size));
[trial.center_hold_t] = parse(center_target_hold_time);
[trial.target_hold_t] = parse(target_hold_time);

[trial.use_corrtr] = parse(use_correction_trials);
[trial.use_rigorous_center_hold] = parse(use_rigorous_center_hold);

[trial.no_penalty_for_picking_wrong] = parse(no_penalty_for_picking_wrong);

[trial.rotate_targets] = parse(rotate_targets);

[trial.use_icms] = parse(use_stim);

[trial.icms_chan_0_current] = parse(icms_chan_0_current);

[trial.icms_chan_0_CV] = parse(icms_chan_0_freqBPctStd);

[trial.icms_chan_0_randFreqB] = parse(icms_chan_0_randFreqB);
  
[trial.icms_chan_0_randPeriodB] = parse(icms_chan_0_randPeriodB);

[trial.correct_freq]  = parse(correct_texture_freq);
[trial.correct_angle] = parse(correct_texture_angle);
[trial.wrong_freq]    = parse(wrong_texture_freq);
[trial.wrong_angle]   = parse(wrong_texture_angle);

[trial.reach_radius] = parse(reach_radius);

% ferret out correction trials
rew_trl = [trial.outcome] == ST_REWARD;         % rewarded trials
err_trl = [trial.outcome] == ST_ERR_GENERIC;    % completed, but wrong
% now let's catch all the canceled trials that might be valid
% NOPE CANT DO THIS FOR FEEDBACK
can_trl = [trial.outcome] ~= ST_REWARD & ...
          [trial.outcome] ~= ST_ERR_GENERIC;    % canceled trials
tmp = double(rew_trl);
tmp = [1 tmp(1:end-1)];
if any(tmp == -1)
  disp('oops');
  keyboard;
end
tmp = num2cell(logical(tmp));
[trial.is_random] = deal(tmp{:});       % should be random

correct_target_x = trialify([trial.outcome_t],correct_target_pos_x,'previous');
correct_target_y = trialify([trial.outcome_t],correct_target_pos_y,'previous');

wrong_target_x = trialify([trial.outcome_t],wrong_target_pos_x,'previous');
wrong_target_y = trialify([trial.outcome_t],wrong_target_pos_x,'previous');

for i=1:length(trial)
  trial(i).correct_target_pos = [correct_target_x(i) ; correct_target_y(i)];
  trial(i).wrong_target_pos = [wrong_target_x(i) ; wrong_target_y(i)];
end

trial = orderfields(trial); % make it pretty

% save in parsed file
[pstr,fstr,estr] = fileparts(f);

try
  save(fullfile(pstr,[fstr,'_parsed',estr]), ...
  'trial', 'ST_*');
catch
  save(fullfile(pstr,[fstr,'_parsed',estr]), ...
  'trial', 'ST_*');
end

end

function [f] = make_parser(trial_markers, mode)
  f = @(events) dealify(trial_markers, events, mode);
end


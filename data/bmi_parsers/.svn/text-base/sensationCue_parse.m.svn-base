% SENSATIONFCUE_PARSE 
%
% $Id: sensationCue_parse.m 713 2009-11-04 04:13:47Z joey $
% 
% this function reads in a sensationCue behavior file
% processes the data and saves a _parsed file to speed up
% subsequent analysis

function sensationCue_parse(f)

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

load(f,	'js*', ...
	'*target_*', ...
	'cursor_*', ...
	'reach_radius', ...
	'use_*', ...
	'*_time', '*_timeout', ...
	'button_state', '*_auto_button', '*control', '*trans*');

basicTask_parse;

[trial.cursor_size] = dealify([trial.outcome_t],cursor_size,'previous');
[trial.target_size] = dealify([trial.outcome_t],target_size,'previous');
[trial.center_target_size] = dealify([trial.outcome_t],center_target_size,'previous');
[trial.center_hold_t] = dealify([trial.outcome_t],center_target_hold_time,'previous');
[trial.target_hold_t] = dealify([trial.outcome_t],target_hold_time,'previous');
try
  [trial.target_num] = dealify([trial.outcome_t],active_target_number,'previous');
catch
  [trial.target_num] = deal(-1);
end

[trial.use_corrtr] = dealify([trial.outcome_t],use_correction_trials,'previous');
try
  [trial.use_forced_choice] = dealify([trial.outcome_t],use_forced_choice,'previous');
catch
  [trial.use_forced_choice] = deal(1);
end
[trial.use_rigorous_center_hold] = dealify([trial.outcome_t],use_rigorous_center_hold,'previous');

[trial.use_vib] = dealify([trial.outcome_t],use_vibrator,'previous');
[trial.use_vis] = dealify([trial.outcome_t],use_visual_cue,'previous');
try
  [trial.use_icms] = dealify([trial.outcome_t],use_stimulator,'previous');
catch
  [trial.use_icms] = deal(0);
end

% the rewarded target
try
  tmp1 = dealify([trial.outcome_t],target_x,'previous');
catch
  tmp1 = dealify([trial.outcome_t],[NaN 0],'previous');
end
try
  tmp2 = dealify([trial.outcome_t],target_y,'previous');
catch
  tmp2 = dealify([trial.outcome_t],[0 0],'previous');
end
[trial.target] = deal(num2cell([tmp1 tmp2],2));

try
  [trial.reach_radius] = dealify([trial.outcome_t],reach_radius,'previous');
catch
  [trial.reach_radius] = sqrt(target_trl(:,1).^2 + target_trl(:,2).^2);

end

% save in parsed file
[pstr,fstr,estr] = fileparts(f);
save(fullfile(pstr,[fstr,'_parsed',estr]), ...
  'trial', 'ST_*');

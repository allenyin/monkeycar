% FITTSTASK2_PARSE 
%
% $Id: fittsTask2_parse.m 988 2010-11-11 06:36:44Z joey $
% 
% this function reads in a fittsTask behavior file
% processes the data and saves a _parsed file to speed up
% subsequent analysis

function fittsTask2_parse(f)

% DEFINE THE STROBES
ST_NULL = 0;
ST_DEFAULT = 1;
ST_PRE_CENTER = 2;
ST_HOLD_PRE_VISION = 3;
ST_HOLD_POST_VISION = 4;
ST_REACH = 5;
ST_IN = 6;
ST_REWARD = 7;
ST_ERR_TOOFAR = 8;
ST_ERR_TIMEOUT = 9;
ST_ERR_CANCELED = 10;
ST_OUT_OF_RING =11;
ST_INTERTRIAL = 12;


disp(f);

load(f, 'state', 'cursor_x', 'cursor_y');

if any(state(:,1)==12)
    ST_ERR_IN_AND_OUT = 11;
    ST_INTERTRIAL = 12;
end
    
common_parse;

load(f,	'js*', ...
	'target_*', ...
	'center_target_*', ...
	'cursor_size', ...
	'reach_radius', ...
    'block_pos',...
	'intertrial_time', 'timeout', 'error_time', ...
	'button_state', '*_auto_button', '*control', '*trans*');

basicTask_parse;

[trial.cursor_size] = dealify([trial.outcome_t],cursor_size,'previous');
[trial.target_r1] = dealify([trial.outcome_t],target_r1,'previous');
[trial.target_r2] = dealify([trial.outcome_t],target_r2,'previous');
[trial.target_theta1] = dealify([trial.outcome_t],target_location_angle,'previous');  %location of variable target
[trial.target_theta2] = dealify([trial.outcome_t],target_width,'previous');           %width of variable target
%comment out the following line on data before 9/30/2010
[trial.block_pos] = dealify([trial.outcome_t],block_pos,'previous');

[trial.target_hold_t] = dealify([trial.outcome_t],target_hold_time,'previous');

[trial.center_target_size] = dealify([trial.outcome_t],center_target_size,'previous');
[trial.center_hold_t1] = dealify([trial.outcome_t],center_target_hold_pre_vision,'previous');
[trial.center_hold_t2] = dealify([trial.outcome_t],center_target_hold_post_vision,'previous');

tmp1 = trialify([trial.outcome_t],target_x,'previous');    %only outputs the target_x and y  of the variable target...update if needed
tmp2 = trialify([trial.outcome_t],target_y,'previous');
[trial.target] = deal(num2cell([tmp1 tmp2],2));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% From here we have to loop :-(
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for i=1:ntrials,

  trial(i).t_hold_1_start = trial(i).states_t(trial(i).states == ST_HOLD_PRE_VISION);
  trial(i).t_hold_1_end   = trial(i).states_t(trial(i).states == ST_HOLD_POST_VISION);
  trial(i).t_hold_2_start = trial(i).states_t(trial(i).states == ST_HOLD_POST_VISION);
  trial(i).t_hold_2_end   = trial(i).states_t(trial(i).states == ST_REACH);

  trial(i).t_reach_start = trial(i).states_t(trial(i).states == ST_REACH); % there should only be one
  
end

% save in parsed file
[pstr,fstr,estr] = fileparts(f);
save(fullfile(pstr,[fstr,'_parsed',estr]), ...
  'trial', 'ST_*');

% FITTSTASK_PARSE 
%
% $Id: fittsTask_parse.m 834 2010-08-11 01:00:50Z joey $
% 
% this function reads in a fittsTask behavior file
% processes the data and saves a _parsed file to speed up
% subsequent analysis

function fittsTask_parse(f)

% DEFINE THE STROBES
ST_NULL = 100;
ST_DEFAULT = 101;
ST_MOV_1 = 102;
ST_IN_CENTER = 103;
ST_MOV_2 = 104;
ST_IN = 105;
ST_REWARD = 106;
ST_INTERTRIAL = 107;
ST_MOV_1_ERR = 108;
ST_IN_CENTER_ERR = 109;
ST_MOV_2_ERR = 110;
ST_IN_ERR = 111;
ST_TIMEOUT_ERR = 112;

disp(f);

load(f, 'state', 'cursor_x', 'cursor_y');

common_parse;

load(f,	'js*', ...
	'target_*', ...
	'center_target_*', ...
	'cursor_size', ...
	'reach_radius', ...
	'intertrial_time', 'timeout', 'error_time', ...
	'button_state', '*_auto_button', '*control', '*trans*');

basicTask_parse;

[trial.cursor_size] = dealify([trial.outcome_t],cursor_size,'previous');
[trial.target_size] = dealify([trial.outcome_t],target_size,'previous');
[trial.center_target_size] = dealify([trial.outcome_t],center_target_size,'previous');
[trial.center_hold_t] = dealify([trial.outcome_t],center_target_hold_time,'previous');
[trial.target_hold_t] = dealify([trial.outcome_t],target_hold_time,'previous');
[trial.reach_radius] = dealify([trial.outcome_t],reach_radius,'previous');

% the rewarded targets
tmp1 = trialify([trial.outcome_t],target_x,'previous');
tmp2 = trialify([trial.outcome_t],target_y,'previous');
[trial.target] = dealcell(num2cell([tmp1 tmp2],2));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% From here we have to loop :-(
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for i=1:ntrials,

  iii = trial(i).states == ST_IN;           % logical vector of IN states
  trial(i).in_t = trial(i).states_t(iii);   % vector of IN state times
  iiii = trial(i).states(find(iii)+1) == ST_MOV_2; % logical of MOV after IN
  trial(i).out_t = trial(i).states_t(iiii); % vector of MOV_2 times after IN
  
  iii = trial(i).states == ST_MOV_2; 		% logical of MOV_2 states
  jjj = trial(i).states == trial(i).outcome; 	% outcome state
  tmp = trial(i).states_t(iii);			% vector of MOV_2 states
  if (~isempty(tmp))
    trial(i).len_mov_t = trial(i).outcome_t - tmp(1);
    iiii = find(iii);
    jjjj = find(jjj);
    iiiii = trial(i).states_cursor(iiii(1)); % index into cursor vector 
    jjjjj = trial(i).states_cursor(jjjj(1));
    ttmp = trial(i).cursor(1,iiiii:jjjjj);
	 xtmp = trial(i).cursor(2,iiiii:jjjjj);
    ytmp = trial(i).cursor(3,iiiii:jjjjj);
	 trial(i).len_mov = sum(sqrt(diff(xtmp).^2 + diff(ytmp).^2));
	% this is the radial distance from cursor to target
	% taken at each time point
	% starting with MOV_2
	trial(i).cursor_r(1,:) = ttmp;
	trial(i).cursor_r(2,:) = sqrt((xtmp-target_trl(i,1)).^2 + (ytmp-target_trl(i,2)).^2);
  else
	trial(i).len_mov_t = NaN;
	trial(i).len_mov = NaN;
	trial(i).cursor_r = NaN;
  end
  
  trial(i).tar_theta = atan2(target_trl(i,2),target_trl(i,1));

end

% save in parsed file
[pstr,fstr,estr] = fileparts(f);
save(fullfile(pstr,[fstr,'_parsed',estr]), ...
  'trial', 'ST_*');

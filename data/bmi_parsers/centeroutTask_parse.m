% CENTEROUTTASK_PARSE
% 
% this function reads in a centerout task behavior file
% processes the data and saves a _parsed file to speed up
% subsequent analysis
%
% $Id: centeroutTask_parse.m 959 2010-10-27 04:38:09Z joey $

function centeroutTask_parse(f)

% DEFINE THE STROBES
ST_NULL = 100;
ST_DEFAULT = 101;
ST_MOV = 102;
ST_IN = 103;
ST_REWARD = 104;
ST_INTERTRIAL = 105;
ST_MOV_ERR = 106;
ST_MOVTO_ERR = 107;
ST_IN_ERR = 108;
ST_OVERRIDE = 109;

disp(f);

load(f, 'state', 'pos_x', 'pos_y', 'cursor_x', 'cursor_y');

common_parse;

load(f, 'js*', ...
		'target_x', 'target_y', 'target_pos_*', ...
		'cursor_size', 'target_size', ...
		'reward_criteria', 't_hold*', ...
		'button_state', ...
		'reach_radius' , '*_auto_button', '*control', 'trans*');

basicTask_parse;

% if the target size ratio does not exist, set it to 1.0.

cur_sz_trl = trialify([trial.outcome_t],cursor_size,'previous');
tar_sz_trl = trialify([trial.outcome_t],target_size,'previous');
rew_cr_trl = trialify([trial.outcome_t],reward_criteria,'previous');
if exist('t_hold','var')
  [trial.hold_t] = dealify([trial.outcome_t],t_hold,'previous');
else
 [trial.center_hold_t] = dealify([trial.outcome_t],t_hold_center,'previous');
 [trial.target_hold_t]= dealify([trial.outcome_t],t_hold_peripheral,'previous');
end

if ( ~exist('target_x','var') | ...
     (exist('target_x','var') & exist('target_pos_x','var')) )
  target_x = target_pos_x;
  target_y = target_pos_y;
end

% the rewarded targets
tmp1 = trialify([trial.outcome_t],target_x,'previous');
tmp2 = trialify([trial.outcome_t],target_y,'previous');
target_trl = [tmp1 tmp2];


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% From here we have to loop :-(
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for i=1:ntrials,

  iii = trial(i).states == ST_IN;           % logical vector of IN states
  trial(i).in_t = trial(i).states_t(iii);   % vector of IN state times
  iiii = trial(i).states(find(iii)+1) == ST_MOV; % logical of MOV after IN
  trial(i).out_t = trial(i).states_t(iiii); % vector of MOV times after IN
    
  % get vector indicating if trial is to center target or periphery target
  trial(i).center = 0;
  if ( target_trl(i,1) == 0 && target_trl(i,2) == 0 )
    trial(i).center = 1;
  end

  trial(i).tar_theta = NaN;
  if (trial(i).center == 0)
    trial(i).tar_theta = atan2(target_trl(i,2),target_trl(i,1));
  end 

  % catch everything that was done outside this loop
  trial(i).cursor_size = cur_sz_trl(i);
  trial(i).target_size = tar_sz_trl(i);
  trial(i).reward_crit = rew_cr_trl(i);
  %trial(i).hold_t = t_hold_trl(i);
  trial(i).target = target_trl(i,:);

end

% save in parsed file
[pstr,fstr,estr] = fileparts(f);
save(fullfile(pstr,[fstr,'_parsed',estr]), ...
  'trial', 'ST_*');

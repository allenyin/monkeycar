ut% ACQUIRETASK_PARSE
%
% $Id: acquireTask_parse.m 713 2009-11-04 04:13:47Z joey $
% 
% this function reads in a acquire task behavior file
% processes the data and saves a _parse file to speed up
% subsequent analysis

function acquireTask_parse(f)

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
ST_IN_WRONG = 110;
ST_IN_WRONG_ERR = 111;

disp(f);

load(f, 'state', 'pos_x', 'pos_y', 'cursor_x', 'cursor_y');

common_parse;

load(f, 'js*', ...
			'target_*', ...
			'inactive_target_*', ...
			'cursor_size', 'center_tar_size*', ...
			'reward_criteria', 't_hold', ...
			'*auto_button', ...
			'reach_radius' , '*_state', '*control', ...
			'*_vis', ...
			'use_*', ...
			'*background*', ...
			'*trans*');

basicTask_parse;

cur_sz_trl = trialify([trial.outcome_t],cursor_size,'previous');
tar_sz_trl = trialify([trial.outcome_t],target_size,'previous');
try
  cntr_tar_sz_trl = trialify([trial.outcome_t],center_tar_size,'previous');
catch  
  cntr_tar_sz_trl = tar_sz_trl .* trialify([trial.outcome_t],center_tar_size_ratio,'previous');
end
reach_radius_trl = trialify([trial.outcome_t],reach_radius,'previous');
t_hold_trl = trialify([trial.outcome_t],t_hold,'previous');

rew_cr_trl = trialify([trial.outcome_t],reward_criteria,'previous');
vib_st_trl = trialify([trial.outcome_t],vib_state,'previous');
tar_activ_vis_trl = trialify([trial.outcome_t],target_active_vis,'previous');
tar_activ_vis_trl(isnan(tar_activ_vis_trl)) = 0;
tar_inact_vis_trl = trialify([trial.outcome_t],target_inactive_vis,'previous');
tar_inact_vis_trl(isnan(tar_inact_vis_trl)) = 0;

try
  vis_st_trl = trialify([trial.outcome_t],vis_state,'previous');
catch
  vis_st_trl = zeros(ntrials,1);
end
vis_st_trl(isnan(vis_st_trl)) = 0;

try
   color_bkgnd_during_cue_trl = trialify([trial.outcome_t],color_background_during_cue,'previous');
catch
   color_bkgnd_during_cue_trl = zeros(ntrials,1);
end
color_bkgnd_during_cue_trl(isnan(color_bkgnd_during_cue_trl)) = 0;

try
   bkgnd_opacity_during_cue_trl = trialify([trial.outcome_t],background_opacity_during_cue,'previous');
catch
   bkgnd_opacity_during_cue_trl = zeros(ntrials,1);
end

% compute "visual" trials
vis_st_trl = 	vis_st_trl | ... 
	     	tar_activ_vis_trl ~= 0 | ...
		tar_inact_vis_trl == 0 | ...
		color_bkgnd_during_cue_trl;

try 
    ustim_st_trl = trialify([trial.outcome_t], stim_state, 'previous');
catch
    ustim_st_trl = zeros(ntrials,1);
end

try
    pavlov_trl = trialify([trial.outcome_t],use_pavlov,'previous');
catch
    pavlov_trl = zeros(ntrials,1);
end

try
    use_cue_trl = trialify([trial.outcome_t],use_cue,'previous');
catch
    use_cue_trl = zeros(ntrials,1);
end

try
   use_corrtr_trl = trialify([trial.outcome_t],use_correction_trials,'previous');
catch
   use_corrtr_trl = zeros(ntrials,1);
end

try
   color_bkgnd_during_cue_trl = trialify([trial.outcome_t],color_background_during_cue,'previous');
catch
   color_bkgnd_during_cue_trl = zeros(ntrials,1);
end

try
   bkgnd_opacity_during_cue_trl = trialify([trial.outcome_t],background_opacity_during_cue,'previous');
catch
   bkgnd_opacity_during_cue_trl = zeros(ntrials,1);
end

if ( ~exist('target_x','var') || ...
     (exist('target_x','var') && exist('target_pos_x','var')) )
  target_x = target_pos_x;
  target_y = target_pos_y;
end

% the rewarded targets
tmp1 = trialify([trial.outcome_t],target_x,'previous');
tmp2 = trialify([trial.outcome_t],target_y,'previous');
target_trl = [tmp1 tmp2];

% target 0 position
tmp1 = trialify([trial.outcome_t],inactive_target_0_pos_x,'previous');
tmp2 = trialify([trial.outcome_t],inactive_target_0_pos_y,'previous');
target_0_trl = [tmp1 tmp2];

% target 1 position
tmp1 = trialify([trial.outcome_t],inactive_target_1_pos_x,'previous');
tmp2 = trialify([trial.outcome_t],inactive_target_1_pos_y,'previous');
target_1_trl = [tmp1 tmp2];

% target 2 position
tmp1 = trialify([trial.outcome_t],inactive_target_2_pos_x,'previous');
tmp2 = trialify([trial.outcome_t],inactive_target_2_pos_y,'previous');
target_2_trl = [tmp1 tmp2];

% get trials to center
% this is pretty clever if i do say so myself
center_trl = ( sum(abs(target_0_trl-target_trl) < MY_EPS,2) == 2 );

% get the "bad" target. assumes:
% 1. only 2 targets are on at a time
% 2. targets 1 and 2 are symmetrically (radially) arranged around zero
target_bad_trl = NaN(ntrials,2);
target_bad_trl(~center_trl,:) = -target_trl(~center_trl,:);

target_num_trl = zeros(ntrials,1);
target_num_trl(sum(abs(target_trl - target_0_trl) < MY_EPS,2) == 2) = 0;
target_num_trl(sum(abs(target_trl - target_1_trl) < MY_EPS,2) == 2) = 1;
target_num_trl(sum(abs(target_trl - target_2_trl) < MY_EPS,2) == 2) = 2;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% From here we have to loop :-(
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for i=1:length(trial) 
    
  iii = trial(i).states == ST_IN;           % logical vector of IN states
  trial(i).in_t = trial(i).states_t(iii);   % vector of IN state times
  iiii = trial(i).states(find(iii)+1) == ST_MOV; % logical of MOV after IN
  trial(i).out_t = trial(i).states_t(iiii); % vector of MOV times after IN

  if ( any(state(:,1) == ST_IN_WRONG) ) 		% the easy way
      iii = trial(i).states == ST_IN_WRONG;             % logical vector of IN_WRONG
      trial(i).in_wrong_t = trial(i).states_t(iii);     % vector of IN_WRONG times
      iiii = trial(i).states(find(iii)+1) == ST_MOV;    % logcal of MOV after IN_WRONG
      trial(i).out_wrong_t = trial(i).states_t(iiii);	% vector of MOV times after IN_WRONG
  else % the hard way
      n=1; o=1; okin=1;
      for j=1:size(trial(i).cursor,2)
          % is the cursor in the "wrong" target?
          if ( cursor_in_target(trial(i).cursor(2:3,j), ...
	                        target_bad_trl(i,:)', ...
				cur_sz_trl(i), ...
				tar_sz_trl(i), ...
				rew_cr_trl(i)) ...
			&& okin == 1)
              okin=0;
              trial(i).in_wrong_t(n) = trial(i).cursor(1,j);
              n=n+1;
          end
          if ( ~cursor_in_target(trial(i).cursor(2:3,j), ...
	  		         target_bad_trl(i,:)', ...
				 cur_sz_trl(i), ...
				 tar_sz_trl(i), ...
				 rew_cr_trl(i)) ...
                  	&& okin == 0)
              okin=1;
	          trial(i).out_wrong_t(o) = trial(i).cursor(1,j);
	          o=o+1;
          end
      end
  end

  % catch everything that was done outside this loop
  trial(i).cursor_size = cur_sz_trl(i);
  trial(i).target_size = tar_sz_trl(i);
  trial(i).reward_crit = rew_cr_trl(i);
  trial(i).vib_state = vib_st_trl(i);
  trial(i).hold_t = t_hold_trl(i);
  trial(i).tar_act_vis = tar_activ_vis_trl(i);
  trial(i).tar_inact_vis = tar_inact_vis_trl(i);
  trial(i).vis_state = vis_st_trl(i);
  trial(i).ustim_state = ustim_st_trl(i);
  trial(i).pavlov_st = pavlov_trl(i);
  trial(i).use_cue = use_cue_trl(i);
  trial(i).use_corrtr = use_corrtr_trl(i);
  trial(i).target = target_trl(i,:);
  trial(i).target_bad = target_bad_trl(i,:);
  trial(i).target_0 = target_0_trl(i,:);
  trial(i).target_1 = target_1_trl(i,:);
  trial(i).target_2 = target_2_trl(i,:);
  trial(i).center = center_trl(i);
  trial(i).target_num = target_num_trl(i);
end

% save in parsed file
[pstr,fstr,estr] = fileparts(f);
save(fullfile(pstr,[fstr,'_parsed',estr]), ...
  'trial', 'ST_*');

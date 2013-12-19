% SENSATIONFEEDBACK_PARSE 
%
% $Id: sensationFeedbackRandFreqB_parse.m 1041 2011-01-30 08:44:57Z joey $
% 
% this function reads in a sensationFeedback behavior file
% processes the data and saves a _parsed file to speed up
% subsequent analysis

function sensationFeedbackRandFreqB_parse(f)

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

load(f, 'icms_*', 'feedback_cloud_*', 'no_penalty_for_picking_wrong', ...
	'stim*', 'rotate_targets');

[trial.cursor_radius] = dealify([trial.outcome_t],d2r(cursor_size),'previous');
[trial.target_radius] = dealify([trial.outcome_t],d2r(target_size),'previous');
[trial.center_target_radius] ...
	= dealify([trial.outcome_t],d2r(center_target_size),'previous');
[trial.feedback_cloud_radius] ...
	= dealify([trial.outcome_t],d2r(feedback_cloud_size),'previous');
[trial.center_hold_t] = dealify([trial.outcome_t],center_target_hold_time,'previous');
[trial.target_hold_t] = dealify([trial.outcome_t],target_hold_time,'previous');
try
  [trial.target_num] = dealify([trial.outcome_t],active_target_number,'previous');
catch
  [trial.target_num] = deal(-1);
end
num_targets = max([trial.target_num]) + 1;
if exist('other_target_number','var')
  [trial.target_num_B] = dealify([trial.outcome_t],other_target_number,'previous');
else
  if num_targets == 2
    [trial.target_num_B] = dealarray([trial.target_num]+1);
    [trial([trial.target_num_B]==2).target_num_B] = deal(0);
  else
    [trial.target_num_B] = deal(-1);
  end
end


[trial.use_corrtr] = dealify([trial.outcome_t],use_correction_trials,'previous');
[trial.use_rigorous_center_hold] = dealify([trial.outcome_t],use_rigorous_center_hold,'previous');

try
  [trial.no_penalty_for_picking_wrong] = dealify([trial.outcome_t],no_penalty_for_picking_wrong,'previous');
catch
  [trial.no_penalty_for_picking_wrong] = deal(0);
end

try
  [trial.rotate_targets] = dealify([trial.outcome_t],rotate_targets,'previous');
catch
  [trial.rotate_targets] = deal(0);
end

try
  [trial.use_icms_psycho] = dealify([trial.outcome_t],use_random_icms_current,'previous');
catch
  [trial.use_icms_psycho] = deal(0);
end

try
  [trial.use_icms] = dealify([trial.outcome_t],use_stimulator,'previous');
catch
  [trial.use_icms] = deal(0);
end

try
  [trial.icms_chan_0_current] = dealify([trial.outcome_t],icms_chan_0_current,'previous');
catch
  [trial.icms_chan_0_current] = deal(-1);
end

[trial.icms_chan_0_freqBPctStd] = dealify([trial.outcome_t],icms_chan_0_freqBPctStd,'previous');

try
  [trial.icms_chan_0_randFreqB] = dealify([trial.outcome_t],icms_chan_0_randFreqB,'previous');
catch
  [trial.icms_chan_0_randFreqB] = deal(1);
end

try
  [trial.icms_chan_0_randPeriodB] = dealify([trial.outcome_t],icms_chan_0_randPeriodB,'Previous');
catch
  [trial.icms_chan_0_randPeriodB] = deal(0);
end

try
  [trial.reach_radius] = dealify([trial.outcome_t],reach_radius,'previous');
catch
  [trial.reach_radius] = sqrt(target_trl(:,1).^2 + target_trl(:,2).^2);
end

% ferret out correction trials
rew_trl = [trial.outcome] == ST_REWARD;         % rewarded trials
err_trl = [trial.outcome] == ST_ERR_GENERIC;    % completed, but wrong
% now let's catch all the canceled trials that might be valid
% NOPE CANT DO THIS FOR FEEDBACK
can_trl = [trial.outcome] ~= ST_REWARD & ...
          [trial.outcome] ~= ST_ERR_GENERIC;    % canceled trials
tmp = double(rew_trl);
%tmp(can_trl) = -1;
tmp = [1 tmp(1:end-1)];
%for i=1:length(tmp)
%  if tmp(i) == -1
%    tmp(i) = tmp(i-1);
%  end
%end
if any(tmp == -1)
  disp('oops');
  keyboard;
end
tmp = num2cell(logical(tmp));
[trial.is_random] = deal(tmp{:});       % should be random

% %%% O HORRIBLE HACK OF ANTIOCH %%%
%
% THIS FIXES THE BUG THAT EXISTED BETWEEN 12/3/2009 AND 12/18/2009 (inclusive)
% WHERE THE ROTATION OF THE TARGET HAPPENED AFTER THE TARGET LOCATION
% WAS LOGGED, LEADING TO GARBAGE BEING LOGGED, NATURALLY.

tmp = split(fileparts(f),'/');
thedate = str2double(tmp{end});
if thedate >= 20091203 && thedate <= 20091218
  s = 'next';
else
  s = 'previous';
end

% the rewarded target
try
  target_x = trialify([trial.outcome_t],target_x,s);
catch
  target_x = trialify([trial.outcome_t],[NaN 0],s);
end
try
  target_y = trialify([trial.outcome_t],target_y,s);
catch
  target_y = trialify([trial.outcome_t],[0 0],s);
end

% correct for correct target number, if necessary
% see horrible hack of antioch, above.
% ps all this shit will break when we have more than 2 targets. whee.

for i=1:length(trial)
  trial(i).target_pos = [target_x(i) ; target_y(i)];
  for j=1:num_targets-1
    trial(i).target_wrong_pos{j} = rotmat(j*2*pi/num_targets) * trial(i).target_pos;	% the other target(s)
  end
  cx = trial(i).cursor(2,trial(i).states_cursor(end-1));
  cy = trial(i).cursor(3,trial(i).states_cursor(end-1));
  cursor_outcome_pos = [ cx ; cy ];
  % correct for correct target number, if necessary
  % see horrible hack of antioch, above.
  % ps all this shit will break when we have more than 2 targets. whee.
  do_swap = 0;
  if strcmp(s,'next') 
    if (trial(i).outcome == ST_ERR_CANCELED || trial(i).outcome == ST_ERR_TIMEOUT)
      do_swap = 1;
    end
    if trial(i).outcome == ST_REWARD && ...
    ~cursor_in_target(trial(i).target_pos,cursor_outcome_pos,trial(i).target_radius,trial(i).cursor_radius,2)
      do_swap = 1;
    end
    if trial(i).outcome == ST_ERR_GENERIC && ...
    cursor_in_target(trial(i).target_pos,cursor_outcome_pos,trial(i).target_radius,trial(i).cursor_radius)
      do_swap = 1;
    end
  end
  if do_swap
    trial(i).target_pos = trial(i).target_wrong_pos{1}; % because there was only 2 targets then
    trial(i).target_wrong_pos{1} = [target_x(i) ; target_y(i)];
  end

  % poplate target_id and target_pos vectors
  % this way we can map a target_id to a target position
  trial(i).target_ids = 0:num_targets-1;
  tmp = find(trial(i).target_ids == trial(i).target_num);
  trial(i).targets{tmp} = trial(i).target_pos;
  for j=1:num_targets-1
    trial(i).targets{mod(tmp+j-1,num_targets)+1} = trial(i).target_wrong_pos{j};
  end

  % find target_num_picked
  trial(i).target_num_picked = NaN;
  if trial(i).outcome == ST_REWARD
    trial(i).target_num_picked = trial(i).target_num;
  elseif trial(i).outcome == ST_ERR_GENERIC
    for j=1:num_targets-1
      if cursor_in_target(trial(i).target_wrong_pos{j}, cursor_outcome_pos, trial(i).target_radius, trial(i).cursor_radius, 2)
        trial(i).target_num_picked = mod(j+trial(i).target_num,num_targets);
      end
    end
  end
end

for i=1:length(trial)
  % in targets
  tps = trial(i).targets;
  cur = trial(i).cursor_radius;
  tar = trial(i).target_radius;
  clr = trial(i).feedback_cloud_radius;
  
  reach_i = find(trial(i).states == ST_EXPLORE); % index of reach start
  if isempty(reach_i)
    reach_i = 1;  % no reach made (canceled trial)
  end
  reach_start = trial(i).states_cursor(reach_i(1)); % only need first one
  reach_j = find( ...
                trial(i).states == ST_REWARD | ...
                trial(i).states == ST_ERR_GENERIC | ...
                trial(i).states == ST_ERR_TIMEOUT | ...
                trial(i).states == ST_ERR_CANCELED );
  reach_end   = trial(i).states_cursor(reach_j(1));

  in_state_seq   = [];
  in_state_seq_t = [];
  cloud_state_seq   = [];
  cloud_state_seq_t = [];
  cloud_state_seq_cur = [];
  cloud_state_seq_out   = [];
  cloud_state_seq_out_t = [];
  cloud_state_seq_out_cur = []; 

  time_in_cloud = zeros(num_targets,1);
  am_in_cloud = zeros(num_targets,1);
  dt = mean(diff(trial(i).cursor(1,:)));

  for j=reach_start:reach_end

    cp = [trial(i).cursor(2,j) ; trial(i).cursor(3,j)]; % cursor position
    cur_t = trial(i).cursor(1,j);
    for k=1:num_targets
      tar_id = trial(i).target_ids(k);
      if cursor_in_target(tps{k},cp,tar,cur)
        if ((~isempty(in_state_seq) && in_state_seq(end) ~= tar_id) || ...
	    (isempty(in_state_seq)))
          in_state_seq   = [in_state_seq ; tar_id];
          in_state_seq_t = [in_state_seq_t ; cur_t];
        end
      end
      if cursor_in_target(tps{k},cp,clr,cur)
        if ~am_in_cloud(k)
          cloud_state_seq   = [cloud_state_seq ; tar_id];
          cloud_state_seq_t = [cloud_state_seq_t ; cur_t];
          cloud_state_seq_cur = [cloud_state_seq_cur ; j];
          am_in_cloud(k) = 1;
        end
        % update time in correct and incorrect targets here
	time_in_cloud(k) = time_in_cloud(k) + dt;
      else
        if am_in_cloud(k)
          cloud_state_seq_out = [cloud_state_seq_out ; tar_id];
          cloud_state_seq_out_t = [cloud_state_seq_out_t ; cur_t];
          cloud_state_seq_out_cur = [cloud_state_seq_out_cur ; j];
          am_in_cloud(k) = 0;
        end
      end
    end
  end

  if length(cloud_state_seq) == length(cloud_state_seq_out) + 1
    cloud_state_seq_out = [cloud_state_seq_out ; cloud_state_seq(end)];
    cloud_state_seq_out_t = [cloud_state_seq_out_t ; trial(i).cursor(1,reach_end)];
    cloud_state_seq_out_cur = [cloud_state_seq_out_cur ; reach_end];
  end
  
  prev_cloud = [nan ; cloud_state_seq(1:end-1)];
  rm_cloud = cloud_state_seq == prev_cloud;
  
  cloud_state_seq(rm_cloud) = [];
  cloud_state_seq_t(rm_cloud) = [];
  cloud_state_seq_cur(rm_cloud) = [];

  rm_cloud = [rm_cloud(2:end) ; false];

  cloud_state_seq_out(rm_cloud) = [];
  cloud_state_seq_out_t(rm_cloud) = [];
  cloud_state_seq_out_cur(rm_cloud) = [];

  trial(i).num_in_states = length(in_state_seq);
  trial(i).num_cloud_states = length(cloud_state_seq);
  trial(i).in_state_seq   = in_state_seq;
  trial(i).in_state_seq_t = in_state_seq_t;
  trial(i).cloud_state_seq   = cloud_state_seq;
  trial(i).cloud_state_seq_t = cloud_state_seq_t;
  trial(i).cloud_state_seq_cur = cloud_state_seq_cur;
  trial(i).cloud_state_seq_out   = cloud_state_seq_out;
  trial(i).cloud_state_seq_out_t = cloud_state_seq_out_t;
  trial(i).cloud_state_seq_out_cur = cloud_state_seq_out_cur;
  trial(i).time_in_cloud = time_in_cloud;
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

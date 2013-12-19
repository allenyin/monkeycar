function analogCueReach_parse(fname)
% This function reads in an analogCueReach task behavior file
% processes the data and saves a _parsed file to speed up
% subsequent analysis
%
% analogCueReach_parse(fname)
%
% $Id: analogCueReach_parse.m 713 2009-11-04 04:13:47Z joey $

% DEFINE THE STROBES
ST_NULL = 100;
ST_DEFAULT = 101;
ST_PRE_CUE_MOV = 102;
ST_IN_CUE = 103;
ST_CUE_REWARD = 104;
ST_POS_CUE_MOV = 105;
ST_IN_CORRECT = 106;
ST_IN_WRONG = 107;
ST_REWARD = 108;
ST_INTERTRIAL = 109;
ST_PRE_CUE_MOV_ERR = 110;
ST_IN_CUE_ERR = 111;
ST_POS_CUE_MOV_ERR = 112;
ST_PRE_CUE_MOV_TO_ERR = 113;
ST_POS_CUE_MOV_TO_ERR = 114;
ST_IN_CORRECT_ERR = 115;
ST_IN_WRONG_ERR = 116;
ST_OVERRIDE = 117;	% Historical strobe; not currently used
ST_MOVTO_ERR = 107;

disp(fname);

load(fname, 'state', 'pos_x', 'pos_y', 'cursor_x', 'cursor_y');

common_parse;

if (ntrials == 0)
  disp('  => NO trials!');
  return;
end

load(fname, 'js*', ...
		'*target_pos*', 'target_x', 'target_y', 'target_num', ...
		'target_*_enabled', 'mk_target_choice', ...
		'*size', ...
		'hold_time*', ...
		'*auto_button', '*control', 'trans*', ...
		'use_correction_trials', 'use_visual_cue', ...
		'ustim_current');

basicTask_parse;

% if the target size ratio does not exist, set it to 1.0.

cur_sz_trl = trialify([trial.outcome_t],cursor_size,'previous');
cuetar_sz_trl = trialify([trial.outcome_t],cue_target_size,'previous');
annulus_sz_trl = trialify([trial.outcome_t],annulus_size,'previous');
hold_time_trl = trialify([trial.outcome_t],hold_time,'previous');
cuehold_time_trl = trialify([trial.outcome_t],hold_time_cue,'previous');
wiener_trl = trialify([trial.outcome_t],wiener_control,'previous');
lms_trl = trialify([trial.outcome_t],nlms_control,'previous');
use_corrtr_trl = trialify([trial.outcome_t],use_correction_trials,'previous');
target_num_trl = trialify([trial.outcome_t],target_num,'previous');
ustim_current_trl = trialify([trial.outcome_t],ustim_current,'previous');

if (exist('target_0_enabled'))
  tmp = who('target_*_enabled');
  for i=1:length(tmp)
    target_enabled_trl(i,:) = trialify([trial.outcome_t],eval(tmp{i}),'previous');
  end
else
  target_enabled_trl = ones(length(unique(target_num_trl)),ntrials);
end
clear tmp;

try
  mk_target_choice_trl = trialify([trial.outcome_t],mk_target_choice,'previous');
catch
  mk_target_choice_trl = zeros(ntrials,1);
end
mk_target_choice_trl(isnan(mk_target_choice_trl)) = -1;
mk_target_choice_trl = mk_target_choice_trl(:);

try
  use_viscue_trl = trialify([trial.outcome_t],use_visual_cue,'previous');
catch
  use_viscue_trl = zeros(ntrials,1);
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% From here we have to loop :-(
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for i=1:ntrials

  iii = trial(i).states == ST_IN_CUE;       % logical vector of IN_CUE states
  trial(i).in_cue_t = trial(i).states_t(iii);   % vector of IN_CUE state times

  jjj = trial(i).states == ST_IN_CORRECT | trial(i).states == ST_IN_WRONG;
  trial(i).in_t = trial(i).states_t(jjj);   % vector of IN state times

  % catch everything that was done outside this loop
  trial(i).cursor_size = cur_sz_trl(i);
  trial(i).cuetar_size = cuetar_sz_trl(i);
  trial(i).annulus_size = annulus_sz_trl(i);
  trial(i).hold_t = hold_time_trl(i);
  trial(i).cuehold_t = cuehold_time_trl(i);
  trial(i).wiener = wiener_trl(i);
  trial(i).lms = lms_trl(i);
  trial(i).use_corrtr = use_corrtr_trl(i);
  trial(i).target_num = target_num_trl(i);
  trial(i).ustim_current = ustim_current_trl(i);
  trial(i).targets_enabled = target_enabled_trl(:,i);
  trial(i).target_choice = mk_target_choice_trl(i);
  trial(i).use_visual_cue = use_viscue_trl(i);
end

% save in parsed file
[pstr,fstr,estr] = fileparts(fname);
save(fullfile(pstr,[fstr,'_parsed',estr]), ...
 'trial', 'ST_*');

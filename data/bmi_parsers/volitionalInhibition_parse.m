% VOLITIONAL INHIBITION 
%
% $Id: $
% 
% this function reads in a volitional inhibition behavior file
% processes the data and saves a _parsed file to speed up
% subsequent analysis

function volitionalInhibition_parse(f)

% DEFINE THE STROBES
ST_NULL = 0;
ST_DEFAULT = 1;
ST_PRE_CENTER = 2;
ST_CENTER = 3;
ST_CENTER_HOLD = 4;
ST_STOP = 5;
ST_REACH = 6;
ST_IN = 7;
ST_REWARD = 8;
ST_ERR_STOP_FAIL =9; 
ST_ERR_TIMEOUT = 10;
ST_ERR_CANCELED = 11;
ST_INTERTRIAL = 12;

disp(f);

load(f, 'state', 'cursor_x', 'cursor_y');
    
common_parse;

load(f,	'js*', ...
	'target_*', ...
	'center_target_*', ...
	'cursor_size', ...
          'count', 'stop_signal_delay', 'trials_btw_switch', 'stop_trial', 'reach_radius', ...
	'intertrial_time', 'timeout', 'error_time', ...
	'button_state', '*_auto_button', '*control', '*trans*');

basicTask_parse;

[trial.cursor_size] = dealify([trial.outcome_t],cursor_size,'previous');
[trial.spacing] = dealify([trial.outcome_t],trials_btw_switch,'previous'); %approximate freq
[trial.count] = dealify([trial.outcome_t],count,'previous'); 
[trial.stop_tr] = dealify([trial.outcome_t],stop_trial,'previous'); %most important thing
[trial.target_ang] = dealify([trial.outcome_t],target_location_angle,'previous'); 
[trial.target_size] = dealify([trial.outcome_t],target_size,'previous');      
[trial.reach_radius] = dealify([trial.outcome_t],reach_radius,'previous');
[trial.target_hold_t] = dealify([trial.outcome_t],target_hold_time,'previous');
[trial.center_target_size] = dealify([trial.outcome_t],center_target_size,'previous');
[trial.center_hold] =  dealify([trial.outcome_t],center_target_hold,'previous'); %in milliseconds
[trial.SSD] = dealify([trial.outcome_t],stop_signal_delay,'previous');

tmp1 = trialify([trial.outcome_t],target_x,'previous'); 
tmp2 = trialify([trial.outcome_t],target_y,'previous');
[trial.target] = deal(num2cell([tmp1 tmp2],2));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% From here we have to loop :-(
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for i=1:ntrials,
          
    
          if(trial(i).stop_tr)                       % only stop_trial
                    trial(i).target_app = trial(i).states_t(trial(i).states == ST_CENTER_HOLD);   %time of target appearance
                    trial(i).inhib_t = trial(i).states_t(trial(i).states == ST_STOP);      %time of stop signal
          else
                    trial(i).target_app = trial(i).states_t(trial(i).states == ST_REACH);   %time of target appearance
                    trial(i).inhib_t = 0;
          end
end

% save in parsed file
[pstr,fstr,estr] = fileparts(f);
save(fullfile(pstr,[fstr,'_parsed',estr]), ...
  'trial', 'ST_*');

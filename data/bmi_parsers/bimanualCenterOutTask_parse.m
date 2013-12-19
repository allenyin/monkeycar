% BIMANUAL CENTEROUTTASK_PARSE
% 
% this function reads in a bimanual centerout task behavior file
% processes the data and saves a _parsed file to speed up
% subsequent analysis
%
% Mostly copied over from the OLD fitts task (not fittsTask2)
% $ $

function bimanualCenterOutTask_parse(f)

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

load(f, 'state', 'pos_x', 'pos_y', 'cursor_x', 'cursor_y');

common_parse;

load(f, 'js*', ...
        'pos_x_2','pos_y_2','cursor_x_2','cursor_y_2', ...
		'target_x', 'target_y', 'target_2_x', 'target_2_y', 'target_pos_*', ...
		'cursor_size', 'target_size', ...
		'reward_criteria', 't_hold', ...
        'condition','Passive_observation','Intuitive_layout', ...
		'button_state', 'target_hold_time', 'Single_Target', ...
		'reach_radius' , '*_auto_button', '*control', 'trans*');

basicTask_parse;

[trial.cursor_size] = dealify([trial.outcome_t],cursor_size,'previous');
[trial.target_size] = dealify([trial.outcome_t],target_size,'previous');
[trial.center_target_size] = dealify([trial.outcome_t],center_target_size,'previous');
[trial.center_hold_t] = dealify([trial.outcome_t],center_target_hold_time,'previous');
[trial.target_hold_t] = dealify([trial.outcome_t],target_hold_time,'previous');
[trial.reach_radius] = dealify([trial.outcome_t],reach_radius,'previous');
[trial.condition] = dealify([trial.outcome_t],condition,'previous');

% the rewarded targets
tmp1 = trialify([trial.outcome_t],target_x,'previous');
tmp2 = trialify([trial.outcome_t],target_y,'previous');
[trial.target] = dealcell(num2cell([tmp1 tmp2],2));


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% From here we have to loop :-(
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% for cursor
i0cx = nearestpoint([trial.start_t],cursor_x_2(:,2));
i1cx = nearestpoint([trial.end_t],cursor_x_2(:,2));
i0cy = nearestpoint([trial.start_t],cursor_y_2(:,2));
i1cy = nearestpoint([trial.end_t],cursor_y_2(:,2));

% for joystick
if (~exist('js_x_2','var'))
  js_x_2 = js_x_lo;
  js_y_2 = js_y_lo;
end
i0jx = nearestpoint([trial.start_t],js_x_2(:,2));
i1jx = nearestpoint([trial.end_t],js_x_2(:,2));
i0jy = nearestpoint([trial.start_t],js_y_2(:,2));
i1jy = nearestpoint([trial.end_t],js_y_2(:,2));

% now we have to loop :-(
for i=1:ntrials

  ii = i0cx(i):i1cx(i);
  jj = i0cy(i):i1cy(i);
  iijs = i0jx(i):i1jx(i);
  jjjs = i0jy(i):i1jy(i);

  % handle weirdness
  if (isempty(ii))
    continue;
  end

  % cursor
  try
    trial(i).cursor2 = [cursor_x_2(ii,2) cursor_x_2(ii,1) cursor_y_2(jj,1)]';
  catch
    if (length(ii) < length(jj))
      tmp = double(resample_discont(cursor_y_2(jj,1), cursor_y_2(jj,2), cursor_x_2(ii,2)));
      trial(i).cursor_2 = [cursor_x_2(ii,2) cursor_x_2(ii,1) tmp]';
    else
      tmp = double(resample_discont(cursor_x(ii,1), cursor_x_2(ii,2), cursor_y_2(jj,2)));
      trial(i).cursor_2 = [cursor_y_2(jj,2) tmp cursor_y_2(jj,1)]';
    end
  end
  trial(i).states_cursor_2 = nearestpoint(trial(i).states_t, trial(i).cursor_2(1,:));

  % js_trl
  try
    trial(i).js_2 = [js_x_2(iijs,2) js_x_2(iijs,1) js_y_2(jjjs,1)]';
  catch
    if (length(iijs) < length(jjjs))
      tmp = double(resample_discont(js_y_2(jjjs,1), js_y_2(jjjs,2), js_x_2(iijs,2)));
      trial(i).js_2 = [js_x_2(iijs,2) js_x_2(iijs,1) tmp]';
    else
      tmp = double(resample_discont(js_x(iijs,1), js_x(iijs,2), js_y(jjjs,2)));
      trial(i).js_2 = [js_y_2(jjjs,2) tmp js_y_2(jjjs,1)]';
    end
  end
  trial(i).states_js_2 = nearestpoint(trial(i).states_t, trial(i).js_2(1,:));

  % button
  % if button_state does not exist, assume that button is always touched
  try
    tmp = nearestpoint(trial(i).cursor(1,:),button_state(:,2),'previous');
    tmp(isnan(tmp)) = 1;        % I HATE NaNs
    trial(i).button = button_state(tmp,1);
  catch
    trial(i).button  = ones(length(trial(i).cursor(1,:)),1);
  end

  % transformation matrix
  trial(i).A = [a00_trl(i) a01_trl(i) ; a10_trl(i) a11_trl(i)];

  if ( trial(i).A(1,2) == 0 && trial(i).A(2,1) == 0) % just gain
    trial(i).gain_x = trial(i).A(1,1);
    trial(i).gain_y = trial(i).A(2,2);
    trial(i).rot_theta = 0;
  elseif ( det(trial(i).A) == 1 & min(min(inv(trial(i).A)==trial(i).A')) ) % just rotation
    trial(i).rot_theta = acos(a00_trl(i));
    trial(i). gain_x = 1;
    trial(i). gain_y = 1;
  else                          % more complicated
    trial(i).rot_theta = NaN;
    trial(i).gain_x = NaN;
    trial(i).gain_y = NaN;
  end

end

clear a00_trl a01_trl a10_trl a11_trl;
clear i0cx i1cx i0cy i1cy;
clear i0jx i1jx i0jy i1jy;
clear ii jj iijs jjjs
clear tmp;




% save in parsed file
[pstr,fstr,estr] = fileparts(f);
save(fullfile(pstr,[fstr,'_parsed',estr]), ...
  'trial', 'ST_*');

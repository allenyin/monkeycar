% GRAPETASK_PARSE
%
% $Id: grapeTask_parse.m 713 2009-11-04 04:13:47Z joey $

% load parsed file here

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

trial_start = find(state(:,1) == ST_DEFAULT);
trial_end = find( (state(:,1) == ST_INTERTRIAL) );
if (length(trial_start)-1 == length(trial_end))
    trial_start = trial_start(1:end-1); 
end

outcome = state(trial_end-1,1); % whatever comes before ST_INTERTRIAL
outcome_time = state(trial_end-1,2);  % time of outcome state
start_time = state(trial_start,2);
end_time = state(trial_end,2);
trial_len = end_time - start_time;
trials = 1:length(trial_start);

keyboard

for i=1:length(trials),
    ii = nearestpoint(start_time(i),pos_x(:,2)) : nearestpoint(outcome_time(i),pos_x(:,2));
    jj = nearestpoint(start_time(i),pos_y(:,2)) : nearestpoint(outcome_time(i),pos_y(:,2));
    ij = nearestpoint(start_time(i),grape_pos_x(:,2));  % index of target pos for this trial
    ik = nearestpoint(start_time(i),plate_pos_x(:,2));  % index of frame pos for this trial
    
    % get the trajectory for this trial
    traj{i} = [pos_x(ii) ; pos_y(jj)]; 
end

if (trial_len(1) < 0)
    % should be fixed for recordings 2006 07 25
    trial_start = trial_start(2:end);
    trial_end = trial_end(2:end);
    outcome = state(trial_end-1,1);
    start_time = state(trial_start,2);
    end_time = state(trial_end,2);
    trial_len = end_time - start_time;
    trials = 1:length(trial_start);
end

% get vibrator state (0 or 1)
itmp = nearestpoint(start_time,vib_state(:,2));
vib_state2 = vib_state(itmp,1);

% get grape visibility [0...1]
grape_vis = 1:length(target_visibility);
tmp = find( (start_time < target_visibility(2,2)) );
grape_vis(tmp) = target_visibility(1,1);
for i=3:length(target_visibility),
    tmp = find( (start_time < target_visibility(i,2)) & ...
                (start_time >= target_visibility(i-1,2)) );
    grape_vis(tmp) = target_visibility(i-1,1);
end
% last one
tmp = find( (start_time >= target_visibility(end,2)) );
grape_vis(tmp) = target_visibility(end,1);

% XXX FIXED IN SVN
% for all files newer than 2006-07-19
% temporary correction factor
%grp_prev = grape_vis(1);
%tmp(1) = grp_prev;
%for i=1:length(grape_vis)-1,
 %   if grape_vis(i+1) ~= grp_prev
 %       tmp(i+1) = grape_vis(i+1);
 %   else
 %       tmp(i+1) = tmp(i);
 %   end
 %   if (outcome(i) == ST_REWARD)
%        tmp(i+1) = tmp(i+1) - 0.01;
%    else
%        tmp(i+1) = tmp(i+1) + 0.02; 
%    end
%    grp_prev = grape_vis(i+1);
%end
%grape_vis = tmp;
grape_vis = grape_vis';

% step functionize everything less than zero
grape_vis(find(grape_vis<0)) = grape_vis(find(grape_vis<0)) * 0;
% and gt one?!?
grape_vis(find(grape_vis>0)) = grape_vis(find(grape_vis>0)) * 0 + 1;

% get trials of interest
visonvibon = find(grape_vis == 1 & vib_state2 == 1 );
visonvibof = find(grape_vis == 1 & vib_state2 == 0 );
visofvibon = find(grape_vis == 0 & vib_state2 == 1 );
visofvibof = find(grape_vis == 0 & vib_state2 == 0 );

% make failed trials equal maximum length
trial_len2 = trial_len;
ii = find(outcome ~= ST_REWARD);
if ~isempty(ii)
    trial_len2(ii) = to_mov(1,1);  % max trial length
end

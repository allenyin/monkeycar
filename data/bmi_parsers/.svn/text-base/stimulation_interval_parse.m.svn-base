% dn is a datenum
% eg 20081231

function o = stimulation_interval_parse(dn)

  MK = 'guava';
  STR = '*acquire*parsed*mat';
  STR2 = 'gu-*mat';

  WIN = [-3 3];		% in seconds
  BINRATE = 50/1000;	% in msec 

  f = getdaysfiles(dn,MK,STR);
  load(f{1});
  if (isempty(f))
	  o=[];
	  return;
  end

  % get all those that end in rew or wrong target error
  rew_trl = outcome == ST_REWARD;         % rewarded trials
  err_trl = outcome == ST_IN_WRONG_ERR;   % completed, but wrong
  if (all(use_corrtr_trl==0)) % any trials dont use correction trials?
    rnd_trl = [1 ; rew_trl(1:end-1)];	  % guaranteed random trials
  else  
    rnd_trl = ones(length(rew_trl),1);
  end

  % trials of interest
  foo = center_trial == 0 & ...
      ustim_st_trl == 1 & ...
      vib_st_trl == 0 & ...
      use_cue_trl == 1 & ...
      arm_ctrl_trl == 1 & ...
      (rew_trl == 1 | err_trl == 1);

  % get those to the right and to the left
  cue_right_trl = zeros(length(foo),1);
  cue_left_trl = zeros(length(foo),1);
  for i=1:length(foo)
    cue_right_trl(i) = abs(activ_tar_pos{i}(1) - 7.5) < MY_EPS;
    cue_left_trl(i)  = abs(activ_tar_pos{i}(1) + 7.5) < MY_EPS;
  end

  % load neuronal file
  g = getdaysfiles(dn,MK,STR2);

  [spikes,nindex] = get_ts(g{1});

  for i=1:length(nindex)
    disp([ num2str(i) ' / ' num2str(length(nindex)) ]);
    [R] = peth(spikes(spikes(:,2)==i),start_time(foo),WIN,BINRATE);
    n(i).rates = R;
  end

  th = mean(t_hold_trl)/1000; % t_hold, converted to seconds

  % output it all
  o.n = n;
  o.th = th;
  o.cue_right_trl = cue_right_trl(foo);
  o.cue_left_trl = cue_left_trl(foo);
  o.rew_trl = rew_trl(foo);
  o.err_trl = err_trl(foo);
  o.rnd_trl = rnd_trl(foo);
  o.note = 'n contains a structure of cell array of neuronal spikes. each element in n is a different neuron. each cell array in n consists of the spikes occuring in a trial, relative to the onset of movement (in seconds). th is the length of the hold time/stimulation interval in seconds. cue_right_trl are the trials that the cue given was to the right target, cue_left_trl is the opposite. rew_trl are thr trials that ended with reward. err_trl are the trials that ended with the monkey moving to the incorrect target. rnd_trl indicates if a given trial was "random" or a "correction_trial.';

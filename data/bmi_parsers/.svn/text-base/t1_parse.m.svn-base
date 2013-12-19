% task1_parse.m   nicely parse task1 data
% 
% Author: j.e. o'doherty
% $Id: t1_parse.m 713 2009-11-04 04:13:47Z joey $

% filefilter = 'Ta*_t1*.mat';
% psth_win = 10;    % window on which release is centered [sec] 

function t1_parse(filefilter,psth_win)

  datadir = 'd:\data\';
  savedir = 'd:\parsed\';
            % end slashes are important!

  % define task1 constants
  TSTART   = 100;
  VTSTRT   = 200;
  PRESS    = 300;
  RELEASE  = 400;
  ERROR0   = 500;
  ERROR1   = 600;
  REWARD   = 700;
  TEND     = 900;
  MIN_HOLD = 1000;
  MAX_HOLD = 2000;
  JUICE    = 3000;

  D = dir(strcat(datadir,filefilter));
  for j=1:length(D),
     file{j} = D(j).name;
  end
  clear D;

  % do this in two passes: 1. check to see if the files are properly formed
  % and automagically make changes if possible. 2. parse the files.
  % eventually, it would be better to put the preparse logic in another file.

  disp('pre-parsing files for errors');
  for j=1:length(file),
    
    disp(file{j});
    pre_parse_t1(char(strcat(datadir,file(j))));    
  
  end

  for j=1:length(file),

    disp(file{j});
    load(strcat(datadir,file{j}));

    strobes = Strobed(:,1:2);
    clear Strobed;

    sigs = char([who('sig*a') ; who('sig*b') ; who('sig*c') ; ...
                 who('sig*i') ; who('sig*d')]);
    sigs = sortrows(sigs);

    press   = find(strobes(:,2) == PRESS);
    release = find(strobes(:,2) == RELEASE);
    error0  = find(strobes(:,2) == ERROR0);
    error1  = find(strobes(:,2) == ERROR1);
    reward  = find(strobes(:,2) == REWARD);
    minhold = (strobes(find((strobes(:,2) > MIN_HOLD) & ...
                   (strobes(:,2) < MAX_HOLD)),2)-MIN_HOLD)./10;
    maxhold = (strobes(find((strobes(:,2) > MAX_HOLD) & ...
                   (strobes(:,2) < JUICE)),2)-MAX_HOLD)./10;

    if ( length(reward)+length(error0)+length(error1) ~= length(press) )
        warning('rewards and errors do not add up');
    end

    outcome = zeros(length(strobes),1);
    outcome(reward) = REWARD;
    outcome(error0) = ERROR0;
    outcome(error1) = ERROR1;
    outcome(find(outcome == 0)) = [];

    press_times   = strobes(press,1);
    release_times = strobes(release,1);
    hold_times = release_times - press_times;

    time_stamp = []; identity   = [];
    nneurons = size(sigs,1);

    for i=1:nneurons,
        time_stamp = [ time_stamp ; eval(sigs(i,:)) ];
        identity   = [ identity   ; i*ones(length(eval(sigs(i,:))),1) ];
    end

    N_index = sigs;
    clear sig*;
  
    for i=1:size(release_times,1),

      temp = find( (time_stamp >  release_times(i) - psth_win/2) & ...
                    (time_stamp <= release_times(i) + psth_win/2) );
      trial(i).spikes         = time_stamp(temp) - release_times(i);
      trial(i).ident          = identity(temp);
      trial(i).outcome        = outcome(i);
      trial(i).release_time   = release_times(i);
      trial(i).hold_time      = hold_times(i);
      trial(i).min_hold       = minhold(i);
      trial(i).max_hold       = maxhold(i);

      if (mod(i,50) == 0)
         disp(strcat(num2str(i),'/',num2str(size(release_times,1))));
      end
    end

    save(strcat(savedir,num2str(file{j}([1:8 12])),'_t1_parsed.mat'), ...
         'trial','N_index');

    clear trial N_index time_stamp identity temp outcome strobes ...
         error0 error1 maxhold minhold press press_times release ...
         release_times hold_times reward nneurons i;

  end

function pre_parse_t1(fname)

  load(fname);

  % define task1 constants
  TSTART   = 100;
  VTSTRT   = 200;
  PRESS    = 300;
  RELEASE  = 400;
  ERROR0   = 500;
  ERROR1   = 600;
  REWARD   = 700;
  TEND     = 900;
  MIN_HOLD = 1000;
  MAX_HOLD = 2000;
  JUICE    = 3000;

  if (exist('Strobed','var') ~= 1)
    disp('Strobed variable does not exist.');
    disp('Is this really a task1 file?');
    keyboard;
  end

  tstart  = find(Strobed(:,2) == TSTART);
  press   = find(Strobed(:,2) == PRESS);
  error0  = find(Strobed(:,2) == ERROR0);
  error1  = find(Strobed(:,2) == ERROR1);
  reward  = find(Strobed(:,2) == REWARD);
  tend    = find(Strobed(:,2) == TEND);

  readme = strcat(date,': this file was modified:');

  if ( (length(reward)+length(error0)+length(error1) ~= length(press)) | ...
    (length(tstart) ~= length(tend)) )
    disp('Detected corrupted trial ... Attepting to fix');

    % backup original file
    bak = strcat(fname,'.orig');
    if (exist('bak','file') ~= 0)
      display('Backup file ',bak,' exists ... Please intervene');
      keyboard;
    end
    status = movefile(fname,bak);
    if (~status)
      display('Could not backup original file ... Please intervene');
      keyboard;
    end
  
    % kill off last trial (hopefully the corrupted one) 
    Strobed = Strobed(1:tend(end)+1,:);
  
    readme = strcat(readme,' Automatically removed corrupted final trial.');
  
    % save new file
    save(fname,'Strobed','sig*','readme');
  end

  if ( ...
  (length(find(Strobed(:,2)==TSTART))~=length(find(Strobed(:,2)==TSTART+1))) | ...
  (length(find(Strobed(:,2)==VTSTRT))~=length(find(Strobed(:,2)==VTSTRT+1))) | ...
  (length(find(Strobed(:,2)==PRESS))~=length(find(Strobed(:,2)==PRESS+1))) | ...
  (length(find(Strobed(:,2)==RELEASE))~=length(find(Strobed(:,2)==RELEASE+1))) | ...
  (length(find(Strobed(:,2)==ERROR0))~=length(find(Strobed(:,2)==ERROR0+1))) | ...
  (length(find(Strobed(:,2)==ERROR1))~=length(find(Strobed(:,2)==ERROR1+1))) | ...
  (length(find(Strobed(:,2)==REWARD))~=length(find(Strobed(:,2)==REWARD+1))) |...
  (length(find(Strobed(:,2)==TEND))~=length(find(Strobed(:,2)==TEND+1))) )
  readme = strcat(readme,' Problem with double-encode. No fix attempted.');
  save(fname,'Strobed','sig*','readme');
  end
          
  

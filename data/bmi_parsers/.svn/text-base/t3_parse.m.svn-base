% t3_parse.m 	  compute some statistics about task 1
%
% $Id: t3_parse.m 713 2009-11-04 04:13:47Z joey $ 

function [trials] = t3_parse(fname)

    t3_common;

    load(fname);
  
    % check for strobes
    if (exist('Strobed','var') ~= 1)
        disp('Strobed variable does not exist.');
        keyboard;
    end

    strobes = Strobed(:,1:2);
    clear Strobed;
    
    magicnum = find(strobes(:,2) == MAGICNUMBER)';
    if ( length(magicnum) ~= 2 )
        disp('Mangled file headers!');
        keyboard;
    end;
    tasknum = strobes(magicnum(1)+1:magicnum(end)-1,2);
    if (tasknum ~= 3)
        disp('does not appear to be a 3 file');
        keyboard;
    end
    magictrl = find(strobes(:,2) == MAGICTRIAL)';
    if (mod(length(magictrl),2) ~= 0)
        disp('mangled trial headers');
        keyboard;
    end
    
    j=1;
    for i = 1:2:length(magictrl),
        trials(j).type   = strobes(magictrl(i)+1,2);
        if (trials(j).type ~= 0)
            disp('whoops need to handle other trial types');
            keyboard;
        end
        trials(j).num    = strobes(magictrl(i)+2,2);
        trials(j).maxhold= strobes(magictrl(i)+3,2);
        trials(j).rewardq= strobes(magictrl(i)+4,2);
        trials(j).delay0 = strobes(magictrl(i)+5,2);
        trials(j).delay1 = strobes(magictrl(i)+6,2);
        trials(j).delay2 = strobes(magictrl(i)+7,2);
        trials(j).delay3 = strobes(magictrl(i)+8,2);
        trials(j).delay4 = strobes(magictrl(i)+9,2);
        trials(j).posi(1)= strobes(magictrl(i)+10,2);
        trials(j).posi(2)= strobes(magictrl(i)+11,2);
        trials(j).posf(1)= strobes(magictrl(i)+12,2);
        trials(j).posf(2)= strobes(magictrl(i)+13,2);
        trials(j).targnum= strobes(magictrl(i)+14,2);
        
        % remove header data which could confuse things
        strobes(magictrl(i)+1:magictrl(i)+14,2) = -1*ones(14,1);
        
        j=j+1;
    
    end
    
    tr_start = find(strobes(:,2) == TRIALSTART)';
    tr_end   = find(strobes(:,2) == TRIALEND)';
    
    % kill last (partial) trial if necessary
    if ( length(tr_start) ~= length(tr_end) )
        if ( length(tr_start) == length(tr_end) + 1 )
            strobes = strobes(1:magictrl(end),:);
            tr_start = find(strobes(:,2) == TRIALSTART)';
            tr_end   = find(strobes(:,2) == TRIALEND)';
            trials = trials(1:end-1);
        end
    end
    
  press    = find(strobes(:,2) == MK_PRESS)';
  release  = find(strobes(:,2) == MK_RELEASE)';
  
  for i=1:length(trials),
      trials(i).start = strobes(tr_start(i),1);
      trials(i).end   = strobes(tr_end(i),1);
      trials(i).press = strobes(press(i),1);
      trials(i).release = strobes(release(i),1);
      
      tmp = strobes(tr_start(i):tr_end(i),:);
      trials(i).events = [];
      trials(i).events = [trials(i).events tmp(find(tmp(:,2)== EVENT0),1) ];
      trials(i).events = [trials(i).events tmp(find(tmp(:,2)== EVENT1),1) ];
      trials(i).events = [trials(i).events tmp(find(tmp(:,2)== EVENT2),1) ];
      trials(i).events = [trials(i).events tmp(find(tmp(:,2)== EVENT3),1) ];
      trials(i).events = [trials(i).events tmp(find(tmp(:,2)== EVENT4),1) ];
      
      trials(i).outcome = [];
      trials(i).outcome = cat(1,trials(i).outcome,tmp(find(tmp(:,2)== ERROR0),2));
      trials(i).outcome = cat(1,trials(i).outcome,tmp(find(tmp(:,2)== ERROR1),2));
      trials(i).outcome = cat(1,trials(i).outcome,tmp(find(tmp(:,2)== ERROR2),2));
      trials(i).outcome = cat(1,trials(i).outcome,tmp(find(tmp(:,2)== ERROR3),2));
      trials(i).outcome = cat(1,trials(i).outcome,tmp(find(tmp(:,2)== ERROR4),2));
      trials(i).outcome = cat(1,trials(i).outcome,tmp(find(tmp(:,2)== ERRORN),2));
      trials(i).outcome = cat(1,trials(i).outcome,tmp(find(tmp(:,2)== REWARD),2));
            
      if (length(trials(i).outcome) == 0 || length(trials(i).outcome) > 1)
          disp('mangled outcome');
          keyboard
      end
   
  end

% PETH - Generate a Peri Event Time Histogram
% $Id: peth.m 863 2010-08-19 10:21:07Z joey $
% Arguments: 
%   sig: a spike channel
%   events: a vector of event times [seconds]
%   win: a window, [t1 t2] [seconds]
%   binsz: a bin size [seconds]
%   do_zscore: if 1, zscore histogram (defaults to 0)
%
% Returns:
%   R:  a cell array of relative spike times
%   B:  vector of the binned firing rates (in hertz)
%   BB: matrix of the binned firing rates for each trial (in hertz)
%   T:  time vector for the binned firiting rate


function [R,B,BB,T] = peth(sig, events, win, binsz, varargin)

    do_zscore = 0;
    for i=1:size(varargin,2)
        switch i
            case 1
                do_zscore = varargin{i};
        end
    end

    R = cell(length(events),1); % cell of relative spike times
    nb = ceil((win(2)-win(1))/binsz)+1;   % number of bins
    T = win(1):binsz:win(2);            % time vector
    num_events = length(events);
    
    BTMP = zeros(nb,num_events);
    for i=1:num_events
        inds = (sig>(events(i)+win(1))) & (sig<(events(i)+win(2)));
        R{i} = sig(inds)-events(i);
        BTMP(:,i) = histc(R{i},T) / binsz;
    end
    if do_zscore
        BTMP = zscore(BTMP);
    end
    B = sum(BTMP,2) / num_events;
    BB = BTMP;
    T = T(:);

% MAKE_SINGLE_PETH: Make PETH for one neuron, averaged over all trials of a type of task
%
% bin_counts:  binned counts for the given neuron over all times
% event_onset: time in seconds of the event onset
% win:      time window around the event onset
% bin_times:   time in seconds corresponding to the start and end of each bin

function [single_peth] = make_single_peth(bin_counts, event_onset, win, bin_times)
   
    bins_per_peth = (win(2)-win(1))/(bin_times(2)-bin_times(1));
    single_peth = zeros(1, bins_per_peth);

    for event=1:length(event_onset)
        window_start = event_onset(event) + win(1);
        window_end = event_onset(event) + win(2);
        window_start_bin_index = find(window_start > bin_times);
        window_start_bin_index = window_start_bin_index(end)+1;

        window_end_bin_index = find(window_end <= bin_times);
        window_end_bin_index = window_end_bin_index(1)-1;

        single_peth = (single_peth.*(event-1) + bin_counts(1, window_start_bin_index:window_end_bin_index))./event;
        %single_peth = single_peth + bin_counts(1, window_start_bin_index:window_end_bin_index);
    end
end




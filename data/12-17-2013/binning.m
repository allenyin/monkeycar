% BINNING: Put neural data into equal sized bins, for each neuron defined in unit_list
% 
% <spike_data>: 2-column array in form of (neural_recording_time, channel_number)*
% * = outputs from wireless_spike_reformat
% <bin_size>: in msec
%

function [binned, good_neurons] = binning(spike_data, bin_size)

    bin_size = bin_size/1000; % convert to sec
    tmin = min(spike_data(:,1));
    tmax = max(spike_data(:,1));

    spikes = spike_data(:,1) - tmin; % shift start time to 0
    spikes(:,2) = spike_data(:,2);

    % frequency table
    table = tabulate(spikes(:,2));
    good_neurons = table(table(:,2) > 500, 1); % only look at neurons that have fired more than 500 times

    nbins = ceil((tmax-tmin)/bin_size);
    bins = 0:bin_size:(nbins-1)*bin_size;
    binned = zeros(length(good_neurons), length(bins));

    for i=1:length(good_neurons)
        ii = find(spikes(:,2) == good_neurons(i));
        binned(i,:) = histc(spikes(ii,1), bins);
    end
end


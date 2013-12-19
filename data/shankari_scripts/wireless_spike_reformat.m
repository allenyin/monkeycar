

function [ spike_data, unit_list ] = wireless_spike_reformat( path, spike_file )
%UNTITLED Takes spike file from wireless setup, converts it into get_ts
%esque output

load(strcat(path, '/', spike_file));

%wireless separates channels and units from channels (Thank Tim >:( )
%Join them quickly and efficiently by using format {channel.unit}
%then join them to the time stampz

%first, I index the timer with spike_ts ( as I should have done a billion
%years ago

real_spike_ts = time(spike_ts+1); % Add 1, because the indexes are in C++ style

spike_data = [cast(real_spike_ts, 'double') cast(spike_ch, 'double')+cast(spike_unit, 'double')/10];

unit_list  = unique(spike_data(:,2)); %convenient list of all the units


end


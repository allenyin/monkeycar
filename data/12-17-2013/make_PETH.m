
% 1445 = withoutfood
% Taskname = 'monkeyCarPassiveMovement_20131217131445.mat');
% bmi_parse(true, Taskname);
TaskLog = load('monkeyCarPassiveMovement_20131217131445.mat');

% results is a pair (neuron_time, bmi_time)
wireless_start = TaskLog.wireless_timestamp(1,1)/1000;    % convert to s
wireless_end = TaskLog.wireless_timestamp(end,1)/1000;
wireless_length = length(TaskLog.wireless_timestamp);

% convert neuronLog to spike data
[spike_data, unit_list] = wireless_spike_reformat('.', 'cherry_121713_L2B_L2C_L3C_L2A_passivetask_withoutfood.mat');
spike_data_index = find(wireless_start <= spike_data(:,1) & wireless_end >= spike_data(:,1));
spike_data = spike_data(spike_data_index,:);

target_x = TaskLog.target_x;
bin_size = 50; % msec
[bin_counts, good_neurons] = binning(spike_data, bin_size);
bin_times = (0:length(bin_counts)).*(bin_size/1000);  % bin_times in sec

win = [-1, 3]; % window in sec, relative to event onset

% make lists of event onset times, in sec
forward = []; backward = [];
for i=1:length(TaskLog.target_x) 
    if (TaskLog.target_x(i,1)==9)
        forward = [forward, TaskLog.target_x(i,2)];
    elseif (TaskLog.target_x(i,1)==-9)
        backward = [backward, TaskLog.target_x(i,2)];
    else continue;
    end
end

% average spike_data of each neurons over ALL events
forward_PETH = zeros(size(bin_counts,1), (win(2)-win(1))/(bin_size/1000));
backward_PETH = zeros(size(bin_counts,1), (win(2)-win(1))/(bin_size/1000));

for neuron=1:size(bin_counts,1)
    forward_PETH(neuron,:) = make_single_peth(bin_counts(neuron,:), forward, win, bin_times);
    backward_PETH(neuron,:) = make_single_peth(bin_counts(neuron,:), backward, win, bin_times);
end

% x-axis time...bin starting times
win_times = -1:bin_size/1000:3;

% plot overall PETH
figure;
%bar(win_times(1:end-1), mean(forward_PETH, 1), 'BarWidth', 1);
bar(win_times(1:end-1), sum(forward_PETH, 1), 'BarWidth', 1);
title('Forward PETH overall');

figure;
%bar(win_times(1:end-1), mean(backward_PETH, 1), 'BarWidth', 1);
bar(win_times(1:end-1), sum(backward_PETH, 1), 'BarWidth', 1);
title('Backward PETH overall');

% plot all the forward single neuron PETH
for neuron=1:size(bin_counts,1)
    figure;
    bar(win_times(1:end-1), forward_PETH(neuron,:));
    title(strcat('Forward PETH for neuron ', num2str(good_neurons(neuron))));
end

% normalized over minimum activation
%figure;
%bar(win_times(1:end-1), mean(forward_PETH, 1)./max(forward_PETH), 'BarWidth', 1);
%title('Forward PETH overall');
%
%figure;
%bar(win_times(1:end-1), mean(backward_PETH, 1)./max(backward_PETH), 'BarWidth', 1);
%title('Backward PETH overall');
%
    
% convert spike_data time to 







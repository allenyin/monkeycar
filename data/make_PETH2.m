% Same as make_PETH.m, use state-reward as even onset
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

win = [-3, 3]; % window in sec, relative to event onset

% make list of event onset times, in sec
index_state_reward = find(TaskLog.state == 104);
time_state_reward = TaskLog.state(index_state_reward, 2);

% substract the timestep difference from the event-onset
time_state_reward = time_state_reward - TaskLog.wireless_timestamp(1,2);
time_state_reward = time_state_reward(1:end-1);  % quick hack to take care of index out of bound

% average spike data of each neuron overa ALL events, WRT state_reward
state_reward_PETH = zeros(size(bin_counts,1), (win(2)-win(1))/(bin_size/1000));

for neuron = 1:size(bin_counts, 1)
    state_reward_PETH(neuron,:) = make_single_peth(bin_counts(neuron,:), time_state_reward, win, bin_times);
end

% x-axis time = bin starting times
win_times = win(1):bin_size/1000:win(2);

% subtract the mean from the single-neuron trial-average
for i=1:size(state_reward_PETH, 1)
    state_reward_PETH(i,:) = state_reward_PETH(i,:) - mean(state_reward_PETH(i,:));
end

% plot all the single neurons
for neuron = 1:size(bin_counts,1)
    figure;
    bar(win_times(1:end-1), abs(state_reward_PETH(neuron,:)));
    title(strcat('State reward PETH for neuron ', num2str(good_neurons(neuron))));
end

% plot overall PETH
figure;
bar(win_times(1:end-1), sum(abs(state_reward_PETH),1), 'Barwidth', 1);
title('State reward overall');


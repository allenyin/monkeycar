% cherry neural analaysis
% from wireless recordings

%Make sure to run wireless spike reformat on the wireless .mat file, append
%Spikes_

clc; clear; close all

%addpath(genpath('C:\Users\Nicolelis\Documents\primary'));



global DATADIR;
%DATADIR = '/Users/zeraphil/Desktop';
DATADIR = 'C:\Users\Nicolelis\Documents\primary\CherryMonkeyCarData\20130318_in_car';
BEHVDIR = 'C:\Users\Nicolelis\Documents\primary\CherryMonkeyCarData\20130318_in_car\parsed';
FILEDIR = 'C:\Users\Nicolelis\Documents\primary\CherryMonkeyCarData';
monkey= 'cherry';
date = '20130318';

wifi = false;

UKF = false;
bin = false;
PSTH = true;
direction = true;
coordinate = false;
tuning = false;
saving = false;
drop = false;

directory = fullfile(DATADIR);
parsed_directory = fullfile(BEHVDIR);
allfiles = fullfile(FILEDIR);

%fn = getdaysfiles(date,monkey,'*spkwav.mat'); % find the neural file
fn = get_recursive_filenames(directory, 'Spikes_*');
fb = get_recursive_filenames(parsed_directory,'Track_Cherry_*'); % find behavioral file
% ft = get_recursive_filenames(parsed_directory,'trial_*'); %find trial
% information file - not available for car data

SRATE = 10;
binsz = 1/SRATE * 1000;       % msec

day1 = load('C:\Users\Nicolelis\Documents\primary\CherryMonkeyCarData\20130318_in_car\Spikes_Cherry_20130318-inacar-114-L2B-L2C-L1C-R3B-124-L2A-L3C-R1B-L3B.mat', 'unit_list');
day2 = load('C:\Users\Nicolelis\Documents\primary\CherryMonkeyCarData\20130319_in_car\Spikes_Cherry_20130319-inacar-114-L2B-L2C-L1C-R3B-124-L2A-L3C-R1B-L3B.mat', 'unit_list');
day3 = load('C:\Users\Nicolelis\Documents\primary\CherryMonkeyCarData\20130320_in_car\Spikes_Cherry_20130320-inacar-114-L2B-L2C-L1C-R3B-124-L2A-L3C-R1B-L3B.mat','unit_list');
% day4 = load('C:\Users\Nicolelis\Documents\primary\CherryMonkeyCarData\20130329_motor_intent\Spikes_cherry_20130329-inacar-114-L2B-L2C-L1C-R3B-124-L2A-L3C-R1B-mat.mat', 'unit_list');
% day5 = load('C:\Users\Nicolelis\Documents\primary\CherryMonkeyCarData\20130402_motor_intent\Spikes_cherry_20130402-inacar-114-L2B-L2C-L1C-R3B-124-L2A-L3C-R1B-mat.mat', 'unit_list');
unit_list = intersect(intersect(day1.unit_list,day2.unit_list),day3.unit_list);
% unit_list = intersect(intersect(com_cell,day4.unit_list),day5.unit_list);

% for i = 1: size(fn)
% %% loads and resamples kinematic data
% load(fb{i}, 'data');
% 
% [x_, x_t] = resampleparam([data.x_marker0 data.time],SRATE,0);% 0 refers to dont interp true/false in resampleparam
% [y_, y_t] = resampleparam([data.y_marker0 data.time],SRATE,0);
% 
% % [x_, x_t] = loadandresamp('cursor_x',fb{1},SRATE);
% % [y_, y_t] = loadandresamp('cursor_y',fb{1},SRATE);
% position = [x_ y_]; clear x_ y_;
% times_ = x_t;
% addvel = @(x)[x [[0 0] ; diff(x)]];
% cursor_ = addvel(position);      % [LEFT_X LEFT_Y LEFT_VX LEFT_VY]

if(wifi)
% load strobe info
    load(fb{i},'wireless_timestamp');
    offset = wireless_timestamp(1,2); %into seconds

    %grab the times for the start and stop of the session
    wifi_start = wireless_timestamp(1,1)/1000;
    wifi_end = wireless_timestamp(end, 1)/1000; %in seconds
    clear wireless_timestamp
else
    offset = 0;
end
% ix_subset = find(times_ >= offset);
% times = times_(ix_subset);
% cursor = cursor_(ix_subset,:);

%% load and bin the cells
load(fn{1},'spike_data'); %nx2 matrix
% load(fn{1},'unit_list');  %cell identity vect

% I generally save binned and bin_t for each session so I don't
% need to re-run this every time... it can take ~ 30 s to run each time

%start the recordings at 0 so binning doesn't fuck up (this should be
%standard in all binning I think)
if(wifi)
    spikes = spike_data(spike_data(:,1) > wifi_start & spike_data(:,1) < wifi_end,:);
    spikes(:,1) = spikes(:,1) - wifi_start;
else
    spikes = spike_data;
    clear spike_data
end

if(bin)
    disp('binning')
    [binned_] = binD(spikes,unit_list, binsz); clear spike_data;
    bins = 0:1/SRATE:1/SRATE*(rows(binned_)-1);

    % I usually have a function here that allows you  to select specific subsets
    % of cells, like only Left/Right/M1, etc.
    use_these_cells = 1:length(unit_list);

    % the indices represent the desired columns of "binned"
    tmp = binned_(:,use_these_cells); clear binned_

    % now remove quiet neurons
    QT = 5;                                   % quiet time [seconds]
    FC = 0.5;                                 % fraction of a session
    [~, ix_kept] = killQuietNeurons(tmp, QT, FC, binsz);
    binned = tmp(:,ix_kept); clear tmp
    neurons = cols(binned);    
    
    %%Tuning Curve - (Note by Shankari - this will only work for bmi
    %%generated behvr data. No cursor data in car experiment
    if(tuning)
        disp('doing Tuning Curve');
            load(ft{1},'trial'); %available only for bmi trial data
            %get logical array with rewarded events
            sub_events = ([trial.outcome] == 104);
            events = [trial.end_t];
            %get end times for all rewarded events
            events = events(sub_events);
            %center around rewarded events
            window = [-2 1]; %in s
            kinem = [];
            fr = [];
            indexes = logical(zeros(length(times),1));
            %slice only spikes associated with window
            

           for i=1:length(events)
               inds = (times>(events(i)+window(1))) & (times<(events(i)+window(2)));
               indexes = indexes | inds;
            end
            
            kinem = [kinem;cursor(indexes,:)];
            fr = [fr;binned(indexes,:)];
            %need to do the same for kin
            fitdata = [kinem ones(rows(kinem),1)];

        for cn = 1:cols(fr)
            ydata = fr(:,cn);
            [b] = regress(ydata,fitdata);
            A = b(1);
            B = b(2);
            C = b(3);
            D = b(4);
            angs = 1:1:360;
            outputP(cn,:) = A*sind(angs) + B*cosd(angs) - mean(A*sind(angs) + B*cosd(angs));
            outputV(cn,:) = C*sind(angs) + D*cosd(angs) - mean(C*sind(angs) + D*cosd(angs));
        end

        if (saving)
            disp('Saving')

            save(strcat(monkey, '_', date, '_tuning_curve'), 'outputP', 'outputV', '-v7.3');
        end
        
    end
    
%% offline predictions with UKF
    if(UKF)
        disp('Doing predictions')

        FRACT_FIT = 0.8;
        train_length = floor(length(times)*FRACT_FIT);
        v1 = 1:train_length;                              % indices of training data
        v2 = train_length+1:length(times);                % indices of test data

        xMeasured = cursor(v2,1);
        yMeasured = cursor(v2,2);

        f=@(a,b) [a(1:2,:); sqrt(sum(a(1:2,:).^2)); a(3:4,:); sqrt(sum(a(3:4,:).^2))];   

        FTAPS = 2; PTAPS = 3; MTAPS = 1;
        params = fit_ar_ukf(cursor(v1,:),binned(v1,:),f,[],FTAPS,PTAPS,MTAPS);
        preds = ar_ukf(binned(v2,:), params);

        xPredicted = preds(:,4*(PTAPS-1)+1);
        yPredicted = preds(:,4*(PTAPS-1)+2);

        [~, rx] = snrdb(xPredicted, xMeasured)
        [~, ry] = snrdb(yPredicted, yMeasured)
    end
    
   if(drop)
       ukf = true;
       
        use_times = times;
        iterations = 5;
        FRACT_FIT = 0.8;
        train_length = floor(length(use_times)*FRACT_FIT);
        v1 = 1:train_length;                              % indices of training data
        v2 = train_length+1:length(use_times);                % indices of test data
        
        xMeasured = cursor(v2,1);
        yMeasured = cursor(v2,2);
        
        f=@(a,b) [a(1:2,:); sqrt(sum(a(1:2,:).^2)); a(3:4,:); sqrt(sum(a(3:4,:).^2))];   
        FTAPS = 2; PTAPS = 4; MTAPS = 4;
        
        disp('Bootstrapped dropping curve')
        curve = struct;
        dropping_curves = [];
        kinem = cursor;
        
        for iter=1:iterations
        r_x = []; units = []; snr_x = []; snr_y = []; r_y = [];
        %exponential counting for logarithmic scale
        % 1, 2, 3, 4...10, 20 30 40...100, 200 etc.
        % 
        counter = 0;
        subset = 0;
            while (subset < neurons)
                counter = counter+1;
                subset = (mod(counter, 10) + 1) * 10^(floor(counter/10));
                if( subset > neurons)
                    %loop is ending, use the max for this last iteration
                    subset = neurons;
                end
                disp(subset)
                  % get neurons to use
                  n2use = randcomb(subset, neurons);
                  % fit ukf on first segment
                  %params = fit_wiener_arr(kinem(v1,:),binned(v1,n2use), 3);
                  % predict on second segment
                  %preds = batch_wiener(binned(v2,n2use), params);
                  % do SNR
                 params = fit_ar_ukf(cursor(v1,:),binned(v1,n2use),f,[],FTAPS,PTAPS,MTAPS);
                 preds = ar_ukf(binned(v2,n2use), params);
                 xPredicted = preds(:,4*(PTAPS-1)+1);
                 yPredicted = preds(:,4*(PTAPS-1)+2);
    %               
                [snrx, rx] = snrdb(xPredicted, xMeasured);
                [snry, ry] = snrdb(yPredicted, yMeasured);

                r_x = [r_x;rx];
                r_y = [r_y;ry];
                
                snr_x = [snr_x;snrx];
                snr_y = [snr_y;snry];
                
                units = [units;subset];

            end
                            
            curve.rx = r_x;
            curve.ry = r_y;
            
            curve.snrx = snr_x;
            curve.snry = snr_y;
            
            curve.units = units;
            dropping_curves = [dropping_curves;curve];
        end
        
        if (saving)
            disp('Saving')
            save(strcat(monkey, '_', date, '_dropping_curve'), 'dropping_curves', '-v7.3');
        end
       
   end
end
%% PETH creations
if(PSTH)
disp('Doing PETHs')


% load(fb{1},'target_x');

%     if(coordinate)
%     %angle, target onset
%     events = target_x(:,2);
%     window = [-5 5]; %in s
%     peth_matrix = {};
%     peth_sum = {};
%     end

    if (direction)
        load(fb{1},'data');
        peth_forward_matrices = {};
        peth_forward_sums = {};
        window = [-2 2]; %in s
        binsz = 0.1; %in s
        position_traces = true;

        for direction = 1:1
            %going through different onsets, angle 0, 90, 180, 270
            [events_forward, events_backward] = get_event_times(data); %one event matrix for now
            events = events_forward;
            peth_matrix = {};
            peth_sum = {};

           
            for s = 1: length(unit_list)
                sig = spikes(spikes(:,2) == unit_list(s));
                %discount empty cells
                if(length(sig) < 5)
                    continue;
                end
                [relative_spikes, sum_vector, matrix, time_vec] = peth(sig, events, window, binsz);
                %matrix = zscore(matrix);
                peth_matrix{s} = matrix(1:end-1,:);
                peth_sum{s} = sum_vector(1:end-1);

                disp(strcat('PETH for neuron #', num2str(unit_list(s)),' is complete'));
                disp(strcat('Progress:', ' ', num2str(s),'/', num2str(length(unit_list))));

                %imagesc(peth_matrix{s});
            end

            peth_forward_matrices{direction} = peth_matrix;
            peth_forward_sums{direction} = peth_sum;
        end
        disp('Saving')
        save(strcat(monkey, '_', date, '_peth_forward_psth'), 'peth_forward_matrices', 'peth_forward_sums', '-v7.3');
    end
end



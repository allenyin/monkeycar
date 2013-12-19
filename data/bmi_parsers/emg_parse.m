% $Id: emg_parse.m 713 2009-11-04 04:13:47Z joey $

fname = '/neuromancer/darpa/data/Tatiana/tatiana_011305_t700.mat';

srate    = 1000;  % [Hz]
bin_size = 50;    % [ms]
cutoff   = 20;    % [Hz]
pos_ts   = 0;

load(fname);

bin_size = bin_size/1000;  % convert to sec

EMG = [ AD01 AD04 AD03 AD02 ]; % bicep, tricep, w. flex, w. extens
EMG = abs(EMG); % rectify EMG signal

len = size(EMG,1);

[b,a] = butter(2,cutoff/srate); % 2nd order butterworth filter
for i=1:size(EMG,2);
   EMG2(:,i) = filter(b,a,EMG(:,i));   % filter & downsample to bin_size
   EMG3(:,i) = interp1q([1:len]',EMG2(:,i),[1:srate*bin_size:len]');
end

t           = bin_size*size(EMG3,1);     % Total time, in seconds
bins        = 0:bin_size:t-bin_size;    % Vector of bins
        
    sigs = char(who('sig*'));

    spikes = zeros(length(bins),size(sigs,1));

    % Bin spikes, drop spikes that occur before pos_ts.
    for i = 1:size(sigs,1)
       eval([sigs(i,:) '=' sigs(i,:) '- pos_ts;']);
       eval([sigs(i,:) '(find(' sigs(i,:) '< 0)) = [];']);

       % Force 'spike' to be a column.
       spikes(:,i) = histc([-inf; eval(sigs(i,:))],bins);
    end

O = EMG3;
N = spikes;

%save temp-tatiana-foo.mat N O -V6;


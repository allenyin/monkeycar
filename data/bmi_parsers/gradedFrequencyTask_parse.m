% GRADEDFREQUENCYTASK_PARSE
% 
% this function reads in a graded fraquency task behavior file
% processes the data and saves a _parsed file to speed up
% subsequent analysis
% 
% f - filename of .mat file produced by bmi_parse
% $Id: gradedFrequencyTask_parse.m $

function gradedFrequencyTask_parse(f)

%DEFINE THE STROBES

ST_NULL = 0;
ST_READY = 1;			
ST_EXPLORE_WITH_TARGET = 2; 	
ST_EXPLORE_WITHOUT_TARGET = 3;
ST_IN_PERIPHERY = 4;
ST_IN_TARGET = 5;			
ST_REWARD = 6;				
ST_ERR_TIMEOUT = 7;			
ST_ERR_CANCELED = 8;		
ST_INTERTRIAL = 9;				

disp(f);

load(f, 'state', 'cursor_x', 'cursor_y');

common_parse;
[msgid,msgid] = lastwarn;
if (strcmp(msgid,'common_parse:no_trials'))
	lastwarn('','');
	return;
end

load(f,	'js*', ...
	'*target_*', ...
	'cursor_*', ...
	'use_*', ...
	'*_time', '*_timeout');


basicTask_parse;

[trial.target_pos] = dealify([trial.outcome_t],cursor_x,'previous');


for i=1:ntrials,
    
    
% save in parsed file
[pstr,fstr,estr] = fileparts(f);
save(fullfile(pstr,[fstr,'_parsed',estr]), ...
  'trial', 'ST_*');
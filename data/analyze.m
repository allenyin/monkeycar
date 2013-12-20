close all;
clear all; clc;

% data files needed

%% 12-17-2013
d = '12-17-2013/';
Taskname = 'monkeyCarPassiveMovement_20131217134238.out';
SpikeFile = 'cherry_121713_L2B_L2C_L3C_L2A_passivetask_withfood.mat';

% Taskname = 'monkeyCarPassiveMovement_20131217131445.out';
% SpikeFile = 'cherry_121713_L2B_L2C_L3C_L2A_passivetask_withfood.mat';

%% 12-20-2013
% d = '12-20-2013/';
% Taskname = 
% SpikeFile =

% Taskname = 
% SpikeFIle = 

Taskname = strcat(d, Taskname);
SpikeFile = strcat(d, SpikeFile);
bmi_parse(true, Taskname);
TaskLog = load(strcat(Taskname(1:end-3), 'mat'));


% Analysis starts
disp('Making PETH...');
make_PETH;

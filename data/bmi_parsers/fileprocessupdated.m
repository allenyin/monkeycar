function fileprocessupdated(f)


clear all
close all
% % 
% filename = input('What is filename? ','s');
% monkey = 'nectarine';
% date = input('What is the date? ','s');
% cell = 'RHA1_001a';
% f = strcat('d:\Nectarine\converted_data\', [filename]);

load(f)

%DEFINE THE STROBES

ST_NULL = 0;
ST_READY = 1;			
ST_PRE_CENTER =2;			
ST_IN_CENTER =3;			
ST_EXPLORE=4;				
ST_IN_CORRECT_TARGET=5;
ST_IN_WRONG_TARGET=6;
ST_REWARD=7;
ST_ERR_GENERIC=8;
ST_ERR_TIMEOUT=9;
ST_ERR_CANCELED=10;
ST_INTERTRIAL=11;		

disp(f);

load(f, 'state', 'cursor_x', 'cursor_y',  'cursor_gain_x')

cd('/mnt/crackle/arjun/codes/bmi_parsers');
common_parse

[msgid,msgid] = lastwarn;
if (strcmp(msgid,'common_parse:no_trials'))
	lastwarn('','');
	return;
end

load(f,	'js*', ...
	'*target_*', ...
	'cursor_*', ...
    'trans_A_*', ...
	'use_*', ...
	'*_time', '*_timeout')


basicTask_parse

[trial.target_theta1] = dealify([trial.outcome_t],active_target_number,'previous');
%filename = strcat(f,'_parsed');

filename = strcat(f(1:length(f) - 4), '_parsed.mat');

save(filename,'trial', 'ST_*');

% target_pos_x does not register position of correction trials which is the
% same position as the previous trial

% cd('d:\Google Drive\jehian\analysis')
% 
% in_trl = find([trial.outcome] == ST_IN_TARGET);
% rew_trl = find([trial.outcome] == ST_REWARD);         % rewarded trials
% err_trl = find([trial.outcome] == ST_ERR_TIMEOUT);    % timeout trials 
% 
% alpha_zero = min(find(target_alpha(:,1)==0)); 
% t_alpha_zero = target_alpha(alpha_zero,2); % the time when alpha was turned to zero aka invisible target
% 
% for ts=1:length(trial)
%     
%     real_trial_start_times(ts) = trial(ts).start_t;
%     real_trial_end_times(ts)   = trial(ts).end_t;
%     real_trial_button(ts)     = length(trial(ts).button);
%    
% 
% end
%     
% pre_trial_rew_times   = state(find(state(:,1)==6),2);
% pre_trial_start_times = state(trial_start(rew_trl),2);
% 
% 
% % find trials where target-alpha is zero
% 
% trial_alpha_zero = min(find(real_trial_start_times>t_alpha_zero));
% 
% trial_alpha_zero_time = real_trial_start_times(min(find(real_trial_start_times>t_alpha_zero)));
% 
% trial_rew_times   = pre_trial_rew_times(trial_alpha_zero:end);
% 
% trial_start_times = pre_trial_start_times(trial_alpha_zero:end);
% 
% cursor_time_difference = [];
% 
% %% find trials where monkey didn't try
% 
% for u=1:length(real_trial_start_times)
%     real_cursor_start(u) = min(find(cursor_x(:,2)>=real_trial_start_times(u)));    
%     real_cursor_end(u)   = max(find(cursor_x(:,2)< real_trial_end_times(u)));
%     real_cursor_pos{u}= cursor_x(real_cursor_start(u):real_cursor_end(u),1);
%     real_cursor_pos_length(u) = length(real_cursor_pos{u});
%     real_cursor_time{u}= cursor_x(real_cursor_start(u):real_cursor_end(u),2);
%     real_cursor_time_difference(u) = max(real_cursor_time{u}) - min(real_cursor_time{u});
% end
% 
% pre_lazy_trials1 = find(real_cursor_pos_length<(mean(real_cursor_pos_length(err_trl))+std(real_cursor_pos_length(err_trl))));
% 
% real_lazy_trials = intersect(pre_lazy_trials1, err_trl);
% 
% total_trials = length(real_trial_start_times) - trial_alpha_zero
% lazy_trials = real_lazy_trials(min(find(real_lazy_trials>=trial_alpha_zero)):end)
% 
% reward = length(trial_rew_times)
% 
% %% get rid of correction and incorrect trials
% [c,ia,ib] = intersect(trial_start_times,target_size(:,2));
% good_trials = ia;
% trial_start_times = trial_start_times(ia);
% trial_rew_times = trial_rew_times(ia);
% target_size = target_size (ib);
% target_x(find(diff(target_x(:,2))==0),:)=[];
% target_x(find(diff(target_x(:,2))<0),:)=[];
% [d,ic,id] = intersect(trial_start_times, target_x(:,2));
% target_x = target_x(id,:);
% trial_start_times = trial_start_times(ic);
% trial_rew_times = trial_rew_times(ic);
% 
% %% find catch trials where the target was invisible and no microstimulation was delivered
% zero_current = find(icms_chan_0_current(:,1)==0);
% normal_current = find(icms_chan_0_current(:,1)==100);
% zero_current_times = icms_chan_0_current(zero_current,2);
% normal_current_times = icms_chan_0_current(normal_current,2);
% [countz,zero_current_index, total_index] = intersect(zero_current_times,trial_start_times);
% z = intersect(zero_current_times,real_trial_start_times);
% rewarded_catch_trials = [];
% 
% for c=1:length(countz)-1
% catch_start(c) = zero_current_times(c);
% catch_end(c)   = normal_current_times(c+2);
% rewarded_catch_trials = [rewarded_catch_trials (find(trial_start_times==catch_start(c)):find(trial_start_times==catch_end(c))-1)];
% end
% 
% length(countz)
% length(rewarded_catch_trials)
% 
% %% analysis of rewarded trials only
% trial_rew_times(rewarded_catch_trials) = [];
% trial_start_times(rewarded_catch_trials) = [];
% target_size(rewarded_catch_trials,:) = [];
% target_x(rewarded_catch_trials,:) = [];
% 
% 
% for i=1:length(trial_start_times)
%     cursor_start(i) = min(find(cursor_x(:,2)>=trial_start_times(i)));    
%     cursor_end(i)   = max(find(cursor_x(:,2)< trial_rew_times(i)));
%     cursor_pos{i}= cursor_x(cursor_start(i):cursor_end(i),1);
%     cursor_time{i}= cursor_x(cursor_start(i):cursor_end(i),2);
%     cursor_time_difference(i) = max(cursor_time{i}) - min(cursor_time{i});
%     js_pos{i} = js_x(cursor_start(i):cursor_end(i),1);
% %     figure(i)
% % %     plot(cursor_time{i},cursor_pos{i})
% %     ylim([-20 20])
% %    hold on
% %     plot(cursor_end(i),target_x(i,1),'r*')
% end
% 
% 
% % find how long it takes for the monkey to reach target depending on target
% % position
% % 
% % figure(1)
% % plot(cursor_time_difference)
% % hold on
% % plot(trial_target_x,'r')
% % hold off
% % xlabel('trials')
% % ylabel('Position and trial duration (s)')
% % legend('trial duration','target position')
% 
% % outliers = find(cursor_time_difference>10); %get rid of trials where the monkey took >10s to find target
% % cursor_time_difference([outliers]) = [];
% % 
% % trials = 1:length(trial_start_times)';
% % trials(outliers) = [];
% % % 
% 
% trial_target_x = target_x(:,1);
% 
% nn = hist(trial_target_x,[-9:2:9]); %nn is the number of trials between -10 and -8, -8 and -6, and so on
% 
% xx = [-10:2:10];
% % 
% for ii=1:length(xx)-1
%       target_position{ii} = intersect([find((trial_target_x)>=xx(ii))],[find((trial_target_x)<xx(ii+1))]) ;   
%       t_in_pos(ii) = mean(cursor_time_difference(target_position{ii}));
% end
% % 
% % figure(1)
% % plot([-9:2:9],t_in_pos,'-*')
% % xlabel('target position')
% % ylabel('trial duration (s)')
% 
% %sizes = [2 3 4 5];
% 
% % trial_target_size = target_size(:,1);
% % % 
% % % for iii=1:length(sizes)
% % %       target_sizes{iii} = find(trial_target_size==sizes(iii));   
% % %       t_in_size(iii) = mean(cursor_time_difference(target_sizes{iii}));
% % % end
% 
% % figure(2)
% % plot(sizes,t_in_size,'-*')
% % xlabel('target sizes')
% % ylabel('trial duration (s)')
% 
% 
% 
% %%
% %compare the time spent in different divisions of x-axis.
% %For ex: time spent between -10 and -5, -5 and 0, 0 and 5, and 5 and 10
% x_range = -10:5:10;
% 
% cd('d:\Google Drive\new analysis\general');
% 
% %% position vs velocity firing rate
% binsize=200; %ms
% trial_target_x = target_x(:,1);
% left_targets = find(trial_target_x<0);
% right_targets = find(trial_target_x>0);
% % % 
% [M1 S1 useful_sigs]=getUsefulSigs(monkey,date);
% 
% getFRVelPos
% %% cells
% % left_targets = find(trial_target_x<0);
% % right_targets = find(trial_target_x>0);
% % 
% % [R_total B_total M1 S1]= analyzeCells(monkey,date,[0 3],50/1000,trial_start_times(left_targets));
% % 
% % for t=1:length(B_total)
% %     avg_B = nanmean(B_total);
% %     dev_B = nanstd(B_total);
% %     norm_B_total(:,t) = (B_total(:,t)- avg_B(t))./dev_B(t);
% % end
% % 
% % 
% % sh_norm_B_total = [norm_B_total(:,M1) norm_B_total(:,S1)];
% % sh_norm_B_total(:,6)=[];
% % 
% % figure(1)
% % imagesc(sh_norm_B_total(1:end-1,:)')
% % colorbar 
% % caxis([-2 3])
% % 
% % xlabel('time before hold')
% % ylabel('neurons')
% % 
% % clear R_total B_total sh_norm_B_total avg_B dev_B norm_B_total
% % 
% % [R_total B_total M1 S1]= analyzeCells(monkey,date,[0 3],50/1000,trial_start_times(right_targets));
% % 
% % for t=1:length(B_total)
% %     avg_B = nanmean(B_total);
% %     dev_B = nanstd(B_total);
% %     norm_B_total(:,t) = (B_total(:,t)- avg_B(t))./dev_B(t);
% % end
% % 
% % 
% % sh_norm_B_total = [norm_B_total(:,M1) norm_B_total(:,S1)];
% % sh_norm_B_total(:,6)=[];
% % 
% % figure(2)
% % imagesc(sh_norm_B_total(1:end-1,:)')
% % colorbar 
% % caxis([-2 3])
% % 
% % xlabel('time before hold')
% % ylabel('neurons')
% % 
% % clear R_total B_total sh_norm_B_total avg_B dev_B norm_B_total
% % 
% % [R_total B_total M1 S1]= analyzeCells(monkey,date,[-2.8 -1.2],50/1000,trial_rew_times(left_targets));
% % 
% % for t=1:length(B_total)
% %     avg_B = nanmean(B_total);
% %     dev_B = nanstd(B_total);
% %     norm_B_total(:,t) = (B_total(:,t)- avg_B(t))./dev_B(t);
% % end
% % 
% % 
% % sh_norm_B_total = [norm_B_total(:,M1) norm_B_total(:,S1)];
% % sh_norm_B_total(:,6)=[];
% % 
% % figure(3)
% % imagesc(sh_norm_B_total(1:end-1,:)')
% % colorbar 
% % caxis([-2 3])
% % 
% % xlabel('time before hold')
% % ylabel('neurons')
% % 
% % clear R_total B_total sh_norm_B_total avg_B dev_B norm_B_total
% % 
% % [R_total B_total M1 S1]= analyzeCells(monkey,date,[-2.8 -1.2],50/1000,trial_rew_times(right_targets));
% % 
% % for t=1:length(B_total)
% %     avg_B = nanmean(B_total);
% %     dev_B = nanstd(B_total);
% %     norm_B_total(:,t) = (B_total(:,t)- avg_B(t))./dev_B(t);
% % end
% % 
% % 
% % sh_norm_B_total = [norm_B_total(:,M1) norm_B_total(:,S1)];
% % sh_norm_B_total(:,6)=[];
% % 
% % figure(4)
% % imagesc(sh_norm_B_total(1:end-1,:)')
% % colorbar 
% % 
% % caxis([-2 3])
% % xlabel('time before hold')
% % ylabel('neurons')
% % 
% % % caxis([-2 3])
% % % plot2svg('invTargRight20120411.svg')
% % 
% % 
% % for vii=1:length(x_range)-1
% %     trial_range1 = find(trial_target_x>x_range(vii));
% %     trial_range2 = find(trial_target_x<=x_range(vii+1));
% %     trial_range{vii}= intersect(trial_range1,trial_range2);
% %     clear trial_range1 trial_range2
% % end
% % 
% % total_trial_range = [];
% % for viii=1:length(x_range)-1
% %     temp_trial_range = trial_range{viii};
% %     temp_data(viii,:) = mean(total_duration(temp_trial_range,:)); 
% % end
% 
% s = struct('cursor_position',{cursor_pos}, ...
% 'cursor_time',{cursor_time}, ...
% 'cursor_time_difference', {cursor_time_difference}, ...
% 'target_pos_per_trial', trial_target_x, ...
% 'every',every);
% 
% save([strcat('d:\Nectarine\converted_data\',filename,'_invisibleTarget_',cell)],'-struct','s')

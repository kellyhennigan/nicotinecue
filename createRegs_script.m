% makeRegsSA2_script

% script to make regressors for all cue exp subjects
%


clear all
close all

% define relevant directories
mainDir = '/Users/kelly/nicotinecue';
scriptsDir = [mainDir '/scripts']; % this should be the directory where this script is located
dataDir = [mainDir '/data'];
figDir = [mainDir '/figures']; % where to save out figures

path(path,genpath(scriptsDir)); % add scripts dir to matlab search path


task='cue';

subjects={'pilot171111'};

nTRs = 436;


% stim file, where %s will be subject id
stimfilepath = [dataDir '/%s/behavior/cue_matrix.csv'];

% this corresponds to trial types 1-4, respectively
conds = {'alcohol','cig','food','neutral'};


% labels to be used for reg filenames for pref ratings
pref_idx = [-3 -1 1 3];
pref_labels = {'strongdontwant','somewhatdontwant',...
    'somewhatwant','strongwant'};


hrf = 'waver'; % choices are spm or 'waver'

% subject stim file will have a TR column where TR indexes the following
% parts of each trial:
%   1 - cue onset
%   2 - image onset
%   3 & 4 - choice period
%   5,6 & 7 - iti period


%%%%% this script makes the following (unconvolved regressors):
% cue onset by condition (alcohol, drugs. etc.)
% img onset by condition
% choice onset by condition
% choice period by condition
% cue rt
% choice rt
% pref ratings at image onset
% pref ratigns at choice period onset


%% SUBJECT LOOP


for s=1:numel(subjects)

subject = subjects{s};

fprintf(['\n\nSaving regressor time series for subject ' subject '...\n\n']);

% define subjects-specific directories
subjDir = fullfile(dataDir,subject);
regDir =  fullfile(subjDir,'regs');

% if reg dir doesn't exist, create it
if ~exist(regDir,'dir')
    mkdir(regDir)
end


[trial,tr,starttime,clock,trial_onset,trial_type,cue_rt,choice,choice_num,...
    choice_type,choice_rt,iti,drift,image_name]=getCueTaskBehData(sprintf(stimfilepath,subject),'long');


% if numel(tr) is zero, then behavioral data for this subject wasn't loaded
if numel(tr)==0
    fprintf(['\n behavioral data not loaded for subject ' subject ', so skipping...\n'])
else
    
    
    %% make reg time series
    
    
    %%%%%%%%%%%%%%%%%%% cue onset period: tr=1
    [reg,regc]=createRegTS(find(tr==1),1,nTRs,hrf,[regDir '/cue_cue.1D']);
    
    
    
    %%%%%%%%%%%%%%%%%%% img onset period: tr=2
    [reg,regc]=createRegTS(find(tr==2),1,nTRs,hrf,[regDir '/img_cue.1D']);
    
    
    %%%%%%%%%%%%%%%%%%% choice onset period: tr=3
    [reg,regc]=createRegTS(find(tr==3),1,nTRs,hrf,[regDir '/choice_cue.1D']);
    
    
    %%%%%%%%%%%%%%%%%%% choice period: tr=3 & tr=4
    [reg,regc]=createRegTS(find(tr==3 | tr==4),1,nTRs,hrf,[regDir '/choice2_cue.1D']);
    
    
    %%%%%%%%%%%%%%%%%%% cue onset by trial type
    for i=1:4
        [reg,regc]=createRegTS(find(tr==1 & trial_type==i),1,nTRs,hrf,[regDir '/' conds{i} '_cue_cue.1D']);
    end
    
 
    
    %%%%%%%%%%%%%%%%%%% image onset by trial type
    for i=1:4
        [reg,regc]=createRegTS(find(tr==2 & trial_type==i),1,nTRs,hrf,[regDir '/' conds{i} '_img_cue.1D']);
    end
    
    
    %%%%%%%%%%%%%%%%%%% cue & image by trial type
    for i=1:4
        [reg,regc]=createRegTS(find(trial_type==i & (tr==1 | tr==2)),1,nTRs,hrf,[regDir '/' conds{i} '_cueimg_cue.1D']);
    end
    
    
    %%%%%%%%%%%%%%%%%%% choice onset by trial type
    for i=1:4
        [reg,regc]=createRegTS(find(tr==3 & trial_type==i),1,nTRs,hrf,[regDir '/' conds{i} '_choice_cue.1D']);
    end
    
    
    %%%%%%%%%%%%%%%%%%% choice period by trial type
    for i=1:4
        [reg,regc]=createRegTS(find(trial_type==i & (tr==3 | tr==4)),1,nTRs,hrf,[regDir '/' conds{i} '_choice2_cue.1D']);
    end
    
    
    %%%%%%%%%%%%%%%%%% model whole trial by type
    for i=1:4
        [reg,regc]=createRegTS(find(trial_type==i & (tr==1 | tr==2 | tr==3 | tr==4)),1,nTRs,hrf,[regDir '/' conds{i} '_trial_cue.1D']);
    end
    [reg,regc]=createRegTS(find(tr==1 | tr==2 | tr==3 | tr==4),1,nTRs,hrf,[regDir '/trial_cue.1D']);
    
    
    %%%%%%%%%%%%%%%%%%% cue onset by pref ratings (for VOIs)
    for i=1:4
        [reg,~]=createRegTS(find(tr==1 & choice_num==pref_idx(i)),1,nTRs,0, [regDir '/' pref_labels{i} '_cue_cue.1D']);
    end
    
    
    %%%%%%%%%%%%%%%%%%% image onset by pref ratings
    for i=1:4
        [reg,regc]=createRegTS(find(tr==2 & choice_num==pref_idx(i)),1,nTRs,hrf, [regDir '/' pref_labels{i} '_img_cue.1D']);
    end
    
    %%%%%%%%%%%%%%%%%%% choice onset by pref ratings
    for i=1:4
        [reg,regc]=createRegTS(find(tr==3 & choice_num==pref_idx(i)),1,nTRs,hrf, [regDir '/' pref_labels{i} '_choice_cue.1D']);
    end
    
    
    %%%%%%%%%% cue rt - model stick function w/RT as height at cue onset (tr=1)
    [reg,regc]=createRegTS(find(tr==1),cue_rt(tr==1),nTRs,hrf,[regDir '/cuert_cue.1D']);
    
    
    %%%%%%%%%% choice rt - model stick function w/RT as height at choice onset (tr=1)
    [reg,regc]=createRegTS(find(tr==3),choice_rt(tr==1),nTRs,hrf,[regDir '/choicert_cue.1D']);
    
    
%     %%%%%%%%% whole-trial parametric regressor modulated by pref ratings
%     pref=choice_num(find(tr==1 | tr==2 | tr==3 | tr==4));
%     pref=pref-mean(pref);
%     [reg,regc]=createRegTS(find(tr==1 | tr==2 | tr==3 | tr==4),pref,nTRs,hrf,[regDir '/pref_trial_cue.1D']);
%     [reg,regc]=createRegTS(find(tr==1 | tr==2 | tr==3 | tr==4),1,nTRs,hrf,[regDir '/trial_cue.1D']);
%     
%     
%     %%%%%%%%% whole-trial parametric regressor modulated by pref by cond
%     for i=1:4
%         pref=choice_num(find(trial_type==i & (tr==1 | tr==2 | tr==3 | tr==4)));
%         pref=pref-mean(pref);
%         [reg,regc]=createRegTS(find(trial_type==i & (tr==1 | tr==2 | tr==3 | tr==4)),pref,nTRs,hrf,[regDir '/pref' conds{i} '_trial_cue.1D']);
%     end
%   
    
    fprintf(['\n\ndone with subject ' subject '.\n']);
    
end

end % subjects




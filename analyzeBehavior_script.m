% behavioral analysis script

% this script loads behavioral data from the nicotine cue reactivity task
% and plots out some variables of interest (reaction time, preference
% ratings, etc.) 

clear all
close all


% define relevant directories
mainDir = '/Users/kelly/nicotinecue';
scriptsDir = [mainDir '/scripts']; % this should be the directory where this script is located
dataDir = [mainDir '/data'];
figDir = [mainDir '/figures']; % where to save out figures

path(path,genpath(scriptsDir)); % add scripts dir to matlab search path

task='cue';

% cell array of subject ids to include in plots
subjects={'pilot171111'};
gi = 0; % group index for each subject 

conds = {'alcohol','cig','food','neutral'};

%%%%%%%%%%%%%%% define groups to plot %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
groups = {'pilot'};
groupStr = '';

cols = []; % plot colors 

% # of total subjects, and # of controls and patients
N=numel(subjects);


% cue task data
fp1 = fullfile(dataDir, '%s/behavior/cue_matrix.csv');  %s is a placeholder for subj id string
fp2 = fullfile(dataDir, '%s/behavior/cue_ratings.csv');


% directory for saving out figures
outDir = fullfile(figDir,'behavior');

if ~exist(outDir,'dir')
    mkdir(outDir)
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% load behavioral data

%%%%%%%%%%%%%%%%%%%%%%%%% load task stim files %%%%%%%%%%%%%%%%%%%%%%%%%%%%
fp1s = cellfun(@(x) sprintf(fp1,x), subjects, 'uniformoutput',0);
[trial,tr,starttime,clock,trial_onset,trial_type,cue_rt,choice,choice_num,...
    choice_type,choice_rt,iti,drift,image_name]=cellfun(@(x) getCueTaskBehData(x,'short'), fp1s, 'uniformoutput',0);

ci = trial_type{1}; % condition trial index (should be the same for every subject)


%%%%%%%%%%%%%%%%%%%%%%% load PA/NA cue ratings %%%%%%%%%%%%%%%%%%%%%%%%%%%%
fp2s = cellfun(@(x) sprintf(fp2,x), subjects, 'uniformoutput',0);
[cue_type,cue_pa,cue_na] = cellfun(@(x) getCueVARatings(x), fp2s, 'uniformoutput',0);
 


%%%%%%%%%%%%%%%%%%%%%%%%%%%% pref ratings %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% get mean pref ratings by condition w/subjects in rows
pref = cell2mat(choice_num')'; % subjects x items pref ratings
mean_pref = [];
for j=1:numel(conds) % # of conds
    mean_pref(:,j) = nanmean(pref(:,ci==j),2);
end

%%%%%%%%%%%%%%%%%%%%%%%%%% PA/NA cue ratings %%%%%%%%%%%%%%%%%%%%%%%%%%%%
% re-arrange cue PA & NA ratings into matrix w/subjects in rows
cue_pa = cell2mat(cue_pa); 
cue_na = cell2mat(cue_na); 

% %%%%%%%%%%%%%%%%%%%%%%%%%% PA/NA image ratings %%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % get mean pa and na ratings by condition w/subjects in rows
% mean_pa = []; mean_na = [];
% for j=1:numel(conds) % # of trial types
%     mean_pa(:,j) = nanmean(pa(:,qimage_type==j),2);
%     mean_na(:,j) = nanmean(na(:,qimage_type==j),2);
% end
% 
% 
% %%%%%%%%%%%%%%%%%%%%%%%%%% familiarity image ratings %%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % get mean familiarity ratings by condition w/subjects in rows
% mean_famil = []; 
% for j=1:numel(conds) % # of trial types
%     mean_famil(:,j) = nanmean(famil(:,qimage_type==j),2);
% end
% 



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% RTs %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% get mean cue/choice RTs & # of no responses by condition w/subjs in rows
cue_rt = cell2mat(cue_rt')'; % subjects x items cue RT
choice_rt=cell2mat(choice_rt')'; % subjects x items choice RT

% re-code no responses from -1 to NaN
cue_rt(cue_rt<0)=nan;  choice_rt(choice_rt<0)=nan;

mean_cueRT = []; n_cueNoresp = []; mean_choiceRT = []; n_choiceNoresp = [];
for j=1:numel(conds)
    
    % cue rts
    mean_cueRT(:,j) = nanmean(cue_rt(:,ci==j),2);
    n_cueNoresp(:,j) = sum(isnan(cue_rt(:,ci==j)),2);
    
    % choice rts
    mean_choiceRT(:,j) = nanmean(choice_rt(:,ci==j),2);
    n_choiceNoresp(:,j) = sum(isnan(choice_rt(:,ci==j)),2);
    
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% PLOTS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Q: differences in preference across trial types & groups? 

% pref ratings 
dName = 'wanting'; % name of measure to plot
saveStr = 'want'; % string for fig out name
d = mean_pref; % data w/subjects in rows, conds in columns

plotSig = [1 1];
titleStr = 'want ratings by group and condition';
plotLeg = 1;
savePath = fullfile(outDir,[saveStr groupStr '.png']);

dg={};
for k=1:numel(groups)
    dg{k} = d(gi==k-1,:); % data in cell array by groups
end
[fig,leg] = plotNiceBars(dg,dName,conds,strrep(groups,'_',' '),cols,plotSig,titleStr,plotLeg,savePath);


% now plot without alc condition
idx = [2 4 3]; % cig neutral food
dg=cellfun(@(x) x(:,idx), dg, 'uniformoutput',0);
savePath = fullfile(outDir,[saveStr groupStr ' no alc.png']);
fig = plotNiceBars(dg,dName,conds(idx),strrep(groups,'_',' '),cols,plotSig,titleStr,1,savePath);

% ttest for cig want ratings difference in patients vs controls
% [h,p,~,stats]=ttest2(dg{2}(:,1),dg{1}(:,1))

% % ttest for pref ratings difference in relapsers vs nonrelapsers
[h,p,~,stats]=ttest2(dg{2}(:,1),dg{3}(:,1))

%% Q: differences in pos arousal across trial types and groups? 

% PA
dName = 'image positive arousal'; % name of measure to plot
saveStr = 'imagePA'; % string for fig out name
d = mean_pa; % data w/subjects in rows, conds in columns

plotSig = [1 1];
titleStr = 'PA ratings by group and condition';
plotLeg = 1;
savePath = fullfile(outDir,[saveStr groupStr '.png']);

dg={};
for k=1:numel(groups)
    dg{k} = d(gi==k-1,:); % data in cell array by groups
end
[fig,leg] = plotNiceBars(dg,dName,conds,strrep(groups,'_',' '),cols,plotSig,titleStr,plotLeg,savePath);


% now plot without alc condition
idx = [2 4 3]; % cig neutral food
dg=cellfun(@(x) x(:,idx), dg, 'uniformoutput',0);
savePath = fullfile(outDir,[saveStr groupStr ' no alc.png']);
fig = plotNiceBars(dg,dName,conds(idx),strrep(groups,'_',' '),cols,plotSig,titleStr,1,savePath);

% ttest for pref ratings difference in relapsers vs nonrelapsers
[h,p,~,stats]=ttest2(dg{2}(:,1),dg{3}(:,1))



%% Q: difference in negative arousal across trial types and groups?

dName = 'image negative arousal'; % name of measure to plot
saveStr = 'imageNA'; % string for fig out name
d = mean_na; % data w/subjects in rows, conds in columns

plotSig = [1 1];
titleStr = 'NA ratings by group and condition';
plotLeg = 1;
savePath = fullfile(outDir,[saveStr groupStr '.png']);

dg={};
for k=1:numel(groups)
    dg{k} = d(gi==k-1,:); % data in cell array by groups
end
[fig,leg] = plotNiceBars(dg,dName,conds,groups,cols,plotSig,titleStr,plotLeg,savePath);


% now plot without alc condition
idx = [2 4 3]; % cig neutral food
dg=cellfun(@(x) x(:,idx), dg, 'uniformoutput',0);
savePath = fullfile(outDir,[saveStr groupStr ' no alc.png']);
fig = plotNiceBars(dg,dName,conds(idx),groups,cols,plotSig,titleStr,1,savePath);




%% Q: difference in negative arousal across trial types and groups?

dName = 'image familiarity'; % name of measure to plot
saveStr = 'imageFamiliarity'; % string for fig out name
d = mean_famil; % data w/subjects in rows, conds in columns

plotSig = [1 1];
titleStr = 'familiarity ratings by group and condition';
plotLeg = 1;
savePath = fullfile(outDir,[saveStr groupStr '.png']);

dg={};
for k=1:numel(groups)
    dg{k} = d(gi==k-1,:); % data in cell array by groups
end
[fig,leg] = plotNiceBars(dg,dName,conds,groups,cols,plotSig,titleStr,plotLeg,savePath);


% now plot without alc condition
idx = [2 4 3]; % cig neutral food
dg=cellfun(@(x) x(:,idx), dg, 'uniformoutput',0);
savePath = fullfile(outDir,[saveStr groupStr ' no alc.png']);
fig = plotNiceBars(dg,dName,conds(idx),groups,cols,plotSig,titleStr,1,savePath);



%% Q: differences in cue RT or # of no responses by trial type between groups? 


dName = 'cue RT'; % name of measure to plot
saveStr = 'cueRT'; % string for fig out name
d = mean_cueRT; % data w/subjects in rows, conds in columns

plotSig = [1 1];
titleStr = 'cue RT by group and condition';
plotLeg = 1;
savePath = fullfile(outDir,[saveStr groupStr '.png']);

dg={};
for k=1:numel(groups)
    dg{k} = d(gi==k-1,:); % data in cell array by groups
end
[fig,leg] = plotNiceBars(dg,dName,conds,groups,cols,plotSig,titleStr,plotLeg,savePath);


% now plot without alc condition
idx = [2 4 3]; % cig neutral food
dg=cellfun(@(x) x(:,idx), dg, 'uniformoutput',0);
savePath = fullfile(outDir,[saveStr groupStr ' no alc.png']);
fig = plotNiceBars(dg,dName,conds(idx),groups,cols,plotSig,titleStr,1,savePath);


dName = 'cue no responses'; % name of measure to plot
saveStr = 'cueNoresp'; % string for fig out name
d = n_cueNoresp; % data w/subjects in rows, conds in columns

groupStr = '';
plotSig = [1 1];
titleStr = 'omitted cue responses';
plotLeg = 1;
savePath = fullfile(outDir,[saveStr groupStr '.png']);

dg={};
for k=1:numel(groups)
    dg{k} = d(gi==k-1,:); % data in cell array by groups
end
[fig,leg] = plotNiceBars(dg,dName,conds,groups,cols,plotSig,titleStr,plotLeg,savePath);




%% Q: differences in choice RT or # of no responses by trial type between groups? 


dName = 'choice RT'; % name of measure to plot
saveStr = 'choiceRT'; % string for fig out name
d = mean_choiceRT; % data w/subjects in rows, conds in columns

groupStr = '';
plotSig = [1 1];
titleStr = 'choice RT by group and condition';
plotLeg = 1;
savePath = fullfile(outDir,[saveStr groupStr '.png']);

for k=1:numel(groups)
    dg{k} = d(gi==k-1,:); % data in cell array by groups
end
[fig,leg] = plotNiceBars(dg,dName,conds,groups,cols,plotSig,titleStr,plotLeg,savePath);


dName = 'choice no responses'; % name of measure to plot
saveStr = 'choiceNoresp'; % string for fig out name
d = n_choiceNoresp; % data w/subjects in rows, conds in columns

groupStr = '';
plotSig = [1 1];
titleStr = 'omitted choice responses';
plotLeg = 1;
savePath = fullfile(outDir,[saveStr groupStr '.png']);

for k=1:numel(groups)
    dg{k} = d(gi==k-1,:); % data in cell array by groups
end
[fig,leg] = plotNiceBars(dg,dName,conds,groups,cols,plotSig,titleStr,plotLeg,savePath);




%% Q: is there a relationship between RT and preference ratings?


figure
plot(pref,choice_rt,'.','markersize',10,'color',[.2 .2 .2])
xlabel('pref rating')
ylabel('choice RT')

% looks slightly quadratic - shorter RTs for strong prefs & slightly longer
% rts for weaker prefs 


%% do post-experiment positive arousal ratings match preference ratings?

% correlation between PA and pref for each subject
r = diag(corr(pref',pa')); 
nanmean(r)
fprintf(['\naverage correlation between pref & positive arousal ratings:\n' ...
    'r=%4.2f\n'], nanmean(r))
    
% yes - pref is correlated with post-experiment positive arousal ratings

% now across all subjects
vi=find(~isnan(pa) & pref~=0); % vals idx (NOT nan)
plotCorr([],pref(vi),pa(vi),'pref ratings','PA','rp')
savePath = fullfile(outDir,'pref PA corr.png');
print(gcf,'-dpng','-r300',savePath);


%% are people's hunger levels related to their food ratings? 

r = corr(qd.hungry(~isnan(qd.hungry)),mean_pref(~isnan(qd.hungry),3));
fprintf(['\ncorrelation between hunger & food preference ratings:\n' ...
    'r=%4.2f\n'], r);


r = corr(qd.hungry(~isnan(qd.hungry)),mean_pa(~isnan(qd.hungry),3));
fprintf(['\ncorrelation between hunger & food PA ratings:\n' ...
    'r=%4.2f\n'], r);

% nope...


%% correlation btwn pref and PA ratings....

% fig=setupFig
% j=1;
% cols = getCueExpColors(4)
% for j=1:4
%     subplot(2,2,j)
%     [axH,rpStr]=plotCorr(gca,reshape(want(:,ci==j),[],1),reshape(pa(:,ci==j),[],1),...
%         'want','PA','',cols(j,:))
%     title(gca,[conds{j} ' ' rpStr])
% end
% 
% print(gcf,'-dpng','-r300',fullfile(figDir,'PA-want correlation by image type'))
% 
    

%% check item-wise pref and PA ratings for cig images in patients- any outliers? 
    
% pref ratings
fig=setupFig
cig_pref = pref(gi==1,ci==2);
cig_pref(cig_pref==0)=nan;
boxplot(cig_pref,'PlotStyle','compact')
ylabel([groups{2} ' pref ratings'])
xlabel('cig images')
title([groups{2} ' (n=' num2str(size(cig_pref,1)) ') pref ratings for cig images'])
print(gcf,'-dpng','-r300',fullfile(outDir,'patient cig pref ratings boxplot'))

zscore(nanmean(cig_pref))
fprintf('\nnumber of cig images with outlier pref scores in patients: %d\n',numel(find(abs(zscore(nanmean(cig_pref)))>3==1)))


% PA ratings
fig=setupFig
cig_pa = pa(gi==1,ci==2);
cig_pa(cig_pa==0)=nan;
boxplot(cig_pref,'PlotStyle','compact')
ylabel([groups{2} ' PA ratings'])
xlabel('cig images')
title([groups{2} ' (n=' num2str(size(cig_pref,1)) ') PA ratings for cig images'])
print(gcf,'-dpng','-r300',fullfile(outDir,'patient cig PA ratings boxplot'))

zscore(nanmean(cig_pa))
fprintf('\nnumber of cig images with outlier pref scores in patients: %d\n',numel(find(abs(zscore(nanmean(cig_pref)))>3==1)))






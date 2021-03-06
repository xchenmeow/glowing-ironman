
% this script predicts the afternoon trend by finding the most similar 
% morning trend in the history 


%%
% set 20 points to present the whole day trend
clear; clc;

% should change the way of loading data
load('highfreqdata.mat');
price = Data(:,2);
datenum = Data(:,1);
price = price(692:end);
datenum = datenum(692:end);
m = 239;
[n,~] = size(price);
for i = 1:n
    try
        price{i} = price{i}(1:m,4);
    catch exceptions
        price{i} = [];
        datenum{i} = [];
    end
end
close = cell2mat(price');
close = close';

k = 10;
%%%%%%%%%%%%%%%%%%
closeflag = 0;
% 0 set trend without the previous close
% 1 set trend with the previous close
%%%%%%%%%%%%%%%%%%
if closeflag == 0
    trend = SetTrend(k, close); 
elseif closeflag == 1
    trend = SetTrendwithClose(k, close, close(:,end)); 
else
    fprintf('closeflag can only take 0 or 1');
end

%%
% finding the most similar trend
samplesize = 1000;
trainingsample = trend(:,1:k+closeflag);
regsample = Reg(trainingsample);

trenddist = zeros(size(trainingsample,1) - samplesize,1);
idx = zeros(size(trainingsample,1) - samplesize,1);
for i = 1:size(trainingsample,1) - samplesize
    [trenddist(i), idx(i)] = min(pdist2(regsample(1:samplesize+i-1,:),...
        regsample(samplesize+i,:)));
end



%%
% backtesting...
testingsample = trend(:,k+1+closeflag:end);
error = zeros(length(idx),1);
for i = 1:length(idx)
    error(i) = pdist2(testingsample(idx(i),:), testingsample(samplesize+i,:));
end

%%

% uncomment the following codes to see the accuracy of this model
% press Ctrl C to stop this program.

% for testind = 100:length(error)
%     clf
%     subplot(2,1,1);
%     hold on
%     plot(1:k+1,trainingsample(idx(testind),:),'r');
%     plot(k+2:2*k+2,testingsample(idx(testind),:),'b');
%     xlabel(datenum(idx(testind)));
%     hold off
%     subplot(2,1,2);
%     hold on
%     plot(1:k+1,trainingsample(samplesize+testind,:),'r');
%     plot(k+2:2*k+2,testingsample(samplesize+testind,:),'b');
%     xlabel(datenum(samplesize+testind));
%     hold off
%     
%     % Pause
%     fprintf('Program paused. Press enter to continue.\n');
%     pause;
%     
%     fprintf('the predicting distance is %d. \n', error(testind));    
% 
% end

%%
% predicting...

% load today's morning data
% should change the way of loading data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
todaydata = xlsread('nov27highfreq.xlsx');
previousclose = 1.63;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if closeflag == 0
    datatoday = SetTrend(k/2, todaydata(:,4)'); 
elseif closeflag == 1
    datatoday = SetTrendwithClose(k/2, todaydata(:,4)', previousclose);
end
regtoday = Reg(datatoday);
[trenddisttoday, idxtoday] = min(pdist2(regsample(1:end-1,:),regtoday));
minsample = min(trainingsample(idxtoday,:));
maxsample = max(trainingsample(idxtoday,:));
regtestsample = (testingsample(idxtoday,:)-minsample)/(maxsample-minsample);
predictingtrend = regtestsample * (max(datatoday)-min(datatoday)) ...
    + min(datatoday);


% plot the prediction
subplot(2,1,1);
hold on
plot(1:k+closeflag,trainingsample(idxtoday,:),'r');
plot(k+closeflag:2*k+2*closeflag,[trainingsample(idxtoday,end),testingsample(idxtoday,:)],'b');
xlabel(datenum(idxtoday));
hold off

subplot(2,1,2);
hold on
plot(1:k+closeflag,datatoday,'r');
plot(k+closeflag:2*k+2*closeflag,[datatoday(end), predictingtrend], 'b--');
xlabel(date);
hold off



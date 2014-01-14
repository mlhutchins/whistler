%% Load new whistlers.txt file

	fid = fopen('whistlers.txt','r');
	newTimes = fscanf(fid,'%g/%g/%g %g:%g:%g, D = %g',[7 Inf]);

	newTimes = unique(newTimes','rows');

	newDates = datenum(newTimes(:,1:6));
	
%% Load old trigger times

	trainingDir = 'training/';

	% File with whistler locations and labels
	trainingFile = sprintf('%striggerTypes.txt',trainingDir);

	% Load training ist file
	fid = fopen(trainingFile,'r');
	trainingList = fscanf(fid,'%g/%g/%g, %g:%g:%g, %g, %g, %g',[9 Inf]);
	trainingList = trainingList';
	
	trainingList(:,6:7) = trainingList(:,8:9);
	
	trainingList(:,8:end) = [];
	
	origDates = datenum(trainingList(:,1:6));
	
	
	origLabels = trainingList(:,7);
	
	origDates = origDates(origLabels > 0);
	origLabels = origLabels(origLabels > 0);
	
%% Get positive triggers in original present in new

	match = zeros(length(origDates),1);

	for i = 1 : length(origDates);
		
		dateDiff = abs(newDates - origDates(i));
		
		closest = find(dateDiff == min(dateDiff));
		
		match(i) = closest(1);
		
	end
	
%% Histogram the difference in best match

	dateDiff = origDates - newDates(match);
	timeDiff = dateDiff * 24 * 3600;

	hist(timeDiff(origLabels > 0),[-10 : 0.1 : 10])
	
	xlim([-11 11])
	
	FN = sum(abs(timeDiff) > 2) / length(timeDiff);
	
%% Get positive triggers in new present closest match in orig

	reverseMatch = zeros(length(newDates),1);
	matchDiff = reverseMatch;
	
	for i = 1 : length(newDates);
		
		dateDiff = abs(newDates(i) - origDates);
		
		closest = find(dateDiff == min(dateDiff));
		
		reverseMatch(i) = closest(1);
		
		matchDiff(i) = origDates(reverseMatch(i)) - newDates(i);
		
	end
	
%% Histogram the difference in best match

	dateDiff = matchDiff;
	timeDiff = dateDiff * 24 * 3600;

	hist(timeDiff,[-10 : 0.1 : 10])
	
	xlim([-11 11])
	
	FP = sum(abs(timeDiff) > 2) / length(timeDiff);

%% Get false positives to add to training

	falsePositives = abs(timeDiff) > 10;

	falseTriggers = newTimes(falsePositives,1:6);
	
	fid = fopen('training/falseTriggers.txt','wt');
	
	fprintf(fid,'%04g/%02g/%02g %02g:%02g:%.1f\n',falseTriggers');
	
	
	
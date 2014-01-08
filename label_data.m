%UNTITLED6 Summary of this function goes here
%   Detailed explanation goes here

	load trainingData
	
	trainingDir = 'training/';

	triggerFile = sprintf('%snewTraining.txt',trainingDir);

	fid = fopen(triggerFile,'r');
	trainingList = fscanf(fid,'%g/%g/%g, %g:%g:%g, %g, %g',[8 Inf]);
	trainingList = trainingList';

	trigger = trainingList(:,8);
	
	images = images(labels,:,:);
	
	[samples, nWidth] = format_data(images);
	
	newType = nan(size(images,1),1);
	
	startTime = tic;
	lastTime = tic;
	
	try
		load('new_type_data_temp')
	end
	
	
	
	%% Plot "types"
	
	whistlerTypes = [1 2 3 5 17 31];
	
	figure
	
	for j = 1 : length(whistlerTypes)
	
		subplot(3,3,j)
	
		i = whistlerTypes(j);
		sample = samples(i,:);
		
		newImage = reshape(sample,numel(sample)/nWidth,nWidth);
		
		time = linspace(trigger(i) - 0.5, trigger(i) + 1,nWidth);
		freq = linspace(1000,10000,size(newImage,2));
		
		imagesc(time,freq,newImage)
		
		hold on
		plot([trigger(i),trigger(i)],[100,10000] - 1,'Color','k','LineWidth',1)
		hold off
		
		set(gca,'YDir','normal');
		daspect([1 3e4 1])
		set(gcf,'Position',[0 000 1440 600])
		set(gca,'XTick',[]);
		set(gca,'YTick',[]);
			
		title(j)
	
	end
	
	
	%%
	
	figure
	startIndex = find(isnan(newType),1,'first');

	%for i = startIndex : length(newType);
			
	for i = update';
		
		if trigger(i) == -1
			continue
		end
		
		sample = samples(i,:);
		
		newImage = reshape(sample,numel(sample)/nWidth,nWidth);
		
		time = linspace(trigger(i) - 0.5, trigger(i) + 1,nWidth);
		freq = linspace(1000,10000,size(newImage,2));
		
		imagesc(time,freq,newImage)
		
		hold on
		plot([trigger(i),trigger(i)],[100,100000],'Color','k','LineWidth',2)
		hold off
		
		set(gca,'YDir','normal');
		daspect([1 5e4 1])
		set(gcf,'Position',[0 600 1440 200])
		set(gca,'XTick',[0:0.1:60]);
		
		set(gca,'TickDir','Out')
		
		while true
		
			try
				newNewLabel(i) = input(sprintf('%g Sferic Time: ',i));
				break;
			catch
				fprintf('Incorrect input\n')
			end
		end
		
		if rem(i,100) == 1
			
			fprintf('Current Rate: %.2f sec/sample\n',toc(lastTime)/100);
			save('new_type_data_temp','newType','trainingList')
			lastTime = tic;
		end
			
	end

	save('new_type_data2','newType','trainingList')
	


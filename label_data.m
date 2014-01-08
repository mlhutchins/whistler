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
	
	newType = zeros(size(images,1),1);
	
	startTime = tic;
	lastTime = tic;
	
	try
		load('new_label_data_temp')
	end
	
	
	startIndex = find(newType == 0,1,'first');
	
	%%
	
	figure

	for i = startIndex : length(newType);
				
		if trigger(i) == -1
			continue
		end
		
		sample = samples(i,:);
		
		newImage = reshape(sample,numel(sample)/nWidth,nWidth);
		
		time = linspace(trigger(i) - 0.1, trigger(i) + 1.9,nWidth);
		freq = linspace(1000,10000,size(newImage,2));
		
		imagesc(time,freq,newImage)
		
		set(gca,'YDir','normal');
		daspect([1 5e4 1])
		set(gcf,'Position',[0 600 1440 200])
		set(gca,'XTick',[0:0.1:60]);
		
		set(gca,'TickDir','Out')
		
		while true
		
			try
				newType(i) = input(sprintf('%g Sferic Type: ',i));
				break;
			catch
				fprintf('Incorrect input\n')
			end
		end
		
		if rem(i,100) == 1
			
			fprintf('Current Rate: %.2f sec/sample\n',toc(lastTime)/100);
			save('new_label_data_temp','newLabel','trainingList')
			lastTime = tic;
		end
			
	end

	save('new_label_data3','newType','trainingList')
	


function  nn_figures()
%NN_FIGURES generates figures for the discussion paper of the whistler
%detector
%
%	Written by: Michael Hutchins

%%

	addpath('subfunctions/');

%% Get git hash

	hash = git_hash;
	hash = hash(1:7);	
	
%% Output directory

	figurePath = '~/Documents/ESS/Whistler/matlabImages/';
	dataPath = '/Volumes/Kronos/Data/projectFiles/whistler/data/';
	
%% Load Data

	images = [];
	labels = [];
		
	loadHash = '5de02f9';
	dataFile = sprintf('%strainingData_%s.mat',dataPath, loadHash);

	if file_check(dataFile)
		
		load(dataFile);
		
	else
		
		[ images, labels ] = load_data;
				
		dataFile = sprintf('trainingData_%s.mat',hash);

		save(dataFile,'-v7.3');
		
	end
	
%% Whistler Types

	% Set frequency based on best fit neural network
	freqThreshold = [1 6.5];

	% Get list of total whistler labels
	types = unique(labels(:));

	for i = 1 : length(types);
		
		% Extract the first matching label
		example = find(labels == types(i),1);
		
		% Pull spectra from image list
		spectra = squeeze(images(example,:,:));
		
		% Limit the frequency
		frequency = linspace(1000,10000,size(spectra,2));
	
		spectra = spectra(:,frequency > freqThreshold(1) * 1000 & frequency < freqThreshold(2) * 1000,:);

		% Set frequency base for plotting
		freqBase = linspace(freqThreshold(1), freqThreshold(2), size(spectra,2));
	
		% Set time base for plotting, using time from start of image
		timeBase = linspace(0, 1.25, size(spectra,1));

		% Normalize spectra spectra
		maxPower = 0;
		minPower = -40;

		spectra(spectra < minPower) = minPower;
		spectra(spectra > maxPower) = maxPower;
		
		% Create starting figure		
		figure
		
		imagesc(timeBase,freqBase,spectra);
		
		% Set title, axis, and labels
		title(sprintf('Type %g',types(i)));
		
		set(gca,'YDir','Normal');
		set(gca,'TickDir','out');
		
		xlabel('Time (s)');
		ylabel('Frequency (Hz)');
		set(gca,'XTick',[0:.2:2],'YTick',[0:10]);
		
		% Set and format colormap
		colormap(colorbrewer('red',8));
		
		c = colorbar('location','SouthOutside');
		caxis([-40 0])
		
		% Create colorbar
		xlabel(c,'Bounded spectral power');
		set(c,'XTick',[-40:5:0]);
		
		% Aspect ratio
		daspect([1 3 1])
		
		% Save figure
		saveName = sprintf('whistler_type_%g',types(i));
		figSave(figurePath,saveName,hash);
	
			
		
	end
	
	
%% Threshold Figure

	% Base off the type-2 whistler
	
		i = find(types == 2);
	
		% Extract the first matching label
		example = find(labels == types(i),1);
		
		% Pull spectra from image list
		spectra = squeeze(images(example,:,:));
		
		% Limit the frequency
		frequency = linspace(1000,10000,size(spectra,2));
	
		spectra = spectra(:,frequency > freqThreshold(1) * 1000 & frequency < freqThreshold(2) * 1000,:);

		% Set frequency base for plotting
		freqBase = linspace(freqThreshold(1), freqThreshold(2), size(spectra,2));
	
		% Set time base for plotting, using time from start of image
		timeBase = linspace(0, 1.25, size(spectra,1));

		% Normalize spectra spectra
		maxPower = 0;
		minPower = -40;

		spectra(spectra < minPower) = minPower;
		spectra(spectra > maxPower) = maxPower;
		
		% Threshold
		spectra = spectra > prctile(spectra(:),45);

		
		% Create starting figure		
		figure
		
		imagesc(timeBase,freqBase,spectra);
		
		% Set title, axis, and labels
		title(sprintf('Type %g',types(i)));
		
		set(gca,'YDir','Normal');
		set(gca,'TickDir','out');
		
		xlabel('Time (s)');
		ylabel('Frequency (Hz)');
		set(gca,'XTick',[0:.2:2],'YTick',[0:10]);
		
		% Set and format colormap
		colormap(flipud(gray(2)))
		
		caxis([0 1])
		
		% Create colorbar
		xlabel(c,'Bounded spectral power');
		set(c,'XTick',[-40:5:0]);
		
		% Aspect ratio
		daspect([1 3 1])
		
		% Save figure
		saveName = sprintf('whistler_type_%g_threshold',types(i));
		figSave(figurePath,saveName,hash);
	
end


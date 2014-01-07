function [Theta] = whistler_network_training
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

%% Load Data

%% Set whether to re-import the wideband data

	addpath('subfunctions/');

	importData = true;
	dataFile = 'trainingData_Norm.mat';

	if importData

	%% Get training dataset file information

		fprintf('Gathering file lists\n');

		trainingDir = 'training/';
		widebandDir = 'wideband/';

		triggerFile = sprintf('%strigger.txt',trainingDir);

		fid = fopen(triggerFile,'r');
		trainingList = fscanf(fid,'%g/%g/%g, %g:%g:%g, %g',[7 Inf]);
		trainingList = trainingList';

		triggersPos = trainingList(:,7);
		triggersNeg = [triggersPos - 5; triggersPos + 5];

		triggers = [triggersPos; triggersNeg];
		labels = [true(length(triggersPos),1); false(length(triggersNeg),1)];

		% Double for negative examples
		trainingList = [trainingList; trainingList];

		files = cell(size(trainingList,1),1);

		for i = 1 : size(trainingList,1);
			files{i} = sprintf('WB%04g%02g%02g%02g%02g00.dat',trainingList(i,1:5));
		end


	%% List all files to be downloaded from server (if needed)

		fid = fopen('download.sh','w+');

		fprintf(fid,'DIR=''/wd1/forks/wideband''\n');
		fprintf(fid,'scp ');

		oldName = '';

		for i = 1 : length(files)
			newName = sprintf('${DIR}/WB%04g%02g%02g/%s ',trainingList(i,1:3),files{i});

			if ~strcmp(newName,oldName)
				fprintf(fid,newName);
			end

			oldName = newName;
		end

		fprintf(fid,'mlhutch@flash5.ess.washington.edu:widebandTemp/');

	%% Import and unwrap spectra

		fprintf('Importing %s data from %s\n',triggerFile,widebandDir);

		% Import the first to get file sizes

		i = 1;

		fileName = sprintf('%s%s',widebandDir,files{i});

		spectraSize = get_spectra(fileName, triggers(i));

		n = length(spectraSize(:));
		nWidth = size(spectraSize,2);
		nFiles = length(files);

		samples = zeros(nFiles, n);

		% Import the wideband files

		parfor i = 1 : nFiles

			fileName = sprintf('%s%s',widebandDir,files{i});

			% Import wideband file

			spectra = get_spectra(fileName, triggers(i));

			% Unwrap
			spectra = spectra(:);

			samples(i,:) = spectra';

		end

		% Show first 24 whistlers
		display_data(samples(1:24,:),nWidth);

		data.samples = samples;
		data.labels = labels;
		data.nFiles = nFiles;

		save(dataFile,'data','-v7.3');
	
	else

		load(dataFile);
		
	end


%% Format Neural Network

	neuralNetwork = neural_network_init();

%% Train Neural Network

	[Theta, statistics] = neural_network_training(data,neuralNetwork);

%% Report Statistics


%% Save Parameters

	save('whistlerNeuralNet','Theta', 'statistics');
	
	fprintf('Saving parameters\n');

end


function spectra = get_spectra(fileName, trigger)

	[~, eField, Fs] = wideband_import(fileName);
	
	[timeBase,freqBase,power] = wideband_fft(eField,Fs);
	
	spectra = whistler_spectra( timeBase, freqBase, power, trigger );

end
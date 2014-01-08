function [ images, labels ] = load_data
%LOAD_DATA loads whistler wideband data into an array images
%
%	Written by: Michael Hutchins

%% Get training dataset file information

	fprintf('Gathering file lists\n');

	% Subdirectories
	trainingDir = 'training/';
	widebandDir = 'wideband/';

	% File with whistler locations and labels
	trainingFile = sprintf('%striggerTypes.txt',trainingDir);

	% Load training ist file
	fid = fopen(trainingFile,'r');
	trainingList = fscanf(fid,'%g/%g/%g, %g:%g:%g, %g, %g, %g',[9 Inf]);
	trainingList = trainingList';

	% Remove "bad" whistlers
	trainingList(trainingList(:,8) == -1,:) = [];
	
	% Get positive trigger times
	triggersPos = trainingList(:,8);
	
	% Set +-5 seconds as negative examples
	triggersNeg = [triggersPos - 5; triggersPos + 5];

	% Create single trigger list
	triggers = [triggersPos; triggersNeg];
	
	% Get labels for positives and set remaining to 0
	labels = [trainingList(:,9); zeros(length(triggersNeg),1)];

	% Triple training list for negative examples
	trainingList = [trainingList(:,1:5);...
					trainingList(:,1:5);...
					trainingList(:,1:5)];

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

%% Import spectra

	fprintf('Importing %s data from %s\n',trainingFile,widebandDir);

	% Import the first to get file sizes

	i = 1;

	fileName = sprintf('%s%s',widebandDir,files{i});

	[spectraSize] = get_spectra(fileName, triggers(i));

	n = size(spectraSize);
	nFiles = length(files);

	images = zeros(nFiles, n(1), n(2));

	% Import the wideband files

	parfor i = 1 : nFiles

		fileName = sprintf('%s%s',widebandDir,files{i});

		% Import wideband file

		spectra = get_spectra(fileName, triggers(i));

		images(i,:,:) = spectra;

	end


end


function [spectra] = get_spectra(fileName, trigger)

	[~, eField, Fs] = wideband_import(fileName);
	
	[timeBase,freqBase,power] = wideband_fft(eField,Fs);
	
	spectra = whistler_spectra( timeBase, freqBase, power, trigger );

end

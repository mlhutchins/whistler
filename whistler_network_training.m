function [Theta] = whistler_network_training
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

%%

	addpath('subfunctions/');


%% Load Data

	importData = false;
	dataFile = 'trainingData.mat';

	if importData
		
		[ images, labels, nFiles ] = load_data;
				
		save(dataFile,'-v7.3');

	else

		load(dataFile);
		
	end
	
%% Set whether to re-import the wideband data

	[samples, nWidth] = format_data(images);

	% Show first 24 whistlers
	display_data(samples(1:24,:),nWidth);

	data.samples = samples;
	data.labels = labels;
	data.nFiles = nFiles;

%% Format Neural Network

	neuralNetwork = neural_network_init();

%% Train Neural Network

	[Theta, statistics] = neural_network_training(data,neuralNetwork);

%% Report Statistics

	% Visualize weights
	ThetaPrime = Theta{1};
	display_data(ThetaPrime(1:24, 2:end),nWidth);

%% Save Parameters

	save('whistlerNeuralNet','Theta', 'statistics');
	
	fprintf('Saving parameters\n');

end


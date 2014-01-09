function [Theta] = whistler_network_training
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

%%

	addpath('subfunctions/');


%% Load Data

	importData = false;
	dataFile = 'trainingData.mat';

	if importData
		
		[ images, labels ] = load_data;
				
		save(dataFile,'-v7.3');

	else

		images = [];
		labels = [];
		
		load(dataFile);
		
	end
	
%% Remove NaN entries

	badEntry = sum(sum(isnan(images),3),2) > 0 | sum(sum(isinf(images),3),2) > 0 |...
			   sum(isnan(labels)) > 0 | sum(isnan(labels)) > 0 ;
		   
	images(badEntry,:,:) = [];
	labels(badEntry) = [];
	
%% Set whether to re-import the wideband data

	[samples, nWidth] = format_data(images);

	% Show first 24 whistlers
	display_data(samples(1:24,:),nWidth);

%% Format Neural Network

	neuralNetwork = neural_network_init();
	% hiddenLayerSize, lambda, maxIter

%% Train Neural Network

	[Theta, statistics, cost] = neural_network_training(samples,labels,neuralNetwork);

%% Report Statistics

	% Visualize weights
	ThetaPrime = Theta{1};
	display_data(ThetaPrime(1:24, 2:end),nWidth);

	figure
	plot(cost)
	ylabel('Cost')
	xlabel('Iterations')
	
%% Save Parameters

	save('whistlerNeuralNet','Theta', 'statistics');
	
	fprintf('Saving parameters\n');

end


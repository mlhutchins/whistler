function [Theta] = whistler_network_training
%WHISTLER_NETWORK_TRAINING trains the whistler search neural network
%	and saves the results fo whistlerNeuralNet.mat
%
%	Written by: Michael Hutchins

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
	
%% Train and cross validate the neural network

	[ Theta, statistics, cost, validation ] = whistler_cross_validate( images, labels );

%% Report Statistics

	% Visualize weights
	ThetaPrime = Theta{1};
	display_data(ThetaPrime(1:24, 2:end),size(images,3));

	figure
	plot(cost)
	ylabel('Cost')
	xlabel('Iterations')
	
%% Save Parameters

	save('whistlerNeuralNet','Theta', 'statistics','cost','validation');
	
	fprintf('Saving parameters\n');

end


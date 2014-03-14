function [Theta] = whistler_network_training
%WHISTLER_NETWORK_TRAINING trains the whistler search neural network
%	and saves the results fo whistlerNeuralNet.mat
%
%	Written by: Michael Hutchins

%%

	addpath('subfunctions/');

%% Get git hash

	hash = git_hash;
	hash = hash(1:7);	
	
	
%% Parallel start

	if parallel_check
		parallel_start;
	end

%% Load Data

	images = [];
	labels = [];
	
	loadHash = '';	
	
	dataFile = sprintf('data/trainingData_%s.mat',loadHash);

	if file_check(dataFile)
		
		load(dataFile);
		
	else
		
		[ images, labels ] = load_data;
				
		dataFile = sprintf('trainingData_%s.mat',hash);

		save(dataFile,'-v7.3');
		
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


function [ Theta, statistics, cost, cvStatistics ] = whistler_cross_validate( images, labels )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here


%% Set random seed
	
	fprintf('Setting Random Seed\n');

	rng(1);

%% Split into training / CV / test
	
	fprintf('Selecting Training Set\n');

	[ splitLabels ] = sample_split( length(labels), [0.8 0.1 0.1] );

	train = splitLabels == 1; %Train with 80% of the data
	
	cv = splitLabels == 2; % Index of values for cross validation (10%)
	
	test = splitLabels == 3; %Test with last 10% of the data
	
%% Cross validate parameters
	
	fprintf('Cross Validating\n');
	
	% Cross validate over lambda, network shape / size (init)
	%					  threshold, frequency range, min/max (format)
	%		
	i = 1;
	j = 1;
	k = 1;
	cvStatistics = cell(i,j,k);
	
%% Adjust data format

	[samples, nWidth] = format_data(images);

%% Adjust and Initialize Neural Network

	neuralNetwork = neural_network_init();
	% hiddenLayerSize, lambda, maxIter

%% Train Initial Neural Network

	[Theta, statistics, cost] = neural_network_training(samples(train,:),labels(train,:),neuralNetwork);
	
%% Get cross validation statistics

	cvPred = predict(Theta, samples(cv,:)) - 1;
	cvTrue = labels(cv);
	
	[accuracy, precision, sensitivity, specificity] = net_stats(cvPred, cvTrue);
	
	cvStatistics{i,j,k} = [accuracy, precision, sensitivity, specificity];

%% Get best performance

	% Code here to select best
	
	iBest = 1;
	jBest = 1;
	kBest = 1;
	
%% Report test results for best CV data
	
	% Format to best
	[samples, nWidth] = format_data(images);

	% Show first 24 whistlers
	display_data(samples(1:24,:),nWidth);
	
	% Initialize Neural Network to best
	neuralNetwork = neural_network_init();

	% Train
	[Theta, statistics, cost] = neural_network_training(samples(train,:),labels(train,:),neuralNetwork);

	fprintf('Starting test results\n');

	testPred = predict(Theta, samples(test,:)) - 1;
	testTrue = labels(test);
	
	[accuracy, precision, sensitivity, specificity] = net_stats(testPred, testTrue);
	
	fprintf('Test set accuracy: %.1f%%\n',accuracy * 100);
	fprintf('Test set precision: %.1f%%\n',precision * 100);
	fprintf('Test set sensitivity: %.1f%%\n',sensitivity * 100);
	fprintf('Test set specificity: %.1f%%\n',specificity * 100);

	statistics{1} = accuracy;
	statistics{2} = precision;
	statistics{3} = sensitivity;
	statistics{4} = specificity;

end


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
	%					  threshold, frequency range (format)
	%		
	
	% Lamdba (regularization values)
	
	lambda = {0, 0.03, 0.1, 0.3, 1, 3};
	networkShape = {[25],...
					[100, 25],...
					[100, 50, 25],...
					[200, 50],...
					[200, 75, 25],...
					[400],...
					[400, 200, 50]};
				
	threshold = {55, 65, 76, 85, 95};
	
	frequency = {[4 4.5],...
				 [3 4.5],...
				 [4 5.5],...
				 [2 6.5],...
				 [1 8],...
				 [1 10]};
	
	% Permute into parameter cell array
	cvParameters = cell(length(lambda) * length(networkShape) *...
						length(threshold) * length(frequency),5);
	index = 1;
	for i = 1 : length(lambda)
		for j = 1 : length(networkShape)
			for k = 1 : length(threshold)
				for n = 1 : length(frequency)
					cvParameters(index,1) = lambda(i);
					cvParameters(index,2) = networkShape(j);
					cvParameters(index,3) = threshold(k);
					cvParameters(index,4) = frequency(n);
					index = index + 1;
				end
			end
		end
	end
	
	cvStatistics = cell(size(cvParameters,1),1);
	
%% Loop through parameters

	if parallel_check
		parallel_start
	end
	
	parfor i = 1 : size(cvStatistics,1)
		
		%% Extract parameters
		
		lambda = cvParameters{i,1};
		networkShape = cvParameters{i,2};
		threshold = cvParameters{i,3};
		frequency = cvParameters{i,4};
		

		%% Adjust data format

		[samples, nWidth] = format_data( images, threshold, frequency );

		%% Adjust and Initialize Neural Network

		neuralNetwork = neural_network_init(networkShape,lambda);
		% hiddenLayerSize, lambda, maxIter

		%% Train Initial Neural Network

		[Theta, ~, ~] = neural_network_training(samples(train,:),labels(train,:),neuralNetwork);

		%% Get cross validation statistics

		cvPred = predict(Theta, samples(cv,:)) - 1;
		cvTrue = labels(cv);

		[accuracy, precision, sensitivity, specificity] = net_stats(cvPred, cvTrue);

		cvStatistics{i} = [accuracy, precision, sensitivity, specificity];

	end
	
	cvStatistics(:,2:5) = cvParameters;
	
	save('cvDebug','-v7.3');
	
%% Get best performance

	% Code here to select best
	
	iBest = 1;
	jBest = 1;
	kBest = 1;
	nBest = 1;
	
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


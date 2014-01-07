function [Theta, statistics] = neural_network_training(data,neuralNetwork)
%NEURAL_NETWORK_TRAINING(data, neuralNetwork) trains the neuralNetwork with
%	the data loaded into sampels with cross-validation and statistics testing
%
%	Written by: Michael Hutchins

%% Exract sample data

	samples = data.samples;
	labels = data.labels;
	nFiles = data.nFiles;

%% Set random seed
	
	fprintf('Setting Random Seed\n');

	rng(1);
	
%% Split into traing / CV / test
	
	fprintf('Selecting Training Set\n');

	train = randsample(nFiles,round(0.8 * nFiles)); %Train with 80% of the data
	X = samples(train,:);
	y = labels(train,:);
	
	remaining = 1 : nFiles;
	remaining(train) = [];
	
	sampling = randsample(length(remaining), floor(length(remaining) / 2));
	cv = remaining(sampling); % Index of values for cross validation (10%)
	
	remaining(sampling) = [];
	test = remaining; %Test with last 10% of the data

	
%% Initialize variables and parameters

	fprintf('Initializing Neural Network\n');

	lambda = neuralNetwork.lambda; % Initial Regularization parameter
	inputLayerSize = size(X,2);

	hiddenLayerSize = neuralNetwork.hiddenLayerSize;

	nLabels = length(unique(labels));
	
	% Random initialize neural network weights
	
	initialParams = rand_initialize_weights(inputLayerSize, hiddenLayerSize,nLabels);

%% Train neural network
	
	fprintf('Training Neural Network\n');

	% Optimization code options
	options = optimset('MaxIter', neuralNetwork.maxIter);

	% Create "short hand" for the cost function to be minimized
	costFunction = @(p) nn_cost(p, ...
						   inputLayerSize, ...
						   hiddenLayerSize, ...
						   nLabels, X, y, lambda);
	
	% Now, costFunction is a function that takes in only one argument (the
	% neural network parameters)
	[nnParams, cost] = fmincg(costFunction, initialParams, options);

	% Obtain Theta1 and Theta2 back from nnParams

	Theta = theta_unwrap(nnParams, inputLayerSize, hiddenLayerSize, nLabels);
	
	trainPred = predict_whistler(Theta, X);
	trainTrue = y;

	[accuracy, precision, sensitivity, specificity] = net_stats(trainPred, trainTrue);
	
	fprintf('Training set accuracy: %.1f%%\n',accuracy * 100);
	fprintf('Training set precision: %.1f%%\n',precision * 100);
	fprintf('Training set sensitivity: %.1f%%\n',sensitivity * 100);
	fprintf('Training set specificity: %.1f%%\n',specificity * 100);

%% Cross validate parameters
	
	fprintf('Cross Validating\n');
	
%% Pick best parameters

	cvPred = predict_whistler(Theta, samples(cv,:));
	cvTrue = labels(cv);
	
	[accuracy, precision, sensitivity, specificity] = net_stats(cvPred, cvTrue);
	
	fprintf('Cross Validation set accuracy: %.1f%%\n',accuracy * 100);
	fprintf('Cross Validation set precision: %.1f%%\n',precision * 100);
	fprintf('Cross Validation set sensitivity: %.1f%%\n',sensitivity * 100);
	fprintf('Cross Validation set specificity: %.1f%%\n',specificity * 100);
	
%% Report test results
	
	fprintf('Starting test\n');

	testPred = predict_whistler(Theta, samples(test,:));
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

	% Visualize weights
	ThetaPrime = Theta{1};
	display_data(ThetaPrime(1:24, 2:end),nWidth);
	
	save('neuralNetDebug','-v7.3');
	
	fprintf('Done!\n');
	
end

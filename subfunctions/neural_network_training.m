function [Theta, statistics, cost] = neural_network_training(X,y,neuralNetwork)
%NEURAL_NETWORK_TRAINING(data, neuralNetwork) trains the neuralNetwork with
%	the data loaded into samples and initialized by neural_network_init()
%
%	Written by: Michael Hutchins

%% Check for NaN inputs

	if sum(isnan(X(:))) > 0 || sum(isnan(y(:))) > 0
		error('NaN found in input\n')
	end

	if sum(isinf(X(:))) > 0 || sum(isinf(y(:))) > 0
		error('Inf found in input\n')
	end
	
	
%% Initialize variables and parameters

	lambda = neuralNetwork.lambda; % Initial Regularization parameter
	inputLayerSize = size(X,2);

	hiddenLayerSize = neuralNetwork.hiddenLayerSize;

	nLabels = length(unique(y));
	
	% Random initialize neural network weights
	
	initialParams = rand_initialize_weights(inputLayerSize, hiddenLayerSize,nLabels);

%% Train neural network
	
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
	
	trainPred = predict(Theta, X) - 1;
	trainTrue = y;

	[accuracy, precision, sensitivity, specificity] = net_stats(trainPred, trainTrue);

	statistics{1} = accuracy;
	statistics{2} = precision;
	statistics{3} = sensitivity;
	statistics{4} = specificity;
			
end

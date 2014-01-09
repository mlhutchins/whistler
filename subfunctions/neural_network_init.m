function [ neuralNetwork ] = neural_network_init( hiddenLayerSize, lambda, maxIter, split )
%NEURAL_NETWORK_INIT( hiddenLayerSize, lambda, maxIter ) initialize the 
%	neural network structure
%
%	Written by: Michael Hutchins

	defaultIter = 50;
	defaultHidden = [100, 25];
	defaultLambda = 0.5;
	defaultSplit = [0.8 0.1 0.1];

	switch nargin
		case 0
			neuralNetwork.hiddenLayerSize = defaultHidden;
			neuralNetwork.lambda = defaultLambda;
			neuralNetwork.maxIter = defaultIter;
			neuralNetwork.trainSplit = defaultSplit;
		case 1
			neuralNetwork.hiddenLayerSize = hiddenLayerSize;
			neuralNetwork.lambda = defaultLambda;
			neuralNetwork.maxIter = defaultIter;
			neuralNetwork.trainSplit = defaultSplit;
		case 2
			neuralNetwork.hiddenLayerSize = hiddenLayerSize;
			neuralNetwork.lambda = lambda;
			neuralNetwork.maxIter = defaultIter;
			neuralNetwork.trainSplit = defaultSplit;

		case 3
			neuralNetwork.hiddenLayerSize = hiddenLayerSize;
			neuralNetwork.lambda = lambda;
			neuralNetwork.maxIter = maxIter;
			neuralNetwork.trainSplit = split;
	end
	
end


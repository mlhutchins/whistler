function [ neuralNetwork ] = neural_network_init( hiddenLayerSize, lambda, maxIter )
%NEURAL_NETWORK_INIT( hiddenLayerSize, lambda, maxIter ) initialize the 
%	neural network structure
%
%	Written by: Michael Hutchins

	defaultIter = 50;
	defaultHidden = [100, 25];
	defaultLambda = 0.5;

	switch nargin
		case 0
			neuralNetwork.hiddenLayerSize = defaultHidden;
			neuralNetwork.lambda = defaultLambda;
			neuralNetwork.maxIter = defaultIter;
		case 1
			neuralNetwork.hiddenLayerSize = hiddenLayerSize;
			neuralNetwork.lambda = defaultLambda;
			neuralNetwork.maxIter = defaultIter;
		case 2
			neuralNetwork.hiddenLayerSize = hiddenLayerSize;
			neuralNetwork.lambda = lambda;
			neuralNetwork.maxIter = defaultIter;
		case 3
			neuralNetwork.hiddenLayerSize = hiddenLayerSize;
			neuralNetwork.lambda = lambda;
			neuralNetwork.maxIter = maxIter;
	end
	
end


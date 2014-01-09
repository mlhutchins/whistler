function [ probability ] = neural_network( sampleSpectra )
%NEURAL_NETWORK uses the training results of neural_network_training to return
%	the probability that IMAGE is a whistler
%
%	Written by: Michael Hutchins

	%% Load neural network parameters

	load('whistlerNeuralNet');
	
	%% Format image

	spectra = sampleSpectra(:)';
	
	%% Run neural network classification
	
	probability = predict_whistler(Theta, spectra);

end

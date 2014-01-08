function [ success ] = unit_test
% UNIT_TEST runs the neural network code with the basic OCR dataset to check
%	functionality of code
%
%	Written by: Michael Hutchins

	%% Load OCR data
	
	load ocr_data
	
	%% Format into a stack of images

	samples = reshape(X,5000,20,20);
	labels = y;
		
	clear X y
	
	%% Initialize neural network
	
	neuralNetwork = neural_network_init();
	
	%% Train neural network
	
	[Theta, statistics] = neural_network_training(samples,labels,neuralNetwork);
	
	%%
	
	success = true;
	
end


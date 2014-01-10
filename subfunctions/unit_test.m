function unit_test
% UNIT_TEST runs the neural network code with the basic OCR dataset to check
%	functionality of code
%
%	Written by: Michael Hutchins

	addpath('subfunctions/');

	%% Load OCR data
	
	load ocr_data
		
	display_data(X(randsample(size(X,1),100),:),20);

	%% Initialize neural network
	
	neuralNetwork = neural_network_init();
	
	%% Train neural network
	
	[Theta, statistics, cost] = neural_network_training(X,y,neuralNetwork);
	
	%% Display a few of the final Thetas

	ThetaPrime = Theta{1};
	display_data(ThetaPrime(1:24,2:end),20);

	figure
	plot(cost)
	xlabel('Iterations')
	ylabel('Cost')
		
end


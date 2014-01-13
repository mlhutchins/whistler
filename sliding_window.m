function [ location, spectra] = sliding_window( time, frequency, power )
%SLIDING_WINDOW(time, frequency, power) searches a spectogram POWER for 
%	whistlers using a neural network classifier and a sliding window search
%
%	Written by: Michael Hutchins

	%% Sliding window parameters
	
	stepSize = 0.2; %seconds

	windows = 0 : stepSize : 60;
	
	found = false(length(windows),1);
	
	spectra = cell(length(windows),1);
	
	%% Load neural network parameters
	
	network = load('whistlerNeuralNet');
	
	Theta = network.Theta;
	
	%% Chech each window
	
	for i = 1 : length(windows);

		%% Window data
		
		[ windowSpectra ] = whistler_spectra( time, frequency, power, windows(i) );
		
		spectra{i} = windowSpectra;
		
		%% Find local probability maxima above threshold

		[ sample, ~ ] = format_data( windowSpectra, 85, [3 4.5] );
		
		found(i) = predict(Theta, sample) - 1;

	end
	
	%% Count and locate whistlers
	
	[~, idx] = findpeaks(double(found),'minpeakdistance',2);
	
	spectra = spectra(idx);
	
	location = windows(idx);
								 
end

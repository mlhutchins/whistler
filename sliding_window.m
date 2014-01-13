function [ location, spectra, spectraBase] = sliding_window( time, frequency, power )
%SLIDING_WINDOW(time, frequency, power) searches a spectogram POWER for 
%	whistlers using a neural network classifier and a sliding window search
%
%	Written by: Michael Hutchins

	%% Sliding window parameters
	
	stepSize = 0.2; %seconds

	windows = 0 : stepSize : 60;
	
	found = false(length(windows),1);
	
	spectra = cell(length(windows),1);
	spectraBase = cell(length(windows),2);
	%% Load neural network parameters
	
	network = load('whistlerNeuralNet');
	
	Theta = network.Theta;
	
	%% Chech each window
	
	for i = 1 : length(windows);

		%% Window data
		
		[ windowSpectra, windowBase ] = whistler_spectra( time, frequency, power, windows(i) );
		
		spectra{i} = windowSpectra;
		spectraBase{i,1} = windowBase{1};
		spectraBase{i,2} = windowBase{2};

		%% Find local probability maxima above threshold

		[ sample, ~ ] = format_data( windowSpectra, 85, [3 4.5] );
		
		found(i) = predict(Theta, sample) - 1;

	end
	
	%% Count and locate whistlers
	
	[~, idx] = findpeaks(double(found),'minpeakdistance',2);
	
	spectra = spectra(idx);
	spectraBase = spectraBase(idx,:);
	
	location = windows(idx);
								 
end

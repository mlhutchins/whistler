function [ location, spectra, freqBase, timeBase ] = sliding_window( eField, Fs, cutoff )
%SLIDING_WINDOW searches a wideband file for whistlers using a neural network
%	classifier
%
%	Written by: Michael Hutchins

	%% FFT wideband data
	
	[timeBase,freqBase,power] = wideband_fft(eField,Fs);

	%% Sliding window parameters
	
	stepSize = 0.2; %seconds

	windows = 0 : stepSize : 60;
	
	probability = zeros(length(windows),1);
	
	spectra = cell(length(windows),1);
	
	%% Chech each window
	
	for i = 1 : length(windows);

		%% Check each window
		
		[ spec ] = whistler_spectra( timeBase, freqBase, power, windows(i) );

		spectra{i} = spec;
		
		%% Find local probability maxima above threshold

		probability(i) = predict_whistler(Theta1, Theta2, spec(:)');

	end
	
	%% Count and locate whistlers
	
	[location, idx] = findpeaks(probability,'minpeakheights',cutoff,...
									 'minpeakdistance',3);
	
	spectra = spectra(idx);
								 
end

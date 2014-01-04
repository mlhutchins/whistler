function [ location ] = sliding_window( eField, Fs, cutoff )
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
	
	%% Chech each window
	
	for i = 1 : length(windows);

		%% Check each window
		
		[ spectra ] = whistler_spectra( timeBase, freqBase, power, windows(i) );

		%% Find local probability maxima above threshold

		probability(i) = predict_whistler(Theta1, Theta2, spectra(:)');

	end
	
	%% Count and locate whistlers
	
	location = findpeaks(probability,'minpeakheights',cutoff,...
									 'minpeakdistance',3);
	
end

function [ timeBase, spectra ] = whistler_spectra( timeBase, freqBase, power, startTime )
%WHISTLER_SPECTRA takes the FFT of wideband data y and returns the 
%	portion of the spectra between 0 - 13 kHz as a 2D array
%
%	Written by: Michael Hutchins

%% Set start/end time buffers

	startBuffer = 0.1; %seconds
	endBuffer = 1.9; %seconds

%% Cut down in frequency and space

	spectra = power(freqBase < 13000,...
					timeBase > startTime - startBuffer &...
					timeBase < startTime + endBuffer);
				
%% Add padding as necessary

	padValue = mean(spectra(:));
	expectedSize = round((startBuffer + endBuffer) * Fs);
	actualSize = size(spectra,2);

	if actualSize < expectedSize
		
		padAmount = expectedSize - actualSize;
		
		padding = repmat(padValue,size(spectra,1),padAmount);
		
		if (timeBase(end) < (startTime + endBuffer));
		
			spectra = [padding, spectra];
		
		else 
		
			spectra = [spectra, padding];
		end
	
	end

end

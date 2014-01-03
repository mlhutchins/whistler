function neural_network_training
%NEURAL_NETWORK_TRAINING loads in training data set of whistlers and background
%	noise and gets the best fit neural network with performance analysis
%
%	Written by: Michael Hutchins

	%% Get training dataset
	
	
	%% Generate negative examples
	
	
	%% Format training set
	
	
	%% Set random seed
	
	
	%% Split into traing / CV / test
	
	
	%% Initialize variables and parameters


	%% Train neural network
	
	
	%% Cross validate parameters
	
	
	%% Pick best parameters
	
	
	%% Report test results
	
	
	%% Save parameters


end

function [ spectra ] = whistler_spectra( widebandFile, startTime )
%WHISTLER_SPECTRA takes the FFT of wideband data y and returns the 
%	portion of the spectra between 0 - 13 kHz as a 2D array
%
%	Written by: Michael Hutchins

%% Set start/end time buffers

	startBuffer = 0.1; %seconds
	endBuffer = 1.9; %seconds

%% Import wideband file

	[time, eField, Fs] = wideband_import(widebandFile);
	
%% Get spectral power density

	[timeBase,freqBase,power] = wideband_fft(eField,Fs);

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


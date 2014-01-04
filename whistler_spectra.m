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

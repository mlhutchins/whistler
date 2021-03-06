function [ spectra, spectraBase ] = whistler_spectra( timeBase, freqBase, power, startTime )
%WHISTLER_SPECTRA takes the FFT of wideband data y and returns the 
%	portion of the spectra between 1 - 10 kHz as a 2D array
%
%	Written by: Michael Hutchins

%% Set start/end time buffers

	startBuffer = 0.5; %seconds
	endBuffer = 0.75; %seconds

%% Cut down in frequency and space

	timeCut = timeBase > startTime - startBuffer &...
			  timeBase < startTime + endBuffer;
		  
	freqCut = freqBase < 10000 &...
			  freqBase > 1000;

	spectra = power(freqCut, timeCut);
	spectraBase{1} = timeBase(timeCut);
	spectraBase{2} = freqBase(freqCut);
				
%% Add padding as necessary

	padValue = mean(spectra(:));
	expectedSize = round((startBuffer + endBuffer) / (timeBase(4) - timeBase(3)));
	actualSize = size(spectra,2);

	if actualSize < expectedSize
		
		padAmount = expectedSize - actualSize;
		
		padding = repmat(padValue,size(spectra,1),padAmount);
		
		if (timeBase(end) < (startTime + endBuffer));
		
			spectra = [ spectra, padding ];
		
		else 
		
			spectra = [ padding, spectra ];
		end
		
	elseif actualSize > expectedSize
		
		spectra = spectra(:,1:expectedSize);
	
	end

end

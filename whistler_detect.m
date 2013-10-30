%% Whistler_detect.m searches for whistlers in the given wideband file
%
%	Written by: Michael Hutchins

%% Go to directory

	try
		cd('whistler');
	end
	
%% Import data

	[time, eField, Fs] = wideband_import('WB20130223140900.dat');
	
%% Get spectral power density

	[timeBase,freqBase,power] = wideband_fft(eField,Fs);

	
%% Get noise floor

	loc = freqBase < 5600 & freqBase > 3500;
	
	powerWindow = power(loc,:);
	
	noise = prctile(powerWindow(:),95);
	
%% Create binary image

	powerBinary = powerWindow > noise;
	
%% Find starting points

	startPoints = sum(powerBinary(1 : 2,:)) == 2;
	startPoints = startPoints & ~circshift(startPoints,[0,1]);
	
	startIndex = find(startPoints);
	
%% Check shape starting at each start point

	% Good indices to test: 38, 64, 78, 84

	for i = 1 : length(startIndex)
		shape = shape_extract(powerBinary,[size(powerBinary,1),startIndex(i)]);

		shapeSize(i) = sum(shape(:));
		
		% Check for whistler shape
		
		% Cut small shapes
		if sum(shape(:)) < 30
			continue
		end
		
		topRow = timeBase(sum(shape(end - 4 : end,:),1) > 0);
		bottomRow = timeBase(sum(shape(1:4,:),1) > 0);
		
		% Cut shapes where the start is not far from the end
		if mean(bottomRow) < mean(topRow) + 0.1;
			continue
		end
		
	end
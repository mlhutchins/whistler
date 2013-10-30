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

	for i = 1 : length(startIndex)
		shape = shape_extract(powerBinary,[size(powerBinary,1),startIndex(i)]);

	end
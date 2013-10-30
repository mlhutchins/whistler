%% Whistler_detect.m searches for whistlers in the given wideband file
%
%	Written by: Michael Hutchins

%% Go to directory

	try
		cd('whistler');
	end
	
%% Import data

	[time, eField, Fs] = wideband_import('WB20130223112600.dat');
	
%% Get spectral power density

	[frequency,spectra] = spectrogram(eField,time,Fs);
	

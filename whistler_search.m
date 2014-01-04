function [ times, dispersion ] = whistler_search( directory )
%WHISTLER_SEARCH processes wideband files in DIRECTORY and returns the
%	times and best fit dispersion of located whistlers
%
%	Written by: Michael Hutchins

	%% Get file list
	
	fileList = dir(directory);
	index = 1;
	
	for i = 1 : length(fileList);
		
		entry = fileList(i).name;
		
		if strcmp(entry(1:2),'WB') && strcmp(entry(end-2 : end),'dat')
			files{index} = fileList(i).name;
			index = index + 1;
		end
		
	end
	
	%% Initalize parameters
	
	
	%% Use sliding window search on each file
	
	
	%% Collate times
	
	
	%% Get best fit dispersion for each whistler
	
	
	%% Save spectrogram .png images and wideband snippets
	
	
	%% Write times and dispersions to file


end


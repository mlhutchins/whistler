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
	
	cutoff = 0.5;
	reportFile = fopen('whistlers.txt','a+');
	
	%% Process each file
	
	for i = 1 : length(files);

		%% Use sliding window search on each file

		fileName = sprintf('%s%s',directory,files{i});

		[~, eField, Fs] = wideband_import(fileName);

		[ location, spectra, fRange, tw ] = sliding_window( eField, Fs, cutoff );

		if isempty(location)
			continue
		end

		%% Print times and dispersions to file
		
		fileTime = sscanf(files{i},'WB%04g%02g%02g%02g%02g%02g.dat');
		
		for j = 1 : length(location)
				
			%% Get best fit dispersion for each whistler

			[D, time, chirp] = dispersion_check(spectra{j}, fRange, tw);
			
			%% Save spectrogram .png images and wideband snippets

			whistler_image(spectra{j}, chirp, D, time, fileTime, location(j));
			
			%% Write times and dispersions to file
			
			fprintf(reportFile, '%04g/%02g/%02g %02g:%02g:%02g, D = %.2f\n',...
					 fileTime(1:5), location(j), D);
				 
		end

	end

	fclose(reportFile)
	
end

function whistler_image(spectrogram, chirp, D, time, fileTime, location(j));
%WHISTLER_IMAGE Creates a .png file with the whistler spectra and
%	dechirped spectra


end
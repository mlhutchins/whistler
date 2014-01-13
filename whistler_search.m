function whistler_search( directory )
%WHISTLER_SEARCH processes wideband files in DIRECTORY and returns the
%	times and best fit dispersion of located whistlers
%
%	Written by: Michael Hutchins

	%% Format input
	
	if ~strcmp(directory(end),'/');
		directory = sprintf('%s/',directory);
	end

	%% Get file list
	
	fileList = dir(directory);
	index = 1;
	files{length(fileList),1} = [];
	
	for i = 1 : length(fileList);
		
		entry = fileList(i).name;
		
		if length(entry) < 10
			continue
		end
		
		if strcmp(entry(1:2),'WB') && strcmp(entry(end-2 : end),'dat')
			files{index} = fileList(i).name;
			index = index + 1;
		end
		
	end
	
	files = files(1 : index - 1);
	
	%% Initalize parameters
	
	reportFile = fopen('whistlers.txt','a+');
	
	%% Process each file
	
	for i = 1 : length(files);

		%% Import and FFT wideband file

		fileName = sprintf('%s%s',directory,files{i});
		
		[~, eField, Fs] = wideband_import(fileName);

		[ time, frequency, power ] = wideband_fft( eField, Fs );
		
		%% Sliding window search for whistlers
		
		[ location, spectra ] = sliding_window( time, frequency, power );

		if isempty(location)
			continue
		end

		%% Process each whistler
		
		% Get start date/time of file
		
		fileTime = sscanf(files{i},'WB%04g%02g%02g%02g%02g%02g.dat');
		
		for j = 1 : length(location)
				
			%% Get best fit dispersion for each whistler

			[D, ~, chirp] = dispersion_check(spectra{j}, fRange, tw);
			
			%% Save spectrogram .png images and wideband snippets

			whistler_image(spectra{j}, chirp, D, fRange, tw, fileTime, location(j));
			
			%% Write times and dispersions to file and console
			
			dispersionText = sprintf('%04g/%02g/%02g %02g:%02g:%02g, D = %.2f\n',...
					 fileTime(1:5), location(j), D);
			
			fprintf(reportFile, dispersionText);
			fprintf(dispersionText);
				 
		end

	end

	fclose(reportFile);
	
end

function whistler_image(spectrogram, chirp, D, fileTime, location, directory)
%WHISTLER_IMAGE Creates a .png file with the whistler spectra and
%	dechirped spectra

	titleText = sprintf('%04g/%02g/%02g %02g:%02g:%02g, D = %.2f\n',...
					 fileTime(1:5), location, D);
				 
	figure
	subplot(1,2,1)
	imagesc(spectrogram)
	title(titleText);
	
	subplot(1,2,2)
	imagesc(chirp)
	
	fileName = sprintf('%swhistler%04g%02g%02g%02g%02g%02g_%02g.png',...
						directory, fileTime, floor(location));
					
	saveas(gcf,fileName,'-dpng');

end
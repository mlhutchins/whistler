function whistler_search( inputDirectory, outputDirectory )
%WHISTLER_SEARCH(inputDirectory, outputDirectory) processes wideband files
%	in INPUTDIRECTORY and returns the times and best fit dispersion of located whistlers
%	in whistlers.txt and as .png images in OUTPUTDIRECTORY
%
%	Written by: Michael Hutchins

	%% Check number of inputs
	
	switch nargin
		case 0
			inputDirectory = '';
			outputDirectory = '';
		case 1
			outputDirectory = '';
	end

	%% Format input
	
	if ~strcmp(inputDirectory(end),'/');
		inputDirectory = sprintf('%s/',inputDirectory);
	end

	%% Get file list
	
	fileList = dir(inputDirectory);
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
	
	reportFile = fopen(sprintf('%swhistlers.txt',outputDirectory),'a+');
	
	%% Process each file
	
	tic;
	
	for i = 1 : length(files);

		%% Import and FFT wideband file

		fileName = sprintf('%s%s',directory,files{i});
		
		[~, eField, Fs] = wideband_import(fileName);

		[ time, frequency, power ] = wideband_fft( eField, Fs );
		
		%% Sliding window search for whistlers
		
		[ location, spectra, spectraBase ] = sliding_window( time, frequency, power );

		if isempty(location)
			fprintf('Processed %s : %.2f Seconds Elapsed\n',fileName,toc);
			continue
		end

		%% Process each whistler
		
		% Get start date/time of file
		
		fileTime = sscanf(files{i},'WB%04g%02g%02g%02g%02g%02g.dat');
		
		for j = 1 : length(location)
				
			%% Get best fit dispersion for each whistler

			spec = spectra{j};
			tw = spectraBase{j,1};
			fw = spectraBase{j,2};
						
			[D, ~, chirp] = dispersion_check(spec, fw, tw);
			
			%% Save spectrogram .png images and wideband snippets

			whistler_image(spec, chirp, D, fw, tw, fileTime, location(j), outputDirectory);
			
			%% Write times and dispersions to file and console
			
			dispersionText = sprintf('%04g/%02g/%02g %02g:%02g:%02g, D = %.2f\n',...
					 fileTime(1:5), location(j), D);
			
			fprintf(reportFile, dispersionText);
			fprintf(dispersionText);
				 
		end
		
		fprintf('Processed %s : %.2f Seconds Elapsed\n',fileName,toc);

	end

	fclose(reportFile);
	
end

function whistler_image(spectrogram, chirp, D, frequency, time, fileTime, location, directory)
%WHISTLER_IMAGE Creates a .png file with the whistler spectra and
%	dechirped spectra

	titleText = sprintf('%04g/%02g/%02g %02g:%02g:%02g, D = %.2f\n',...
					 fileTime(1:5), location, D);
				 
	figure
	subplot(1,2,1)
	imagesc(time, frequency, spectrogram)
	title(titleText);
	caxis([-40 0])
	set(gca,'TickDir','Out')
	set(gca,'YDir','normal');
	xlabel('Time (s)')
	ylabel('Frequency (Hz)')
	
	subplot(1,2,2)
	imagesc(time, frequency,chirp)
	caxis([-40 0])
	set(gca,'TickDir','Out')
	set(gca,'YDir','normal');
	xlabel('Time (s)')
	ylabel('Frequency (Hz)')
	
	fileName = sprintf('%swhistler%04g%02g%02g%02g%02g%02g_%02g.png',...
						directory, fileTime, floor(location));
					
	saveas(gcf,fileName);

end
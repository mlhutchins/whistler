function [ samples, nWidth ] = format_data( images, threshold, freqThreshold )
%FORMAT_DATA(images) formats and unwraps images for input into a neural network
%
%	Written by: Michael Hutchins

	switch nargin
		case 1
			threshold = 85;
			freqThreshold = [4000, 4500];
	end

	frequency = linspace(1000,10000,size(images,2));

	images = images(:,frequency > freqThreshold(1) & frequency < freqThreshold(2),:);
	
	samples = zeros(size(images,1), size(images,2) * size(images,3));

		
	for i = 1 : size(images,1);

		spectra = squeeze(images(i,:,:));

		%% Formatting code
		
		% Normalize spectra spectra

		maxPower = 0;
		minPower = -40;

		spectra(spectra < minPower) = minPower;
		spectra(spectra > maxPower) = maxPower;

		spectra = spectra > prctile(spectra(:),threshold);
	
		samples(i,:) = spectra(:)';
		
	end
		
	nWidth = size(images,3);

	
	
end


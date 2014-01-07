function [ samples ] = format_data( images )
%FORMAT_DATA(images) formats and unwraps images for input into a neural network
%
%	Written by: Michael Hutchins

	samples = zeros(size(images,1), size(images,2) * size(images,3));

	for i = 1 : size(images,1);

		spectra = squeeze(images(i,:,:));
		
		frequency = linspace(1000,10000,size(spectra,1));

		%% Formatting code
		
		% Normalize spectra spectra

		maxPower = 0;
		minPower = -40;

		spectra(spectra < minPower) = minPower;
		spectra(spectra > maxPower) = maxPower;

		spectra = (spectra - minPower / 2) / (range(spectra(:)) / 2);

		samples(i,:) = spectra(:)';
		
	end
		
end


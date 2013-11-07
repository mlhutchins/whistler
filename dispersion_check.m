function [D, time, chirp] = dispersion_check(spec, fRange, tw)
%DISPERSION_CHECK calculates the best fit dispersion and arrival time of
%the isolated sferic in spectra
%
%	Adapted from python script:
%		https://github.com/mlhutchins/gumstix/blob/master/spectrogram/spectrogram.py
%
%	Written by: Michael Hutchins

    %% Crude dispersion calculation

    % Generate a coarse index to shift each frequency to de-chirp it
    Dtest = linspace(100,800,21);
    dStep = Dtest(2) - Dtest(1);

    % Initialize output array
    power = zeros(length(Dtest),size(spec,2));

    for i = 1 : length(Dtest)

        D = Dtest(i);

        shift = de_chirp(spec, D, tw, fRange);
		
        power(i,:) = sum(shift,1).^2;
	end

    power = sum(power,2);
    dispersion = Dtest(power == max(power));

    if length(dispersion) > 1
        dispersion = dispersion(1);
	end
	
    %% Fine dispersion calculation

    Dtest = linspace(dispersion-dStep,dispersion+dStep,31);

    % Initialize output array
    power = zeros(length(Dtest),size(spec,2));

    for i = 1 : length(Dtest)

        D = Dtest(i);

        shift = de_chirp(spec, D, tw, fRange);

        power(i,:) = sum(shift,1).^4;
	end

    power = sum(power,2);

    dispersion = Dtest(power == max(power));
    if length(dispersion) > 1
        dispersion = dispersion(1);
	end

    % Get de-chirped spectra

    D = dispersion;

    chirp = de_chirp(spec, D, tw, fRange);

	% Get start time
	
	time = 0;
	
end
	
function offset = chirp_offset(D, tw)

    fShift = 1 / sqrt(5000);
    fSamp = 1./(tw(2) - tw(1));
    fShift = fSamp .* fShift;

    offset = -ceil(0.5 .* D .* fShift);

end

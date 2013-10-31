function [D, time] = dispersion_check(spec, fRange, tw)
%DISPERSION_CHECK calculates the best fit dispersion and arrival time of
%the isolated sferic in spectra
%
%	Adapted from python script:
%		https://github.com/mlhutchins/gumstix/blob/master/spectrogram/spectrogram.py
%
%	Written by: Michael Hutchins

    %% Crude dispersion calculation

    % Generate a coarse index to shift each frequency to de-chirp it
    Dtest = linspace(50,800,21);
    dStep = Dtest(2) - Dtest(1);

    % Initialize output array
    power = zeros(length(Dtest),size(spec,1));

    for i = 1 : length(Dtest)

        D = Dtest(i);

        shift = de_chirp(spec, D, tw, fRange);
		
        power(i,:) = sum(shift,2).^4;
	end

    power = sum(power,2);
    dispersion = Dtest(power == max(power));

    if length(dispersion) > 1
        dispersion = dispersion(1);
	end
	
    %% Fine dispersion calculation

    Dtest = linspace(dispersion-dStep,dispersion+dStep,31);

    % Initialize output array
    power = zeros(length(Dtest),size(spec,1));

    for i = 1 : length(Dtest)

        D = Dtest(i)

        shift = de_chirp(spec, D, tw, fRange);

        power(i,:) = sum(shift,1).^4;
	end

    power = sum(power,1);

    dispersion = Dtest(power == max(power));
    if length(dispersion) > 1
        dispersion = dispersion(1);
	end

    % Get de-chirped spectra

    chirp = 0. * spec;
    D = dispersion;

    chirp = de_chirp(spec, D, tw, fRange);

end

%% Dechirp the given spectra by the coefficient D
function shift = de_chirp(spec, D, tw, fRange)

    % Get the left shift-vector in seconds for a D = 1 constant

    fRange(1) = fRange(2);
    fShift = 1./sqrt(fRange);

    % Convert to seconds in units of time step
    fSamp = 1./(tw(2) - tw(1));
    fShift = fSamp .* fShift;

    intShift = ceil(0.5 .* D .* fShift);

    shift = 0 .* spec;

    % Shift each row of spec
    for j = 1 : length(fRange);

        shiftLevel = -intShift(j);
        shift(j,:) = circshift(spec(j,:),[0,shiftLevel]);

	end
end
	
function offset = chirp_offset(D, tw)

    fShift = 1 / sqrt(5000);
    fSamp = 1./(tw(2) - tw(1));
    fShift = fSamp .* fShift;

    offset = -ceil(0.5 .* D .* fShift);

end

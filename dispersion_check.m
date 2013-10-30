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
    Dtest = numpy.linspace(50,800,21)
    dStep = Dtest[1] - Dtest[0]

    % Initialize output array
    power = numpy.zeros((len(Dtest),spec.shape[0]))

    for i in range(len(Dtest)):

        D = Dtest[i]

        shift = de_chirp(spec, D, tw, fRange)

        power[i,:] = numpy.sum(shift,1)**4
	end

    power = numpy.sum(power,axis=1)
    dispersion = Dtest[power == numpy.max(power)]

    if len(dispersion) > 1:
        dispersion = dispersion[0]
	end
	
    %% Fine dispersion calculation

    Dtest = numpy.linspace(dispersion-dStep,dispersion+dStep,31)

    % Initialize output array
    power = numpy.zeros((len(Dtest),spec.shape[0]))

    for i in range(len(Dtest)):

        D = Dtest[i]

        shift = de_chirp(spec, D, tw, fRange)

        power[i,:] = numpy.sum(shift,1)**4
	end

    power = numpy.sum(power,axis=1)

    dispersion = Dtest[power == numpy.max(power)]
    if len(dispersion) > 1:
        dispersion = dispersion[0]
	end

    % Get de-chirped spectra

    chirp = 0. * spec.copy()
    D = dispersion

    chirp = de_chirp(spec, D, tw, fRange)

end

%% Dechirp the given spectra by the coefficient D
function shift = de_chirp(spec, D, tw, fRange)

    % Get the left shift-vector in seconds for a D = 1 constant

    fRange[0] = fRange[1]
    fShift = 1./numpy.sqrt(fRange)

    % Convert to seconds in units of time step
    fSamp = 1./(tw[1]-tw[0])
    fShift = fSamp * fShift

    intShift = numpy.ceil(0.5 * D * fShift);

    shift = 0. * spec.copy()

    % Shift each row of spec
    for j in range(len(fRange)):

        shiftLevel = -intShift[j]
        shift[j,:] = numpy.roll(spec[j,:],int(shiftLevel));

	end
end
	
function offset = chirp_offset(D, tw)

    fShift = 1 / sqrt(5000);
    fSamp = 1./(tw(2) - tw(1));
    fShift = fSamp .* fShift;

    offset = -ceil(0.5 .* D .* fShift);

end

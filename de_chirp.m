function shift = de_chirp(spec, D, tw, fRange)
%% Dechirp the given spectra by the coefficient D
%
%	Written by: Michael Hutchin

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
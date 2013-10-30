function [ tw, fw, SdB ] = wideband_fft( y, Fs )
%WIDEBAND_FFT Returns the spectrogram from the wideband e-Field data Y with
%sampling rate Fs
%   
%	Adapted from https://github.com/mlhutchins/gumstix/blob/master/spectrogram/spectrogram.py
%
%	Written by: Michael Hutchin

	%% Set window lengths
	
    Nw = 2^10; % Hanning window length
    Ny = len(y); % Sample length

    %% Create Hanning window
    j = numpy.arange(1.0,Nw+1);
    w = 0.5 * (1 - numpy.cos(2*numpy.pi*(j-1)/Nw));
    varw = 3./8.;

    %% Window the data
    nwinf = numpy.floor(Ny/Nw);
    nwinh = nwinf - 1;
    nwin = nwinf + nwinh;

    %% Fill in the windows array
    yw = zeros(Nw,nwin);
    yw(:,0:nwin:2) = reshape(y(1:nwinf*Nw),Nw,nwinf);                                                                             221,2-5       64%
	yw(:,1:(nwin-1):2) = reshape(y((Nw/2):(nwinf-0.5)*Nw),Nw,nwinh);

    % Taper the data
    yt = yw * repmat(w,nwin,1)';

    %% DFT of the data
	
    ythat = zeros(size(yt,1),size(yt,2));

	for i = 1 : size(yt,1)
        ythat(:,i) = fft(yt(:,i));
    S = abs(ythat).^2/varw;
    S = S(0:Nw/2,:);
    SdB = 10*log10(S);
    Mw = linspace(0,Nw/2);
    fw = Fs .* Mw ./ Nw;
    tw = linspace(1,nwin+1) .* 0.5 .* Nw ./ Fs;

end


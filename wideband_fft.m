function [ tw, fw, SdB ] = wideband_fft( y, Fs )
%WIDEBAND_FFT Returns the spectrogram from the wideband e-Field data Y with
%sampling rate Fs
%   
%	Adapted from https://github.com/mlhutchins/gumstix/blob/master/spectrogram/spectrogram.py
%
%	Written by: Michael Hutchin

	%% Set window lengths
	
    Nw = 2^10; % Hanning window length
    Ny = length(y); % Sample length

    %% Create Hanning window
    j = 1 : Nw;
    w = 0.5 * (1 - cos(2*pi*(j-1)/Nw));
    varw = 3/8;

    %% Window the data
    nwinf = floor(Ny/Nw);
    nwinh = nwinf - 1;
    nwin = nwinf + nwinh;

    %% Fill in the windows array
    yw = zeros(Nw,nwin);
    yw(:,1:2:nwin) = reshape(y(1:nwinf*Nw),Nw,nwinf); 
	yw(:,2:2:(nwin-1)) = reshape(y((Nw/2) + 1:(nwinf-0.5)*Nw),Nw,nwinh);

    % Taper the data
    yt = yw .* repmat(w,nwin,1)';

    %% DFT of the data
	
    ythat = zeros(size(yt,1),size(yt,2));

	for i = 1 : size(yt,2)
        ythat(:,i) = fft(yt(:,i));
	end
	
    S = abs(ythat).^2/varw;
    S = S(1:Nw/2,:);
    SdB = 10*log10(S);
    Mw = [1:Nw/2];
    fw = Fs .* Mw ./ Nw;
    tw = [1:nwin] .* 0.5 .* Nw ./ Fs;

end


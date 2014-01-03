function neural_network_training
%NEURAL_NETWORK_TRAINING loads in training data set of whistlers and background
%	noise and gets the best fit neural network with performance analysis
%
%	Written by: Michael Hutchins

%% Get training dataset file information
	
	trainingDir = 'training/';
	widebandDir = 'data/';
	
	fid = fopen(sprintf('%strigger.txt',trainingDir),'r');
	trainingList = fscanf(fid,'%g/%g/%g, %g:%g:%g, %g',[7 Inf]);
	
	triggersPos = trainingList(:,7);
	triggersNeg = triggersPos - 5;
	
	triggers = [triggersPos; triggersNeg];
	labels = [true(length(triggerPos),1); false(length(triggerNeg),1)];
	
	% Double for negative examples
	trainingList = [trainingList; trainingList];
	
	files = cell(size(trainingList,1),1);
	
	for i = 1 : size(trainingList,1);
		files{i} = sprintf('WB%04g%02g%02g%02g%02g%02g.dat',trainingList(i,1:6));
	end
	
%% Import and unwrap spectra
	
	% Import the first to get file sizes
	
	fileName = sprintf('%s%s',widebandDir,files{1});

	spectra = whistler_spectra(fileName);
	
	n = length(spectra(:));
	nFiles = length(files);
	
	samples = zeroes(nFiles, n);
	
	for i = 1 : nFiles
		
		fileName = sprintf('%s%s',widebandDir,files{i});
	
		spectra = whistler_spectra(fileName, triggers(i));
	
		% Unwrap
		spectra = spectra(:);
		
		samples(i,:) = spectra';
		
	end
	
	
%% Set random seed
	
	rng(1);
	
%% Split into traing / CV / test
	
	train = randsample(nFiles,round(0.8 * nFiles)); %Train with 80% of the data
	X = samples(train,:);
	y = labels(train,:);
	
	remaining = 1 : nFiles;
	remaining(train) = [];
	
	sampling = randsample(length(remaining), floor(length(remaining) / 2));
	cv = remaining(sampling); % Index of values for cross validation (10%)
	
	remaining(sampling) = [];
	test = remaining; %Test with last 10% of the data

	
	%% Initialize variables and parameters

	lambda = 0.5; % Regularization parameter
	inputLayerSize = size(X,2);
	hiddenLayerSize = 400;
	nLabels = length(unique(labels));
	
	% Random initialize neural network weights
	initialTheta1 = rand_initialize_weights(inputLayerSize, hiddenLayerSize);
	initialTheta2 = rand_initialize_weights(hiddenLayerSize, nLabels);

	% Create parameter vector
	initialParams = [initialTheta1(:) ; initialTheta2(:)];

	% Optimization code options
	options = optimset('MaxIter', 50);

	% Create "short hand" for the cost function to be minimized
	costFunction = @(p) nn_cost(p, ...
						   inputLayerSize, ...
						   hiddenLayerSize, ...
						   nLabels, X, y, lambda);
	
	%% Train neural network
	
	% Now, costFunction is a function that takes in only one argument (the
	% neural network parameters)
	[nnParams, cost] = fmincg(costFunction, initialParams, options);

	% Obtain Theta1 and Theta2 back from nnParams
	Theta1 = reshape(nnParams(1:hiddenLayerSize * (inputLayerSize + 1)), ...
				 hiddenLayerSize, (inputLayerSize + 1));

	Theta2 = reshape(nnParams((1 + (hiddenLayerSize * (inputLayerSize + 1))):end), ...
                 nLabels, (hiddenLayerSize + 1));

	% Visualize weights
	display_data(Theta1(:, 2:end));

	%% Cross validate parameters
	
	pred = predict_whistler(Theta1, Theta2, X);

	%% Pick best parameters
	
	
	%% Report test results
	
	
	%% Save parameters


end

function [ spectra ] = whistler_spectra( widebandFile, startTime )
%WHISTLER_SPECTRA takes the FFT of wideband data y and returns the 
%	portion of the spectra between 0 - 13 kHz as a 2D array
%
%	Written by: Michael Hutchins

%% Set start/end time buffers

	startBuffer = 0.1; %seconds
	endBuffer = 1.9; %seconds

%% Import wideband file

	[~, eField, Fs] = wideband_import(widebandFile);
	
%% Get spectral power density

	[timeBase,freqBase,power] = wideband_fft(eField,Fs);

%% Cut down in frequency and space

	spectra = power(freqBase < 13000,...
					timeBase > startTime - startBuffer &...
					timeBase < startTime + endBuffer);
				
%% Add padding as necessary

	padValue = mean(spectra(:));
	expectedSize = round((startBuffer + endBuffer) * Fs);
	actualSize = size(spectra,2);

	if actualSize < expectedSize
		
		padAmount = expectedSize - actualSize;
		
		padding = repmat(padValue,size(spectra,1),padAmount);
		
		if (timeBase(end) < (startTime + endBuffer));
		
			spectra = [padding, spectra];
		
		else 
		
			spectra = [spectra, padding];
		end
	
	end

end

function W = rand_initialize_weights(L_in, L_out)
%RANDINITIALIZEWEIGHTS Randomly initialize the weights of a layer with L_in
%incoming connections and L_out outgoing connections
%   W = RANDINITIALIZEWEIGHTS(L_in, L_out) randomly initializes the weights 
%   of a layer with L_in incoming connections and L_out outgoing 
%   connections. 
%
%   Note that W should be set to a matrix of size(L_out, 1 + L_in) as
%   the column row of W handles the "bias" terms
%
%	Code adapted from: Andrew Ng's Machine Learning Course

% Expected output size: W = zeros(L_out, 1 + L_in);

% Note: The first row of W corresponds to the parameters for the bias units

% Randomly initialize the weights to small values
epsilon_init = 0.12;
W = rand(L_out, 1 + L_in) * 2 * epsilon_init - epsilon_init;

end


function initialParams = rand_initialize_weights(inputLayerSize, hiddenLayerSize,nLabels)
%RAND_INITIALIZE_WEIGHTS(inputLayerSize, hiddenLayerSize,nLabels) returns
%	the randomly initialized parameters
%
%	Written by: Michael Hutchins

	initialParams = [];
	nLayers = length(hiddenLayerSize) + 1;
	
	for i = 1 : nLayers;
		
		if i == 1
			initialTheta = rand_initialize(inputLayerSize, hiddenLayerSize(i));
		elseif i < nLayers;
			initialTheta = rand_initialize(hiddenLayerSize(i-1), hiddenLayerSize(i));
		else
			initialTheta = rand_initialize(hiddenLayerSize(i-1), nLabels);
		end
		
		initialParams = [initialParams; initialTheta(:)];
		
	end

end

function W = rand_initialize(L_in, L_out)
%RAND_INITIALIZE Randomly initialize the weights of a layer with L_in
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
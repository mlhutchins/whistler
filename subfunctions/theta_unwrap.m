function [Theta] = theta_unwrap(nnParams, inputLayerSize, hiddenLayerSize, nLabels)
%THETA_UNWRAP(nnParams, inputLayerSize, hiddenLayerSize) unwraps
%	nnParams into the Theta cell array for the specified size neural
%	network

%% Get network sizes

	nLayers = length(hiddenLayerSize) + 1;

%% Reshape nn_params back into the parameters Thetas

	Theta{nLayers} = [];
	
	for i = 1 : nLayers;
		
		if i == 1
			
			a = 1; % Start point
			b = (inputLayerSize + 1); % First layer size + 1 (bias)
			c = hiddenLayerSize(i); % Next layer size

			d = a + b * c - 1;
			index = d;
			
		elseif i < nLayers
			
			a = index + 1; % Start point
			b = (hiddenLayerSize(i - 1) + 1); % Current layer size + 1 (bias)
			c = hiddenLayerSize(i + 1 - 1); % Next layer size

			d = a + b * c - 1;
			index = d;
			
		elseif i == nLayers

			a = index + 1; % Start point
			b = (hiddenLayerSize(i - 1) + 1); % Current layer size + 1 (bias)
			c = nLabels; % Next layer size

			d = a + b * c - 1;
			index = d;
				
		end
					
		Theta{i} = reshape(nnParams(a:d),c,b);

	end
	
end
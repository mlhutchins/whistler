function [J, grad] = nn_cost(nnParams, ...
                                   inputLayerSize, ...
                                   hiddenLayerSize, ...
                                   nLabels, ...
                                   X, y, lambda)
%NN_COST Implements the neural network cost function for a two layer
%neural network which performs classification
%   [J grad] = NN_COST(nn_params, hidden_layer_size, nLabels, ...
%   X, y, lambda) computes the cost and gradient of the neural network. The
%   parameters for the neural network are "unrolled" into the vector
%   nn_params and need to be converted back into the weight matrices. 
% 
%   The returned parameter grad should be a "unrolled" vector of the
%   partial derivatives of the neural network.
%
%	Code adapted from: Andrew Ng's Machine Learning Course

%  Setup some useful variables

	m = size(X, 1);
	nLayers = length(hiddenLayerSize) + 1;
	
%% Unwrap nnParams
	
	Theta = theta_unwrap(nnParams, inputLayerSize, hiddenLayerSize, nLabels);

%% Forward propagate network to get h(theta)

	z{nLayers} = [];
	a = z;
	
	z{1} = X;
	
	for i = 1 : nLayers + 1
		
		if i == 1;
			
			z{i} = X;
			
		else
		
			zPrime = a{i - 1} * Theta{i - 1}';
		
			z{i} = sigmoid(zPrime);
		
		end
		
		
		a{i} = [ones(m,1), z{i}];
				
	end
	
	a{end} = a{end}(:,2:end);
	
	h = a{end};

%% Get cost function J(theta)

	% Get number of classes

	K = unique(y(:));

	% Remap y
	yRemap = false(size(y,1),length(K));

	for i = 1 : length(K);
		yRemap(:,i) = y == K(i);
	end

	% Add cost of each class to J(theta)

	y1 = bsxfun(@times,yRemap,log(h));
	y2 = bsxfun(@times,~yRemap,log(1-h));
	J = (1/m) * nansum( -y1(:) - y2(:));

	% Add regularization
	
	reg = 0;

	for i = 1 : length(Theta);
	
		ThetaPrime = Theta{i};
		
		reg = reg + sum(sum(ThetaPrime(:,2:end).^2));
		
	end

	regularization = (lambda/(2 * m)) * (reg);

	J = J + regularization;

%% Backpropagation to get grad(J(theta))

	% Set errors
	%delta3 = a3 - yRemap;
	%delta2 = delta3 * Theta2(:,2:end) .* sigmoidGradient(z2);

	delta{nLayers} = [];
	
	for i = nLayers : -1 : 1
		
		if i == nLayers
			delta{i} = a{end} - yRemap;
		else
			ThetaPrime = Theta{i + 1};
			delta{i} = delta{i + 1} * ThetaPrime(:,2:end) .* sigmoid_gradient(z{i + 1});
		end	
	end

	% Accumulate Errors into Grad Arrays
		
	Theta_grad{nLayers} = [];
		
	for i = 1 : nLayers
		ThetaPrime = Theta{i};
		ThetaGradPrime = (1 / m) * delta{i}' * a{i};
		
		% Regularize
		ThetaGradPrime(:,2:end) = ThetaGradPrime(:,2:end) + (lambda/m) * ThetaPrime(:,2:end);
		Theta_grad{i} = ThetaGradPrime;
	end

%% Unroll gradients

	grad = [];

	for i = 1 : nLayers
		
		ThetaGradPrime = Theta_grad{i};

		grad = [grad ; ThetaGradPrime(:)];
		
	end
		
end



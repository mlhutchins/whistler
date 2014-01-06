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
					
		Theta{i} = reshape(nnParams(a:d),b,c);

		
	end


%% Forward propagate network to get h(theta)

	z{nLayers} = [];
	a = z;
	
	z{1} = X;

	for i = 1 : nLayers
		
		if i == 1;
			
			z{i} = X;
			
		else
		
			zPrime = a{i} * Theta{i}';
		
			z{i} = sigmoid(zPrime);
		
		end
		
		a{i} = [ones(m,1), z{i}];
				
	end
	
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
	J = (1/m) * sum( -y1(:) - y2(:));

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

	delta{nLayers} = [];
	
	for i = nLayers : 1
		
		if i == nLayers
			delta{i} = a{i} - yRemap;
		else
			ThetaPrime = Theta{i};
			delta{i} = delta{i + 1} * ThetaPrime(:,2:end) .* sigmoid_gradiant(z{i});
		end	
	end

	% Accumulate Errors into Grad Arrays

	Theta_grad = cell{nLayers - 1,1};
	
	for i = 1 : nLayers - 1
		ThetaPrime = {i};
		ThetaGradPrime = (1 / m) * delta{i + 1}' * a{i};
		
		% Regularize
		ThetaGradPrime(:,2:end) = ThetaGradPrime(:,2:end) + (lambda/m) * ThetaPrime(:,2:end);
		Theta_grad{i} = ThetaGradPrime;
	end
	

%% Unroll gradients

	grad = [];

	for i = 1 : nLayers - 1
		
		ThetaGradPrime = Theta_grad{i};

		grad = [grad ; ThetaGradPrime(:)];
		
	end

end



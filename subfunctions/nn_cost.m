function [J grad] = nn_cost(nn_params, ...
                                   input_layer_size, ...
                                   hidden_layer_size, ...
                                   num_labels, ...
                                   X, y, lambda)
%NN_COST Implements the neural network cost function for a two layer
%neural network which performs classification
%   [J grad] = NN_COST(nn_params, hidden_layer_size, num_labels, ...
%   X, y, lambda) computes the cost and gradient of the neural network. The
%   parameters for the neural network are "unrolled" into the vector
%   nn_params and need to be converted back into the weight matrices. 
% 
%   The returned parameter grad should be a "unrolled" vector of the
%   partial derivatives of the neural network.
%
%	Code adapted from: Andrew Ng's Machine Learning Course


%% Reshape nn_params back into the parameters Thetas

	Theta{1} = reshape(nnParams(1:hiddenLayerSize * (inputLayerSize + 1)), ...
				 hiddenLayerSize(1), (inputLayerSize + 1));	

	for i = 1 : nHidden;
		
		if i == 1
			Theta{i + 1} = reshape(nnParams(1:hiddenLayerSize(i) * (inputLayerSize + 1)), ...
						hiddenLayerSize(1), (inputLayerSize + 1));	
		elseif i == nHidden
			if nHidden == 1
				Theta{i + 1} = reshape(nnParams((1 + (hiddenLayerSize(i) * (inputLayerSize + 1))):end), ...
					 nLabels, (hiddenLayerSize(i) + 1));
			else
				Theta{i + 1} = reshape(nnParams((1 + (hiddenLayerSize(i) * (hiddenLayerSize(i-1) + 1))):end), ...
					 nLabels, (hiddenLayerSize(i) + 1));	
			end
		else
			Theta{i + 1} = reshape(nnParams((1 + (hiddenLayerSize(i) * (inputLayerSize + 1))):end), ...
					 hiddenLayerSize(i + 1), (hiddenLayerSize(i) + 1));		
		end
		
	end

	%  Setup some useful variables

	m = size(X, 1);
	nLayers = length(hiddenLayerSize) + 1;

%% Forward propagate network to get h(theta)

	z = cell(nLayers,1);
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

	delta3 = a3 - yRemap;
	delta2 = delta3 * Theta2(:,2:end) .* sigmoid_gradient(z2);

	% Accumulate Errors into Grad Arrays

	Theta1_grad = (1 / m) * delta2' * a1;
	Theta2_grad = (1 / m) * delta3' * a2;

	% Regularize

	Theta1_grad(:,2:end) = Theta1_grad(:,2:end) + (lambda/m) * Theta1(:,2:end);
	Theta2_grad(:,2:end) = Theta2_grad(:,2:end) + (lambda/m) * Theta2(:,2:end);


%% Unroll gradients

	grad = [Theta1_grad(:) ; Theta2_grad(:)];

end



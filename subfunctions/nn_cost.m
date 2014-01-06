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


%% Reshape nn_params back into the parameters Theta1 and Theta2,
%	the weight matrices for our 2 layer neural network
	Theta1 = reshape(nn_params(1:hidden_layer_size * (input_layer_size + 1)), ...
                 hidden_layer_size, (input_layer_size + 1));

	Theta2 = reshape(nn_params((1 + (hidden_layer_size * (input_layer_size + 1))):end), ...
                 num_labels, (hidden_layer_size + 1));

	%  Setup some useful variables

	m = size(X, 1);

%% Forward propagate network to get h(theta)

	a1 = [ones(m, 1) X];

	z2 = a1 * Theta1';

	a2 = sigmoid(z2);

	a2 = [ones(m, 1) a2];

	z3 = a2 * Theta2';

	a3 = sigmoid(z3);

	h = a3;

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

	reg1 = sum(sum(Theta1(:,2:end).^2));
	reg2 = sum(sum(Theta2(:,2:end).^2));

	regularization = (lambda/(2 * m)) * (reg1 + reg2);

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



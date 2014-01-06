function g = sigmoid_gradient(z)
%SIGMOIDGRADIENT returns the gradient of the sigmoid function
%evaluated at z
%   g = SIGMOIDGRADIENT(z) computes the gradient of the sigmoid function
%   evaluated at z. 

	g = sigmoid(z) .* (1 - sigmoid(z));

end
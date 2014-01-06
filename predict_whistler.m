function p = predict_whistler(Theta1, Theta2, X)
%PREDICT Predict the label of an input given a trained neural network
%   p = PREDICT(Theta1, Theta2, X) outputs the predicted label of X given the
%   trained weights of a neural network (Theta1, Theta2)
%
%	Written by: Michael Hutchins
%	Adapted from: Andrew Ng's Machine Learning Course

%% Useful values
	m = size(X, 1);

%% Get predicted output label index

	h1 = sigmoid([ones(m, 1) X] * Theta1');
	h2 = sigmoid([ones(m, 1) h1] * Theta2');
	[~, p] = max(h2, [], 2);
	
%% Set to positive/negetive index

	p = logical(p - 2);

end
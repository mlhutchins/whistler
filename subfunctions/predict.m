function p = predict(Theta, X)
%PREDICT Predict the label of an input given a trained neural network
%   p = PREDICT(Theta, X) outputs the most likely label of X given the
%   trained weights of a neural network (Theta)
%
%	Written by: Michael Hutchins
%	Adapted from: Andrew Ng's Machine Learning Course

%% Useful values
	m = size(X, 1);

%% Get predicted output label index
	
	nLayers = length(Theta);

	% Forward propagate network to get h(theta)

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

	[dummy, p] = max(h, [], 2);
	
end

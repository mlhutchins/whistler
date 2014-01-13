function [ Theta, statistics, cost, cvStatistics ] = whistler_cross_validate( images, labels )
%WHISTLER_CROSS_VALIDATE(images, labels) trains a neural network on the
%	images data and returns the best neural network parameters after cross
%	validating
%
%	Written by: Michael Hutchins

%% Start parallel processing

	if parallel_check
		parallel_start
	end
	
%% Get Git Hash

	try
		hash = git_hash;
		hash = hash(1:7);
	catch
		hash = '';
	end
	
%% Set random seed
	
	fprintf('Setting Random Seed\n');

	rng(2);

%% Split into training / CV / test
	
	fprintf('Selecting Training Set\n');

	[ splitLabels ] = sample_split( length(labels), [0.8 0.1 0.1] );

	train = splitLabels == 1; %Train with 80% of the data
	
	cv = splitLabels == 2; % Index of values for cross validation (10%)
	
	test = splitLabels == 3; %Test with last 10% of the data
	
%% Cross validate parameters
	
	fprintf('Setting Cross Validation Parameters\n');
	
	% Cross validate over lambda, network shape / size (init)
	%					  threshold, frequency range (format)
	%		
	
	% Lamdba (regularization values)
	
	lambda = {0, 0.01, 0.05, 0.1, 0.2};
	networkShape = {[300],...
					[400],...
					[400, 50],...
					[500]};
				
	threshold = {55, 65, 75, 85, 95};
	
	frequency = {[2 4.5],...
				 [3 4.5],...
				 [4 4.5],...
				 [2 6.5],...
				 [3 6.5],...
				 [4 6.5]};
	
	% Permute into parameter cell array
	cvParameters = cell(length(lambda) * length(networkShape) *...
						length(threshold) * length(frequency),4);
	index = 1;
	for i = 1 : length(lambda)
		for j = 1 : length(networkShape)
			for k = 1 : length(threshold)
				for n = 1 : length(frequency)
					cvParameters(index,1) = lambda(i);
					cvParameters(index,2) = networkShape(j);
					cvParameters(index,3) = threshold(k);
					cvParameters(index,4) = frequency(n);
					index = index + 1;
				end
			end
		end
	end
	
	cvStatistics = cell(size(cvParameters,1),1);
	
%% Loop through parameters

	fprintf('Starting Cross Validation\n');
	
	parTic = tic;
	
	parfor i = 1 : size(cvStatistics,1)
		
		%% Extract parameters
		
		lambda = cvParameters{i,1};
		networkShape = cvParameters{i,2};
		threshold = cvParameters{i,3};
		frequency = cvParameters{i,4};
		

		%% Adjust data format

		[samples, nWidth] = format_data( images, threshold, frequency );

		%% Adjust and Initialize Neural Network

		neuralNetwork = neural_network_init(networkShape,lambda, 200);
		% hiddenLayerSize, lambda, maxIter

		%% Train Initial Neural Network

		[Theta, ~, ~] = neural_network_training(samples(train,:),labels(train,:),neuralNetwork);

		%% Get cross validation statistics

		cvPred = predict(Theta, samples(cv,:)) - 1;
		cvTrue = labels(cv);

		[accuracy, precision, sensitivity, specificity] = net_stats(cvPred, cvTrue);

		cvStatistics{i} = [accuracy, precision, sensitivity, specificity];

		%% Print status
		
		fprintf('%g / %g Done - %.2f seconds elapsed\n',i,size(cvParameters,1),toc(parTic));
		
	end

	cvStatistics(:,2:5) = cvParameters;

	save(sprintf('cvDebug_%s',hash),'-v7.3');	
	
%% Get best performance

	% Compile statistics into array
	
	statistics = zeros(size(cvStatistics,1),4);
	
	for i = 1 : size(cvStatistics,1)
		statistics(i,:) = cvStatistics{i};
	end

	% Remove parameters with no positives
	remove = sum(isnan(statistics),2) > 0;
	
	threshold = 99;
	best = [];
	
	while isempty(best)

		cutoff = prctile(statistics(~remove,:),threshold);

		top = bsxfun(@ge,statistics,cutoff);

		best = find(sum(top,2) == 4 & ~remove);
	
		secondBest = find(sum(top,2) >= 3 & ~remove);
		
		threshold = threshold - 1;

	end

	fprintf('\n')
	fprintf('Best parameter selection:\n')
	print_parameters(cvStatistics(best,2:5));
	
	fprintf('\n')
	fprintf('Second best parameter selections:\n')
	print_parameters(cvStatistics(secondBest,2:5));
	
%% Report test results for best CV data
	
	lambda = cvStatistics{best,2};
	networkShape = cvStatistics{best,3};
	threshold = cvStatistics{best,4};
	frequency = cvStatistics{best,5};
	
	% Format to best
	[samples, nWidth] = format_data( images, threshold, frequency );

	% Show first 24 whistlers
	display_data(samples(1:24,:),nWidth);
	
	% Initialize Neural Network to best
	neuralNetwork = neural_network_init(networkShape,lambda,200);
	
	% Train
	[Theta, statistics, cost] = neural_network_training(samples(train,:),labels(train,:),neuralNetwork);

	fprintf('Starting test results\n');

	testPred = predict(Theta, samples(test,:)) - 1;
	testTrue = labels(test);
	
	[accuracy, precision, sensitivity, specificity] = net_stats(testPred, testTrue);
	
	fprintf('Test set accuracy: %.1f%%\n',accuracy * 100);
	fprintf('Test set precision: %.1f%%\n',precision * 100);
	fprintf('Test set sensitivity: %.1f%%\n',sensitivity * 100);
	fprintf('Test set specificity: %.1f%%\n',specificity * 100);

	statistics{1} = accuracy;
	statistics{2} = precision;
	statistics{3} = sensitivity;
	statistics{4} = specificity;

end

function print_parameters(parameters)

	fprintf('Lambda\t| Network\t| Threshold\t| Frequency\n');

	for i = 1 : size(parameters,1);
		
		fprintf('%g\t| ',parameters{i,1});
		
		networkSize = parameters{i,2};
		
		for j = 1 : length(networkSize);
			if j == length(networkSize)
				fprintf('%g',networkSize(j));
			else
				fprintf('%g, ',networkSize(j));
			end
		end
		
		if length(networkSize) == 1
			fprintf('\t')
		end

		fprintf('\t| ')
		fprintf('%g\t\t| ',parameters{i,3});

		fprintf('[%g, %g] ',parameters{i,4});
		fprintf('\n');
	end
	
end
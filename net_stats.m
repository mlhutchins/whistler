function [accuracy, precision, sensitivity, specificity] = net_stats(predicted, truth)
%NET_STATIS(PREDICTED, TRUTH) returns summary statistics on accuracy
%
%	Written by Michael Hutchins

	predicted = logical(predicted);
	truth = logical(truth);

	truePos = predicted & truth;
	trueNeg = ~predicted & ~truth;
	falsePos = predicted & ~truth;
	falseNeg = ~predicted & truth;
	
	% Proportion of true results
	accuracy = (sum(truePos) + sum(trueNeg)) /...
			   (sum(truePos) + sum(falsePos) + sum(falseNeg) + sum(trueNeg));
		   
    % Positive predictive value
    precision = (sum(truePos)) / (sum(truePos) + sum(falsePos));
	
	% Ability to identify positives
	sensitivity = (sum(truePos)) / (sum(truePos) + sum(falseNeg));
	
	% Ability to identify negatives
	specificity = (sum(trueNeg)) / (sum(trueNeg) + sum(falsePos));


end


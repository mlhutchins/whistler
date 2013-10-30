function [ shape ] = shape_extract( binaryImage, startPoint )
%SHAPE_EXTRACT Finds the shape connected to startPoint in binaryImage
%
%	Written by: Michael Hutchins

	%% Condition inputs
	
	binaryImage = logical(binaryImage);
	
	%% Get size and start parameters

	iStart = startPoint(1);
	jStart = startPoint(2);
	
	n = size(binaryImage,1);
	m = size(binaryImage,2);
	
	shape = false(n,m);
	
	oldShape = shape;
	shape(iStart, jStart) = true;

	%% Find the connected image

	while any((oldShape(:) - shape(:)) ~= 0)
		
		oldShape = shape;
		
	
		up = circshift(shape,[1,  0]);
		up(1,:) = false;
		
		down = circshift(shape,[-1, 0]);
		down(end,:) = false;
		
		left = circshift(shape,[0,  -1]);
		left(:,1) = false;
		
		right = circshift(shape,[0,  1]);	
		right(:,end) = false;
		
		shape = (binaryImage & up) |...
				(binaryImage & down) |...
				(binaryImage & left) |...
				(binaryImage & right) |...
				shape;
			
	end
	
	
end


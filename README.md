Whistler Neural Network Detection
========

A neural network detection program to find VLF whistler waves in wideband data.  The project goal is to have automated detection, analysis, and data curation of whistler waves at individual WWLLN stations.

MATLAB functions are used for training and cross-validating the neural network based on the training data.

Python (see pyWhistler) is used for the automated detection at the remote stations, using the final weights of the MATLAB based training.

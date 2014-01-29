# Text



# Import statements


class WidebandVLF:
    
    def __init__(self, fileName):
        
        self.time = self.frequency = self.power = self.fs = [];

        self.widebandImport(fileName)
        self.widebandFFT()
    
        
    def widebandImport(self):
        pass;
        
    def widebandFFT(self):
        pass;
        
        
    def whistlerSearch(self):
    
    
        return 
    
class Spectra:
    
    def __init__(self):
        pass;
    
    def format(self):
        pass;
        
    def deChirp(self):
        pass;
        
    def whistlerPlot(self):
        pass;
    
class NeuralNetwork:
    
    def __init__(self, nnParams):
        self.getNN(nnParams);
        
    def getNN(self, nnParams):
        pass;
        
    def predict(self, whistler):
        pass;

    
if __name__ == '__main__':
    
    nnParams = 'nnParams.dat';
    
    neuralNet = NeuralNetwork(nnParams);
    
    
    
    pass
    
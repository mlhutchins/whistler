# Text

import argparse
import numpy

# Import statements


class WidebandVLF:
    
    def __init__(self, fileName):
        
        self.time = self.eField = self.power = self.Fs = self.freqBase = self.timeBase = self.fileStart = [];
        self.date = [1999,01,01,00,00,00];
        
        ## TODO: Set date from filename
        
    def importFile(self, fileName):
        ## Read in Wideband VLF Data
        self.file = fileName;

        fid = open(self.file, 'rb')
    
        self.fileStart = numpy.fromfile(fid, dtype=numpy.dtype('<i4'), count = 1)
        Fs = numpy.fromfile(fid, dtype=numpy.dtype('<f8'), count = 1)
        offset = numpy.fromfile(fid, dtype=numpy.dtype('<f8'), count = 1)
        y = numpy.fromfile(fid, dtype=numpy.dtype('<i2'))
    
        ## Normalize to soundcard units and switch to float
        y = y.astype(numpy.float)
        y = y/32768
    
        ## Make the time base
    
        t = numpy.arange(0.0,len(y))
        t = t + offset
        t = t/Fs
    
        self.eField = y;
        self.time = t;
        self.Fs = Fs;
            
    def widebandFFT(self):
                
        y = self.eField;
        Fs = self.Fs;
        
        Nw = 2**10 # Hanning window length
        Ny = len(y) # Sample length
        
        # Create Hanning window
        j = numpy.arange(1.0,Nw+1)
        w = 0.5 * (1 - numpy.cos(2*numpy.pi*(j-1)/Nw))
        varw = 3./8.
        
        # Window the data
        nwinf = numpy.floor(Ny/Nw)
        nwinh = nwinf - 1
        nwin = nwinf + nwinh
        
        # Fill in the windows array
        yw = numpy.zeros((Nw,nwin))
        yw[:,0:nwin:2] = y[:nwinf*Nw].reshape(Nw,nwinf,order='F').copy()
        yw[:,1:(nwin-1):2] = y[(Nw/2):(nwinf-0.5)*Nw].reshape(Nw,nwinh,order='F').copy()
        
        # Taper the data
        yt = yw * numpy.tile(w,(nwin,1)).T
        
        # DFT of the data
        ythat = numpy.zeros(yt.shape)
        ythat = ythat + 0j
        for i in range(yt.shape[1]):
            ythat[:,i] = numpy.fft.fft(yt[:,i])
        S = (numpy.absolute(ythat)**2)/varw
        S = S[0:Nw/2,:]
        SdB = 10*numpy.log10(S)
        Mw = numpy.arange(0,Nw/2)
        fw = Fs * Mw / Nw
        tw = numpy.arange(1,nwin+1) * 0.5 * Nw/Fs
        
        self.timeBase = tw;
        self.freqBase = fw;
        self.power = SdB;
        
        
    
class Spectra:
    
    def __init__(self):
        self.time = 0.0;
        self.date
        self.threshold = 85;
        self.freqBand = [4.0, 4.5];
        self.startBuffer = 0.5; #seconds
        self.endBuffer = 0.75; #second
        self.power = self.image = [];
                
    def format(self, wideband, time):
        self.time = time;
        self.date = wideband.date;
        

        timeBase = wideband.timeBase;
        freqBase = wideband.freqbase;
        
        image = wideband.power;
        
        image = image[(timeBase > time - self.startBuffer) & (timeBase < time + self.endBuffer),
                      (freqBase > 1000 * self.freqBand[0]) & (freqBase < 1000 * self.freqBand[1])];
                      
        self.power = image;
                      
        ## TODO: pad image
        
        maxPower = 0.0;
        minPower = -40.0;
        
        image[image < minPower] = minPower;
        image[image > maxPower] = maxPower;
        
        image = image > numpy.percentile(image[:],self.threshold);

        self.image = image;
        
        self.width = image.shape[0];
                
    def deChirp(self):
        
        pass;
                    
    def whistlerPlot(self):
        pass;
    
class NeuralNetwork:
    
    def __init__(self, nnParams):
        self.Theta = [];
        self.getNN(nnParams);
        
    def getNN(self, nnParams):
        ## TODO: get Theta from nnParams file
        pass;
        
    def predict(self, spectra):
        theta = self.Theta;

        nLayers = len(theta);
        m = spectra.shape[1];
        
        z = [];
        a = [];
        for dummy in range(nLayers):
            z.append([])
            a.append([])
            
        z[0] = numpy.ravel(spectra.image,1);

        for i in range(nLayers + 1):
            
            if i == 0:
                z[i] = numpy.ravel(spectra.image,1);
            else:
                zPrime = numpy.dot(a[i - 1], theta[i - 1]);
                z[i] = self.sigmoid(zPrime);
                
            a[i] = numpy.concatenate((numpy.zeros(m,1), z[i]), 0);
        
        a[-1] = a[-1][:,0:-1];
        
        h = a[-1];
        
        p = numpy.argmax(h, axis = 1);
        
        return p - 1.0
    
    def sigmoid(self, z):
        return 1.0 / (1.0 + numpy.exp(-z));
        
    def sigmoidGradient(self,z):
        return self.sigmoid(z) * (1 - self.sigmoid(z));
        
    def search(self, wideband):
        
        stepSize = 0.2 # seconds
        windows = numpy.linspace(stepSize, 60.0, 60.0/stepSize);
        
        whistlers = []
        
        for time in windows:
            
            spectra = Spectra();
            
            spectra.format(wideband, time);
            
            located = self.predict(spectra);
       
            if located:
                whistlers.append(spectra)
        
        return whistlers

    
if __name__ == '__main__':
    
    parser = argparse.ArgumentParser(description='Searches for whistlers in wideband WB.dat files')
    parser.add_argument('fileName', metavar='filename', type=str, nargs='+', help = 'Name (list) of wideband file(s)')

    
    args = parser.parse_args()
    filenames = args.fileName
    
    nnParams = 'nnParams.dat';
    
    neuralNet = NeuralNetwork(nnParams);
    
    outputFile = 'search.txt';
    
    for fileName in filenames:
        
        wideband = WidebandVLF()
        
        wideband.importFile(fileName);
        
        wideband.widebandFFT();
        
        whistlers = neuralNet.search(neuralNet);
        
        dechirp = whistlers.deChirp()
        
        whistlers.whistlerPlot()
        dechirp.whistlerPlot()
        
        
    
    
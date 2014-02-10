# TODO: Documentation

import argparse
import numpy  
import copy

try:
    import matplotlib
    matplotlib.use('Agg')
    import matplotlib.pyplot as plt
    matplotLoaded = True;
except:
    matplotLoaded = False;
        
class WidebandVLF:
    
    def __init__(self):
        
        self.time = self.eField = self.power = self.Fs = self.freqBase = self.timeBase = self.fileStart = [];
        self.date = [1999,01,01,00,00,00];
                
    def importFile(self, fileName):
        ## Read in Wideband VLF Data
        self.file = fileName;

        fileDate = fileName.split('/')
        fileDate = fileDate[-1]

        year = int(fileDate[2:6])
        month = int(fileDate[6:8])
        day = int(fileDate[8:10])
        hour = int(fileDate[10:12])
        minute = int(fileDate[12:14])

        self.date = [year, month, day, hour, minute, -1.0];

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
        self.date = [];
        self.threshold = 85;
        self.freqBand = [3.0, 4.5];
        self.startBuffer = 0.5; #seconds
        self.endBuffer = 0.75; #second
        self.formatimage = imageFormat();
        self.power = self.image = self.dechirped = [];
        self.dechirpedOffset = 0.0;
        self.dispersion = 0.0;
                
    def format(self, wideband, time):
        self.time = time;
        self.date = wideband.date;
        self.date[5] = time;

        timeBase = wideband.timeBase;
        freqBase = wideband.freqBase;
        
        image = wideband.power;
                        
        padding = numpy.zeros((image.shape[0],image.shape[1]));
        image = numpy.concatenate((padding,image),1);
        image = numpy.concatenate((image,padding),1);
        
        step = timeBase[10] - timeBase[9];
        
        timeTemp = timeBase.copy();
        timeBase = numpy.concatenate((timeTemp - timeTemp[-1],timeBase),0);
        timeBase = numpy.concatenate((timeBase,timeTemp + timeTemp[-1]),0);
        
        expectedTime = numpy.floor((self.startBuffer + self.endBuffer) / (step))

        freqCut = (freqBase > 1000 * self.freqBand[0]) & (freqBase < 1000 * self.freqBand[1]);
        timeCut = (timeBase > (time - self.startBuffer)) & (timeBase < (time + self.endBuffer));
        
        if numpy.sum(timeCut) > expectedTime:
            timeCut = timeCut & numpy.roll(timeCut,-1)
        elif (numpy.sum(timeCut) < expectedTime):
            timeCut = timeCut | numpy.roll(timeCut,1)
            
        self.timebase = timeBase[timeCut];
        self.freqbase = freqBase[freqCut];
            
        image = image[freqCut,:];
        image = image[:,timeCut];
                      
        self.power = image;
        
        maxPower = 0.0;
        minPower = -40.0;
        
        image[image < minPower] = minPower;
        image[image > maxPower] = maxPower;
        
        image = image > numpy.percentile(image[:],self.threshold);

        self.image = image.astype(float);
        
        self.width = image.shape[0];
                
    def deChirp(self):

        def _de_chirp(self, D):
 
            # Get the left shift-vector in seconds for a D = 1 constant
            
            fRange = self.freqbase.copy();
            
            fRange[0] = fRange[1]
            fShift = 1./numpy.sqrt(fRange)
            
            # Convert to seconds in units of time step
            fSamp = 1./(self.timebase[1]-self.timebase[0])
            fShift = fSamp * fShift
            
            intShift = numpy.ceil(0.5 * D * fShift);
        
            shift = 0. * self.power.copy()
        
            # Shift each row of power spectra
            for j in range(len(fRange)):
                
                shiftLevel = -intShift[j]
                shift[j,:] = numpy.roll(self.power[j,:],int(shiftLevel));    
                
            return shift
        
        def _find_d(self, Dtest):
            
            # Initialize output array
            spectralPower = numpy.zeros((len(Dtest),self.power.shape[0]))
        
            for i in range(len(Dtest)):
                    
                D = Dtest[i]
                
                shift = _de_chirp(self, D)
                
                spectralPower[i,:] = numpy.sum(shift,1)**4
                
            spectralPower = numpy.sum(spectralPower,axis=1)
            dispersion = Dtest[spectralPower == numpy.max(spectralPower)]
            
            if len(dispersion) > 1:
                dispersion = dispersion[0]
                
            return dispersion
         
        ## Calculate the amount to shift the dispersion plotting window based on the dispersion amount
        def _chirp_offset(self, D):
        
            fShift = 1. / numpy.sqrt(5000)
            fSamp = 1./(self.timebase[1] - self.timebase[0])
            fShift = fSamp * fShift
            
            offset = -numpy.ceil(0.5 * D * fShift)
            
            return offset
                          
        ## Coarse dispersion calculation
        Dtest = numpy.linspace(50,800,21)
        dispersion = _find_d(self, Dtest);
                
        ## Fine dispersion calculation
        dStep = Dtest[1] - Dtest[0];
        Dtest = numpy.linspace(dispersion-dStep,dispersion+dStep,31)
        dispersion = _find_d(self, Dtest);
            
        self.dispersion = dispersion;
            
        # De-chirp spectra
            
        self.dechirped = _de_chirp(self, dispersion)
        self.dechirpedOffset = _chirp_offset(self, dispersion)          
                    
    def whistlerPlot(self):
        
        # Initialize figure
        fig = plt.figure(figsize=(self.formatimage.width,self.formatimage.height));
                
        # Create spectrogram plot
        self.insertSpectrogram()
        
        # Set title to give filename and sampling frequency
        plt.title(self.formatimage.name)
        
        # Save figure
        plt.savefig(self.formatimage.savename,dpi = self.formatimage.dpi)
        
        # Close the plot
        plt.close(fig)
        
    def insertSpectrogram(self):
        
        # Plot the spectrogram and set colorbar limits
        plt.imshow(self.power, origin='lower',vmin = -40, vmax = -15)
        
        # Set scale to be a float
        scale = 10.0;
        
        # Set plot labels
        plt.xlabel('Time (s)')
        plt.ylabel('Frequency (kHz)')
        
        # X and Y tick skip interval  
        yStep = 4;
        xStep = 2;
        
        # Setup X tick marks and labels      
        tStart = numpy.ceil( self.timebase[0] * scale) / scale;
        tEnd = numpy.ceil( self.timebase[-1] * scale) / scale;
        
        tSteps = numpy.floor((1 / scale) / (self.timebase[1] - self.timebase[0]));
        
        tickXloc = numpy.arange(0,len(self.timebase),step = tSteps)
        tickXlabel = numpy.arange(tStart,tEnd,step = (1 / scale));

        # Setup Y Tick marks and labels
        tickYloc = numpy.arange(0,len(self.freqbase))
        tickYlabel = numpy.round(self.freqbase)

        # Skip designated amounts and round to nearest 0.1 kHz and 0.1 s
        tickXloc = tickXloc[::xStep]
        tickXlabel = tickXlabel[::xStep];
        tickXlabel = numpy.round(tickXlabel * 10.0) / 10.0;

        tickYloc = tickYloc[::yStep]
        tickYlabel = tickYlabel[::yStep];
        tickYlabel = numpy.round(tickYlabel / 100.0) / 10.0;
        
        # Update tickmarks
        plt.xticks(tickXloc,tickXlabel)
        plt.yticks(tickYloc,tickYlabel)

        # Generate and label colorbar
        cbar = plt.colorbar(orientation = 'horizontal')
        cbar.set_label('Spectral Power (dB)')
        
    
class NeuralNetwork:
    
    def __init__(self):
        self.Theta = [];
        
    def getNN(self, nnParams):

        self.Theta = [];

        f = open(nnParams)
        thetaShape = f.readline().split();

        while (len(thetaShape) > 0):
            
            m = int(thetaShape.pop(0))
            n = int(thetaShape.pop(0))

            theta = numpy.zeros((m,n));
            
            for i in range(m):
                newLine = f.readline().split();

                for j in range(n):
                    theta[i,j] = newLine[j];
            
            self.Theta.append(theta);
            f.readline(); # Skip empty line between theta parameters

    def predict(self, spectra):
        theta = self.Theta;

        image = spectra.image;
        image = numpy.ravel(image,1);
        image = numpy.reshape(image,(1,len(image)));

        nLayers = len(theta);
        m = image.shape[0];
        
        z = [];
        a = [];
        for dummy in range(nLayers + 1):
            z.append([])
            a.append([])
            
        z[0] = image;

        for i in range(nLayers + 1):
            
            if i == 0:
                z[i] = image;
            else:
                zPrime = numpy.dot(a[i - 1], numpy.transpose(theta[i - 1]));
                z[i] = self.sigmoid(zPrime);
                
               
            biasTerm = numpy.zeros((m,1));
            a[i] = numpy.concatenate((biasTerm, z[i]), 1);
        
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

class imageFormat:
    
    def __init__(self):
        self.width = 7.5;
        self.height = 7.5;
        self.dpi = 75;
        self.savename = 'whistler.png';
        self.name = 'whistler';
        self.imagedir = '';

    def makename(self,filename, append):
        name = filename.split("/");
        name = name[-1];
        self.name = name;
        
        name = name[:-6];
        
        name = self.imagedir + name + append + '.png';
        self.savename = name;
        
        
if __name__ == '__main__':
    
    parser = argparse.ArgumentParser(description='Searches for whistlers in wideband WB.dat files')
    parser.add_argument('fileName', metavar='filename', type=str, nargs='+', help = 'Name (list) of wideband file(s)')

    args = parser.parse_args()
    filenames = args.fileName
    
    nnParams = 'nnTest.dat';
    
    neuralNet = NeuralNetwork();
    
    neuralNet.getNN(nnParams);
    
    outputFile = 'search.txt';
    
    fid = open(outputFile, 'a')
    
    spectrogramFormat = imageFormat();
    spectrogramFormat.imagedir = '';
    
    for fileName in filenames:
        
        wideband = WidebandVLF()
        
        wideband.importFile(fileName);
        
        wideband.widebandFFT();
        
        whistlers = neuralNet.search(wideband);
        
        for whistler in whistlers:
            
            whistler.deChirp()

            date = whistler.date;
            
            printLine = '%04g/%02g/%02g, %02g:%02g:%02g, D = %.2f' % (date[0],date[1],date[2],date[3],date[4],whistler.time, whistler.dispersion)  
            print printLine    
            fid.write(printLine + '\n')
            
            if matplotLoaded:
            
                whistler.formatimage = spectrogramFormat;
            
                # Append time of whistler to the filename
                whistlerAppend = '_' + str(int(whistler.time));
                whistler.formatimage.makename(fileName, whistlerAppend);
        
                ## TODO: Combine figures into one
        
                whistler.whistlerPlot();
    
            
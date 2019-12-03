import numpy as np
import mne
#from sklearn.svm import SVC
from mne.decoding import CSP
from scipy.signal import butter, lfilter
from sklearn.discriminant_analysis import LinearDiscriminantAnalysis
from sklearn.pipeline import make_pipeline

low_cut = 8.0
high_cut = 28.0
bank_size = 4.0
num_bank = 9
csp_components = 6
freq = 500
window_size = 500
stride = 128
numChannels=31
info=None
channel_names=[]



# data: numpy.ndarray or list of dimension (epoch, channel, frequency)
# label: numpy.ndarray or list of dimension (epoch)

class CommonSpatialPattern:
    def __init__(self, augment=False, nChannels=31, frequency=500, chnames=None):
        global info, numChannels, channel_names, freq
        self.name = self.__class__.__name__
        self.clf=None
        self.augment = augment
        channel_names=chnames
        freq=frequency
        numChannels=nChannels
        print(channel_names)
        montage = mne.channels.read_montage('standard_1005')

        info = mne.create_info(ch_names=channel_names, sfreq=freq, ch_types='eeg', montage=montage)

    def build_model(self, data, label):
        global info, csp_components,low_cut,high_cut
        print("{}: Building model with {} and {}".format(self.name, np.shape(data), np.shape(label)))
        MI_epochs=mne.EpochsArray(data, info)
        MI_epochs.filter(low_cut,high_cut,method='iir')
        MI_epochs.set_eeg_reference('average',projection=True)
        self.clf=make_pipeline(CSP(n_components=csp_components, reg=None, log=True, norm_trace=False), LinearDiscriminantAnalysis())
        self.clf.fit(MI_epochs.get_data(),label)

    def predict(self, data):
        global info
        MI_test=mne.EpochsArray(data, info)
        MI_test.filter(low_cut,high_cut,method='iir')
        return self.clf.predict(MI_test.get_data())

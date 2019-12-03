import numpy as np
import mne
from sklearn.svm import SVC
from mne.decoding import CSP
from scipy.signal import butter, lfilter
from sklearn.discriminant_analysis import LinearDiscriminantAnalysis

low_pass_freq = 8.0
bank_size = 4.0
num_bank = 7
csp_components = 6
freq = 500
window_size = 500
stride = 128
numChannels=31
info=None
# data: numpy.ndarray or list of dimension (epoch, channel, frequency)
# label: numpy.ndarray or list of dimension (epoch)
channel_names=[]

class FBCSP:
    def __init__(self, augment=False,nChannels=31, frequency=500, chnames=None):
        global info, numChannels, channel_names, freq
        self.name = self.__class__.__name__
        self.csp_list = []
        self.lda = None
        self.filter_bank = []
        self.augment = augment
        channel_names=chnames
        freq=frequency
        numChannels=nChannels
        montage = mne.channels.read_montage('standard_1005')

        info = mne.create_info(ch_names=channel_names, sfreq=freq, ch_types='eeg', montage=montage)
        for b in range(num_bank):
            self.filter_bank.append([low_pass_freq + bank_size * b, low_pass_freq + bank_size * (b + 1)])

    def build_model(self, data, label):
        global info, csp_components
        print("{}: Building model with {} and {}".format(self.name, np.shape(data), np.shape(label)))
        self.csp_list = []
        self.lda=LinearDiscriminantAnalysis()
        csp_feature_train=None
        for i in range(num_bank):
            low_cut = self.filter_bank[i][0]
            high_cut = self.filter_bank[i][1]

            MI_epochs=mne.EpochsArray(data, info)
            MI_epochs.filter(low_cut,high_cut,method='iir')
            MI_epochs.set_eeg_reference('average',projection=True)
            csp = CSP(n_components=csp_components, norm_trace=True)

            x_train = csp.fit_transform(MI_epochs.get_data(), label)
            self.csp_list.append(csp)

            if i == 0:
                csp_feature_train = x_train
            else:
                csp_feature_train = np.concatenate((csp_feature_train, x_train), axis=1)
        self.lda.fit(csp_feature_train, label)

    def predict(self, data):
        global info
        csp_feature_eeg = None
        for i in range(num_bank):
            low_cut = self.filter_bank[i][0]
            high_cut = self.filter_bank[i][1]
            MI_epochs=mne.EpochsArray(data, info)
            MI_epochs.filter(low_cut,high_cut,method='iir')
            MI_epochs.set_eeg_reference('average',projection=True)
            csp = self.csp_list[i]
            x_train = csp.transform(MI_epochs.get_data())
            if i == 0:
                csp_feature_eeg = x_train
            else:
                csp_feature_eeg = np.concatenate((csp_feature_eeg, x_train), axis=1)

        return self.lda.predict(csp_feature_eeg)

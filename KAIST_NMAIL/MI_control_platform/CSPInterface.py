import time
from pylsl import StreamInlet, resolve_stream
import numpy as np
import threading
import datetime
import math
import Queue
from CommonSpatialPattern import CommonSpatialPattern
import os
import multiprocessing
from multiprocessing import Process, Pipe
from socket import *
from struct import *


freq = 500
channel_names=['F5','FC5','C5','CP5','P5','FC3','C3','CP3','P3','F1','FC1','C1','CP1','P1','Cz','CPz','Pz','F2','FC2','C2','CP2','P2','FC4','C4','CP4','P4','F6','FC6','C6','CP6','P6']
EEGdata_size = 20
wait_time = 1  # how long to wait before collecting data
action_time = 10 # time range to cut up strides
total_ch=31
select_ch=range(1, total_ch + 1)
window_sec=1

folder = "Data"
data_type = "EEG_CSPinterface(testing)"
date = datetime.datetime.now().strftime("%m%d")

class CSPInterface:

    def __init__(self, filenames, nChannels=31, frequency=512, streamer_type="OpenVibe", channels=None, subject=None):
        global total_ch, freq, select_ch
        total_ch=int(nChannels)
        freq=int(frequency)
        select_ch=range(1, total_ch + 1)
        self.name = self.__class__.__name__
        self.running = True
        self.edx = 0
        self.global_time = time.clock()
        channel_names=channels

        self.streamer=str(streamer_type)

        if (self.streamer == "OpenVibe"):
            print("{}: Looking for an EEG stream...".format(self.name))
            streams = resolve_stream('type', 'signal')
            self.inlet = StreamInlet(streams[0])

        i = 1
        fname = "{}/{}_{}_{}s{}ch_{}".format(folder, date, data_type, window_sec,
                                                   len(select_ch), subject)
        self.filename = "{}_{}.txt".format(fname, i)
        while os.path.exists(self.filename):
            i += 1
            self.filename = "{}_{}.txt".format(fname, i)
        self.file = open(self.filename, "w")
        print("{}: Writing to {}".format(self.name, self.filename))

        self.filenames = filenames
        file = open(filenames[0], "r")
        lines = file.readlines()
        self.total_ch = len(lines[0].split('],')[0].split(','))
        self.window_size = len(lines[0].split('],'))
        self.window_sec = int(self.window_size / freq)
        file.close()

        self.EEGdata = np.zeros((freq * EEGdata_size, self.total_ch + 1))
        self.model = CommonSpatialPattern(nChannels=self.total_ch, frequency=freq, chnames=channel_names)

        self.buffer = Queue.Queue()


    def make_model(self):
        print("{}: Making model".format(self.name))

        output_data = []
        output_label = []
        for fname in self.filenames:
            file = open(fname, 'r')
            lines = file.readlines()
            np_arr = []
            for line in lines:
                tokens = line.split(',')
                if len(tokens) > 1:
                    tokens = [float(i.strip(" [],\n")) for i in tokens]
                    np_arr = np.array(tokens).reshape((-1, self.total_ch))
                else:
                    trial_num = int(tokens[0])
                    if trial_num == -2:
                        continue
                    output_data.append(np_arr)
                    output_label.append(trial_num)
            file.close()

        output_data = np.transpose(output_data, [0, 2, 1])
        output_label = np.array(output_label)
        self.model.build_model(output_data, output_label)

    def receive_commands(self):
        print("{}: Receiving commands".format(self.name))
        self.edx=0
        prev_time=0
        start_time = time.clock()
        predicted_before=[1000]
        predicted_label=[1000]
        while self.running:
            current_time = int(math.floor(time.clock() - start_time))
            if current_time <= wait_time + action_time:
                continue
            time.sleep(0.01)

            if(current_time>=prev_time+window_sec):
                prev_time = current_time
                edx=self.edx
                selected_eeg = get_eeg(self.EEGdata, edx - (freq * self.window_sec), edx)
                self.file.write(str(np.ndarray.tolist(selected_eeg.T)) + '\n')
                
                selected_eeg = np.asarray(np.transpose(np.asmatrix(selected_eeg)))
                transformed_eeg = np.asarray([selected_eeg])
                predicted_before=predicted_label
                predicted_label = self.model.predict(transformed_eeg)
                print(predicted_label)
                #self.buffer.put(predicted_label[0])
                if(predicted_label[0]==0 and predicted_before[0]==0):
                    self.buffer.put('r')
                if(predicted_label[0]==1 and predicted_before[0]==1):
                    self.buffer.put('l')
                if(predicted_label[0]==2 and predicted_before[0]==2):
                    self.buffer.put('j')
                if(predicted_label[0]==3 and predicted_before[0]==3):
                    self.buffer.put('i')

                if(predicted_label[0]==4 and predicted_before[0]==4):
                    self.buffer.put('w')
                if(predicted_label[0]==5 and predicted_before[0]==5):
                    self.buffer.put('s')

    def retrieve_eeg(self):
        global total_ch
        if(self.streamer=="Brainvision Recorder"):
            parent_conn, child_conn = Pipe()
            eeg_process = multiprocessing.Process(target=retrieve_eeg_BREC, args=(child_conn,))
            eeg_process.start()
        sample=None
        while self.running:
            if(self.streamer=="Brainvision Recorder"):
                (sample, timestamp) = parent_conn.recv()
            elif(self.streamer=="OpenVibe"):
                sample, timestamp = self.inlet.pull_sample()
            if(sample==None or len(sample)!=total_ch):
                continue
            current_time = time.clock() - self.global_time
            self.EEGdata[self.edx % (freq * EEGdata_size), 0] = current_time
            self.EEGdata[self.edx % (freq * EEGdata_size), 1:total_ch + 1] = sample
            self.edx = self.edx + 1
            if self.edx >= freq * EEGdata_size:
                self.edx = 0

    def has_command(self):
        return not self.buffer.empty()

    def get_command(self):
        command = self.buffer.get()
        return command

    def end_operation(self):
        self.running = False
        self.inlet.close_stream()

    def start(self):

        eeg_thrd = threading.Thread(target=self.retrieve_eeg)
        eeg_thrd.daemon = True
        eeg_thrd.start()

        self.make_model()

        input_thrd = threading.Thread(target=self.receive_commands)
        input_thrd.daemon = True
        input_thrd.start()

def get_eeg(data, x, y):
    if x < 0:
        if y == 0:
            return data[x:(freq * EEGdata_size), select_ch]
        else:
            return np.concatenate((data[x:(freq * EEGdata_size), select_ch], data[0: y, select_ch]), axis=0)
    return data[x:y, select_ch]


######Brainvision Recorder section######


def RecvData(socket, requestedSize):
    returnStream = ''
    while len(returnStream) < requestedSize:
        databytes = socket.recv(requestedSize - len(returnStream))
        if databytes == '':
            raise RuntimeError
        returnStream += databytes

    return returnStream


def SplitString(raw):
    stringlist = []
    s = ""
    for i in range(len(raw)):
        if raw[i] != '\x00':
            s = s + raw[i]
        else:
            stringlist.append(s)
            s = ""

    return stringlist


def GetProperties(rawdata):
    # Extract numerical data
    (channelCount, samplingInterval) = unpack('<Ld', rawdata[:12])

    # Extract resolutions
    resolutions = []
    for c in range(channelCount):
        index = 12 + c * 8
        restuple = unpack('<d', rawdata[index:index + 8])
        resolutions.append(restuple[0])

    # Extract channel names
    channelNames = SplitString(rawdata[12 + 8 * channelCount:])

    return (channelCount, samplingInterval, resolutions, channelNames)


def retrieve_eeg_BREC(conn):
    con = socket(AF_INET, SOCK_STREAM)
    con.connect(("localhost", 51244))
    finish = False
    data1s = []
    lastBlock = -1

    while not finish:
        rawhdr = RecvData(con, 24)
        (id1, id2, id3, id4, msgsize, msgtype) = unpack('<llllLL', rawhdr)
        rawdata = RecvData(con, msgsize - 24)
        if msgtype == 1:
            (channelCount, samplingInterval, resolutions, channelNames) = GetProperties(rawdata)
            lastBlock = -1

            print("Start")
            print("Number of channels: " + str(channelCount))
            print("Sampling interval: " + str(samplingInterval))
            print("Resolutions: " + str(resolutions))
            print("Channel Names: " + str(channelNames))

        elif msgtype == 4:
            (block, points, markerCount) = unpack('<LLL', rawdata[:12])
            data = []
            for i in range(points * channelCount):
                index = 12 + 4 * i
                value = unpack('<f', rawdata[index:index + 4])
                data.append(value[0])
                if (len(data) == channelCount):
                    conn.send((data, time.clock()))
                    data = []

        elif msgtype == 3:
            file.close()
            print("Stop")
            finish = True
    con.close()

import time
import numpy as np
import threading
import math
import os
import datetime
import socket
import random
from pylsl import StreamInlet, resolve_stream
from multiprocessing import Queue
from time import sleep
import multiprocessing
from multiprocessing import Process, Pipe
from struct import *
#from BCI_GUI import write_to_progress

# Channel Names (1~32)
# 1: Fp1, Fz, F3, F7,
# 5: FT9, FC5, FC1, C3,
# 9: T7, TP9, CP5, CP1,
# 13: Pz, P3, P7, O1,
# 17: Oz, O2, P4, P8,
# 21: TP10, CP6, CP2, Cz,
# 25: C4, T8, FT10, FC6,
# 29: FC2, F4, F8, Fp2
# reference_channel = [24]  # Cz for reference

# ip = "143.248.135.204"
ip = "127.0.0.1"
port = 10002

EEGdata_size = 512
freq = 500
total_ch = 31
select_ch = range(1, total_ch+1)

num_trials = 10
window_sec = 1
session_sec = 8
wait_time = 0   # how long to wait before starting to collect eeg

num_classes = 4  # right, left, both, rest
class_order = [1, 2, 3, 0]
class_random = True
num_iteration = len(class_order)

folder = "Data"
data_type = "EEG_hands"
date = datetime.datetime.now().strftime("%m%d")

channel_names=[]

class HandRecorder:

    def __init__(self, subject="test", nChannels=31, frequency=512, streamer_type="Brainvision Recorder", channels=None):
        global screen, total_ch, freq, select_ch
        freq = int(frequency)
        total_ch = int(nChannels)
        select_ch = range(1, total_ch + 1)
        channel_names=channels

        self.streamer = str(streamer_type)
        self.name = self.__class__.__name__
        self.running = True
        self.server_running = True
        self.server_connected = False
        self.sock = None
        self.global_time = time.clock()
        self.EEGdata = np.zeros((freq * EEGdata_size, total_ch + 1))
        self.label = ""
        self.samples=0
        self.print_label=0
        self.edx=0

        print("{}: Looking for an EEG stream...".format(self.name))

        if (self.streamer == "OpenVibe"):
            print("{}: Looking for an EEG stream...".format(self.name))
            streams = resolve_stream('type', 'signal')
            self.inlet = StreamInlet(streams[0])

        i = 1
        fname = "{}/{}_{}_{}t{}c{}s{}ch_{}".format(folder, date, data_type, num_trials, num_classes, window_sec, len(select_ch), subject)
        self.filename = "{}_{}.txt".format(fname, i)
        while os.path.exists(self.filename):
            i += 1
            self.filename = "{}_{}.txt".format(fname, i)
        self.file = open(self.filename, "w")
        print("{}: Writing to {}".format(self.name, self.filename))


        self.output_data = []
        self.output_label = []
        self.class_count = [0] * num_classes

    def get_label(self):
        return self.print_label

    def collect_data(self):
        self.sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        server_address = (ip, port)
        self.sock.bind(server_address)
        self.sock.listen(100)
        connection, client_address = self.sock.accept()

        label=[0 for i in range(num_trials*num_iteration)]
        sleep(20)
        for i in range(num_trials*num_iteration):
            if(class_random==False):
                label[i] = class_order[i % num_iteration]
            elif(class_random==True):
                if(i%num_iteration==0):
                    class_flags=[0]*num_iteration
                while True:
                    temp=random.randint(1,num_iteration) - 1
                    if(class_flags[temp]==0):
                        class_flags[temp]=1
                        label[i] = class_order[temp]
                        break
        print("{}: Collection starting".format(self.name))
        #write_to_progress("Collection Started")
        for i in range(num_trials * num_iteration):
            self.edx=0
            self.samples=0
            flag=1
            start_time=time.time()
            prev_time=0
            while True:
                current_time=time.time()-start_time
                if current_time >= 1 and flag == 1:  # cross
                    self.label = 'w'
                    connection.sendall(self.label.encode())
                    self.print_label=0
                    flag = 2
                elif current_time >= 2 and flag == 2 and label[i] == 0:  # rest
                    self.label = 'w'
                    connection.sendall(self.label.encode())
                    self.print_label=0
                    flag = 3
                elif current_time >= 2 and flag == 2 and label[i] == 1:  # right
                    self.label = 'd'
                    connection.sendall(self.label.encode())
                    self.print_label=0
                    flag = 3
                elif current_time >= 2 and flag == 2 and label[i] == 2:  # left
                    self.label = 'a'
                    connection.sendall(self.label.encode())
                    self.print_label=0
                    flag = 3
                elif current_time >= 2 and flag == 2 and label[i] == 3:  # both
                    self.label = 's'
                    connection.sendall(self.label.encode())
                    self.print_label=0
                    flag = 3
                elif current_time >= 4 and flag == 3:  # cross
                    self.label = 'w'
                    connection.sendall(self.label.encode())
                    self.print_label=0
                    flag = 4
                elif current_time >= 5 and flag == 4:  # cross
                    print("start recording")
                    if label[i] == 0:
                        print("rest")
                        #write_to_progress("rest")
                        self.label = 'i'
                        connection.sendall(self.label.encode())
                        self.print_label=1
                    if label[i] == 1:
                        print("right")
                        #write_to_progress("right")
                        self.label = 'l'
                        connection.sendall(self.label.encode())
                        self.print_label=2
                    if label[i] == 2:
                        print("left")
                        #write_to_progress("left")
                        self.label = 'j'
                        connection.sendall(self.label.encode())
                        self.print_label=3
                    if label[i] == 3:
                        print("both")
                        #write_to_progress("both")
                        self.label = 'k'
                        connection.sendall(self.label.encode())
                        self.print_label=4
                    flag = 5
                elif (current_time >= (5 + wait_time+ window_sec) and current_time >= prev_time + window_sec and flag == 5):
                    prev_time = current_time
                    selected_eeg = self.EEGdata[(self.edx - (freq * window_sec)): self.edx, select_ch]
                    self.output_data.append(selected_eeg.T)
                    self.output_label.append(self.print_label-1)
                    self.file.write(str(np.ndarray.tolist(selected_eeg)) + '\n')
                    self.file.write(str(self.print_label-1) + '\n')
                    self.class_count[self.print_label-1] += 1
                elif current_time >= (5 + wait_time + session_sec) and flag==5:  # 3 second data
                    self.label = 'i'
                    connection.sendall(self.label.encode())
                    self.print_label=0
                    flag=6
                elif current_time > (6 + wait_time + session_sec):
                    self.label = 'i'
                    connection.sendall(self.label.encode())
                    print("end recording")
                    break

        sleep(10)
        self.file.close()
        connection.close()
        print("{}: Collection finished".format(self.name))
        #write_to_progress("Collection Finished")

    def retrieve_eeg(self):
        if (self.streamer == "Brainvision Recorder"):
            parent_conn, child_conn = Pipe()
            eeg_process = multiprocessing.Process(target=retrieve_eeg_BREC, args=(child_conn,))
            eeg_process.start()

        while self.running:
            if (self.streamer == "Brainvision Recorder"):
                (sample, timestamp) = parent_conn.recv()
            elif (self.streamer == "OpenVibe"):
                sample, timestamp = self.inlet.pull_sample()

            current_time = time.clock() - self.global_time
            self.EEGdata[self.edx % (freq * EEGdata_size), 0] = current_time
            self.EEGdata[self.edx % (freq * EEGdata_size), 1:total_ch + 1] = sample
            self.edx = self.edx + 1
            if self.edx >= freq * EEGdata_size:
                self.edx = 0

    def close_recorder(self):
        self.file.close()
        self.running = False
        if(self.streamer == "OpenVibe"):
            self.inlet.close_stream()

    def send_hand(self, label):
        try:
            command = ['i', 'l', 'j', 'k'][int(label)]
        except ValueError:
            return
        self.label = command

    def start(self):
        eeg_thrd = threading.Thread(target=self.retrieve_eeg)
        eeg_thrd.daemon = True
        eeg_thrd.start()
        print("{}: Waiting for Unity...".format(self.name))
        #write_to_progress("Waiting for Unity...")
        self.collect_data()
        self.close_recorder()

        return self.filename


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


import time
import numpy as np
import threading
import math
import os
import datetime
import pygame
import keyboard
from ctypes import windll
from pylsl import StreamInlet, resolve_stream
from scipy.signal import butter, lfilter
from FBCSP import FBCSP
from CommonSpatialPattern import CommonSpatialPattern
import multiprocessing
from multiprocessing import Process, Pipe
from socket import *
from struct import *

EEGdata_size = 60
freq = 512
total_ch = 31
select_ch = range(1, total_ch + 1)

num_trials = 8
num_tests = 0
session_sec = 12  # how long each session is
window_sec = 3
stride_sec = 1
wait_time = 0  # how long to wait before starting to collect eeg

num_classes = 4  # rest, right, left, up
class_order = [3, 0, 1, 2]
num_iteration = len(class_order)

folder = "Data"
data_type = "EEG_BallFour(training)"
date = datetime.datetime.now().strftime("%m%d")

SetWindowPos = windll.user32.SetWindowPos
NOSIZE = 1
NOMOVE = 2
TOPMOST = -1
NOT_TOPMOST = -2
circle_radius = 20
XSCREEN = 1920  # 1600
YSCREEN = 1080  # 900
screen = None
plus_size = XSCREEN / 24

channel_names=[]


class Marker:
    def __init__(self):
        self.position = 0
        self.points = 0
        self.channel = -1
        self.type = ""
        self.description = ""

class BallRecorderFour:
    def __init__(self, subject="test", nChannels=31, frequency=512, streamer_type="OpenVibe", channels=None):
        global screen, total_ch, freq, select_ch, channel_names
        freq = int(frequency)
        channel_names=channels
        total_ch = int(nChannels)
        select_ch = range(1, total_ch + 1)

        self.streamer=str(streamer_type)
        self.name = self.__class__.__name__
        self.running = True
        self.edx = 0
        self.global_time = time.clock()
        self.EEGdata = np.zeros((freq * EEGdata_size, total_ch + 1))

        if(self.streamer=="OpenVibe"):
            print("{}: Looking for an EEG stream...".format(self.name))
            streams = resolve_stream('type', 'signal')
            self.inlet = StreamInlet(streams[0])

        i = 1
        fname = "{}/{}_{}_{}t{}c{}s{}ch_{}".format(folder, date, data_type, num_trials, num_classes, window_sec,
                                                   len(select_ch), subject)
        self.filename = "{}_{}.txt".format(fname, i)
        while os.path.exists(self.filename):
            i += 1
            self.filename = "{}_{}.txt".format(fname, i)
        self.file = open(self.filename, "w")
        print("{}: Writing to {}".format(self.name, self.filename))

        pygame.init()
        pygame.font.init()
        screen = pygame.display.set_mode([XSCREEN, YSCREEN], pygame.FULLSCREEN)
        always_on_top(False)
        self.output_data = []
        self.output_label = []
        self.class_count = [0] * num_classes

        self.model = CommonSpatialPattern(augment=False, nChannels=total_ch, chnames=channels)

    @staticmethod
    def draw_train(flag):
        screen.fill((0, 0, 0))
        if flag == 0:
            pygame.draw.rect(screen, (255, 255, 255), (XSCREEN / 2 - (plus_size / 2), YSCREEN / 2 - 3, plus_size, 6))
            pygame.draw.rect(screen, (255, 255, 255), (XSCREEN / 2 - 3, YSCREEN / 2 - (plus_size / 2), 6, plus_size))
        elif flag == 1:
            pygame.draw.polygon(screen, (255, 255, 255), (
                (XSCREEN / 2 - (plus_size / 2), YSCREEN / 2 - (plus_size / 2)),
                (XSCREEN / 2 + (plus_size / 2), YSCREEN / 2),
                (XSCREEN / 2 - (plus_size / 2), YSCREEN / 2 + (plus_size / 2))))
        elif flag == 2:
            pygame.draw.polygon(screen, (255, 255, 255), (
                (XSCREEN / 2 - (plus_size / 2), YSCREEN / 2),
                (XSCREEN / 2 + (plus_size / 2), YSCREEN / 2 - (plus_size / 2)),
                (XSCREEN / 2 + (plus_size / 2), YSCREEN / 2 + (plus_size / 2))))
        elif flag == 3:
            pygame.draw.polygon(screen, (255, 255, 255), (
                (XSCREEN / 2, YSCREEN / 2 - (plus_size / 2)),
                (XSCREEN / 2 + (plus_size / 2), YSCREEN / 2 + (plus_size / 2)),
                (XSCREEN / 2 - (plus_size / 2), YSCREEN / 2 + (plus_size / 2))))
        else:
            assert False
        pygame.display.update()

    @staticmethod
    def draw_test(flag):
        screen.fill((0, 0, 0))
        if flag == 0:
            pygame.draw.rect(screen, (255, 255, 255),
                             (int(XSCREEN / 2) - (plus_size / 2), int(YSCREEN / 2) - 3, plus_size, 6))
            pygame.draw.rect(screen, (255, 255, 255),
                             (int(XSCREEN / 2) - 3, int(YSCREEN / 2) - (plus_size / 2), 6, plus_size))
        elif flag == 1:
            pygame.draw.rect(screen, (0, 255, 0), (XSCREEN - circle_radius, 0, circle_radius, YSCREEN))
            pygame.draw.circle(screen, (0, 0, 255), (int(XSCREEN / 2), YSCREEN - circle_radius * 2), circle_radius)
        elif flag == 2:
            pygame.draw.rect(screen, (0, 255, 0), (0, 0, circle_radius, YSCREEN))
            pygame.draw.circle(screen, (0, 0, 255), (int(XSCREEN / 2), YSCREEN - circle_radius * 2), circle_radius)
        elif flag == 3:
            pygame.draw.rect(screen, (0, 255, 0), (0, 0, XSCREEN, circle_radius))
            pygame.draw.circle(screen, (0, 0, 255), (int(XSCREEN / 2), YSCREEN - circle_radius * 2), circle_radius)
        else:
            assert False
        pygame.display.update()

    @staticmethod
    def update_circle(x, y, v_x, v_y):
        pygame.draw.circle(screen, (0, 0, 0), (x, y), circle_radius)
        x += v_x
        y += v_y
        pygame.draw.circle(screen, (0, 0, 255), (x, y), circle_radius)
        pygame.display.update()
        return x, y

    def collect_data(self):
        print("{}: Collection starting".format(self.name))
        for i in range(num_trials * num_iteration):
            self.edx = 0
            time.sleep(5)
            flag = class_order[i % num_iteration]
            self.draw_train(flag)
            start_time = time.clock()
            prev_time = 0
            while True:
                current_time = int(math.floor(time.clock() - start_time))
                if current_time >= session_sec:
                    break
                if current_time >= wait_time + window_sec and current_time >= prev_time + stride_sec:
                    prev_time = current_time
                    edx=self.edx
                    selected_eeg = self.EEGdata[(edx - (freq * window_sec)): edx, select_ch]
                    print(selected_eeg)
                    self.output_data.append(selected_eeg.T)
                    self.output_label.append(flag)
                    self.file.write(str(np.ndarray.tolist(selected_eeg)) + '\n')
                    self.file.write(str(flag) + '\n')
                    self.class_count[flag] += 1
            screen.fill((0,0,0))
            pygame.display.update()
        print("{}: Collection finished".format(self.name))

    def test_model(self):
        print("{}: Started model testing".format(self.name))
        for t in range(num_tests * 3):
            # collecting direction data
            size_rest, size_right, size_left, size_up = self.class_count
            circle_x = int(XSCREEN / 2)
            circle_y = YSCREEN - circle_radius * 2
            v_x = 0
            v_y = 0
            if size_right <= size_left and size_right <= size_up:
                flag = 1
            elif size_left <= size_right and size_left <= size_up:
                flag = 2
            else:
                flag = 3
            self.draw_test(flag)
            self.edx = 0
            start_time = time.clock()
            prev_time = 0
            print("Flag is: {}, class_count is: {}".format(flag, self.class_count))
            while circle_radius < circle_x < XSCREEN - circle_radius and circle_y > circle_radius:
                current_time = int(math.floor(time.clock() - start_time))
                if keyboard.is_pressed('m'):
                    time.sleep(2)
                    break
                if keyboard.is_pressed('p'):
                    self.file.close()
                    time.sleep(3)
                    print("{}: Forced close model testing".format(self.name))
                    return
                if current_time < 3:
                    continue

                circle_x, circle_y = self.update_circle(circle_x, circle_y, v_x, v_y)
                time.sleep(0.01)

                if current_time >= prev_time + window_sec:
                    prev_time = current_time
                    edx=self.edx
                    selected_eeg = get_eeg(self.EEGdata, edx - (freq * window_sec), edx)
                    transformed_eeg = np.asarray(np.transpose(np.asmatrix(selected_eeg)))
                    transformed_eeg = np.asarray([transformed_eeg])
                    print(transformed_eeg)
                    if np.shape(transformed_eeg) != (1, len(select_ch), window_sec * freq):
                        print(np.shape(transformed_eeg))
                        assert False

                    predicted_label = self.model.predict(transformed_eeg)
                    print(predicted_label)
                    if predicted_label[0] == 0:
                        v_x = 0
                        v_y = 0
                    elif predicted_label[0] == 1:
                        v_x = 1
                        v_y = 0
                    elif predicted_label[0] == 2:
                        v_x = -1
                        v_y = 0
                    elif predicted_label[0] == 3:
                        v_x = 0
                        v_y = -1
                    self.output_data.append(selected_eeg.T)
                    self.output_label.append(flag)
                    self.file.write(str(np.ndarray.tolist(selected_eeg)) + '\n')
                    self.file.write(str(flag) + '\n')
                    self.class_count[flag] += 1

            # collecting rest data
            flag = 0
            self.draw_test(flag)
            self.edx = 0
            start_time = time.clock()
            prev_time = 0
            size_rest, size_right, size_left, size_up = self.class_count
            while size_rest < min(size_left, size_right, size_up):
                current_time = int(math.floor(time.clock() - start_time))
                if keyboard.is_pressed('m'):
                    time.sleep(2)
                    break
                if keyboard.is_pressed('p'):
                    self.file.close()
                    time.sleep(3)
                    print("{}: Forced close model testing".format(self.name))
                    return

                if current_time >= 3 and current_time >= prev_time + window_sec:
                    prev_time = current_time
                    edx=self.edx
                    selected_eeg = get_eeg(self.EEGdata, edx - (freq * window_sec), edx)
                    self.output_data.append(selected_eeg.T)
                    self.output_label.append(flag)
                    self.file.write(str(np.ndarray.tolist(selected_eeg)) + '\n')
                    self.file.write(str(flag) + '\n')
                    self.class_count[flag] += 1
                    size_rest, size_right, size_left, size_up = self.class_count

            min_data = []
            min_label = []
            min_count = min(self.class_count)
            count = [0] * num_classes
            print("len_output_data: {}, min_count: {}".format(len(self.output_data), min_count))
            for j in range(len(self.output_data)):
                if count[self.output_label[j]] >= min_count:
                    continue
                min_data.append(self.output_data[j])
                min_label.append(self.output_label[j])
                count[self.output_label[j]] += 1

            self.model.build_model(min_data, min_label)

    def close_recorder(self):
        self.file.close()
        self.running = False
        if(self.streamer=="OpenVibe"):
            self.inlet.close_stream()
        pygame.display.quit()

    def retrieve_eeg(self):
        if(self.streamer=="Brainvision Recorder"):
            parent_conn, child_conn = Pipe()
            eeg_process = multiprocessing.Process(target=retrieve_eeg_BREC, args=(child_conn,))
            eeg_process.start()

        while self.running:
            if(self.streamer=="Brainvision Recorder"):
                (sample, timestamp) = parent_conn.recv()
            elif(self.streamer=="OpenVibe"):
                sample, timestamp = self.inlet.pull_sample()

            current_time = time.clock() - self.global_time
            self.EEGdata[self.edx % (freq * EEGdata_size), 0] = current_time
            self.EEGdata[self.edx % (freq * EEGdata_size), 1:total_ch + 1] = sample
            self.edx = self.edx + 1
            if self.edx >= freq * EEGdata_size:
                self.edx = 0

    def start(self):
        eeg_thrd = threading.Thread(target=self.retrieve_eeg)
        eeg_thrd.daemon = True
        eeg_thrd.start()

        self.collect_data()
        self.model.build_model(self.output_data, self.output_label)
        self.test_model()
        self.close_recorder()

        return self.filename


def always_on_top(b):
    zorder = (NOT_TOPMOST, TOPMOST)[b]  # choose a flag according to bool
    hwnd = pygame.display.get_wm_info()['window']  # handle to the window
    SetWindowPos(hwnd, zorder, 0, 0, 0, 0, NOMOVE | NOSIZE)


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


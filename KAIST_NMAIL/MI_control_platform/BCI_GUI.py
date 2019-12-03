from Tkinter import *
import ttk
from ttk import Combobox
from ScreenOutput import ScreenOutput
#from BebopController import BebopController
#from WheelchairController import WheelchairController
from BallRecorderFour import BallRecorderFour
from BallRecorderSix import BallRecorderSix
from HandRecorder import HandRecorder
#from Recorder.ConcentrationRecorder import ConcentrationRecorder
#from Recorder.WBCIRecorder import WBCIRecorder
#from Recorder.HandRecorder import HandRecorder
#from Recorder.SSVEPRecorder import SSVEPRecorder
#from Recorder.MISSVEPRecorder import MISSVEPRecorder
#from Interface.KeyboardInterface import KeyboardInterface
from FilterbankInterface import FilterbankInterface
from CSPInterface import CSPInterface
#from Interface.FilterbankProbabilityInterface import FilterbankProbabilityInterface
#from Interface.DroneInterface import DroneInterface
#from Interface.DroneInterfaceSix import DroneInterfaceSix
#from Interface.DroneInterfaceSixF import DroneInterfaceSixF
#from Interface.WheelchairInterface import WheelchairInterface
#from Device.droneDevice import droneDevice
import threading
import socket
import os

ip = "127.0.0.1"
device_port = 14000
model_port = 14100
subject = "test"

channels =['F5','FC5','C5','CP5','P5','FC3','C3','CP3','P3','F1','FC1','C1','CP1','P1','Cz','CPz','Pz','F2','FC2','C2','CP2','P2','FC4','C4','CP4','P4','F6','FC6','C6','CP6','P6']

# Socket for communication with the device
device_sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
device_conn = None

# Socket for communication with the model
model_sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
model_conn = None

device=None
thread_dev=None
interface=None
crecorder=None
cfilename=None

streamer_type=None
nChannels=31
frequency=512
def write_to_progress(words):
    global text1, text2
    text1.insert(END, words+"\n")
    text2.insert(END, words+"\n")

def setup_device_socket():
    global device_sock, device_conn, ip, device_port
    device_sock.bind((ip, device_port))
    device_sock.listen(1)
    device_conn, addr = device_sock.accept()


def setup_model_socket():
    global model_sock, model_conn
    model_sock.bind((ip, model_port))
    model_sock.listen(1)
    model_conn, addr = model_sock.accept()

def run_protocol():
    global subject, combo_protocol, crecorder, cfilename, nChannels, frequency, combo_streamer
    subject=entry_subject.get()
    protocol=combo_protocol.get()
    streamer=combo_streamer.get()
    write_to_progress(protocol)
    if(protocol=="Four Class Recorder"):
        crecorder = BallRecorderFour(subject,nChannels,frequency, streamer, channels)
    if(protocol=="Six Class Recorder"):
        crecorder = BallRecorderSix(subject,nChannels,frequency, streamer,channels)

    if(protocol=="Hand Recorder"):
        write_to_progress("Waiting for Unity...")
        crecorder=HandRecorder(subject,nChannels,frequency,streamer,channels)

    write_to_progress("Protocol Running...")
    cfilename = crecorder.start()
    write_to_progress("Protocol Finished...")

def connect_device():
    global thread_dev, device, combo_deviceType, ip, device_port
    ip=entry_IP.get()
    deviceType=combo_deviceType.get()
    if(deviceType=="Screen Output"):
        device = ScreenOutput()
    write_to_progress("Processing connection...")
    setup_device_socket()
    print("Main: Done")

    write_to_progress("Device Connected!!")

def start_interface():
    global interface, device, cfilename, device_conn, combo_model, nChannels, frequency, channels, streamer_type, subject
    model=combo_model.get()

    if(model=="Filter Bank CSP"):
        interface = FilterbankInterface([cfilename], nChannels=nChannels, frequency=frequency, streamer_type=streamer_type,channels=channels, subject=subject)
    elif(model=="CSP"):
        interface = CSPInterface([cfilename], nChannels=nChannels, frequency=frequency, streamer_type=streamer_type,channels=channels, subject=subject)
    interface.start()

    write_to_progress("Interface Running...")

    while True:
        label = ""
        if interface.has_command():
            label = str(interface.get_command())

        if label != "":
            if label == 'q':
                device.end_operation()
                interface.end_operation()
                break

            device_conn.sendall(label.encode())

    device_conn.close()

def EEG_settings():
    global entry_nChannels, entry_frequency, nChannels, frequency, combo_streamer,entry_chnames, streamer_type
    nChannels=entry_nChannels.get()
    frequency=entry_frequency.get()
    streamer_type=combo_streamer.get()
    chnames=entry_chnames.get(1.0, "end-1c")
    print(chnames)
    chnames.replace(" ","")
    channels=[]
    for i in chnames.split(","):
        channels.append(str(i))
    if(int(nChannels)==len(channels)):
        write_to_progress("===========settings==========")
        write_to_progress("channels: "+str(nChannels))
        write_to_progress("frequency: "+str(frequency))
        write_to_progress("streamer: "+str(streamer_type))
        write_to_progress("chnames: "+str(chnames))
        write_to_progress("===========confirmed==========")
    else:
        write_to_progress("ERROR!!")
        write_to_progress("Number of channels mismatch")
        write_to_progress("Please redo settings!!")

root = Tk()
root.title('Brain-Computer Interface Device Control Software Platform')
tab_parent=ttk.Notebook(root)
main_tab=ttk.Frame(tab_parent)
settings_tab=ttk.Frame(tab_parent)
tab_parent.add(main_tab,text="Main")
tab_parent.add(settings_tab,text="Settings")
tab_parent.pack(expand=1, fill='both')

################################### Main Tab ######################################
frame_protocol = LabelFrame(main_tab, text="Trainer", relief=GROOVE)
label_subject = Label(frame_protocol, text="Subject Name: ")
entry_subject = Entry(frame_protocol)
entry_subject.insert(END,'test')
protocol_type=["Four Class Recorder","Six Class Recorder","Hand Recorder"]
label_protocol = Label(frame_protocol, text="Training Protocol: ")
combo_protocol = Combobox(frame_protocol,values=protocol_type, state='readlonly')
combo_protocol.current(0)
button_protocol=Button(frame_protocol, text="Start Protocol", command=run_protocol)

frame_protocol.grid(row=0, sticky='NSEW')
label_subject.grid(row=0, column=0, sticky='E')
entry_subject.grid(row=0, column=1, sticky='WE')
label_protocol.grid(row=1, column=0, sticky='E')
combo_protocol.grid(row=1, column=1, sticky='WE')
button_protocol.grid(row=2, column=1, sticky='WE')

frame_device = LabelFrame(main_tab, text="Device", relief=GROOVE)
device_type=["Screen Output","Device"]
label_deviceType=Label(frame_device,text="Device Type: ")
combo_deviceType=Combobox(frame_device,values=device_type, state='readlonly')
combo_deviceType.current(0)
label_IP = Label(frame_device, text="Device IP: ")
entry_IP = Entry(frame_device)
entry_IP.insert(END,'127.0.0.1')
button_device=Button(frame_device, text="Connect Device", command=connect_device)

frame_device.grid(row=3, sticky='NSEW')
label_deviceType.grid(row=3, column=0, sticky='E')
combo_deviceType.grid(row=3,column=1,sticky='WE')
label_IP.grid(row=4, column=0, sticky='E')
entry_IP.grid(row=4, column=1, sticky='WE')
button_device.grid(row=5, column=1, sticky='WE')

frame_trainer = LabelFrame(main_tab, text="Interface", relief=GROOVE)
trainer_type=["Filter Bank CSP", "CSP"]
label_model = Label(frame_trainer, text="Training Model: ")
combo_model = Combobox(frame_trainer,values=trainer_type, state='readlonly')
combo_model.current(0)
button_model=Button(frame_trainer, text="Start Interface", command=start_interface)

frame_trainer.grid(row=6, sticky='NSEW')
label_model.grid(row=6, column=0, sticky='E')
combo_model.grid(row=6, column=1, sticky='WE')
button_model.grid(row=7, column=1, sticky='WE')

#frame_interface=LabelFrame(main_tab,text="Interface", relief=GROOVE)
#button_interface=Button(frame_interface,text="start interface", command=start_interface)
#frame_interface.grid(row=7, sticky='NSEW')
#button_interface.grid(row=7, column=1)

frame_text1=LabelFrame(main_tab, text="Progress Window", relief=GROOVE)
text1=Text(frame_text1)
scr1=Scrollbar(frame_text1,orient=VERTICAL, command=text1.yview)
frame_text1.grid(row=0, column=2, rowspan=7,sticky='NSEW')
text1.grid(row=0,column=2,rowspan=7, sticky='W')
scr1.grid(row=0, column=3, rowspan=7,sticky='NS')
text1.config(yscrollcommand=scr1.set, width=30, height=16)


################################# Settings Tab ####################################
frame_EEG = LabelFrame(settings_tab, text="Settings", relief=GROOVE)
label_nChannels = Label(frame_EEG, text="Number of Channels: ")
entry_nChannels = Entry(frame_EEG)
entry_nChannels.insert(END,'31')
label_frequency = Label(frame_EEG, text="Frequency Rate(Hz): ")
entry_frequency = Entry(frame_EEG)
entry_frequency.insert(END,'512')
streamer_type=["OpenVibe","Brainvision Recorder"]
label_streamer=Label(frame_EEG, text="Streamer: ")
combo_streamer=Combobox(frame_EEG, values=streamer_type, state='readlonly')
combo_streamer.current(0)
label_chnames = Label(frame_EEG, text="Channel Names")
entry_chnames = Text(frame_EEG)
entry_chnames.insert(END, 'F5,FC5,C5,CP5,P5,FC3,C3,CP3,P3,F1,FC1,C1,CP1,P1,Cz,CPz,Pz,F2,FC2,C2,CP2,P2,FC4,C4,CP4,P4,F6,FC6,C6,CP6,P6')

button_EEG=Button(frame_EEG, text="Confirm EEG Settings", command=EEG_settings)


frame_EEG.grid(row=0, sticky='NSEW')
label_nChannels.grid(row=0, column=0, sticky='E')
entry_nChannels.grid(row=0, column=1, sticky='WE')
label_frequency.grid(row=1, column=0, sticky='E')
entry_frequency.grid(row=1, column=1, sticky='WE')
label_streamer.grid(row=2, column=0, sticky='E')
combo_streamer.grid(row=2, column=1, sticky='WE')
label_chnames.grid(row=3, sticky='NE')
entry_chnames.grid(row=3, column=1, sticky='WE')
entry_chnames.config(width=20, height=10)
button_EEG.grid(row=4,column=1,sticky='WE')

frame_text2=LabelFrame(settings_tab, text="Progress Window", relief=GROOVE)
text2=Text(frame_text2)
scr2=Scrollbar(frame_text2,orient=VERTICAL, command=text2.yview)
frame_text2.grid(row=0, column=2, rowspan=7,sticky='NSEW')
text2.grid(row=0,column=2,rowspan=7, sticky='W')
scr2.grid(row=0, column=3, rowspan=7,sticky='NS')
text2.config(yscrollcommand=scr2.set, width=30, height=16)

root.mainloop()
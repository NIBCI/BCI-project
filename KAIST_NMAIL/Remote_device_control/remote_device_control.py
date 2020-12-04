from tkinter import *
import tkinter.ttk as ttk
from tkinter.ttk import *
import threading
import socket
import os
from threading import Thread
from time import sleep
from socket import SHUT_RDWR

hostname = socket.gethostname()
ip_addr = socket.gethostbyname(hostname)
com_port = None
app_port = None

# Socket for communication with the device
com_sock = None
com_conn = None

# Socket for communication with the model
app_sock = None
app_conn = None

cur_direction = None

comm_thread = None
man_thread = None

def write_to_progress(words):
   global text
   text.insert(END, words+"\n")

def change_status(entry, message):
   entry.config(state = 'normal')
   entry.delete(0, 'end')
   entry.insert(END, message)
   if 'DIS' in message:
      entry.config(foreground = 'red')
   else:
      entry.config(foreground = 'green')
   entry.config(state = 'readonly')

def setup_com_socket(com_config):
   global com_sock, com_conn
   write_to_progress("Setting up sockets to BCI computer...")
   tmp = com_config.split(' - ')
   com_ip, com_port = tmp[0], int(tmp[1])
   print(com_ip, com_port)
   com_sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
   com_sock.bind((com_ip, com_port))
   com_sock.listen()
   com_conn, addr = com_sock.accept()
   write_to_progress("Setup done")

def setup_app_socket(app_config):
   global app_sock, app_conn
   write_to_progress("Setting up sockets to DJI app...")
   tmp = app_config.split(' - ')
   app_ip, app_port = tmp[0], int(tmp[1])
   print(app_ip, app_port)
   app_sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
   app_sock.bind((app_ip, app_port))
   app_sock.listen(1)
   app_conn, addr = app_sock.accept()
   write_to_progress("Setup done")

def connect_com():
   com_config = entry_bci_ip.get()

   ### connect to BCI computer socket ###
   write_to_progress("Processing connection to BCI computer...")
   setup_com_socket(com_config)
   write_to_progress("Device Connected!!")
   change_status(entry_bci_con, 'CONNECTED')

def connect_app():
   app_config = entry_app_ip.get()

   write_to_progress("Processing connection to DJI app...")
   setup_app_socket(app_config)
   write_to_progress("Device Connected!!")
   change_status(entry_app_con, 'CONNECTED')

def start_thread():
   comm_thread = Thread(target=comm)
   comm_thread.start()


def highlight_arrow(msg):
   global cur_direction, canvas
   if cur_direction != None:
      canvas.itemconfig(cur_direction, fill = 'black')

   direction = msg.decode("utf8")

   if direction == 'e':
      cur_direction = arrow_up
   elif direction == 'q':
      cur_direction = arrow_down
   elif direction == 'd':
      cur_direction = arrow_right
   elif direction == 'a':
      cur_direction = arrow_left
   elif direction == 'w':
      cur_direction = arrow_for
   elif direction == 's':
      cur_direction = arrow_back

   canvas.itemconfig(cur_direction, fill = 'red')

def comm():
   global com_conn, app_conn, com_sock, app_sock
   write_to_progress("Establishing connection...")

   if entry_bci_con.get() == 'DISCONNECTED':
      write_to_progress("Com connection not established")

   elif entry_app_con.get() == 'DISCONNECTED':
      write_to_progress("App connection not established")

   else:
      write_to_progress("Connection established")
      change_status(entry_thr_con, 'CONNECTED')
      prev_msg = "dummyMSG"
      while True:
         try:
            msg = com_conn.recv(1024)
            if not msg:
               write_to_progress("Com connection lost")
               change_status(entry_bci_con, 'DISCONNECTED')
               change_status(entry_thr_con, 'DISCONNECTED')
               break
         except:
            write_to_progress("Com connection lost")
            change_status(entry_bci_con, 'DISCONNECTED')
            change_status(entry_thr_con, 'DISCONNECTED')
            break

         highlight_arrow(msg)

         try:
            app_conn.send(msg)

         except:
            write_to_progress("App connection lost")
            change_status(entry_app_con, 'DISCONNECTED')
            change_status(entry_thr_con, 'DISCONNECTED')
            break
         
def man_con(command):

   global com_sock, app_conn

   try:

      if command == 'i':
         com_sock.shutdown(SHUT_RDWR)
         com_sock.close()

      command = command + '\n'
      app_conn.send(command.encode())
      write_to_progress("Sending: " + command)
      highlight_arrow(command.encode())

   except:
      write_to_progress("Connection not established with DJI app")

######################################## GUI ######################################

root = Tk()
root.title('Brain-Computer Interface Device Control Software Platform')
tab_parent=ttk.Notebook(root)
main_tab=ttk.Frame(tab_parent)
settings_tab=ttk.Frame(tab_parent)
tab_parent.add(main_tab,text="Main")
tab_parent.pack(expand=1, fill='both')


################################### Main Tab ######################################

frame_bci = LabelFrame(main_tab, text="BCI Computer", relief=GROOVE)
label_bci_ip = Label(frame_bci, text="Device IP: ")
entry_bci_ip = Entry(frame_bci)
entry_bci_ip.insert(END, ip_addr + " - " + str(com_port))
label_bci_con = Label(frame_bci, text="Current status: ")
entry_bci_con = Entry(frame_bci)
entry_bci_con.insert(END, 'DISCONNECTED')
entry_bci_con.config(foreground = 'red')
entry_bci_con.config(state = 'readonly')
button_bci = Button(frame_bci, text="Connect Device", command=connect_com)
# button_bci = Button(frame_bci, text="Connect Device", command=tmp)

frame_bci.grid(row=0, sticky='NSEW')
label_bci_ip.grid(row=0, column=0, sticky='E')
entry_bci_ip.grid(row=0, column=1, sticky='WE')
label_bci_con.grid(row=1, column=0, sticky='E')
entry_bci_con.grid(row=1, column=1, sticky='WE')
button_bci.grid(row=2, column=1, sticky='WE')

frame_app = LabelFrame(main_tab, text="DJI App", relief=GROOVE)
label_app_ip = Label(frame_app, text="Device IP: ")
entry_app_ip = Entry(frame_app)
entry_app_ip.insert(END, ip_addr + " - " + str(app_port))
label_app_con = Label(frame_app, text="Current status: ")
entry_app_con = Entry(frame_app)
entry_app_con.insert(END, 'DISCONNECTED')
entry_app_con.config(foreground = 'red')
entry_app_con.config(state = 'readonly')
button_app = Button(frame_app, text="Connect Device", command=connect_app)

frame_app.grid(row=3, sticky='NSEW')
label_app_ip.grid(row=3, column=0, sticky='E')
entry_app_ip.grid(row = 3, column = 1, sticky = 'WE')
label_app_con.grid(row=4, column=0, sticky='E')
entry_app_con.grid(row=4, column=1, sticky='WE')
button_app.grid(row=5, column=1, sticky='WE')

frame_thr = LabelFrame(main_tab, text = "Threading", relief = GROOVE)
label_thr_con = Label(frame_thr, text = "Connection status: ")
entry_thr_con = Entry(frame_thr)
entry_thr_con.insert(END, 'DISCONNECTED')
entry_thr_con.config(foreground = 'red')
entry_thr_con.config(state = 'readonly')
# comm_thread = Thread(target=comm)
button_start = Button(frame_thr, text="Start", command=start_thread)

frame_thr.grid(row = 6, sticky = 'NSEW')
label_thr_con.grid(row = 7, column = 0)
entry_thr_con.grid(row = 7, column = 1)
button_start.grid(row=8, column = 1, sticky='WE')

frame_man = LabelFrame(main_tab, text="Manual Control", relief=GROOVE)
button_for = Button(frame_man, text = "Forward", command = lambda: man_con('w'))
button_back = Button(frame_man, text = "Backward", command = lambda: man_con('s'))
button_left = Button(frame_man, text = "Turn left", command = lambda: man_con('a'))
button_right = Button(frame_man, text = "Turn right", command = lambda: man_con('d'))
button_up = Button(frame_man, text = "Upward", command = lambda: man_con('e'))
button_down = Button(frame_man, text = "Downward", command = lambda: man_con('q'))
button_hold = Button(frame_man, text="Hold position", command = lambda: man_con('i'))
button_land = Button(frame_man, text="Land", command = lambda: man_con('c'))

frame_man.grid(row=9, sticky='NSEW')
button_for.grid(row = 10, column = 0, sticky = 'W')
button_back.grid(row = 10, column = 1, sticky = 'E')
button_left.grid(row = 11, column = 0, sticky = 'W')
button_right.grid(row = 11, column = 1, sticky = 'E')
button_up.grid(row = 12, column = 0, sticky = 'W')
button_down.grid(row = 12, column = 1, sticky = 'E')
button_hold.grid(row = 13, column = 0, sticky = 'W')
button_land.grid(row = 13, column = 1, sticky = 'E')

frame_text = LabelFrame(main_tab, text="Progress Window", relief=GROOVE)
text = Text(frame_text)
scr = Scrollbar(frame_text,orient=VERTICAL, command=text.yview)
frame_text.grid(row=0, column=2, rowspan=13, sticky='NSEW')
text.grid(row=0,column=2,rowspan=13, sticky='NSEW')
scr.grid(row=0, column=3, rowspan=13, sticky='NS')
text.config(yscrollcommand=scr.set, width = 60, height = 30)

frame_arrow = LabelFrame(main_tab, text = "Current Direction", relief = GROOVE)
canvas = Canvas(frame_arrow, width = 400, height = 400)
center_x, center_y = 120, 200
center_w, center_z = 320, 200
arrow_for = canvas.create_line(center_x, center_y, center_x, center_y - 100, width = 7, arrow = LAST)
arrow_back = canvas.create_line(center_x, center_y, center_x, center_y + 100, width = 7, arrow = LAST)
arrow_right = canvas.create_line(center_x, center_y, center_x + 100, center_y, width = 7, arrow = LAST)
arrow_left = canvas.create_line(center_x, center_y, center_x - 100, center_y, width = 7, arrow = LAST)
arrow_up = canvas.create_line(center_w, center_z, center_w, center_z - 100, width = 7, arrow = LAST)
arrow_down = canvas.create_line(center_w, center_z, center_w, center_z + 100, width = 7, arrow = LAST)

frame_arrow.grid(row = 0, column = 4, rowspan = 12, sticky = 'NSEW')
canvas.grid(row = 0, column = 4, rowspan = 12, sticky = 'NSEW')


root.mainloop()
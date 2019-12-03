import socket
import threading
import time


class ScreenOutput:

    def __init__(self):
        self.name = self.__class__.__name__
        self.sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        # self.sock.settimeout(10)
        self.running = True

    def receive_commands(self):
        while self.running:
            command = self.sock.recv(8).decode()
            print("{}: Received {}".format(self.name, command))

    def connect_socket(self, ip, port):
        try:
            self.sock.connect((ip, port))
        except socket.error:
            return False
        print("{}: Connected to server socket".format(self.name))
        client_thrd = threading.Thread(target=self.receive_commands)
        client_thrd.daemon = True
        client_thrd.start()
        return True

    def end_operation(self):
        self.running = False
        print("{}: Operation stopped".format(self.name))

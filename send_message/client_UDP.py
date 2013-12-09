import socket

HOST = 'localhost'
PORT = 50007
s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
i = 0
while (i<5):
    s.sendto('!M 1 '+str(i), (HOST, PORT))
    i = i+1
#data = s.recv(1024)
s.close()

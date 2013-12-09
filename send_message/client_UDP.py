import socket

HOST = '192.168.1.139'
#HOST = 'localhost'
PORT = 50007
s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
i = 0
while (i<5):
    speed = i*100
    s.sendto('!M %s 0\r' % str(speed), (HOST, PORT))
    i = i+1
#data = s.recv(1024)
s.sendto('!M 0 0\r', (HOST, PORT))
s.close()

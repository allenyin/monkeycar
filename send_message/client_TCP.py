import socket

addr = 'localhost'
port_source = 5005
port_listen = 5006
BUFFER_SIZE = 256
MESSAGE = "Hello, World!"

s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
s.bind((addr, port_source))
s.connect((addr, port_listen))
i = 1
while (i<5):
    s.send(MESSAGE+str(i))
    data = s.recv(BUFFER_SIZE)
    print "ECHO data:", data
    i = i+1
s.close()


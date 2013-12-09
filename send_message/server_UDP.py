import socket

HOST = 'localhost'
PORT = 50007
s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
s.bind((HOST, PORT))

while 1:
    data, addr = s.recvfrom(1024)
    if not data: continue
    print 'Received', repr(data)
conn.close()


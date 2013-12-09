import socket

addr = 'localhost'
port = 5006
BUFFER_SIZE = 256

s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
s.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
s.bind((addr, port))
s.listen(1)

while 1:
    conn, addr = s.accept()
    print 'Connection address:', addr
    conn.send("Connection from %s" % str(addr))
    while 1:
        data = conn.recv(BUFFER_SIZE)
        if not data: break
        print "received data:", data
        conn.send(data) # echo
    conn.close()

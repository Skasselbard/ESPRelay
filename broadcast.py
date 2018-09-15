import socket
 
s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
s.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
s.setsockopt(socket.SOL_SOCKET, socket.SO_BROADCAST, 1)
s.bind(('', 5053))
 
print("waiting for messages")
while 1:
    try:
        message, address = s.recvfrom(1024)
        print("Message from %s: %s" % (address, message.decode()))
        s.sendto("OK!".encode(), address)
    except:
        raise

import http.server
import socketserver
import os
import threading
import sys
import getopt
import socket
import time

import os.path as p

# run with python 3


def printHelp():
    print("run with: \ndeploy -i nodeMCU_IP")


def main(argv):
    # parse arguments
    try:
        opts, args = getopt.getopt(argv, "hi:", ["ip="])
    except getopt.GetoptError:
        printHelp()
        sys.exit(2)
    for opt, arg in opts:
        if opt == 'help' or opt == '--help' or opt == '-h':
            printHelp()
            sys.exit()
        elif opt in ("-i", "--ifile"):
            ip = arg
    #################

    # get project path relative from this file
    path = os.path.dirname(os.path.dirname(os.path.realpath(__file__)))
    print("project path: " + path)
    os.chdir(path)

    # init http server
    PORT = 80
    Handler = http.server.SimpleHTTPRequestHandler
    httpd = socketserver.TCPServer(("", PORT), Handler)

    server_thread = threading.Thread(target=httpd.serve_forever)
    server_thread.daemon = False
    server_thread.start()

    # do work
    nodePort = 2323  # hardcoded in init.lua script
    s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    s.connect((ip, nodePort))
    s.recv(1024)
    files = [
        f for f in os.listdir(path)
        if p.isfile(p.join(path, f)) and p.splitext(f)[1] == ".lua"
    ]
    # transmit files
    # for f in files:
    #     filepath = path+'/'+f
    #     print("transmitting: " + filepath)
    #     command = "loadFile(\"+192.168.34\", \"/"+f+"\", \""+f+"\")"
    #     s.sendall(str.encode(command))
    #     s.recv(1024)
    #     time.sleep(1)
    s.close()


if __name__ == "__main__":
    main(sys.argv[1:])

import serial
import argparse
import threading
import sys
import readline
import cmd


def executeCommand(device, baudRate, command):
    s = serial.Serial(device)
    s.baudrate = baudRate
    line = command+"\r\n"
    s.write(line.encode())
    s.readline()


def main():
    # parse arguments
    parser = argparse.ArgumentParser()
    parser.add_argument("device", help="UART target device")
    parser.add_argument("baudRate", nargs='?', const=115200)
    parser.add_argument("-c", nargs='?', help="single command")
    args = parser.parse_args()
    if args.baudRate == None:
        args.baudRate = 115200

    # run single command and exit if requested
    if args.c != None:
        executeCommand(args.device, args.baudRate, args.c)
        exit(0)

    # init serial
    s = serial.Serial(args.device)
    s.baudrate = args.baudRate

    # init "console"

    class Console(cmd.Cmd):
        intro = 'Hi'
        prompt = '>'
        file = None

        def default(self, line):
            line = line+"\r\n"
            s.write(line.encode())

    def readNode():
        while True:
            sys.stdout.write(s.read(1).decode('ascii'))

    # run reading thread
    readThread = threading.Thread(target=readNode)
    readThread.daemon = True
    readThread.start()

    # start
    Console().cmdloop()


if __name__ == "__main__":
    main()

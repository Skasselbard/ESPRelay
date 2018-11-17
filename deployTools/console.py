import serial
import argparse
import threading
import sys
import readline
import cmd
import time


def executeCommand(device, baudRate, command):
    s = serial.Serial(device)
    s.baudrate = baudRate
    line = command+"\r\n"  # add a newline to finish the command
    s.write(line.encode())
    # print the answer
    answer = s.readline().decode('ascii', 'backslashreplace')
    time.sleep(0.01)  # wait for additional output
    while True:
        bytesToRead = s.inWaiting()
        answer = answer + \
            s.read(bytesToRead).decode('ascii', 'backslashreplace')
        if bytesToRead == 0:
            answer = answer[:-3]  # trim the newline and promt ('>')
            print("answer: " + answer)
            break


def main():
    # parse arguments
    parser = argparse.ArgumentParser()
    parser.add_argument("device", help="UART target device")
    parser.add_argument("baudRate", nargs='?', const=115200)
    parser.add_argument("-c", nargs='?', help="single command")
    args = parser.parse_args()
    if args.baudRate == None:
        args.baudRate = 115200
    print("device: " + args.device)
    print("baudRate: " + str(args.baudRate))

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
            sys.stdout.write(s.read(1).decode('ascii', 'backslashreplace'))

    # run reading thread
    readThread = threading.Thread(target=readNode)
    readThread.daemon = True
    readThread.start()

    # start
    Console().cmdloop()


if __name__ == "__main__":
    main()

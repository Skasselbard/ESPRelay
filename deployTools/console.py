import serial
import argparse
import threading
import sys
import readline
import cmd


def printHelp():
    print("run with: \nconsole -d device -b baudrate")


# parse arguments
parser = argparse.ArgumentParser()
parser.add_argument("device", help="UART target device")
parser.add_argument("baudRate", nargs='?', const=115200)
parser.add_argument("-c", nargs='?', const=115200, help="single command")
args = parser.parse_args()
if args.baudRate == None:
    args.baudRate = 115200
print("device: " + args.device)
print("baudRate: " + str(args.baudRate))
#################

s = serial.Serial(args.device)
s.baudrate = args.baudRate

if args.c != None:
    line = args.c+"\r\n"
    s.write(line.encode())
    s.readline()
    print("Answer: " + s.readline().decode('ascii'))
    exit(0)


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


readThread = threading.Thread(target=readNode)
readThread.daemon = True
readThread.start()

Console().cmdloop()
# while True:
#     line = input(">")
#     s.write(line.encode())

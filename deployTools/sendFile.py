import console
import argparse
import os


def sendFile(filePath, device, baudRate):
    fileName = os.path.basename(filePath)
    openCommand = "file.open(\"" + fileName + "\",\"w+\")"
    console.executeCommand(device, baudRate, openCommand)
    f = open(filePath)
    for line in f:
        line = line.replace("\n", "")       # remove \n
        line = line.replace("\\", "\\\\")   # escape backslashes (first!)
        line = line.replace("\"", "\\\"")   # escape double quotes
        line = line.replace("\'", "\\\'")   # escape single quotes
        writeCommand = "file.writeline(\"" + line + "\")"  # send the line
        console.executeCommand(device, baudRate, writeCommand)
    f.close()
    console.executeCommand(device, baudRate, "file.close()")


def main():
    # parse arguments
    parser = argparse.ArgumentParser()
    parser.add_argument("file")
    parser.add_argument("device", help="UART target device")
    parser.add_argument("baudRate", nargs='?', const=115200)
    args = parser.parse_args()
    if args.baudRate == None:
        args.baudRate = 115200
    sendFile(args.file, args.device, args.baudRate)


if __name__ == "__main__":
    main()

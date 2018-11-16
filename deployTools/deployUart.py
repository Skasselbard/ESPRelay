import sendFile
import argparse
import os


def deploy(device, baudRate):
    # get project path relative from this file
    path = os.path.dirname(os.path.dirname(os.path.realpath(__file__)))
    os.chdir(path)
    # get all .lua files
    files = [
        f for f in os.listdir(path)
        if os.path.isfile(os.path.join(path, f)) and os.path.splitext(f)[1] == ".lua"
    ]
    print("Transmitting " + str(len(files)) + " files")
    for f in files:
        print("\n<<<" + f + ">>>")
        sendFile.sendFile(f, device, baudRate)


def main():
    # parse arguments
    parser = argparse.ArgumentParser()
    parser.add_argument("device", help="UART target device")
    parser.add_argument("baudRate", nargs='?', const=115200)
    args = parser.parse_args()
    if args.baudRate == None:
        args.baudRate = 115200
    deploy(args.device, args.baudRate)


if __name__ == "__main__":
    main()

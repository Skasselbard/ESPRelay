import console
import argparse


def configureMqtt(clientName, brokerAdress, device, baudRate):
    ssidCmd = "setSetting(\"mqtt_name\",\"" + clientName + "\")"
    passwdCmd = "setSetting(\"mqtt_server\",\"" + brokerAdress + "\")"
    console.executeCommand(device, baudRate, ssidCmd)
    console.executeCommand(device, baudRate, passwdCmd)


def main():
    # parse arguments
    parser = argparse.ArgumentParser()
    parser.add_argument("clientName")
    parser.add_argument("brokerAdress")
    parser.add_argument("device", help="UART target device")
    parser.add_argument("baudRate", nargs='?', const=115200)
    args = parser.parse_args()
    if args.baudRate == None:
        args.baudRate = 115200
    configureMqtt(args.clientName, args.brokerAdress,
                  args.device, args.baudRate)


if __name__ == "__main__":
    main()

import console
import argparse


def configureWlan(ssid, wifipass, device, baudRate):
    ssidCmd = "setSetting(\"wifi_ssid\",\"" + ssid + "\")"
    passwdCmd = "setSetting(\"wifi_pwd\",\"" + wifipass + "\")"
    console.executeCommand(device, baudRate, ssidCmd)
    console.executeCommand(device, baudRate, passwdCmd)


def main():
    # parse arguments
    parser = argparse.ArgumentParser()
    parser.add_argument("ssid")
    parser.add_argument("wifiPassword")
    parser.add_argument("device", help="UART target device")
    parser.add_argument("baudRate", nargs='?', const=115200)
    args = parser.parse_args()
    if args.baudRate == None:
        args.baudRate = 115200
    configureWlan(args.ssid, args.wifiPassword, args.device, args.baudRate)


if __name__ == "__main__":
    main()

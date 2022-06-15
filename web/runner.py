#!/usr/bin/env python3
import os
import setproctitle
import eel

PORT = 8000
DIRECTORY = os.path.abspath(os.path.dirname(__file__))

def main():
    os.environ["DISPLAY"] = ":0"
    def close_callback(route, websockets):
        if not websockets:
            exit()
    eel.init(DIRECTORY)
    # close callback is not called if there is no ./eel.js script in the index.html
    #eel.start('index.html', port=PORT, cmdline_args=['--kiosk'] ,close_callback=close_callback)
    eel.start('index.html', port=PORT,close_callback=close_callback)

if __name__ == "__main__":
    setproctitle.setproctitle("dieklingel-runner")
    main()

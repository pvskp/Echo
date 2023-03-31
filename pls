#! /usr/bin/env python3

import urllib.request
from urllib.request import HTTPError
import urllib.parse
import json
import os

import signal
import curses
from curses.textpad import rectangle, Textbox
import asyncio

TOKEN=os.getenv("OPENAI_API_KEY")
URL="https://api.openai.com/v1/chat/completions"

CONTEXT="""
You're a helpful AI.
"""

class ChatSession():
    def __init__(self, assistantName: str):
        self.assistantName = assistantName
        self.context = [
            {"role": "system", "content": CONTEXT}
        ]

        self.MSG_BOX_HEIGHT = 50
        self.MSG_BOX_WIDTH  = 10

        self.INPUT_BOX_HEIGHT = 50
        self.INPUT_BOX_WIDTH  = 10

        self.drawScreen()
        self.stdscr.keypad(True)

        # eventListenerLoop = asyncio.get_event_loop()
        # listener = eventListenerLoop.create_task(self.listenEvent())
        # eventListenerLoop.run_until_complete(listener)

        # curses.raw()
        signal.signal(signal.SIGINT, self._exitSession)

    def drawScreen(self):
        self.MSG_BOX_HEIGHT = 10
        self.MSG_BOX_WIDTH  = 100

        self.INPUT_BOX_HEIGHT = 5
        self.INPUT_BOX_WIDTH  = 100

        BOX_FIX=-10
        try:
            self.stdscr = curses.initscr()
            # Cria uma janela para exibir as mensagens
            # self.msg_win = curses.newwin(10, 50, 0, 0)

            self.msg_win = curses.newwin(self.MSG_BOX_HEIGHT, self.MSG_BOX_WIDTH, 0, 0)
            self.msg_win.scrollok(True) # Permite que a janela role automaticamente
            rectangle(self.msg_win, 0, 0, self.MSG_BOX_HEIGHT - 1, self.MSG_BOX_WIDTH - 1)

            # Cria uma janela para a caixa de texto
            # self.input_win = curses.newwin(1, 100, self.MSG_BOX_HEIGHT + 2, 0)

            # self.input_win = curses.newwin(1, 50, 11, 0)
            self.input_win = curses.newwin(1, 100, self.MSG_BOX_HEIGHT + 1, 0)

            self.stdscr.refresh()
            
            input_win_uly = int(self.input_win.getbegyx()[0])
            input_win_ulx = int(self.input_win.getbegyx()[1])
            input_win_lry = int(self.input_win.getmaxyx()[0] * 0.7)
            input_win_lrx = int(self.input_win.getmaxyx()[1] - 2)

            rectangle(self.input_win, input_win_uly, input_win_ulx, input_win_lry, input_win_lrx)

            input_box = Textbox(self.input_win)
            # rectangle(self.input_win, 0, 0, 0, self.INPUT_BOX_WIDTH - 1)
            self.input_win.addstr(0, 0, "> ")
            self.input_win.refresh()

            input_box.edit()

            self.stdscr.refresh()
            self.msg_win.refresh()

        except Exception as e:
            print(e)

    def _exitSession(self, signal, frame):
        curses.nocbreak()
        self.stdscr.keypad(False)
        curses.echo()
        curses.endwin()
        exit(0)

    def _printMsg(self, msg):
         self.msg_win.addstr(msg + "\n")
         self.msg_win.refresh()

         self.input_win.erase()
         self.input_win.addstr(0, 0, "> ")

    async def listenEvent(self):
        c = self.stdscr.getch()
        if c == '3':
            self._exitSession(None, None)

    def startChat(self):
        # Loop principal do chat
        # input = ''
        while True:
         # Lê a entrada do usuário
         # input_str = self.input_win.getstr(0, 2).decode()
         # self._printMsg(input_str)
         # char = self.input_win.get_wch()
         pass

    def sendQuestion (self, question: str) -> str:
        self.fillContext({"role": "user", "content": question})
                
        headers = {
            'Content-Type': 'application/json',
            'Authorization': f'Bearer {TOKEN}'
        }

        data = {
          "model": "gpt-3.5-turbo",
          "messages": self.context,
          "temperature": 0.0
        }

        try:
            req = urllib.request.Request(
                    URL,
                    json.dumps(data).encode(),
                    headers
                )

            response = urllib.request.urlopen(req)

            response = json.loads(response.read().decode())
            return response["choices"][0]["message"]["content"]

        except HTTPError as e:
            return f'Erro HTTP:, {e.code}, {e.reason}'

    
    def fillContext (self, newContent: dict):
        self.context.append(newContent)

echo = ChatSession("Echo")

# echo.startChat()
echo.drawScreen()

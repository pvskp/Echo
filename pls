#! /usr/bin/env python3

import urllib.request
from urllib.request import HTTPError
import urllib.parse
import json
import os

import signal
import curses
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

        self.stdscr = curses.initscr()
        self.stdscr.keypad(True)

        # Cria uma janela para exibir as mensagens
        self.msg_win = curses.newwin(10, 50, 0, 0)
        self.msg_win.scrollok(True) # Permite que a janela role automaticamente

        # Cria uma janela para a caixa de texto
        self.input_win = curses.newwin(1, 50, 11, 0)
        self.input_win.addstr(0, 0, "> ")
        self.input_win.refresh()

        # eventListenerLoop = asyncio.get_event_loop()
        # listener = eventListenerLoop.create_task(self.listenEvent())
        # eventListenerLoop.run_until_complete(listener)

        # curses.raw()
        signal.signal(signal.SIGINT, self._exitSession)

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
         input_str = self.input_win.getstr(0, 2).decode()
         self._printMsg(input_str)
         # char = self.input_win.get_wch()

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

echo.startChat()

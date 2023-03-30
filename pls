#! /usr/bin/env python3

import urllib.request
from urllib.request import HTTPError
import urllib.parse
import json
import os

import curses

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

    def startChat(self):
        # Cria uma janela para exibir as mensagens
        msg_win = curses.newwin(10, 50, 0, 0)
        msg_win.scrollok(True) # Permite que a janela role automaticamente

        # Cria uma janela para a caixa de texto
        input_win = curses.newwin(1, 50, 11, 0)
        input_win.addstr(0, 0, "> ")
        input_win.refresh()

        # Loop principal do chat
        while True:
         # Lê a entrada do usuário
         input_str = input_win.getstr(0, 2).decode()
         input_win.erase()
         input_win.addstr(0, 0, "> ")
    
         if input_str == 'exit':
            curses.endwin()
            break

         # Exibe a mensagem na janela de mensagens
        msg_win.addstr(input_str + "\n")
        msg_win.refresh()


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

#! /usr/bin/env python3

import urllib.request
import urllib.parse
import json
import os

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

    def startChat(self):
        pass

    def sendQuestion (self, question: str) -> str:
        self.context.append(
                {"role": "user", "content": question}
            )

        headers = {
            'Content-Type': 'application/json',
            'Authorization': f'Bearer {TOKEN}'
        }

        data = {
          "model": "gpt-3.5-turbo",
          "messages": self.context,
          "temperature": 0.0
        }

        req = urllib.request.Request(
                URL,
                json.dumps(data).encode(),
                headers
            )

        response = urllib.request.urlopen(req)

        response = json.loads(response.read().decode())
        return response["choices"][0]["message"]["content"]
    
    def fillContext (self, ):
        pass

echo = ChatSession("Echo")

echo.sendQuestion("Bom dia! Tudo bem?")

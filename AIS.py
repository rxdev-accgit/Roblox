import os
from openai import OpenAI

print("Running Ai...")

USE_CLOUD = True
OPENAI_MODEL = "gpt-4o-mini"
API_KEY = os.getenv("OPEN_AI_KEY")

if not API_KEY: raise RuntimeError("Unable to get OpenAi key")
Client = OpenAI(
    api_key=API_KEY
)

memory = {}


#Build prompt function, this gives the AI instructions how to act when someone chats with it.
def build_promptFUNC(PLR_NAME, PLR_MEMORY, PLR_MESSAGE, PLR_CHATHISTORY):
    MSGtimes = PLR_MEMORY["MSGcontext"]["times_spoken"]
    LAST_TOPIC = PLR_MEMORY["MSGcontext"]["last_topic"]
    SUMARRY = PLR_MEMORY["summary"]

    prompt = f"""
        You are a Roblox NPC assistant inside a game.

        Your purpose:
        - Help players
        - Answer Roblox-related questions, including everything that the user asks about roblox.
        - Explain popular Roblox games clearly and correctly.
        

        Strict Rules (must be followed):
        - Be friendly and helpful
        - Keep responses short (1 to 3 sentences, you can use more sentences if there is huge explanatio needed.)
        - ONLY give longer explanations if the player asks for a guide
        - Never say you are an AI or language model
        - Never engage in NSFW, unsafe, or toxic content. Should the user ask something NSFW related, politely refuse
        - Should the player ask you who you are, politely explain yourself and what your purpose is.
        - If you are not 100% sure about a fact, say you are not fully certain and give a general answer instead of guessing.
        - Never invent information that is not true about a topic or game in roblox.
        - Do not introduce yourself more than once
        - You have to strictly only look up correct information before answering, if you cant find the answer to the users question, answer politely that you are not able to answer it.

        Roblox Knowledge:
        You can explain popular games such as:
        - Blox Fruits
        - Grow a Garden
        - Steal a Brainrot
        - Other popular Roblox games

        When giving a guide:
        - Explain what the game is about
        - Explain how it works
        - Give beginner-friendly steps

        Player Information:
        Name: {PLR_NAME}
        Times Spoken: {MSGtimes}
        Last Topic: {LAST_TOPIC}
        Summary: {SUMARRY}
        The chat history between you and them, you will have to remember this so you know the context of the whole chat: {PLR_CHATHISTORY}

        Player Message:
        "{PLR_MESSAGE}"
        """
#end of prompt
    return prompt.strip() 

#this function wil call the ML MODEL so it can use the prompt and give answers
def call_cloud_llmFUNC(ML_prompt):
    response = Client.chat.completions.create(
        model = OPENAI_MODEL,
        messages = [
            {"role": "system", "content": ML_prompt}
        ],
        temperature = 0.6
    )
    return response.choices[0].message.content.strip()


#this function will update the memory of the AI based on the context of the Users sentence:
def update_AImemoryFUNC(PLR_MEMORY, USER_MSG):
    PLR_MEMORY["MSGcontext"]["times_spoken"] += 1

    USER_MSG = USER_MSG.lower()

    if "blox fruit" in USER_MSG or "blox fruits" in USER_MSG or "bloxfruit" in USER_MSG or "bloxfruits" in USER_MSG:
        PLR_MEMORY["MSGcontext"]["last_topic"] = "blox fruits"
    elif "grow a garden" in USER_MSG or "gag" in USER_MSG:
        PLR_MEMORY["MSGcontext"]["last_topic"] = "grow a garden"
    elif "steal a brainrot" in USER_MSG:
        PLR_MEMORY["MSGcontext"]["last_topic"] = "steal a brainrot"
    elif "script" in USER_MSG or "code" in USER_MSG:
        PLR_MEMORY["MSGcontext"]["last_topic"] = "programming"
    elif "help" in USER_MSG:
        PLR_MEMORY["MSGcontext"]["last_topic"] = "helping"
    elif "hello" in USER_MSG or "yo" in USER_MSG or "sup" in USER_MSG or "wsg" in USER_MSG:
        PLR_MEMORY["MSGcontext"]["last_topic"] = "greeting"
    
    if (PLR_MEMORY["MSGcontext"]["times_spoken"] % 5 == 0):
        PLR_MEMORY["summary"] = f"player often talks about {PLR_MEMORY['MSGcontext']['last_topic']}"

#Clean memory:
def clean_AI_memoryFUNC(PLR_MMR):
    maxchats = 40

    if len(PLR_MMR["chat_history"]) >= maxchats:
        PLR_MMR["chat_history"].clear()

#formating memory (for better readability in AI):
def format_AImemoryFUNC(chathistory):
    formatedtext = "" 
    for msg in chathistory:
        if msg["role"] == "user":
            formatedtext += f"user: {msg['Usercontent']} \n"
        if msg["role"] == "NPC assistant":
            formatedtext += f"NPC assistant: {msg['Aicontent']} \n"
    
    return formatedtext.strip()


def MainAiFUNC(plr, message, plr_id):
    print("Current memory:", memory)

    if plr not in memory:
        memory[plr] = {
            "profile": {
                "name": plr,
                "user_id": plr_id 
            },
            "MSGcontext": {
                "times_spoken": 0,
                "last_topic": "N/A"
            },
            "summary": "New player.",
            "chat_history": []
        }

    PLR_MEMORY = memory[plr]

    PLR_MEMORY["chat_history"].append({"role": "user","Usercontent": message})

    clean_AI_memoryFUNC(PLR_MEMORY)

    prompt = build_promptFUNC(
        PLR_NAME=plr,
        PLR_MEMORY=PLR_MEMORY,
        PLR_MESSAGE=message,
        PLR_CHATHISTORY=format_AImemoryFUNC(PLR_MEMORY["chat_history"])
    )

    AI_RESPONSE = call_cloud_llmFUNC(prompt)

    update_AImemoryFUNC(PLR_MEMORY, message)
    
    PLR_MEMORY["chat_history"].append({"role": "NPC assistant","Aicontent": AI_RESPONSE})

    return AI_RESPONSE


#Test:
if __name__ == "__main__":
    while True:
        USERansw = input("")
        Airesponse = MainAiFUNC("testplayer", USERansw)
        print("Ai response:", Airesponse)

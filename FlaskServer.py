from AIS import MainAiFUNC as AIfunc
from flask import Flask, request, jsonify 

AIapp = Flask("AIapplicationServer")

@AIapp.route("/rblxAI", methods=["POST"])
def rblxAIconnection():
    data = request.get_json()

    if not data: 
        return jsonify({
            "Error": f"could not receive data from the rblx game"
        }), 400
    
    PlayerName = data.get("PLRNAME", "plr")
    message = data.get("PLRMSG", "")
    PlayerId = data.get("PLRUSERID")

    try: ResFromAI = AIfunc(PlayerName, message, PlayerId)
    except Exception as err: 
        print("An Error Occured while getting AI response, err:", err)
        ResFromAI = "Sorry, i'm having trouble responding."
    

    if ResFromAI == None or ResFromAI == "":
        print("WARNING: something went wrong")
    
    return jsonify({
        "AIres": ResFromAI
    }), 200


if __name__ == "__main__":
    AIapp.run(debug=False, port=5000)


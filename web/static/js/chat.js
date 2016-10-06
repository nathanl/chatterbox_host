// TODO - have this ask you for a name if we don't know it yet
import {Socket} from "phoenix"

function createCookie(name,value,days) {
    if (days) {
        var date = new Date();
        date.setTime(date.getTime()+(days*24*60*60*1000));
        var expires = "; expires="+date.toGMTString();
    }
    else var expires = "";
    document.cookie = name+"="+value+expires+"; path=/";
}

function readCookie(name) {
    var nameEQ = name + "=";
    var ca = document.cookie.split(';');
    for(var i=0;i < ca.length;i++) {
        var c = ca[i];
        while (c.charAt(0)==' ') c = c.substring(1,c.length);
        if (c.indexOf(nameEQ) == 0) return c.substring(nameEQ.length,c.length);
    }
    return null;
}

function eraseCookie(name) {
    createCookie(name,"",-1);
}

if (document.getElementById("chatbox") !== null) {
  let Chat = exports.Chat = function Chat() {
    this.socket                = null
    this.channel_name          = null
    this.user_name             = null
    this.user_id_token         = null
    this.conversation_id_token = null
    this.chatStarted           = false

    this.startChatButton       = document.getElementById("chatbox-startchat")
    this.chatBox               = document.getElementById("chatbox")
    this.chatInput             = document.getElementById("chatbox-input")
    let chatMessages           = document.getElementById("chatbox-messages")
    this.endConversationButton = document.getElementById("chatbox-end-conversation")

    this.userIsCsRep   = !!this.chatBox.className.match("cs-support")

    this.checkAndMaybeStart = function(){
      let inChatSession = !!readCookie("conversationId")

      if (inChatSession || this.userIsCsRep) {
        this.startChat()
      }
    }

    this.startChatButton.addEventListener("click", event => {
      event.preventDefault()
      this.startChat()
    })

    this.startChat = function(){
      if (this.chatStarted) { return false }
      chat.chatStarted = true
      chat.swapClass(this.chatBox, "inactive", "loading")
      chat.requestChatSession(
        function(chatSessionInfo){
          if (chatSessionInfo.error) {
            chat.displayError(chatSessionInfo.error)
            return false
          }
          chat.swapClass(chat.chatBox, "loading", "active")

          chat.channel_name          = chatSessionInfo.channel_name
          chat.user_name             = chatSessionInfo.user_name
          chat.user_id_token         = chatSessionInfo.user_id_token
          chat.conversation_id_token = chatSessionInfo.conversation_id_token

          if (!chat.userIsCsRep) {
            createCookie("conversationId", chat.conversation_id_token)
          }

          chat.endConversationButton.addEventListener("click", event => {
            chat.closeChat()
          })

          chat.socket = new Socket("/chatterbox_socket", {})
          chat.socket.connect()
          chat.channel = chat.socket.channel(chatSessionInfo.channel_name, {conversation_id_token: chatSessionInfo.conversation_id_token})
          chat.channel.on("new_msg", payload => chat.addMessage(payload.timestamp, payload.from, payload.body))
          chat.channel.on("conversation_closed", _response => { chat.disable() })

          chat.channel.join()
          .receive("ok", resp => console.log("Joined successfully", resp))
          .receive("error", resp => console.log("Unable to join", resp))

          chat.onSubmit( (body, user_name, user_id_token) => {
            chat.channel.push("new_msg", {
              body: body,
              user_name: user_name,
              user_id_token: user_id_token,
            })
            .receive("ok", response => {
              response.messages.forEach(body => chat.addMessage(response.from, body))
            })
          })
        }
      )
    }

    this.requestChatSession = function(handleSessionInfo) {
      let url = null
      if (this.userIsCsRep) {
        url = `/api/give_help/${this.chatBox.dataset.conversationId}`
      } else {
        let conversation_id = readCookie("conversationId")
        url = `/api/get_help?conversation_id_token=${conversation_id}`
      }
      this.onAjaxSuccess("GET", url, handleSessionInfo)
    }

    this.onSubmit = function(submitHandler) {
      let enterKeyCode = 13
      this.chatInput.addEventListener("keypress", event => {
        if(event.keyCode === enterKeyCode && !event.shiftKey) {
          let message = this.chatInput.value.trim()
          if (!this.isBlank(message)) {

            submitHandler(message, this.user_name, this.user_id_token)
            this.chatInput.value = ""
          }
          event.preventDefault() // don't insert a new line
        }
      })
    }

    this.addMessage = function(timestamp, from, message) {
      let newMessage = document.createElement("div")
      newMessage.innerHTML = `<span class="chatterbox-message-sender">${from}</span> <span class="chatterbox-message-timestamp">${timestamp}</span> <span class="chatterbox-message-contents">${message}</span>`
      newMessage.className = "chatbox-message"
      chatMessages.appendChild(newMessage)
      chatMessages.scrollTop = chatMessages.scrollHeight // scroll to bottom
    }

    this.onAjaxSuccess = function(verb, url, callback) {
      let httpRequest = new XMLHttpRequest();

      if (!httpRequest) {
        console.log('Giving up :( Cannot create an XMLHTTP instance');
        return false;
      }
      httpRequest.onreadystatechange = function() {
        if (httpRequest.readyState === XMLHttpRequest.DONE) {
          if (httpRequest.status === 200) {
            callback(
              JSON.parse(httpRequest.responseText)
            )
          } else {
            console.log('There was a problem with the request.');
          }
        }
      }
      httpRequest.open(verb, url);
      httpRequest.send();
    }

    this.displayError = function(message) {
      let errorDiv = document.createElement("div")
      errorDiv.setAttribute("class", "chatbox-error")
      errorDiv.innerHTML = message
      this.chatBox.appendChild(errorDiv)
    }

    this.closeChat = function() {
      this.onAjaxSuccess(
        "PUT",
        `/api/close_conversation/${this.conversation_id_token}`, (chatSessionInfo) => {
          eraseCookie("conversationId") // TODO - do this?
          this.chatSessionCleared = true
          this.channel.push("conversation_closed", {
            ended_at: chatSessionInfo.ended_at,
            ended_by: this.user_name,
            user_id_token: this.user_id_token,
          })
        }
        // TODO: hide the window, redraw as an x
      )
    }

    this.disable = function() {
      chat.swapClass(this.chatBox, "active", "ended")
      chat.socket.disconnect()
      this.onSubmit = function(event) { event.preventDefault() }
      this.chatInput.parentNode.removeChild(this.chatInput)
    }

    this.isBlank = function(string) {
      return (!string || /^\s*$/.test(string))
    }

    this.swapClass = function(element, remove, add) {
      element.className = element.className.replace(remove, add)
    }

  }

  let chat = new Chat()
  chat.checkAndMaybeStart()
}

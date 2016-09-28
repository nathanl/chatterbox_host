// TODO - have this ask you for a name if we don't know it yet
import {Socket} from "phoenix"

if (document.getElementById("chatbox") !== null) {
  let Chat = exports.Chat = function Chat() {
    this.socket                = null
    this.channel_name          = null
    this.user_name             = null
    this.user_id_token         = null
    this.conversation_id_token = null

    this.chatBox = document.getElementById("chatbox")
    let chatInput    = document.getElementById("chatbox-input")
    let chatMessages = document.getElementById("chatbox-messages")

    this.endConversation = function() {
      this.ajaxGetRequest(
        `/api/close_conversation/${this.conversation_id_token}`, (chatSessionInfo) => {
          this.addMessage(chatSessionInfo.closed_at, "[System]", "Conversation Closed")
        })
        this.socket.disconnect()
        this.endConversation = function(){}
    }

    this.onSubmit = function(submitHandler) {
      let enterKeyCode = 13
      chatInput.addEventListener("keypress", event => {
        if(event.keyCode === enterKeyCode && !event.shiftKey) {
          let message = chatInput.value.trim()
          if (!this.isBlank(message)) {

            submitHandler(message, this.user_name, this.user_id_token)
            chatInput.value = ""
          }
          event.preventDefault() // don't insert a new line
        }
      })
    }

    this.isBlank = function(string) {
      return (!string || /^\s*$/.test(string))
    }

    this.addMessage = function(timestamp, from, message) {
      let newMessage = document.createElement("div")
      newMessage.innerHTML = `<span class="chatterbox-message-sender">${from}</span> <span class="chatterbox-message-timestamp">${timestamp}</span> <span class="chatterbox-message-contents">${message}</span>`
      newMessage.className = "chatbox-message"
      chatMessages.appendChild(newMessage)
    }

    this.ajaxGetRequest = function(url, onSuccessCallback) {
      let httpRequest = new XMLHttpRequest();

      if (!httpRequest) {
        console.log('Giving up :( Cannot create an XMLHTTP instance');
        return false;
      }
      httpRequest.onreadystatechange = function() {
        if (httpRequest.readyState === XMLHttpRequest.DONE) {
          if (httpRequest.status === 200) {
            onSuccessCallback(
              JSON.parse(httpRequest.responseText)
            )
          } else {
            console.log('There was a problem with the request.');
          }
        }
      }
      httpRequest.open('GET', url);
      httpRequest.send();
      console.log("sent request")
    }

    this.requestChatSession = function(handleSessionInfo) {
      let url = null 
      if (this.chatBox.dataset.conversationId) {
        url = `/api/give_help/${this.chatBox.dataset.conversationId}`
      } else {
        url = "/api/get_help"
      }
      this.ajaxGetRequest(url, handleSessionInfo)
    }

    this.displayError = function(message) {
      let errorDiv = document.createElement("div")
      errorDiv.setAttribute("class", "chatbox-error")
      errorDiv.innerHTML = message
      this.chatBox.appendChild(errorDiv)
    }
  }

  let chat = new Chat()

  chat.requestChatSession(
    function(chatSessionInfo){ 
      if (chatSessionInfo.error) {
        chat.displayError(chatSessionInfo.error)
        return false
      }
      console.log("we got", chatSessionInfo)

      chat.channel_name          = chatSessionInfo.channel_name
      chat.user_name             = chatSessionInfo.user_name
      chat.user_id_token         = chatSessionInfo.user_id_token
      chat.conversation_id_token = chatSessionInfo.conversation_id_token

      chat.socket = new Socket("/socket", {})
      chat.socket.connect()
      let channel = chat.socket.channel(chatSessionInfo.channel_name, {conversation_id_token: chatSessionInfo.conversation_id_token})
      channel.on("new_msg", payload => chat.addMessage(payload.timestamp, payload.from, payload.body))

      channel.join()
      .receive("ok", resp => console.log("Joined successfully", resp))
      .receive("error", resp => console.log("Unable to join", resp))

      chat.onSubmit( (body, user_name, user_id_token) => {
        channel.push("new_msg", {
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

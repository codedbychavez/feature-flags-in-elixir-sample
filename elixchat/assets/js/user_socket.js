import { Socket } from "phoenix"

let socket = new Socket("/socket")

let list = $('#messages');

// Connect to the socket:
socket.connect()

// Set the channel
let channel = socket.channel("chat_room:lobby", {})

channel.join()
  .receive("ok", resp => {
    console.log("Joined successfully", resp);

    // Send a message to request messages after joining
    channel.push("get_messages_after_join", {});

    // Handle messages received after joining
    channel.on("messages", payload => {
      for (let i = 0; i < payload.messages.length; i++) {
        let message = payload.messages[i];
        list.append(`
        <div class="message-card">
        <div class="left-col">
          <b>${message.sender}</b>
          <p class="message-preview">
            ${message.text}
          </p>
        </div>
        <div class="right-col">
          ${payload.message_cta_text}
        </div>
      </div>
        `)
      }
    })

  })
  .receive("error", resp => { console.log("Unable to join", resp) })

export default socket

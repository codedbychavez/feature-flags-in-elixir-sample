import { Socket } from "phoenix"

let socket = new Socket("/socket")

let list = $('#messages');
let chatButton = $('#chat-button');

// Connect to the socket:
socket.connect()

// Set the channel
let channel = socket.channel("chat_room:lobby", {})

channel.join()
  .receive("ok", resp => {
    console.log("Joined successfully", resp);

    // Send a message to request messages after joining
    channel.push("get_messages_after_join", {});

    channel.on("feature_flag", payload => {
      const featureFlagValue = payload.value;
      // Update the color of the button
      if (featureFlagValue === true) {
        chatButton.css('background-color', 'rgb(244 63 94)');
      }
    });

    // Handle messages received after joining
    channel.on("messages", payload => {
      for (let i = 0; i < payload.messages.length; i++) {
        let message = payload.messages[i];
        list.append(`
        <div class="message-card">
          <b>${message.sender}</b>
          <p class="message-preview">
            ${message.text}
          </p>
      </div>
        `)
      }
    })

  })
  .receive("error", resp => { console.log("Unable to join", resp) })

// Listen for the feature flag change event
channel.on("feature_flag_changed", payload => {
  // Handle the feature flag change
  const featureFlagValue = payload.feature_flag_value;
  console.log('Updated', featureFlagValue)
  if (featureFlagValue === true) {
    chatButton.css('background-color', 'rgb(244 63 94)');
  } else {
    // Reset the button
    chatButton.css('background-color', 'rgb(99 102 241)');
  }
});

export default socket

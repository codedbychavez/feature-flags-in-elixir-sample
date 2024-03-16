import { Socket } from "phoenix"

let socket = new Socket("/socket")

let list = $('#messages');
let chatButton = $('#chat-button');

function trackPurpleButtonClick() {
  console.log('trackPurpleButtonClick');
  amplitude.getInstance().logEvent('PURPLE_BUTTON_CLICKED');
}

function trackRedButtonClick() {
  console.log('trackRedButtonClick');
  amplitude.getInstance().logEvent('RED_BUTTON_CLICKED');
}

// Add default click event listener to the chatButton
chatButton.on("click", trackPurpleButtonClick);

// Connect to the socket:
socket.connect()

// Set the channel
let channel = socket.channel("chat_room:lobby", {})

// Join the channel
channel.join()
  .receive("ok", resp => {
    console.log("Joined successfully", resp);

    // Send a message to request messages after joining
    channel.push("get_messages_after_join", {});

    // Get the feature flag value
    channel.on("feature_flag", payload => {
      const featureFlagValue = payload.value;
      if (featureFlagValue === true) {
        // Set the chatButton color
        chatButton.css('background-color', 'rgb(244 63 94)');

        // Remove the previous event
        chatButton.off("click", trackPurpleButtonClick);

        // Add the new event
        chatButton.on('click', trackRedButtonClick);
      }
    });

    // Handle messages received after joining
    channel.on("messages", payload => {
      for (let i = 0; i < payload.messages.length; i++) {
        let message = payload.messages[i];
        // Append messages to the UI
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

  if (featureFlagValue === true) {
    // Set the chatButton color
    chatButton.css('background-color', 'rgb(244 63 94)');

    // Remove the previous event
    chatButton.off("click", trackPurpleButtonClick);

    // Add the new event
    chatButton.on('click', trackRedButtonClick);
  } else {
    // Reset the button color
    chatButton.css('background-color', 'rgb(99 102 241)');

    // Remove the previous event
    chatButton.off("click", trackRedButtonClick);

    // Add the new event
    chatButton.on('click', trackPurpleButtonClick);
  }
});

export default socket

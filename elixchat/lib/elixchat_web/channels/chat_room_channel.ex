defmodule Message do
  defstruct id: 0, sender: "", text: ""

  # Implement Jason.Encoder for the Message struct
  defimpl Jason.Encoder, for: __MODULE__ do
    def encode(message, _opts) do
      Map.from_struct(message) |> Jason.encode!()
    end
  end
end

defmodule ElixchatWeb.ChatRoomChannel do
  use ElixchatWeb, :channel

  @impl true
  def join("chat_room:lobby", payload, socket) do
    if authorized?(payload) do
      {:ok, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  # Channels can be used in a request/response fashion
  # by sending replies to requests from the client
  @impl true
  def handle_in("get_messages_after_join", _payload, socket) do
    # Respond with the list of messages when the client requests it
    {:reply, {:ok, socket |> push_messages()}, socket}
  end

  # It is also common to receive messages from the client and
  # broadcast to everyone in the current topic (chat_room:lobby).
  @impl true
  def handle_in("shout", payload, socket) do
    broadcast(socket, "shout", payload)
    {:noreply, socket}
  end

  defp push_messages(socket) do
    message_cta_text =
      case ConfigCat.get_value("myfeatureflag", false) do
        true  -> "Read Now"
        false -> "Read More"
      end

    # Create a message to send to the client
    message = %{
      event: "messages",
      messages: [
        %Message{id: 1, sender: "Joe", text: "Hi, this is Joe, please call me. Thanks"},
        %Message{id: 2, sender: "Suzan", text: "Suzan here, When should we start the meeting?"},
        %Message{id: 3, sender: "Ann", text: "Its Ann, 10AM appointment still on."}
      ],
      message_cta_text: message_cta_text
    }

    # Push messages to the client
    push(socket, "messages", message)
  end

  # Add authorization logic here as required.
  defp authorized?(_payload) do
    true
  end
end

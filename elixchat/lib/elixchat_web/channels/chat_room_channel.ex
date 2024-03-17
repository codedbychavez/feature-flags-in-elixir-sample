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
      # Subscribe to config changes when the client joins
      ConfigSubscriber.subscribe_to_config_changes(self())
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

  @impl true
  def handle_info({:config_changed, config}, socket) do
    # Extract the value of the feature flag from the config
    feature_flag_value = Map.get(config, "feature_flag_value", false)

    # Notify the client about the feature flag change
    broadcast(socket, "feature_flag_changed", %{feature_flag_value: feature_flag_value})
    {:noreply, socket}
  end

  defp push_messages(socket) do
    feature_flag_value =
      ConfigCat.get_value(
        "myfeatureflag",
        false,
        ConfigCat.User.new("user123", email: "john@elixchatbeta.com")
      )

    message = %{
      event: "messages",
      messages: [
        %Message{id: 1, sender: "Joe", text: "Hi, this is Joe, please call me. Thanks"},
        %Message{id: 2, sender: "Suzan", text: "Suzan here, When should we start the meeting?"},
        %Message{id: 3, sender: "Ann", text: "Its Ann, 10AM appointment still on."}
      ]
    }

    # Push messages and feature flag to the client
    push(socket, "messages", message)
    push(socket, "feature_flag", %{value: feature_flag_value})
  end

  # Add authorization logic here as required.
  defp authorized?(_payload) do
    true
  end
end

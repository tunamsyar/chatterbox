defmodule ChatterboxWeb.ChatRoomChannel do
  use ChatterboxWeb, :channel

  def join("chat_room:lobby", payload, socket) do
    if authorized?(payload) do
      send(self(), :after_join)
      {:ok, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  def handle_info(:after_join, socket) do
    Chatterbox.Message.recent_messages()
    |> Enum.each(fn msg -> push(socket, "shout", format_msg(msg)) end)
    {:noreply, socket}
  end

  # Channels can be used in a request/response fashion
  # by sending replies to requests from the client
  def handle_in("ping", payload, socket) do
    {:reply, {:ok, payload}, socket}
  end

  # It is also common to receive messages from the client and
  # broadcast to everyone in the current topic (chat_room:lobby).
  def handle_in("new_message", payload, socket) do
    broadcast socket, "shout", payload
    {:noreply, socket}
  end

  def handle_in("shout", payload, socket) do
    spawn(fn -> save_message(payload) end)
    broadcast! socket, "shout", payload
    {:noreply, socket}
  end

  def save_message(payload) do
    Chatterbox.Message.changeset(%Chatterbox.Message{}, payload)
      |> Chatterbox.Repo.insert
  end

  # Add authorization logic here as required.
  defp authorized?(_payload) do
    true
  end

  defp format_msg(msg) do
    %{
      name: msg.name,
      message: msg.message
    }
  end
end

defmodule ConfigSubscriber do
  def subscribe_to_config_changes(subscriber_pid) do
    ConfigCat.hooks()
    |> ConfigCat.Hooks.add_on_config_changed({__MODULE__, :on_config_changed, [subscriber_pid]})
  end

  def on_config_changed(config, pid) do
    # feature_flags = Map.get(config, "f", %{})

    # Find the feature flag with the key "myfeatureflag"
    my_feature_flag = Map.get(config, "myfeatureflag")

    # Extracting feature flag data
    feature_flag_data = Map.get(my_feature_flag, "v", %{})

    feature_flag_value = Map.get(feature_flag_data, "b", false)

    send(pid, {:config_changed, %{"feature_flag_value" => feature_flag_value}})
  end
end

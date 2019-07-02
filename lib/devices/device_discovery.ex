defmodule DeviceDiscovery do
  @dns_device_type "_raop._tcp"

  def list_devices(device_type \\ @dns_device_type) do
    results = discover_devices(device_type)

    devices =
      Enum.map(results, fn result ->
        result
        |> elem(0)
        |> String.trim("\n")
        |> String.split("@")
        |> List.last()
      end)
  end

  defp discover_devices(device_type) do
    {:ok, ref} = :dnssd.browse(device_type)
    Process.sleep(1)
    {:ok, results} = :dnssd.results(ref)
    :ok = :dnssd.stop(ref)
    results
  end
end

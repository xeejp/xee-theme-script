defmodule XeeThemeScript do
  @moduledoc """
  A behaviour module for definition a Xee theme.

  ## Examples

  def YourTheme do
    use XeeThemeScript

    # Callbacks

      def init, do: %{ids: MapSet.new(), logs: []}

      def receive_meta(data, %{host_id: host_id, token: token}) do
        {:ok, data}
      end

      def join(%{ids: ids} = data, id) do
        {:ok, %{data | ids: MapSet.put(ids, id)}}
      end

      def handle_message(data, message, token) do
        handle_received(data, message, token)
      end

      def handle_received(data, received) do
        handle_received(data, received, :host)
      end

      def handle_received(%{logs: logs} = data, received, id) do
        {:ok, %{data | logs: [{id, received} | logs]}}
      end
  end

  """

  @typedoc "Return values of `init/0`, `join/2`, and `handle_received/*` functions."
  @type result ::
  {:ok, new_state :: term} |
  :error |
  {:error, reason :: term}

  @doc """
  Invoked when the theme is loaded or reloaded.
  """
  @callback install :: :ok | :error | {:error, reason :: term}

  @doc """
  Invoked before the experiment is created.

  Returning `{:ok, new_state}` sets the initial state to `new_state`.

  Returning `:error` or `{:error, reason}` fails the creating of experiment.
  """
  @callback init :: result

  @doc """
  Invoked just after the experiment is created.

  Returning `{:ok, new_state}` changes the state to `new_state`.

  Returning `:error` or `{:error, reason}` keeps the state.
  """
  @callback receive_meta(state :: term, meta :: %{host_id: term, token: term}) :: result

  @doc """
  Invoked when a participant loads the experiment page.

  Returning `{:ok, new_state}` changes the state to `new_state`.

  Returning `:error` or `{:error, reason}` keeps the state.
  """
  @callback join(state :: term, id :: term) :: result

  @doc """
  Invoked when the experiment receives data from a host.

  Returning `{:ok, new_state}` changes the state to `new_state`.

  Returning `:error` or `{:error, reason}` keeps the state.
  """
  @callback handle_received(data :: term, received :: term) :: result

  @doc """
  Invoked when the experiment receives data from a participant.

  Returning `{:ok, new_state}` changes the state to `new_state`.

  Returning `:error` or `{:error, reason}` keeps the state.
  """
  @callback handle_received(data :: term, received :: term, id :: term) :: result

  @doc """
  Invoked when the experiment receives a message from another experiment.

  Returning `{:ok, new_state}` changes the state to `new_state`.

  Returning `:error` or `{:error, reason}` keeps the state.
  """
  @callback handle_message(data :: term, message :: term, token :: term) :: result

  @doc false
  defmacro __using__(_) do
    quote location: :keep do
      import unquote(__MODULE__)
      @behaviour unquote(__MODULE__)
      Module.register_attribute(__MODULE__, :require_file, accumulate: true)
      @before_compile unquote(__MODULE__)

      @doc false
      def init, do: {:ok, nil}
      def script_type, do: :data
      def install, do: :ok
      def receive_meta(data, meta) do
        {:error, "There is no matched `receive_meta/3`. data = #{inspect data}, meta = #{inspect meta}"}
      end
      def handle_message(data, message, token) do
        {:error, "There is no matched `handle_message/3`. data = #{inspect data}, message = #{inspect message}, token = #{token}"}
      end
      def handle_received(data, received) do
        {:error, "There is no matched `handle_received/2`. data = #{inspect data}, received = #{inspect received}"}
      end
      def handle_received(data, received, id) do
        {:error, "There is no matched `handle_received/3`. data = #{inspect data}, received = #{inspect received}, id = #{inspect id}"}
      end

      defoverridable [init: 0, install: 0, script_type: 0,
       handle_received: 2, handle_received: 3, handle_message: 3, receive_meta: 2]
    end
  end

  defmacro __before_compile__(_env) do
    quote do
      def require_files do
        IO.warn "Script-style themes are deprecated. You should use module-style themes."
        @require_file
      end
    end
  end

  defmacro require_file(file) do
    quote do
      @require_file unquote(file)
    end
  end
end

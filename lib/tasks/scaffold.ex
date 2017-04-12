defmodule Mix.Tasks.Scaffold do
  use Mix.Task
  @recursive true

  @moduledoc """
  Scaffold Phoenix source files using phx.gen tasks from YAML configuration file.
  """

  @doc false
  def run(_args) do
    Application.start(:yamerl)
    :yamerl_app.set_param(:node_mods, [:yamerl_node_erlang_atom])
    yamerl_parse_opts = [erlang_atom_autodetection: true, str_node_as_binary: true, erlang_atom_only_if_exist: true]

    {:ok, _} = Application.ensure_all_started(:phoenix)

    "priv/repo/schema.yaml"
    |> :yamerl_constr.file(yamerl_parse_opts)
    |> List.first()
    |> Enum.each(&process_task/1)
  end

  def process_task({task, args}) do
    Mix.Tasks.Phx.Gen
    |> Module.concat(task)
    |> apply(:run, [prepare_args(args)])
  end

  def prepare_args(args) do
    [
      fetch_value!(args, :context),
      fetch_value!(args, :model),
      fetch_value!(args, :table)
    ] ++ Keyword.fetch!(args, :fields)
  end

  def fetch_value!(args, field) do
    args
    |> Keyword.fetch!(field)
    |> prepare_value_type()
  end

  def prepare_value_type(value) when is_atom(value), do: Atom.to_string(value)
  def prepare_value_type(value) when is_list(value), do: Enum.join(value, " ")
  def prepare_value_type(value) when is_binary(value), do: value
end

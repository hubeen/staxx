defmodule Staxx.Testchain.EVM.Config do
  @moduledoc """
  Default start configuration for new EVM.

  Options:
  - `type` - EVM type. (Default: `:ganache`)
  - `id` - Random unique internal process identificator. Example: `"11296068888839073704"`. If empty system will generate it automatically
  - `existing` - Identifies if we need to start already existing chain. In that case all other options except `id` will be ignored.
  - `network_id` - Network ID (Default: `Application.get_env(:deployment, :default_chain_id)`)
  - `db_path` - Specify a path to a directory to save the chain database
  - `block_mine_time` - Block period to use in developer mode (0 = mine only if transaction pending) (default: 0)
  - `gas_limit` - The block gas limit (defaults to `9000000000000`)
  - `accounts` - How many accoutn should be created on start (Default: `1`)
  - `clean_on_stop` - Clean up `db_path` after chain is stopped. (Default: `false`)
  - `description` - Chain description for storage
  - `snapshot_id` - Snapshot ID that should be loaded on chain start
  """

  require Logger

  alias Staxx.Testchain
  alias Staxx.Testchain.Helper

  # File name where cnofig will be writen
  @config_file_name "chain.cfg"

  @type t :: %__MODULE__{
          type: Testchain.evm_type(),
          id: Testchain.evm_id() | nil,
          existing: boolean(),
          network_id: non_neg_integer(),
          db_path: binary(),
          block_mine_time: non_neg_integer(),
          gas_limit: pos_integer(),
          accounts: non_neg_integer(),
          clean_on_stop: boolean(),
          description: binary,
          snapshot_id: nil | binary
        }

  defstruct type: :ganache,
            id: nil,
            existing: false,
            network_id: Application.get_env(:ex_chain, :default_chain_id, 999),
            db_path: "",
            block_mine_time: 0,
            gas_limit: 9_000_000_000_000,
            accounts: 1,
            clean_on_stop: false,
            description: "",
            snapshot_id: nil

  @doc """
  Store configuration in testhcian `db_path`.
  """
  @spec store(t()) :: :ok | {:error, term}
  def store(%__MODULE__{db_path: ""}),
    do: {:error, "no db_path exist in config"}

  def store(%__MODULE__{db_path: db_path} = config) do
    db_path
    |> Path.join(@config_file_name)
    |> Helper.write_term_to_file(config)
  end

  @doc """
  Load configuration from given path
  """
  @spec load(binary) :: {:ok, t()} | {:error, term}
  def load(db_path) do
    db_path
    |> Path.join(@config_file_name)
    |> Helper.read_term_from_file()
  end
end

defmodule Fruitbot.MarkovBackup do
  @moduledoc """
  Module to handle backing up and restoring markov model files to prevent corruption.
  """

  require Logger

  @model_path "./coach_model"
  @backup_dir "./model_backups"
  @max_backups 10

  def ensure_backup_dir do
    File.mkdir_p(@backup_dir)
  end

  def create_backup do
    ensure_backup_dir()
    
    if File.exists?(@model_path) do
      timestamp = DateTime.utc_now() |> DateTime.to_unix() |> to_string()
      backup_path = Path.join(@backup_dir, "coach_model_#{timestamp}")
      
      case File.cp_r(@model_path, backup_path) do
        {:ok, _} ->
          Logger.info("Created markov model backup at #{backup_path}")
          cleanup_old_backups()
          {:ok, backup_path}
        {:error, reason} ->
          Logger.error("Failed to create markov model backup: #{reason}")
          {:error, reason}
      end
    else
      Logger.warn("No model file found at #{@model_path} to backup")
      {:error, :no_model_file}
    end
  end

  def restore_latest_backup do
    ensure_backup_dir()
    
    case get_latest_backup() do
      {:ok, backup_path} ->
        case File.cp_r(backup_path, @model_path) do
          {:ok, _} ->
            Logger.info("Restored markov model from backup at #{backup_path}")
            {:ok, backup_path}
          {:error, reason} ->
            Logger.error("Failed to restore markov model from backup: #{reason}")
            {:error, reason}
        end
      {:error, reason} ->
        Logger.error("No backup available to restore: #{reason}")
        {:error, reason}
    end
  end

  def get_latest_backup do
    case File.ls(@backup_dir) do
      {:ok, files} ->
        backup_files = files
        |> Enum.filter(fn f -> String.starts_with?(f, "coach_model_") end)
        |> Enum.sort(:desc)
        
        case backup_files do
          [latest | _] ->
            {:ok, Path.join(@backup_dir, latest)}
          [] ->
            {:error, :no_backups}
        end
      {:error, reason} ->
        {:error, reason}
    end
  end

  defp cleanup_old_backups do
    case File.ls(@backup_dir) do
      {:ok, files} ->
        backup_files = files
        |> Enum.filter(fn f -> String.starts_with?(f, "coach_model_") end)
        |> Enum.sort(:desc)
        
        if length(backup_files) > @max_backups do
          files_to_delete = Enum.drop(backup_files, @max_backups)
          Enum.each(files_to_delete, fn file ->
            file_path = Path.join(@backup_dir, file)
            case File.rm_rf(file_path) do
              {:ok, _} ->
                Logger.info("Cleaned up old backup: #{file}")
              {:error, reason} ->
                Logger.error("Failed to clean up old backup #{file}: #{reason}")
            end
          end)
        end
      {:error, reason} ->
        Logger.error("Failed to list backup directory: #{reason}")
    end
  end

  def safe_model_operation(operation) do
    # Create backup before any model operation
    create_backup()
    
    try do
      result = operation.()
      result
    rescue
      error ->
        Logger.error("Model operation failed: #{inspect(error)}")
        Logger.info("Attempting to restore from backup...")
        restore_latest_backup()
        reraise error, __STACKTRACE__
    end
  end
end
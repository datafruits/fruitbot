# Markov Model Backup System

This document describes the model corruption protection system implemented for the fruitbot's markov chain functionality.

## Overview

The backup system protects the `coach_model` file from corruption by:
- Creating automatic backups before model operations
- Performing periodic backups every 30 minutes
- Maintaining a rotation of the last 10 backups
- Providing automatic recovery on model operation failures
- Offering manual restore functionality

## Components

### Fruitbot.MarkovBackup Module

Located in `lib/fruitbot/markov_backup.ex`, this module provides:

- `create_backup()` - Creates a timestamped backup of the current model
- `restore_latest_backup()` - Restores the most recent backup
- `safe_model_operation(function)` - Wraps model operations with backup/recovery
- `get_latest_backup()` - Gets path to the most recent backup

### Backup Storage

- Backups are stored in `./model_backups/` directory
- Each backup is named `coach_model_<timestamp>`
- Directory is automatically created if it doesn't exist
- Old backups are automatically cleaned up (keeps last 10)

## Usage

### Automatic Protection

All markov operations are automatically protected:
- `!advice` command generation
- Model training on unrecognized commands

### Manual Recovery

If the model becomes corrupted, use:
```
!restore-model
```

This command will restore the most recent backup.

## Configuration

- Backup interval: 30 minutes (configurable in worker.ex)
- Max backups kept: 10 (configurable in markov_backup.ex)
- Model path: `./coach_model`
- Backup directory: `./model_backups/`

## Files Excluded from Git

The following are added to `.gitignore`:
- `coach_model` - The main model file
- `model_backups/` - All backup files

This prevents large model files from being committed to the repository.

## Error Handling

If any model operation fails:
1. The error is logged
2. The system attempts to restore from the latest backup
3. The original error is re-raised for proper error propagation
4. Operators are notified via logs

This ensures the bot remains functional even if model corruption occurs.
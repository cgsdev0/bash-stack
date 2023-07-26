#!/usr/bin/env bash

set -e

# Define variables
BASE_URL="https://github.com/cgsdev0/bash-stack/releases/latest/download"
ZIP_NAME="template.zip"

# Function to display usage instructions
show_usage() {
  echo "Usage: $0 <project-name>"
}

# Function to download and extract the framework zip file
download_framework() {
  echo "Downloading the framework..."
  if ! curl -sSL "$BASE_URL/$ZIP_NAME" -o "$TMP_DIR/$ZIP_NAME"; then
    echo "Error: Failed to download the framework." 1>&2
    rm -rf "$TMP_DIR"
    exit 1
  fi
  echo "Extracting the framework..."
  if ! unzip -q "$TMP_DIR/$ZIP_NAME" -d "$TMP_DIR"; then
    echo "Error: Failed to extract the framework." 1>&2
    rm -rf "$TMP_DIR"
    exit 1
  fi
  rm "$TMP_DIR/$ZIP_NAME"
}

# Function to check if the project name is valid
is_valid_project_name() {
  local name="$1"
  if [[ ! "$name" =~ ^[a-zA-Z0-9_-]+$ ]]; then
    return 1
  fi
  return 0
}

# Function to set up a new project
setup_project() {
  echo "Creating a new project '$PROJECT_NAME'..."
  cp -r "$TMP_DIR" "./$PROJECT_NAME"
  cd "$PROJECT_NAME"
  echo "PROJECT_NAME=${PROJECT_NAME}" > "config.sh"
  echo "Project '$PROJECT_NAME' is ready!"
  echo ""
  echo "You can get started by doing the following:"
  echo "\tcd './$PROJECT_NAME'"
  echo "\t./start.sh"
}

# Main script
main() {
  TMP_DIR=$(mktemp -d)

  # Check if a project name is provided as an argument
  if [ -z "$1" ]; then
    # we need to connect to /dev/tty in order to read stdin
    if [ ! -t 0 ]; then
        if [ ! -t 1 ]; then
            echo "Error: Unable to run interactively!" 1>&2
            exit 1
        fi
      read -p "Enter a project name: " PROJECT_NAME </dev/tty
    else
      read -p "Enter a project name: " PROJECT_NAME
    fi
    # Prompt the user for the project name interactively
    if [ -z "$PROJECT_NAME" ]; then
      show_usage
      rm -rf "$TMP_DIR"
      exit 1
    fi
  else
    PROJECT_NAME="$1"
  fi

  # Check if the project name is valid
  if ! is_valid_project_name "$PROJECT_NAME"; then
    echo "Error: Invalid project name. Project name can only contain letters, numbers, dashes, and underscores." 1>&2
    rm -rf "$TMP_DIR"
    exit 1
  fi

  # Check if the project directory already exists
  if [ -d "$PROJECT_NAME" ]; then
    echo "Error: Project directory '$PROJECT_NAME' already exists." 1>&2
    rm -rf "$TMP_DIR"
    exit 1
  fi

  # Download and extract the framework
  download_framework

  # Set up the project
  setup_project

  # Clean up temporary directory
  rm -rf "$TMP_DIR"
}

# Run the main script
main "$@"

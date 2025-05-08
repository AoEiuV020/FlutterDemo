#!/bin/sh
set -e
script_dir=$(cd $(dirname $0);pwd)
ROOT=$(dirname "$script_dir")
GO_PROJECT_PATH="$ROOT"/packages/native_add/go

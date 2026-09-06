#!/usr/bin/env bash
# BI Ticket System - One-Click Launcher for macOS / Linux

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
cd "$SCRIPT_DIR"

echo "========================================"
echo " Starting BI Ticket System (Offline Mode)"
echo "========================================"
echo ""

# Check for bundled portable Ruby inside project directory (vendor/ruby)
if [ -f "$SCRIPT_DIR/vendor/ruby/bin/ruby" ]; then
    echo "Using bundled portable Ruby runtime..."
    export PATH="$SCRIPT_DIR/vendor/ruby/bin:$PATH"
elif ! command -v ruby &> /dev/null; then
    echo "[ERROR] Ruby runtime not found!"
    echo "Please ensure vendor/ruby is present in the project directory or Ruby is installed on this system."
    read -p "Press Enter to exit..."
    exit 1
fi

if [ -d "$SCRIPT_DIR/vendor/bundle" ]; then
    export BUNDLE_PATH="$SCRIPT_DIR/vendor/bundle"
fi

# Check if gems are installed; auto-install if missing
if ! bundle exec rails -v &> /dev/null; then
    echo "First-time setup: Installing required gems..."
    bundle install
fi

if [ ! -f "db/development.sqlite3" ]; then
    echo "First-time setup: Preparing local database..."
    bundle exec rails db:prepare
fi

URL="http://localhost:3000"

echo "Opening $URL in your default web browser..."
if command -v open &> /dev/null; then
    open "$URL"
elif command -v xdg-open &> /dev/null; then
    xdg-open "$URL"
fi

echo ""
echo "BI Ticket System is running at $URL"
echo "Press Ctrl+C in this terminal to stop."
echo ""

bundle exec rails server -b 127.0.0.1 -p 3000

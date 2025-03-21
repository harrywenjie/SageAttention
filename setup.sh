#!/bin/bash

# Create a virtual environment if it doesn't exist
if [ ! -d "venv" ]; then
    python -m venv venv
fi

# Activate the virtual environment and install requirements
source venv/bin/activate
pip install -r requirements.txt


echo "Installation Complete"
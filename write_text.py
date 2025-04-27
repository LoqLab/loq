#!/usr/bin/env python3
import sys
import gi
gi.require_version('Atspi', '2.0')
from gi.repository import Atspi

def insert_text(text):
    # Initialize accessibility
    if not Atspi.is_initialized():
        Atspi.init()
    
    # Use keyboard event string injection (most reliable for accessibility)
    Atspi.generate_keyboard_event(0, text, Atspi.KeySynthType.STRING)
    return True

if __name__ == "__main__":
    # Accept text from command line or stdin
    if len(sys.argv) > 1:
        text_to_insert = sys.argv[1]
    else:
        text_to_insert = sys.stdin.read()
    
    success = insert_text(text_to_insert)
    sys.exit(0 if success else 1)

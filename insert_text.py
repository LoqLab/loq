import gi
gi.require_version('Atspi', '2.0')
from gi.repository import Atspi
import sys

def insert_text(text):
    Atspi.init()
    desktop = Atspi.get_desktop(0)
    focused = desktop.get_focused()
    
    # Traverse ancestors if focused object isn't a text component
    while focused and focused.get_role_name() != 'text':
        focused = focused.get_parent()
    
    if focused and focused.get_role_name() == 'text':
        text_interface = focused.query_text()
        cursor_pos = text_interface.get_caret_offset()
        focused.insert_text(text, cursor_pos)
        return True
    return False

if __name__ == "__main__":
    text_to_insert = sys.argv[1] if len(sys.argv) > 1 else ""
    success = insert_text(text_to_insert)
    sys.exit(0 if success else 1)

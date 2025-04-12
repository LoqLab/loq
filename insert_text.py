import pyatspi
import sys

def insert_text(text):
    pyatspi.Registry.start()
    focused = pyatspi.getFocus()  # Get focused element directly
    
    # Traverse ancestors for text components
    while focused and focused.getRoleName() not in ['text', 'edit']:
        focused = focused.parent
    
    if focused and focused.getRoleName() in ['text', 'edit']:
        text_interface = focused.queryText()
        cursor_pos = text_interface.caretOffset
        text_interface.insertText(cursor_pos, text, -1)
        return True
    return False

if __name__ == "__main__":
    text_to_insert = sys.argv[1] if len(sys.argv) > 1 else ""
    success = insert_text(text_to_insert)
    sys.exit(0 if success else 1)

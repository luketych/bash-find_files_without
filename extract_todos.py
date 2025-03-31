import subprocess
import re
import os

TODO_FILE = "TODO.md"

def extract_todos():
    """
    Extracts all TODO comments from the repository and writes them to a TODO.md file.
    """
    # Run git grep to find all TODOs in the repository
    try:
        result = subprocess.run(
            ["git", "grep", "-In", "TODO"],
            capture_output=True,
            text=True
        )
    except FileNotFoundError:
        print("Error: Git is not installed or not found in PATH.")
        return
    
    if not result.stdout.strip():
        print("No TODOs found in the repository.")
        return

    todos = []
    
    for line in result.stdout.split("\n"):
        match = re.search(r"(.+):(\d+):.*TODO[: ](.*)", line)
        if match:
            file_path, line_number, comment = match.groups()
            todos.append(f"- [ ] {comment.strip()}  *(📍 {file_path}:{line_number})*")

    # Generate new TODO.md content
    todo_content = "# TODO List\n\n"
    todo_content += "\n".join(todos)
    
    with open(TODO_FILE, "w") as f:
        f.write(todo_content)
    
    print(f"Extracted {len(todos)} TODOs and saved them in {TODO_FILE}")

if __name__ == "__main__":
    extract_todos()

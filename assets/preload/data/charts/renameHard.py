import os

# Get the current working directory
cwd = os.getcwd()

# Iterate through all the files and folders in the directory
for root, dirs, files in os.walk(cwd):
    for file in files:
        # Check if the file is a JSON and has "-hard" in its name
        if file.endswith(".json") and "-hard" in file:
            # Construct the full path of the file
            file_path = os.path.join(root, file)
            # Rename the file
            new_file_name = os.path.splitext(file)[0].replace("-hard", "") + os.path.splitext(file)[1]
            new_file_path = os.path.join(root, new_file_name)
            os.rename(file_path, new_file_path)

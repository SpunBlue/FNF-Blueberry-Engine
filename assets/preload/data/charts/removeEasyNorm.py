import os

# Get the current working directory
cwd = os.getcwd()

# variable to hold the json with -hard
json_with_hard = ""
# Iterate through all the files and folders in the directory
for root, dirs, files in os.walk(cwd):
    for file in files:
        # Check if the file is a JSON and doesn't have "-hard" in its name
        if file.endswith(".json") and "-hard" not in file:
            # Construct the full path of the file
            file_path = os.path.join(root, file)
            # Delete the file
            os.remove(file_path)
        # Check if the file is a JSON and has "-hard" in its name
        elif file.endswith(".json") and "-hard" in file:
            json_with_hard = os.path.join(root, file)
            
if json_with_hard:
    new_file_name = os.path.splitext(json_with_hard)[0].replace("-hard", "") + os.path.splitext(json_with_hard)[1]
    os.rename(json_with_hard, new_file_name)

import os
import shutil

def process_folder(folder_path, rename_list):
    for item in os.listdir(folder_path):
        item_path = os.path.join(folder_path, item)
        if os.path.isfile(item_path):
            if item.endswith(".json") and item != "picospeaker.json":
                if "-hard" not in item:
                    os.remove(item_path)
                else:
                    rename_list.append(item_path)
        elif os.path.isdir(item_path):
            process_folder(item_path, rename_list)

def main():
    current_folder = os.getcwd()
    rename_list = []
    process_folder(current_folder, rename_list)
    for item in rename_list:
        folder, filename = os.path.split(item)
        new_name = filename.replace("-hard", "")
        new_path = os.path.join(folder, new_name)
        shutil.move(item, new_path)

if __name__ == "__main__":
    main()

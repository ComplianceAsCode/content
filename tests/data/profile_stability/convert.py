import yaml
from pathlib import Path


def load_selections(file_path):
    try:
        with open(file_path, "r") as file:
            data = yaml.safe_load(file)
            selections = data.get("selections", [])
            if isinstance(selections, list):
                return sorted(selections)
            else:
                print("The 'selections' key is not a list.")
    except FileNotFoundError:
        print(f"File not found: {file_path}")
    except yaml.YAMLError as e:
        print(f"Error parsing YAML file: {e}")


def save_selections(file, selections):
    with file.open("w") as f:
        for selection in selections:
            f.write(f"{selection}\n")


def main():
    profile_stability_dir = Path("tests/data/profile_stability")
    for dir in profile_stability_dir.iterdir():
        if not dir.is_dir():
            continue
        for file in dir.iterdir():
            if file.suffix != ".profile":
                continue
            selections = load_selections(file)
            save_selections(file, selections)


if __name__ == "__main__":
    main()

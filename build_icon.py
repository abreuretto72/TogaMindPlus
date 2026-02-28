from PIL import Image
import os
import sys

def main():
    try:
        source_path = "logo.png"
        if not os.path.exists(source_path):
            print(f"Error: {source_path} not found.")
            sys.exit(1)

        img = Image.open(source_path)

        # 1. Create .ico for PyInstaller / Inno Setup
        ico_sizes = [(16, 16), (32, 32), (48, 48), (64, 64), (128, 128), (256, 256)]
        img.save("icone.ico", format="ICO", sizes=ico_sizes)
        print("Created icone.ico")

        # 2. Create Flutter Web Icons
        web_icons_dir = os.path.join("web", "icons")
        if not os.path.exists(web_icons_dir):
            os.makedirs(web_icons_dir, exist_ok=True)

        flutter_sizes = {
            "web/favicon.png": 16,
            "web/icons/Icon-192.png": 192,
            "web/icons/Icon-512.png": 512,
            "web/icons/Icon-maskable-192.png": 192,
            "web/icons/Icon-maskable-512.png": 512,
            "web/apple-touch-icon.png": 192
        }

        for path, size in flutter_sizes.items():
            resized_img = img.resize((size, size), Image.Resampling.LANCZOS)
            resized_img.save(path, format="PNG")
            print(f"Created {path}")

        print("Icon conversion completed successfully.")
    except Exception as e:
        print(f"Failed to process image: {e}")
        sys.exit(1)

if __name__ == "__main__":
    main()

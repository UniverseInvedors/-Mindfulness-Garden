# download_assets_fixed.py
import os
import requests
import json
from pathlib import Path

# Free audio sources that don't require API keys
SOUNDS = {
    # Using freesound.org preview URLs (these are temporary preview URLs)
    "garden_day.mp3": "https://cdn.freesound.org/previews/346/346124_5121236-lq.mp3",
    "garden_night.mp3": "https://cdn.freesound.org/previews/415/415526_8076909-lq.mp3",
    "bird_chirp.mp3": "https://cdn.freesound.org/previews/412/412064_7205976-lq.mp3",
    "cricket.mp3": "https://cdn.freesound.org/previews/397/397508_8462797-lq.mp3",
    "meditation_bell.mp3": "https://cdn.freesound.org/previews/411/411089_5121236-lq.mp3",
    "rain.mp3": "https://cdn.freesound.org/previews/346/346124_5121236-lq.mp3",
    "ocean_waves.mp3": "https://cdn.freesound.org/previews/431/431294_7098306-lq.mp3",
    "forest_stream.mp3": "https://cdn.freesound.org/previews/346/346124_5121236-lq.mp3",
    "button_click.mp3": "https://cdn.freesound.org/previews/254/254308_4343435-lq.mp3",
    "water.mp3": "https://cdn.freesound.org/previews/367/367754_6435909-lq.mp3",
    "success.mp3": "https://cdn.freesound.org/previews/270/270333_5121236-lq.mp3",
}

# Alternative: Use audio files from GitHub (free)
GITHUB_AUDIO = {
    "garden_day.mp3": "https://github.com/AnasNeBB/sound-effects/raw/main/nature/forest-ambience.mp3",
    "bird_chirp.mp3": "https://github.com/AnasNeBB/sound-effects/raw/main/nature/birds-chirping.mp3",
    "water.mp3": "https://github.com/AnasNeBB/sound-effects/raw/main/water/water-droplet.mp3",
    "success.mp3": "https://github.com/AnasNeBB/sound-effects/raw/main/ui/success.mp3",
}

def download_file(url, filepath):
    """Download a file from URL to filepath"""
    try:
        headers = {
            'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36'
        }
        response = requests.get(url, stream=True, timeout=10, headers=headers)
        response.raise_for_status()
        
        with open(filepath, 'wb') as f:
            for chunk in response.iter_content(chunk_size=8192):
                if chunk:
                    f.write(chunk)
        return True
    except Exception as e:
        print(f"  ❌ Failed to download {url}: {e}")
        return False

def create_silent_audio_file(filepath, duration_sec=1):
    """Create a silent audio file using ffmpeg or just a placeholder"""
    try:
        # Try to use ffmpeg if available
        import subprocess
        result = subprocess.run(['ffmpeg', '-version'], capture_output=True, text=True)
        if result.returncode == 0:
            subprocess.run([
                'ffmpeg', '-f', 'lavfi', '-i', f'anullsrc=r=44100:cl=stereo:d={duration_sec}',
                '-c:a', 'libmp3lame', '-q:a', '9', str(filepath)
            ], check=True, capture_output=True)
            print(f"  ✅ Created silent audio: {filepath}")
            return True
    except:
        pass
    
    # Create placeholder text file as fallback
    with open(filepath, 'w') as f:
        f.write(f"# Placeholder audio file for {filepath.name}\n")
        f.write("# Replace with actual audio file\n")
    print(f"  ⚠️ Created placeholder for {filepath}")
    return False

def create_placeholder_image(filepath):
    """Create a simple text placeholder for images"""
    with open(filepath, 'w') as f:
        f.write(f"# Placeholder image for {filepath.name}\n")
        f.write("# Replace with actual image file\n")
    print(f"  ⚠️ Created placeholder for {filepath}")

def create_placeholder_animation(filepath):
    """Create a simple Lottie animation placeholder"""
    placeholder_json = {
        "v": "5.5.7",
        "fr": 60,
        "ip": 0,
        "op": 60,
        "w": 500,
        "h": 500,
        "nm": filepath.stem,
        "ddd": 0,
        "assets": [],
        "layers": [{
            "ddd": 0,
            "ind": 1,
            "ty": 4,
            "nm": "Placeholder",
            "sr": 1,
            "ks": {
                "o": {"a": 0, "k": 100},
                "r": {"a": 0, "k": 0},
                "p": {"a": 0, "k": [250, 250, 0]},
                "a": {"a": 0, "k": [0, 0, 0]},
                "s": {"a": 0, "k": [100, 100, 100]}
            },
            "shapes": [{
                "ty": "rc",
                "d": 1,
                "s": {"a": 0, "k": [100, 100]},
                "p": {"a": 0, "k": [0, 0]},
                "r": {"a": 0, "k": 0},
                "nm": "Rectangle"
            }]
        }]
    }
    with open(filepath, 'w') as f:
        json.dump(placeholder_json, f, indent=2)
    print(f"  ✅ Created placeholder animation: {filepath.name}")

def main():
    print("🌱 Mindfulness Garden Asset Downloader (Fixed Version)")
    print("=" * 50)
    
    # Create asset directories
    assets_dir = Path("assets")
    sounds_dir = assets_dir / "sounds"
    images_dir = assets_dir / "images"
    animations_dir = assets_dir / "animations"
    
    for directory in [sounds_dir, images_dir, animations_dir]:
        directory.mkdir(parents=True, exist_ok=True)
        print(f"📁 Ensured directory: {directory}")
    
    # Try to download from GitHub first (more reliable)
    print("\n🎵 Downloading sounds from GitHub...")
    for filename, url in GITHUB_AUDIO.items():
        filepath = sounds_dir / filename
        if not filepath.exists():
            print(f"  Downloading {filename}...")
            if not download_file(url, filepath):
                create_silent_audio_file(filepath)
        else:
            print(f"  ✅ {filename} already exists")
    
    # Create silent audio files for missing sounds
    print("\n🔊 Creating silent audio files for missing sounds...")
    required_sounds = [
        "garden_day.mp3", "garden_night.mp3", "bird_chirp.mp3", "cricket.mp3",
        "meditation_bell.mp3", "rain.mp3", "ocean_waves.mp3", "forest_stream.mp3",
        "button_click.mp3", "water.mp3", "plant.mp3", "harvest.mp3", "heal.mp3",
        "sparkle.mp3", "happy.mp3", "bonus.mp3", "breathing_guide.mp3", "collect_water.mp3"
    ]
    
    for filename in required_sounds:
        filepath = sounds_dir / filename
        if not filepath.exists():
            create_silent_audio_file(filepath)
    
    # Create placeholder images
    print("\n🖼️ Creating placeholder images...")
    required_images = [
        "app_icon.png", "splash_background.png", "garden_background_day.jpg",
        "garden_background_night.jpg", "flower.png", "tree.png", "bush.png",
        "herb.png", "mushroom.png", "logo.png", "meditation_icon.png", "breathing_icon.png"
    ]
    
    for filename in required_images:
        filepath = images_dir / filename
        if not filepath.exists():
            create_placeholder_image(filepath)
    
    # Create placeholder animations
    print("\n🎨 Creating placeholder animations...")
    required_animations = [
        "meditation_animation.json", "breathing_animation.json",
        "confetti.json", "celebration.json", "sparkles.json"
    ]
    
    for filename in required_animations:
        filepath = animations_dir / filename
        if not filepath.exists():
            create_placeholder_animation(filepath)
    
    # Fix pubspec.yaml if needed
    print("\n📝 Checking pubspec.yaml...")
    pubspec_path = Path("pubspec.yaml")
    if pubspec_path.exists():
        content = pubspec_path.read_text()
        
        if "assets:" not in content:
            # Add assets section
            content += "\nflutter:\n  assets:\n    - assets/images/\n    - assets/sounds/\n    - assets/animations/\n    - assets/fonts/\n"
            pubspec_path.write_text(content)
            print("  ✅ Added assets section to pubspec.yaml")
    
    print("\n" + "=" * 50)
    print("✅ Asset setup complete!")
    print("\nNext steps:")
    print("1. Run: flutter clean")
    print("2. Run: flutter pub get")
    print("3. Run: dart run build_runner build --delete-conflicting-outputs")
    print("4. Run: flutter run")
    print("\nNote: Silent audio files were created. Replace them with real audio files later.")

if __name__ == "__main__":
    main()
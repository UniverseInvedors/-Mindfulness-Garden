# scripts/download_assets.py
import os
import requests
import json
from pathlib import Path
from urllib.parse import urlparse
import concurrent.futures

class AssetDownloader:
    def __init__(self):
        self.base_dir = Path(__file__).parent.parent
        self.assets_config = {
            'sounds': {
                'nature': {
                    'forest.mp3': 'https://assets.mixkit.co/sfx/preview/mixkit-forest-ambience-943.mp3',
                    'ocean.mp3': 'https://assets.mixkit.co/sfx/preview/mixkit-ocean-waves-loop-1240.mp3',
                    'rain.mp3': 'https://assets.mixkit.co/sfx/preview/mixkit-rain-loop-1242.mp3',
                    'birds.mp3': 'https://assets.mixkit.co/sfx/preview/mixkit-birds-chirping-2469.mp3',
                    'waterfall.mp3': 'https://assets.mixkit.co/sfx/preview/mixkit-waterfall-nature-loop-1241.mp3',
                    'wind.mp3': 'https://assets.mixkit.co/sfx/preview/mixkit-wind-in-the-trees-2492.mp3',
                },
                'meditation': {
                    'bowl.mp3': 'https://assets.mixkit.co/sfx/preview/mixkit-singing-bowl-2595.mp3',
                    'chime.mp3': 'https://assets.mixkit.co/sfx/preview/mixkit-wind-chimes-2995.mp3',
                    'gong.mp3': 'https://assets.mixkit.co/sfx/preview/mixkit-gong-showbiz-announcement-483.mp3',
                    'bell.mp3': 'https://assets.mixkit.co/sfx/preview/mixkit-tibetan-bell-2326.mp3',
                },
                'breathing': {
                    'inhale.mp3': 'https://cdn.pixabay.com/download/audio/2022/11/15/audio_8c1ee13671.mp3',
                    'exhale.mp3': 'https://cdn.pixabay.com/download/audio/2022/11/15/audio_9805c0a764.mp3',
                    'hold.mp3': 'https://cdn.pixabay.com/download/audio/2022/11/15/audio_3731eec314.mp3',
                }
            },
            'images': {
                'garden': {
                    'plant_1.png': 'https://cdn.pixabay.com/photo/2017/06/11/18/57/plant-2393112_640.png',
                    'plant_2.png': 'https://cdn.pixabay.com/photo/2017/06/11/18/57/plant-2393113_640.png',
                    'plant_3.png': 'https://cdn.pixabay.com/photo/2017/06/11/18/57/plant-2393114_640.png',
                    'garden_bg.jpg': 'https://cdn.pixabay.com/photo/2016/11/29/05/45/astronomy-1867616_640.jpg',
                },
                'icons': {
                    'meditation.png': 'https://cdn.pixabay.com/photo/2017/01/31/23/42/meditation-2028156_640.png',
                    'breathing.png': 'https://cdn.pixabay.com/photo/2017/01/31/23/42/leaf-2028158_640.png',
                    'garden.png': 'https://cdn.pixabay.com/photo/2017/01/31/23/42/plant-2028157_640.png',
                    'sleep.png': 'https://cdn.pixabay.com/photo/2017/01/31/23/42/moon-2028159_640.png',
                }
            },
            'animations': {
                'mindfulness_logo.json': 'https://assets9.lottiefiles.com/packages/lf20_xtwyvqnx.json',
                'loading.json': 'https://assets9.lottiefiles.com/packages/lf20_raiw2hpe.json',
                'success.json': 'https://assets9.lottiefiles.com/packages/lf20_ykzpojzk.json',
            }
        }
    
    def download_file(self, url, destination):
        """Download a single file"""
        try:
            response = requests.get(url, stream=True, timeout=30)
            response.raise_for_status()
            
            # Create directory if it doesn't exist
            destination.parent.mkdir(parents=True, exist_ok=True)
            
            # Download the file
            with open(destination, 'wb') as f:
                for chunk in response.iter_content(chunk_size=8192):
                    f.write(chunk)
            
            print(f"✅ Downloaded: {destination}")
            return True
            
        except Exception as e:
            print(f"❌ Failed to download {url}: {e}")
            return False
    
    def check_existing_assets(self):
        """Check which assets already exist"""
        existing = []
        missing = []
        
        for category, subcategories in self.assets_config.items():
            for subcategory, files in subcategories.items():
                for filename, url in files.items():
                    asset_path = self.base_dir / 'assets' / category / subcategory / filename
                    if asset_path.exists():
                        existing.append(str(asset_path))
                    else:
                        missing.append({
                            'url': url,
                            'path': asset_path
                        })
        
        return existing, missing
    
    def download_missing_assets(self, max_workers=5):
        """Download all missing assets in parallel"""
        _, missing = self.check_existing_assets()
        
        if not missing:
            print("🎉 All assets are already downloaded!")
            return
        
        print(f"📥 Downloading {len(missing)} missing assets...")
        
        with concurrent.futures.ThreadPoolExecutor(max_workers=max_workers) as executor:
            futures = []
            for item in missing:
                future = executor.submit(
                    self.download_file,
                    item['url'],
                    item['path']
                )
                futures.append(future)
            
            # Wait for all downloads to complete
            results = []
            for future in concurrent.futures.as_completed(futures):
                results.append(future.result())
        
        success_count = sum(results)
        print(f"\n📊 Download Summary:")
        print(f"   ✅ Successfully downloaded: {success_count}")
        print(f"   ❌ Failed: {len(missing) - success_count}")
    
    def create_placeholder_assets(self):
        """Create placeholder assets if download fails"""
        placeholder_dir = self.base_dir / 'assets' / 'placeholders'
        placeholder_dir.mkdir(parents=True, exist_ok=True)
        
        # Create simple placeholder files
        placeholders = {
            'sounds': ['.mp3'],
            'images': ['.png', '.jpg'],
            'animations': ['.json']
        }
        
        for category, extensions in placeholders.items():
            for ext in extensions:
                placeholder_file = placeholder_dir / f'placeholder{ext}'
                if not placeholder_file.exists():
                    if ext == '.mp3':
                        # Create silent MP3
                        placeholder_file.write_bytes(b'')  # Empty file for now
                    elif ext == '.png':
                        # Create simple 1x1 transparent PNG
                        import base64
                        transparent_png = base64.b64decode(
                            'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg=='
                        )
                        placeholder_file.write_bytes(transparent_png)
                    elif ext == '.json':
                        # Create simple Lottie placeholder
                        placeholder_data = {
                            "v": "5.5.9",
                            "fr": 60,
                            "ip": 0,
                            "op": 60,
                            "w": 100,
                            "h": 100,
                            "nm": "Placeholder",
                            "layers": []
                        }
                        placeholder_file.write_text(json.dumps(placeholder_data))
        
        print(f"✅ Created placeholder assets in {placeholder_dir}")
    
    def generate_asset_list(self):
        """Generate a Dart file with asset constants"""
        dart_file = self.base_dir / 'lib' / 'core' / 'constants' / 'assets.dart'
        
        dart_content = '''// GENERATED FILE - DO NOT EDIT
// This file contains all asset paths used in the app

class Assets {
  Assets._();
  
  // Sounds - Nature
  static const String forestSound = 'assets/sounds/nature/forest.mp3';
  static const String oceanSound = 'assets/sounds/nature/ocean.mp3';
  static const String rainSound = 'assets/sounds/nature/rain.mp3';
  static const String birdsSound = 'assets/sounds/nature/birds.mp3';
  static const String waterfallSound = 'assets/sounds/nature/waterfall.mp3';
  static const String windSound = 'assets/sounds/nature/wind.mp3';
  
  // Sounds - Meditation
  static const String bowlSound = 'assets/sounds/meditation/bowl.mp3';
  static const String chimeSound = 'assets/sounds/meditation/chime.mp3';
  static const String gongSound = 'assets/sounds/meditation/gong.mp3';
  static const String bellSound = 'assets/sounds/meditation/bell.mp3';
  
  // Sounds - Breathing
  static const String inhaleSound = 'assets/sounds/breathing/inhale.mp3';
  static const String exhaleSound = 'assets/sounds/breathing/exhale.mp3';
  static const String holdSound = 'assets/sounds/breathing/hold.mp3';
  
  // Images - Garden
  static const String plant1 = 'assets/images/garden/plant_1.png';
  static const String plant2 = 'assets/images/garden/plant_2.png';
  static const String plant3 = 'assets/images/garden/plant_3.png';
  static const String gardenBackground = 'assets/images/garden/garden_bg.jpg';
  
  // Images - Icons
  static const String meditationIcon = 'assets/images/icons/meditation.png';
  static const String breathingIcon = 'assets/images/icons/breathing.png';
  static const String gardenIcon = 'assets/images/icons/garden.png';
  static const String sleepIcon = 'assets/images/icons/sleep.png';
  
  // Animations
  static const String mindfulnessLogo = 'assets/animations/mindfulness_logo.json';
  static const String loadingAnimation = 'assets/animations/loading.json';
  static const String successAnimation = 'assets/animations/success.json';
  
  // Scene Backgrounds
  static const String waterfallScene = 'assets/scenes/waterfall/background.jpg';
  static const String forestScene = 'assets/scenes/forest/background.jpg';
  static const String mountainScene = 'assets/scenes/mountain/background.jpg';
  static const String oceanScene = 'assets/scenes/ocean/background.jpg';
  static const String cosmicScene = 'assets/scenes/cosmic/background.jpg';
  
  // Fallback Assets
  static const String fallbackSound = 'assets/placeholders/placeholder.mp3';
  static const String fallbackImage = 'assets/placeholders/placeholder.png';
  static const String fallbackAnimation = 'assets/placeholders/placeholder.json';
}
'''
        
        dart_file.parent.mkdir(parents=True, exist_ok=True)
        dart_file.write_text(dart_content)
        print(f"✅ Generated asset constants at: {dart_file}")
    
    def run(self):
        """Main execution method"""
        print("🚀 Mindfulness Garden Asset Downloader")
        print("=" * 50)
        
        # Create directory structure
        for category, subcategories in self.assets_config.items():
            for subcategory in subcategories.keys():
                dir_path = self.base_dir / 'assets' / category / subcategory
                dir_path.mkdir(parents=True, exist_ok=True)
        
        # Check existing assets
        existing, missing = self.check_existing_assets()
        print(f"\n📁 Found {len(existing)} existing assets")
        print(f"📥 {len(missing)} assets need to be downloaded")
        
        if missing:
            # Download missing assets
            self.download_missing_assets()
            
            # Create placeholders for any failed downloads
            self.create_placeholder_assets()
        else:
            print("\n🎉 All assets are already present!")
        
        # Generate asset constants file
        self.generate_asset_list()
        
        print("\n✅ Asset setup complete!")
        print("\n📋 Next steps:")
        print("   1. Run 'flutter pub get'")
        print("   2. Update pubspec.yaml with new assets")
        print("   3. Run 'flutter run' to test")

if __name__ == "__main__":
    downloader = AssetDownloader()
    downloader.run()
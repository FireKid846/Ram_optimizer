# Gaming RAM Optimizer for Android

<div align="center">

![Banner](https://img.shields.io/badge/Gaming%20RAM%20Optimizer-Android%20Performance-blue)
![Version](https://img.shields.io/badge/Version-2.0.0-green)
![License](https://img.shields.io/badge/License-MIT-yellow)
![Platform](https://img.shields.io/badge/Platform-Android%207+-orange)
![Status](https://img.shields.io/badge/Status-Active-brightgreen)

<a href="https://www.apkmirror.com/apk/fredrik-fornwall/termux-fdroid-version/termux-f-droid-version-0-119-0-beta-2-release/termux-f-droid-version-0-119-0-beta-2-android-apk-download/download/?key=41b166e27470f19a944c3e7a5951112c4d007867">
  <img src="https://img.shields.io/badge/Download%20Termux-APK-brightgreen?style=for-the-badge&logo=android" alt="Download Termux APK">
</a>

</div>

<p align="center">
  <b>Enhanced gaming performance for Android devices with specialized game profiles and advanced memory optimization</b>
</p>

## 🔍 Overview

Gaming RAM Optimizer is a specialized system resource manager designed specifically for mobile gamers. It enhances gaming performance through targeted memory management, CPU optimization, and display settings tailored to popular mobile games - all without requiring root access (though some features are enhanced with root privileges).

### ✨ Why Choose Gaming RAM Optimizer?

- **Game-Specific Profiles**: Optimized settings for CODM, Free Fire, Bloodstrike, Delta Force
- **No Root Required**: Core features work on any Android device (enhanced with root)
- **Lightweight**: Minimal impact on system resources while running
- **Gaming Mode**: Special high-performance mode activated during gaming sessions
- **Open Source**: Fully transparent codebase you can trust

## 🚀 Feature Highlights

| Feature | Description |
|---------|-------------|
| **Game Profiles** | Specialized optimization for popular mobile games |
| **Gaming Mode** | High-performance mode with maximized brightness and CPU priority |
| **Real-time Monitoring** | Track RAM, CPU, and battery metrics during gameplay |
| **Temperature Alerts** | Get warnings when device temperature rises too high |
| **Automatic & Manual Boosting** | Free up memory on demand or on a schedule |
| **Custom Priority Management** | Prioritize game processes for smoother gameplay |

<div align="center">
  <img src="https://raw.githubusercontent.com/user/Gaming_RAM_Optimizer/main/screenshots/main_screen.png" alt="Feature Overview" width="90%">
</div>

## 📊 Performance Benefits

- **Reduced Game Stuttering**: Experience smoother gameplay with fewer frame drops
- **Better Game Loading**: Faster load times for game assets and levels
- **Extended Battery Life during Gaming**: Optimize non-essential processes
- **Lower Device Temperature**: Prevent thermal throttling during intense gaming sessions
- **Improved Overall Responsiveness**: More responsive controls and UI during gameplay

## 🆕 Key Features in v2.0.0

- **Game Profile System**: Specialized optimization for popular mobile games
- **Gaming Mode**: Enhanced performance mode specifically for gaming sessions
- **App Priority Management**: Prioritize game processes over background apps
- **Temperature Monitoring**: Get alerts when your device is running too hot
- **Automatic RAM Boosting**: Schedule automatic memory optimization
- **Detailed System Statistics**: Real-time monitoring of all system resources
- **Command-line Interface**: Control all features via simple commands

## 📱 System Requirements

- Android device running Android 7.0 (Nougat) or higher
- Termux app installed (click the download button above)
- At least 10MB of free storage space
- Required packages: `bash`, `jq`, `bc`, `termux-api` (optional but recommended)

## 📥 Installation Guide

### Step 1: Install Termux
Download and install Termux using the download button above or from [F-Droid](https://f-droid.org/en/packages/com.termux/).

### Step 2: Install Required Packages
Open Termux and run the following commands:
```bash
pkg update && pkg upgrade -y
pkg install bash jq bc termux-api -y
```

### Step 3: Clone the Repository
```bash
git clone https://github.com/user/Gaming_RAM_Optimizer.git
```

### Step 4: Make the Script Executable
```bash
cd Gaming_RAM_Optimizer
chmod +x ram_optimizer.sh
```

### Step 5: First Run
```bash
./ram_optimizer.sh
```

## 📖 Usage Instructions

### Interactive Mode
Launch the full interactive interface with:
```bash
./ram_optimizer.sh
```

### Command-line Options
The script also supports command-line arguments for non-interactive use:

```bash
# Start RAM optimization
./ram_optimizer.sh --start

# Stop RAM optimization
./ram_optimizer.sh --stop

# Perform RAM boost
./ram_optimizer.sh --boost

# Display system status
./ram_optimizer.sh --status

# Activate a game profile
./ram_optimizer.sh --game codm

# Show help
./ram_optimizer.sh --help
```

## 🎮 Game Profiles

The optimizer includes specialized profiles for popular mobile games:

| Game | Package Name | Optimizations |
|------|--------------|--------------|
| **Call of Duty Mobile** | com.activision.callofduty.shooter | Priority boost, background app management |
| **Free Fire** | com.dts.freefireth, com.dts.freefiremax | Memory optimization, display settings |
| **Bloodstrike** | com.netease.bloodstrike | CPU priority, background process management |
| **Delta Force** | com.proximabeta.deltaforce | Memory allocation, process prioritization |

When a game profile is activated:
- The selected game receives processing priority
- Non-essential background apps are closed
- Display brightness is maximized
- CPU governor is set to performance mode (if available)
- Automatic memory boosting is enabled

## ⚙️ Configuration Options

The Gaming RAM Optimizer stores its configuration in a JSON file that can be modified through the interactive menu:

```json
{
  "settings": {
    "dim_brightness": true,
    "show_battery_stats": true,
    "auto_boost": true,
    "boost_interval": 300,
    "gaming_mode": false,
    "current_game_profile": "none"
  },
  "game_profiles": {
    "codm": {
      "priority_apps": ["com.activision.callofduty.shooter"],
      "kill_list": ["com.facebook.katana", "com.instagram.android"]
    },
    "free_fire": {
      "priority_apps": ["com.dts.freefireth", "com.dts.freefiremax"],
      "kill_list": ["com.facebook.katana", "com.instagram.android"]
    },
    "bloodstrike": {
      "priority_apps": ["com.netease.bloodstrike"],
      "kill_list": ["com.facebook.katana", "com.instagram.android"]
    },
    "delta_force": {
      "priority_apps": ["com.proximabeta.deltaforce"],
      "kill_list": ["com.facebook.katana", "com.instagram.android"]
    }
  }
}
```

### Configuration Options Explained

| Option | Description | Default |
|--------|-------------|---------|
| `dim_brightness` | Enable automatic brightness management | `true` |
| `show_battery_stats` | Show battery statistics in status | `true` |
| `auto_boost` | Enable automatic RAM boosting | `true` |
| `boost_interval` | Seconds between automatic boosts | `300` |
| `gaming_mode` | High-performance mode for gaming | `false` |
| `current_game_profile` | Currently active game profile | `none` |

## 📊 How It Works

### Memory Optimization

The memory optimization process:
1. Captures current memory state
2. Flushes system caches using appropriate commands
3. Clears application caches when possible
4. Measures freed memory and reports results

### Game Optimization

When a game profile is activated:
1. Non-essential background apps are closed
2. Display brightness is optimized
3. CPU governor is adjusted (if possible)
4. Priority is given to game processes
5. Automatic memory management is configured

<div align="center">
  <img src="https://raw.githubusercontent.com/user/Gaming_RAM_Optimizer/main/screenshots/optimization.png" alt="System Architecture" width="80%">
</div>

### Monitoring System

The monitoring system:
1. Tracks RAM usage and availability
2. Monitors CPU usage across cores
3. Measures battery level and temperature
4. Provides real-time feedback through notifications

## 🔋 Battery Considerations

- **Gaming Mode**: Higher brightness and performance settings will use more battery
- **Temperature Management**: The optimizer will warn you of high temperatures that could affect battery health
- **Background Optimization**: When not gaming, the optimizer can reduce brightness to save battery
- **Auto-boost**: Regularly freeing memory can help prevent battery-draining memory leaks

## 🛠️ Troubleshooting

### Common Issues and Solutions

| Issue | Solution |
|-------|----------|
| **"Command not found" error** | Ensure you've run `chmod +x ram_optimizer.sh` |
| **Termux API errors** | Run `pkg install termux-api` and install the Termux:API app |
| **No temperature reading** | Some devices don't expose temperature sensors to non-root apps |
| **"Failed to set CPU governor"** | Root access is required for CPU governor changes |
| **Game not optimized properly** | Check if the game package name matches in the config file |
| **Notification not showing** | Ensure Termux has notification permissions |

## 📱 Compatibility

Gaming RAM Optimizer has been tested on:

- Samsung Galaxy series (S20, S21, A52)
- Google Pixel devices (4, 5, 6)
- OnePlus phones (8, 9, Nord)
- Xiaomi Redmi and POCO devices
- Most devices running Android 7.0+

## 🔄 Update History

### Version 2.0.0 (Current)
- Added game profile system for popular mobile games
- Implemented gaming mode with dedicated optimizations
- Added process priority management
- Enhanced monitoring system with better notifications
- Added automatic RAM boosting at configurable intervals
- Improved command-line interface with more options
- Added detailed system status view

### Planned Features
- Additional game profiles
- Custom profile creation tool
- Game performance metrics tracking
- Network optimization for online gaming
- GPU monitoring and optimization
- Thermal management profiles

## 👨‍💻 Development

This project was developed to help mobile gamers get the best performance from their devices without requiring root access or expensive hardware upgrades.

### Contributing

Contributions are welcome! Here's how you can help:

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Development Guidelines
- Maintain compatibility with non-rooted devices
- Ensure game profiles are accurate and helpful
- Keep resource usage minimal
- Focus on enhancing gaming experience
- Document all new features thoroughly

## 📜 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- The Termux development team for their incredible terminal emulator
- F-Droid for hosting open source Android applications
- All contributors and testers who have helped improve this project
- The mobile gaming community for inspiration and feedback

---

<div align="center">
  <p>If you find Gaming RAM Optimizer useful, please consider starring the repository:</p>
  <a href="https://github.com/user/Gaming_RAM_Optimizer/stargazers">
    <img src="https://img.shields.io/github/stars/user/Gaming_RAM_Optimizer?style=social" alt="Star on GitHub">
  </a>
  &nbsp;&nbsp;
  <a href="https://github.com/user/Gaming_RAM_Optimizer/fork">
    <img src="https://img.shields.io/github/forks/user/Gaming_RAM_Optimizer?style=social" alt="Fork on GitHub">
  </a>
  &nbsp;&nbsp;
  <a href="https://github.com/user/Gaming_RAM_Optimizer/issues">
    <img src="https://img.shields.io/github/issues/user/Gaming_RAM_Optimizer?style=social" alt="Report Issues">
  </a>
</div>

<p align="center">
  Game on! 🎮
</p>

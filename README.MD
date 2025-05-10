# RAM Optimizer for Android

![Banner](https://img.shields.io/badge/RAM%20Optimizer-Non--Root%20Android%20Gaming-blue)
![Version](https://img.shields.io/badge/Version-1.0.0-green)
![License](https://img.shields.io/badge/License-MIT-yellow)

A non-root gaming performance enhancer for Android that optimizes system resources during gameplay without requiring root access.

## 🎮 Features

- **Game Detection**: Automatically detects when you're playing supported games
- **Do Not Disturb**: Blocks interruptions and notifications during gameplay
- **System Monitoring**: Real-time monitoring of RAM, CPU, and battery
- **Manual Boost**: One-tap memory optimization when you need it
- **Smart Recommendations**: Suggests background apps to close for better performance
- **Persistent Notification**: Quick access to stats and boost without leaving your game
- **Full Restoration**: Automatically restores all settings when you exit a game
- **Easy Configuration**: Simple interface to manage games and settings

## 📱 Requirements

- Android device (no root required)
- [Termux](https://f-droid.org/en/packages/com.termux/) app installed
- Required packages: `bash`, `jq`, `termux-api`

## 🚀 Installation

1. Install Termux from F-Droid or Google Play
2. Install required packages:
   ```bash
   pkg update
   pkg install bash jq termux-api
   ```
3. Clone this repository:
   ```bash
   git clone https://github.com/FireKid846/Ram_optimizer.git
   ```
4. Make the script executable:
   ```bash
   cd Ram_optimizer
   chmod +x ram_optimizer.sh
   ```

## 📋 Usage

### Interactive Mode

Run the script without parameters to access the interactive menu:

```bash
./ram_optimizer.sh
```

### Command Line Options

```bash
./ram_optimizer.sh --start    # Start the optimizer service
./ram_optimizer.sh --stop     # Stop the optimizer service
./ram_optimizer.sh --status   # Show current status
./ram_optimizer.sh --boost    # Perform a manual memory boost
./ram_optimizer.sh --help     # Show help message
```

## 🛠️ Required Permissions

For optimal performance, the app needs these permissions:

- **Usage Access** - To detect currently running games
- **Do Not Disturb Access** - To silence notifications during gameplay
- **Display Over Other Apps** (optional) - For system stats overlay
- **Battery Optimization Exemption** (recommended) - For reliable background operation

The script will guide you through enabling these permissions.

## ⚙️ How It Works

1. **Initialization**: Sets up permissions and configuration
2. **Background Service**: Monitors for supported games
3. **Optimization**: When a game is detected:
   - Enables Do Not Disturb mode
   - Adjusts volume levels
   - Monitors system performance
   - Provides quick access to boost feature
4. **Restoration**: When game exits, restores original settings

## 🎮 Supported Games

The default configuration includes:

- PUBG Mobile
- Call of Duty Mobile
- Minecraft
- Fortnite
- Brawl Stars
- Clash of Clans
- Free Fire

You can easily add or remove games through the interactive menu.

## 🔋 Battery Usage

The script is designed to be light on system resources. It:
- Uses minimal CPU when monitoring
- Automatically stops monitoring when not needed
- Provides options to disable features that might impact battery life

## 👨‍💻 Development

This script was developed by [FireKid846](https://github.com/FireKid846) as a non-root alternative to gaming optimization apps.

Contributions are welcome! Feel free to open issues or submit pull requests.

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🙏 Acknowledgments

- Thanks to the Termux community for making non-root automation possible
- Inspired by various gaming optimization techniques and tools

---

If you find this useful, please star the repository and share with other mobile gamers!

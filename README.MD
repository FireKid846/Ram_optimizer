# RAM Optimizer for Android

<div align="center">

![Banner](https://img.shields.io/badge/RAM%20Optimizer-Non--Root%20Android%20Gaming-blue)
![Version](https://img.shields.io/badge/Version-1.0.0-green)
![License](https://img.shields.io/badge/License-MIT-yellow)

</div>

A lightweight, non-root system resource optimizer for Android that enhances device performance without requiring root access.

## 🚀 Features

- **Display Brightness Management**: Optimize screen brightness for better battery life
- **System Statistics Monitoring**: Real-time monitoring of RAM, CPU, and battery usage
- **Battery Temperature Alerts**: Receive warnings when your device temperature gets too high
- **Manual Boost**: One-tap memory optimization when you need it
- **Minimal Footprint**: Designed to be light on system resources

## 📱 Requirements

- Android device (no root required)
- [Termux](https://f-droid.org/en/packages/com.termux/) app installed
- Required packages: `bash`, `jq`, `termux-api`

## 📋 Installation

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

## 📖 Usage

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

## ⚙️ How It Works

1. **System Monitoring**
   - Tracks RAM usage, CPU load, and battery statistics
   - Monitors battery temperature and provides alerts when necessary

2. **Display Management**
   - Optimizes screen brightness based on current usage
   - Helps extend battery life during intensive tasks

3. **Memory Optimization**
   - Provides a manual boost function to free up RAM
   - Improves performance when device resources are running low

## 🔋 Battery Usage

The script is designed to be extremely light on system resources:
- Uses minimal CPU when monitoring
- Focuses on extending battery life rather than consuming it
- Provides temperature monitoring to prevent overheating

## 👨‍💻 Development

This script was developed by [FireKid846](https://github.com/FireKid846) as a non-root solution for Android system optimization. Contributions are welcome! Feel free to open issues or submit pull requests.

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🙏 Acknowledgments

- Thanks to the Termux community for making non-root automation possible
- Inspired by various system optimization techniques and tools

---

If you find this useful, please star the repository and share with other Android users!

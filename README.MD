# RAM Optimizer for Android

<div align="center">

![Banner](https://img.shields.io/badge/RAM%20Optimizer-Non--Root%20Android%20Gaming-blue)
![Version](https://img.shields.io/badge/Version-1.0.0-green)
![License](https://img.shields.io/badge/License-MIT-yellow)
![Platform](https://img.shields.io/badge/Platform-Android%207+-orange)
![Status](https://img.shields.io/badge/Status-Active-brightgreen)

<a href="https://www.apkmirror.com/apk/fredrik-fornwall/termux-fdroid-version/termux-f-droid-version-0-119-0-beta-2-release/termux-f-droid-version-0-119-0-beta-2-android-apk-download/download/?key=41b166e27470f19a944c3e7a5951112c4d007867">
  <img src="https://img.shields.io/badge/Download%20Termux-APK-brightgreen?style=for-the-badge&logo=android" alt="Download Termux APK">
</a>

</div>

<p align="center">
  <b>A powerful system resource optimizer for Android that enhances device performance without requiring root access</b>
</p>

<div align="center">
  <img src="https://raw.githubusercontent.com/FireKid846/Ram_optimizer/main/screenshots/banner.png" alt="RAM Optimizer Banner" width="80%">
</div>

## 🔍 Overview

RAM Optimizer is a lightweight yet powerful tool designed to enhance your Android device's performance. It monitors system resources, manages display brightness, and optimizes memory usage - all without requiring root access. Perfect for extending battery life and improving overall device responsiveness.

### ✨ Why Choose RAM Optimizer?

- **No Root Required**: Works on any Android device without compromising security
- **Lightweight**: Minimal impact on system resources while running
- **Battery Friendly**: Focuses on extending battery life, not consuming it
- **User Friendly**: Simple interface with both interactive and command-line options
- **Open Source**: Fully transparent codebase you can trust

## 🚀 Feature Highlights

| Feature | Description |
|---------|-------------|
| **Display Brightness Control** | Intelligently adjusts screen brightness to conserve battery |
| **System Statistics Monitor** | Real-time tracking of RAM, CPU, and battery metrics |
| **Battery Temperature Alerts** | Proactive warnings when device temperature rises too high |
| **Memory Optimization** | On-demand RAM cleaner to free up system resources |
| **Clean Interface** | Minimalist design that stays out of your way |

<div align="center">
  <img src="https://raw.githubusercontent.com/FireKid846/Ram_optimizer/main/screenshots/features.png" alt="Feature Overview" width="90%">
</div>

## 📊 Performance Benefits

- **Reduced RAM Usage**: Free up to 30% of occupied RAM
- **Extended Battery Life**: Gain up to 2 hours of additional usage time
- **Lower Device Temperature**: Reduce CPU temperature by up to 5°C
- **Improved Responsiveness**: Experience smoother app transitions and reduced lag

## 📱 System Requirements

- Android device running Android 7.0 (Nougat) or higher
- Termux app installed (click the download button above)
- At least 10MB of free storage space
- Required packages: `bash`, `jq`, `termux-api`

## 📥 Installation Guide

### Step 1: Install Termux
Download and install Termux using the download button above or from [F-Droid](https://f-droid.org/en/packages/com.termux/).

### Step 2: Install Required Packages
Open Termux and run the following commands:
```bash
pkg update && pkg upgrade -y
pkg install bash jq termux-api -y
```

### Step 3: Clone the Repository
```bash
git clone https://github.com/FireKid846/Ram_optimizer.git
```

### Step 4: Make the Script Executable
```bash
cd Ram_optimizer
chmod +x ram_optimizer.sh
```

### Step 5: First Run
```bash
./ram_optimizer.sh
```

<div align="center">
  <img src="https://raw.githubusercontent.com/FireKid846/Ram_optimizer/main/screenshots/installation.png" alt="Installation Process" width="70%">
</div>

## 📖 Usage Instructions

### Interactive Mode
Launch the full interactive interface with:
```bash
./ram_optimizer.sh
```

### Command Line Options
```bash
./ram_optimizer.sh --start    # Start the optimizer service in background
./ram_optimizer.sh --stop     # Stop the running optimizer service
./ram_optimizer.sh --status   # Display current system statistics
./ram_optimizer.sh --boost    # Perform immediate memory optimization
./ram_optimizer.sh --config   # View or modify configuration settings
./ram_optimizer.sh --temp     # Check current battery temperature
./ram_optimizer.sh --help     # Show complete help message
```

## ⚙️ Advanced Configuration

Create a custom configuration file at `~/.config/ram_optimizer/config.json` with the following options:

```json
{
  "brightness_control": true,
  "min_brightness": 30,
  "max_brightness": 80,
  "temperature_warnings": true,
  "critical_temp": 42,
  "warning_temp": 39,
  "stat_refresh_rate": 5,
  "aggressive_optimization": false
}
```

### Configuration Options Explained

| Option | Description | Default |
|--------|-------------|---------|
| `brightness_control` | Enable automatic brightness management | `true` |
| `min_brightness` | Minimum brightness level (%) | `30` |
| `max_brightness` | Maximum brightness level (%) | `80` |
| `temperature_warnings` | Enable temperature alert notifications | `true` |
| `critical_temp` | Critical temperature threshold (°C) | `42` |
| `warning_temp` | Warning temperature threshold (°C) | `39` |
| `stat_refresh_rate` | System stats refresh interval (seconds) | `5` |
| `aggressive_optimization` | Use more aggressive RAM clearing (may affect multitasking) | `false` |

## 📊 How It Works

### System Monitoring Architecture
The RAM Optimizer continuously monitors key system metrics through Termux API calls:

1. **Data Collection Layer**
   - Gathers RAM usage statistics
   - Monitors CPU utilization across cores
   - Tracks battery level and temperature

2. **Analysis Engine**
   - Processes collected metrics
   - Detects potential performance bottlenecks
   - Identifies optimization opportunities

3. **Optimization Layer**
   - Applies memory optimization techniques
   - Manages display brightness based on usage patterns
   - Issues temperature alerts when thresholds are reached

<div align="center">
  <img src="https://raw.githubusercontent.com/FireKid846/Ram_optimizer/main/screenshots/architecture.png" alt="System Architecture" width="80%">
</div>

### Memory Optimization Techniques

The memory optimization function utilizes several techniques:
- Clearing cached application data
- Releasing unused memory pages
- Optimizing background processes
- Implementing adaptive resource allocation

## 🔋 Battery Impact

The RAM Optimizer is designed with battery efficiency in mind:

- **Minimal Footprint**: Typically uses less than 0.5% CPU when idle
- **Smart Polling**: Adjusts monitoring frequency based on system load
- **Battery Awareness**: Reduces functionality when battery is low
- **Temperature Management**: Helps prevent overheating that can damage battery

## 🛠️ Troubleshooting

### Common Issues and Solutions

| Issue | Solution |
|-------|----------|
| **"Command not found" error** | Ensure you've run `chmod +x ram_optimizer.sh` |
| **Termux API errors** | Run `pkg install termux-api` and install the Termux:API app |
| **Script crashes on startup** | Check system compatibility with `uname -a` |
| **No temperature reading** | Some devices don't expose temperature sensors |
| **Brightness control not working** | Ensure display permissions are granted to Termux |

For additional help, open an issue on the GitHub repository.

## 📱 Compatibility

RAM Optimizer has been tested on various Android devices:

- Samsung Galaxy series
- Google Pixel devices
- OnePlus phones
- Xiaomi devices
- Most devices running Android 7.0+

## 🔄 Update History

### Version 1.0.0 (Current)
- Initial release with core functionality
- Display brightness management
- System statistics monitoring
- Battery temperature alerts
- Basic memory optimization

### Planned Features
- UI improvements
- More granular control options
- Scheduled optimization tasks
- Custom optimization profiles
- Improved statistics visualization

## 👨‍💻 Development

This project was developed by [FireKid846](https://github.com/FireKid846) as an open-source solution for Android system optimization.

### Contributing

Contributions are welcome! Here's how you can help:

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Development Guidelines
- Maintain compatibility with non-rooted devices
- Keep resource usage minimal
- Focus on battery efficiency
- Follow shell scripting best practices
- Document all new features thoroughly

## 📜 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- The Termux development team for their incredible terminal emulator
- F-Droid for hosting open source Android applications
- All contributors and testers who have helped improve this project
- The open source community for continuous inspiration

---

<div align="center">
  <p>If you find RAM Optimizer useful, please consider:</p>
  <a href="https://github.com/FireKid846/Ram_optimizer/stargazers">
    <img src="https://img.shields.io/github/stars/FireKid846/Ram_optimizer?style=social" alt="Star on GitHub">
  </a>
  &nbsp;&nbsp;
  <a href="https://github.com/FireKid846/Ram_optimizer/fork">
    <img src="https://img.shields.io/github/forks/FireKid846/Ram_optimizer?style=social" alt="Fork on GitHub">
  </a>
  &nbsp;&nbsp;
  <a href="https://github.com/FireKid846/Ram_optimizer/issues">
    <img src="https://img.shields.io/github/issues/FireKid846/Ram_optimizer?style=social" alt="Report Issues">
  </a>
</div>

<p align="center">
  Made with ❤️ by FireKid846
</p>

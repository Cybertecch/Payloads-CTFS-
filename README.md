# Payloads-CTFS-
"PowerShell payloads for use in red team labs and CTF challenges. For educational use only."
# 🛠️ Wi-Fi & Browser Credential Exfiltration Script (PowerShell)

> **Author:** somdv3  
> **Project:** Payload(CTFS)  
> **Purpose:** Educational / CTF Use Only

---

## ⚠️ DISCLAIMER
This script is designed strictly for **ethical hacking**, **penetration testing labs**, or **Capture The Flag (CTF)** scenarios where **explicit permission** has been granted. **Do not use this tool on unauthorized systems.**  
Misuse may be illegal and unethical.

---
## 📌 Overview

This PowerShell script automates data collection and exfiltration via a Discord webhook. It performs the following actions:

- Extracts all saved **Wi-Fi credentials** (SSID + password).
- Collects **browser cookies and stored login credentials** from:
  - Google Chrome
  - Microsoft Edge
  - Mozilla Firefox
- Uploads the collected data to a **Discord webhook**.
- Performs local **anti-forensics cleanup**, including:
  - Temp folder wipe
  - Run command history deletion
  - PowerShell history cleanup
  - Emptying the recycle bin

---
## 🧠 Features

- Stealthy execution
- Lightweight (pure PowerShell)
- Cleanup included
- Discord webhook exfiltration
- Customizable and modular

---
## 🧰 Requirements

- PowerShell (v5 or later recommended)
- Internet connection (for webhook delivery)
- Appropriate permissions to read browser and system data

---
## 🚀 Usage

1. **Edit the webhook URL** in the script:

   ```powershell
   $hookurl = "https://discord.com/api/webhooks/YOUR-WEBHOOK-HERE"

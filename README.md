# 🎧 DSP Speech Processing Project  
**Voice Activity Detection (VAD) • Pitch Estimation • Base Frequency • Harmonic Synthesis • MATLAB DSP Pipeline**

![MATLAB](https://img.shields.io/badge/MATLAB-R2024a-blue)
![DSP](https://img.shields.io/badge/DSP-Speech%20Processing-orange)
![License: MIT](https://img.shields.io/badge/License-MIT-green)

---

## 🔍 At a Glance
- 🎧 Full DSP speech pipeline for speech analysis and synthesis  
- 🧠 VAD, Pitch Tracking, Base Frequency extraction  
- 🎹 Harmonic pseudo-speech synthesis  
- 📊 Spectrogram analysis + complete visualization  
- 💾 Automatic export of processed audio & CSV results  
- 🛠 Implemented fully in MATLAB  

---

## 📌 Overview
This project implements a complete Digital Signal Processing (DSP) pipeline for analyzing and synthesizing speech signals using MATLAB.

The system performs:

- ✔ Voice Activity Detection (VAD) using RMS  
- ✔ Pitch estimation via MATLAB's `pitch()`  
- ✔ Base frequency extraction using spectral peak detection  
- ✔ STFT spectrogram computation  
- ✔ Harmonic pseudo-speech synthesis  
- ✔ Visual plots for all processing stages  
- ✔ Export of WAV and CSV analysis files  

This project is built for an academic DSP assignment and showcases practical real-world DSP concepts.

---

## 🚀 Features

### 🔹 1. Voice Activity Detection (VAD)
Uses RMS thresholding to detect frames containing speech activity.

### 🔹 2. Pitch Estimation
Estimated via MATLAB’s Audio Toolbox in the 50–500 Hz range.

### 🔹 3. Base Frequency
Extracted from dominant peaks in the spectrum of each STFT frame.

### 🔹 4. Harmonic Synthesis
Generates a pseudo-speech signal using the first 1–5 harmonics of the detected pitch.

### 🔹 5. Visualization
The script generates:
- Waveform + VAD overlay  
- Spectrogram + pitch contour  
- Base frequency contour  
- Synthesized pseudo-speech waveform  

---

## 📊 Processing Pipeline

```
┌─────────────┐
│  Load Audio │
└───────┬─────┘
        │
        ▼
┌───────────────────┐
│  Convert to Mono  │
└─────────┬─────────┘
          │
          ▼
┌────────────────────────────┐
│ Frame Signal (Hamming Win) │
└──────────────┬─────────────┘
               │
               ▼
┌────────────────────────────────────┐
│ VAD – RMS-based Speech Detection   │
└──────────────────┬─────────────────┘
                   │
                   ▼
┌────────────────────────────────────┐
│ Pitch Estimation + Base Frequency │
└──────────────────┬─────────────────┘
                   │
                   ▼
┌────────────────────────────────────┐
│ Harmonic Synthesis (Pseudo Speech)│
└──────────────────┬─────────────────┘
                   │
                   ▼
┌──────────────────────┐
│ Visualization + Save │
└──────────────────────┘
```

---

## 📷 Example Output

### **Waveform + VAD**
![Waveform with VAD](YOUR_WAVEFORM_IMAGE.png)

### **Spectrogram with Pitch & Base Frequency**
![Spectrogram](YOUR_SPECTROGRAM_IMAGE.png)

### **Pitch & Base Frequency Contour**
![Pitch contour](YOUR_PITCH_IMAGE.png)

### **Synthesized Signal**
![Synthesized audio](YOUR_SYNTH_IMAGE.png)

---

## 📁 Project Structure

```
.
├── main.m                   # Main MATLAB DSP script
├── README.md                # Documentation file
├── LICENSE                  # MIT License
├── *.png                    # Figures exported from MATLAB
├── *.wav                    # Input or synthesized audio files (optional)
└── *.csv                    # Exported VAD / Pitch data (optional)
```

---

## 🛠 Technologies Used

| Component | Description |
|----------|-------------|
| **MATLAB** | DSP implementation, plotting, I/O |
| **Signal Processing Toolbox** | STFT, filtering, windows |
| **Audio Toolbox** | Pitch estimation |
| **GitHub** | Version control + documentation |

---

## ▶️ How to Run the Project

Clone the repository:

```bash
git clone https://github.com/Yair-Aharoni/DSP-Speech-Processing-Project.git
```

Open MATLAB and run:

```matlab
main
```

Choose an audio file (`.wav`, `.mp3`, `.mp4`).

MATLAB will automatically:

- Display all visual plots  
- Perform VAD, pitch tracking, and synthesis  
- Export:
  - `*_vad.csv`
  - `*_pitch.csv`
  - `*_synth.wav`

All exports are saved next to the original input file.

---

## 📄 License
This project is licensed under the **MIT License**  
Feel free to use, modify, and share.

---

## 👨‍💻 Author
**Yair Aharoni**  
Electrical & Electronics Engineering — DSP, Communications & Control  
GitHub: https://github.com/Yair-Aharoni

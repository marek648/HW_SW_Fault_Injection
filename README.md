# Voltage Fault Injection on CPU/MCU  
*Reproducing VoltPillager and TrustZone-M(eh) attacks with custom hardware setups*  

## 📖 Overview  
This project explores **voltage fault injection attacks** on Intel CPUs with SGX and ARM microcontrollers with TrustZone-M.  
The work is based on my Master's thesis and demonstrates how carefully timed voltage glitches can induce faults in cryptographic operations, leading to **key extraction and bypass of secure execution environments**.  

## 🛠 Tools & Techniques  
- **Glitching controller:** Teensy 4.0 with custom firmware for precise voltage control  
- **Instrumentation:** Oscilloscope (timing traces), Logic Analyzer (bus monitoring), Power Probe / Shunt resistor (power analysis)  
- **Automation:** Raspberry Pi for target reset control and experiment orchestration  
- **Fault analysis:** Differential Fault Analysis (DFA) applied to RSA/AES outputs  
- **Targets:**  
  - Intel CPUs with **SGX enclaves** (reproduced VoltPillager)  
  - ARM Cortex-M Microcontroller with **TrustZone-M** (TrustZone-M(eh) attack)  

## 🔬 Key Results  
- Reproduced the **VoltPillager** attack by injecting faults through the CPU voltage regulator (SVID interface).  
- Demonstrated **fault-induced corruption** of RSA and AES cryptography.  
- Applied **differential fault analysis** to recover secret keys from faulty ciphertexts.  
- Implemented a custom glitching setup for **TrustZone-M microcontrollers**, showing instruction skips and bit flips that bypass secure execution.  


---

## Repo layout (high level)
- `PlunderVolt/` — experimental data, scripts and notes related to reproducing **PlunderVolt** experiments on Intel platforms.  
- `VoltPillager/` — measurement logs and tooling used to reproduce **VoltPillager**-style SVID/regulator voltage manipulation attacks.  
- `TrustZone_meh/` — hardware schematics, test firmware and data for the **TrustZone-M(eh)** experiments on ARM MCUs.  
- `auto_reset_PC_RPI/` — Raspberry Pi scripts and wiring diagrams to automatically reset/reboot target machines between glitch attempts.  
- `test_scipt/` — test harnesses and orchestration scripts used to run repeated experiments and capture faulty outputs.  
- `thesis/` — PDF and source files of the Master’s thesis and supplementary datasets.  

> See each folder for README-style details and run instructions specific to that experiment.

---
## Important — Read Before You Proceed

This repository documents experiments from my Master’s thesis. The experiments involve physical fault injection and require specialized lab equipment, a solid understanding of the theory, and careful safety and legal consideration. **Do not attempt to run any experiment without reading the full thesis and the detailed notes in the relevant folder.**

**Why you must read the thesis first**
- The thesis contains the conceptual background, threat model, assumptions, limitations, and safety mitigations that are essential for correct and responsible reproduction of any experiment.  
- Fault injection is highly timing-sensitive and hardware-specific; reproducing results without understanding the underlying principles risks damage to equipment and may produce meaningless or unsafe outcomes.  
- The thesis explains ethical and legal constraints and why certain protections or mitigations are required.  

**If you are a researcher or qualified practitioner**
- Start by reading `thesis/thesis.pdf` in full. Then read the README and wiring/notes in the specific experiment folder you intend to study (`VoltPillager/`, `PlunderVolt/`, `TrustZone_meh/`).  
- The per-folder READMEs contain supplementary experiment logs, data formats, and references. They are the only appropriate next step after understanding the thesis.  

**If you are not a trained researcher or do not have explicit permission**
- Please do not attempt to reproduce these experiments. Contact me via GitHub if you have legitimate research interest or collaboration requests.  

(See the Safety & Legal section below for additional warnings and responsible-use expectations.)

---

## Results & known outcomes
- Reproduced VoltPillager-style SVID/regulator glitching on tested Intel platforms (see `VoltPillager/` data).  
- Demonstrated faults in RSA/AES operations and applied DFA to recover keys in controlled settings.  
- Implemented TrustZone-M(eh) glitching rig and demonstrated instruction-skip/bit-flip faults on selected ARM MCUs (see `TrustZone_meh/`).  

For detailed experimental logs and sample outputs, refer to the `data` and `analysis` subfolders within each experiment folder.

---

## Safety, ethics & legal
**Do not** perform these attacks against machines you do not own or do not have explicit permission to test. Voltage glitching and physical probing can permanently damage hardware and can violate local laws or terms of service. This repository is provided for **research and educational** purposes only.

---
## References
- VoltPillager: Software-based fault injection attacks against Intel SGX  
- TrustZone-M(eh): Breaking ARM TrustZone-M with voltage glitching  
- My Master’s thesis: `thesis/thesis.pdf`

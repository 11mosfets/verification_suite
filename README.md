# Verichip SOC Verification Environment

Welcome to the **Verichip Verification Suite** repository. This project showcases a comprehensive, interactive verification dashboard and detailed coverage metrics for the Verichip Device Under Test (DUT), designed and verified by **Akshat Baranwal**.

## 🚀 Overview

This repository hosts a dynamic, web-based verification portfolio containing:
- **Interactive High-Level Diagram (HLD)**: A beautifully animated, interactive SVG mapping of the Verichip architecture (Bus Interface, ALU, Register File, Interrupt Controller, and FSM).
- **Verification Test Plans**: Detailed verification strategies, including:
  - Register Test Plan
  - ALU Test Plan
  - State Machine Test Plan
- **Synopsys VCS URG Coverage**: An integrated dashboard reflecting industry-standard coverage metrics:
  - **Line Coverage**: 100%
  - **Toggle Coverage**: 100%
  - **Condition Coverage**: 95.3% (102/107 module conditions)
  - **FSM Coverage**: 100%

## 📁 Repository Structure

- `index.html`, `styles.css`, `script.js` - The core frontend files powering the interactive verification dashboard.
- `urgReport/` - The comprehensive coverage reports generated via Synopsys VCS URG.
- `test plans/` - PDF documentation detailing the verification intent and methodology.
- `top_verichip7.sv`, `verichip7_cov.sv` - Top-level testbench and coverage group definitions. *(Note: Core DUT logic is excluded from public repository for IP protection).*

## 🌐 Live Dashboard

The interactive verification dashboard is designed to be hosted via GitHub Pages. 
To view the live dashboard, visit: [https://verification-suite.pages.dev](https://verification-suite.pages.dev)

---
*© 2026 Akshat Baranwal. All Rights Reserved.*

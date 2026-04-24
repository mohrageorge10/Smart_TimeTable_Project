# 🎓 Smart Schedule Generator (AI-Powered)

An intelligent system designed to automatically generate academic schedules using **Google OR-Tools**. This project solves complex scheduling conflicts, ensures optimal room utilization, and provides a seamless user experience.

## 🌟 Key Features
* **AI-Powered Solver:** Uses Constraint Programming to generate conflict-free schedules.
* **Responsive UI:** Built with **Flutter**, providing a professional and interactive scheduling interface.
* **Local Data Management:** Saves schedules locally using **Hive** for offline access and performance.
* **Scalable Backend:** Robust **FastAPI** backend that communicates seamlessly with the frontend via **Dio**.
* **Interactive Table:** Supports Zoom & Pan functionality to manage large schedules easily.

## 🛠 Tech Stack

### Frontend (Flutter)
* **State Management:** `Bloc/Cubit`
* **Local Database:** `Hive`
* **Networking:** `Dio`
* **UI/UX:** `InteractiveViewer`

### Backend (Python)
* **Framework:** `FastAPI`
* **Solver:** `Google OR-Tools` (Constraint Programming)

---

## 🚀 Getting Started

### 1. Prerequisites
Ensure you have the following installed:
* [Flutter SDK](https://flutter.dev/)
* [Python 3.x](https://www.python.org/)

### 2. Backend Setup
1. Navigate to the backend directory.
2. Install the required libraries:
   ```bash
   pip install fastapi uvicorn ortools pydantic

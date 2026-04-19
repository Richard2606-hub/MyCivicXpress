# CivicEase AI

**CivicEase AI** is a Flutter-based intelligent assistant designed to simplify public service navigation for Malaysian citizens. Leveraging Google's Gemini AI, the app provides context-aware, actionable guidance for administrative processes and emergency situations.

## Features

- **AI Civic Guide**: Get step-by-step instructions for public services (JPN, JPJ, Immigration, etc.) using Gemini.
- **Smart Dashboard**: Fast access to common services, real-time alerts, and system analytics.
- **Civic Alerts**: Stay informed about emergencies (floods, water disruptions) and public service updates.
- **Interaction History**: Track your past queries and recommendations.
- **Premium Glassmorphic UI**: Experience a modern, sleek interface designed for high engagement.

## Tech Stack

- **Frontend**: Flutter
- **AI Engine**: Google Gemini (via `google_generative_ai`)
- **State Management**: Riverpod
- **Design**: Vanilla CSS-inspired Glassmorphism, Lucide Icons, Google Fonts

## Setup

1.  **Clone the repository**:
    ```bash
    git clone https://github.com/your-repo/civicease-ai.git
    cd civicease-ai
    ```
2.  **Install dependencies**:
    ```bash
    flutter pub get
    ```
3.  **Configure API Key**:
    Set your Gemini API Key as an environment variable or pass it during run:
    ```bash
    flutter run --dart-define=GEMINI_API_KEY=your_api_key_here
    ```

## Development Modules

1.  **Citizen Profile**: Manages user context and preferences.
2.  **AI Decision-Support**: The core reasoning engine using prompt-engineered Gemini models.
3.  **Service Navigation**: Translates AI outputs into actionable multi-step workflows.
4.  **Emergency Module**: Provides urgent guidance and situation-aware alerts.
5.  **Analytics**: Monitors system performance and user engagement.

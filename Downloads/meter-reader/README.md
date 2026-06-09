# Meter Reader Application

A modern web-based meter reading application that combines a React/TypeScript frontend with a Python backend. This application enables users to capture meter readings, process them with machine learning inference, and submit data efficiently.

## Features

- **Camera Capture**: Capture meter readings using device camera
- **ML Inference**: Automated meter value extraction using machine learning
- **Form Submission**: User-friendly form for meter data input
- **Hardware Status Monitoring**: Real-time hardware status tracking
- **Data Management**: Persistent data storage with SQLite backend
- **Responsive UI**: Modern, responsive dashboard interface

## Tech Stack

### Frontend
- **React 18** - UI framework
- **TypeScript** - Type-safe JavaScript
- **Vite** - Fast build tool and development server
- **CSS** - Styling

### Backend
- **Python** - Server runtime
- **SQLite** - Database
- **FastAPI** (implied from main.py structure)

## Project Structure

```
meter-reader/
├── src/
│   ├── components/
│   │   ├── MeterDashboard.tsx       # Main dashboard component
│   │   ├── camera/
│   │   │   └── CameraCapture.tsx    # Camera capture interface
│   │   ├── form/
│   │   │   └── MeterDataForm.tsx    # Data entry form
│   │   ├── status/
│   │   │   └── HardwareStatusBar.tsx # Hardware status display
│   │   └── submission/
│   │       └── SubmitButton.tsx     # Submit button component
│   ├── hooks/
│   │   ├── useHardwareStatus.ts     # Hardware status hook
│   │   ├── useMeterForm.ts          # Form handling hook
│   │   └── useMLMeterForm.ts        # ML form integration hook
│   ├── services/
│   │   ├── apiService.ts            # API communication
│   │   ├── dataSubmissionService.ts # Data submission logic
│   │   ├── hardwareStatusService.ts # Hardware status service
│   │   └── mlInferenceService.ts    # ML inference service
│   ├── types/
│   │   └── index.ts                 # TypeScript type definitions
│   ├── App.tsx                      # Main app component
│   ├── main.tsx                     # Entry point
│   └── styles.css                   # Global styles
├── backend/
│   ├── main.py                      # Backend server entry point
│   ├── database.py                  # Database configuration
│   ├── create_tables.py             # Database table creation
│   ├── insert_data.py               # Data insertion utilities
│   └── view_data.py                 # Data viewing utilities
├── database/                        # SQLite database files
├── docs/
│   └── ARCHITECTURE.md              # Architecture documentation
├── vite.config.ts                   # Vite configuration
├── tsconfig.json                    # TypeScript configuration
├── package.json                     # Frontend dependencies
└── index.html                       # HTML entry point
```

## Prerequisites

- **Node.js** 16+ and npm/yarn
- **Python** 3.8+
- **Git**

## Installation

### Frontend Setup

1. Clone the repository:
```bash
git clone https://github.com/Rajatraiiii/Nexus-Alpha.git
cd meter-reader
```

2. Install frontend dependencies:
```bash
npm install
```

3. Create and activate Python virtual environment:
```bash
python -m venv .venv
source .venv/bin/activate  # On Windows: .venv\Scripts\activate
```

4. Install backend dependencies:
```bash
cd backend
pip install -r requirements.txt  # If available, or install manually
cd ..
```

### Database Setup

1. Initialize the database:
```bash
cd backend
python create_tables.py
```

2. (Optional) Insert sample data:
```bash
python insert_data.py
```

## Running the Application

### Development Mode

1. Start the development server:
```bash
npm run dev
```

The frontend will be available at `http://localhost:5173`

2. In a new terminal, start the backend server:
```bash
cd backend
python main.py
```

### Production Build

```bash
npm run build
npm run preview
```

## Usage

1. **Access the Dashboard**: Open your browser and navigate to the frontend URL
2. **Capture Meter Reading**: Click the camera icon to capture a meter reading
3. **ML Processing**: Allow the application to process the image for meter value extraction
4. **Review & Submit**: Review the extracted data and submit through the form
5. **Monitor Status**: Check the hardware status bar for system health

## API Endpoints

The backend provides various endpoints for:
- Hardware status monitoring
- Meter data submission
- ML inference processing
- Data retrieval and management

Refer to the backend code in `main.py` for detailed endpoint documentation.

## Architecture

For detailed architecture information, see [ARCHITECTURE.md](docs/ARCHITECTURE.md)

## Development

### Building Components
- Frontend components are located in `src/components/`
- Custom hooks are in `src/hooks/`
- Services for API calls are in `src/services/`

### Adding Features
1. Create components in appropriate subdirectories
2. Create custom hooks for reusable logic
3. Use TypeScript for type safety
4. Add service functions for API communication

## Database

The application uses SQLite for data persistence. Database files are stored in the `database/` directory.

### Viewing Data

To view stored data:
```bash
cd backend
python view_data.py
```

## Contributing

1. Create a feature branch
2. Make your changes
3. Commit with clear messages
4. Push to your fork
5. Create a pull request

## License

This project is available on GitHub at: https://github.com/Rajatraiiii/Nexus-Alpha.git

## Support

For issues, questions, or suggestions, please open an issue on the GitHub repository.

---

**Last Updated**: June 9, 2026

# To-Do App (Flutter + Spring Boot)

A simple To-Do app built using Flutter for the frontend and Spring Boot for the backend. It allows users to add, edit, delete, and view tasks with date and optional time.

## Features

- Add tasks with title and due date
- Optional start time and end time
- Edit and delete existing tasks
- Task list displayed in a clean UI
- Flutter connects to Spring Boot via HTTP

## Technologies Used

- **Frontend**: Flutter (Dart)
- **Backend**: Spring Boot (Java)
- **Database**: MySQL or H2

## Folder Structure

project-root/
├── backend/
│ └── todoapp/ # Spring Boot backend
├── frontend/
│ └── my_app/ # Flutter frontend


## How to Run the Project

### Backend (Spring Boot)

1. Open `backend/todoapp` in your IDE (IntelliJ, VS Code, etc.).
2. Run the application.
3. Server runs at: `http://localhost:8080`

### Frontend (Flutter)

1. Navigate to `frontend/my_app`
2. Run `flutter pub get`
3. Use `flutter run` to launch the app

## API Endpoints

- `GET /tasks` - List all tasks
- `POST /tasks` - Add new task
- `PUT /tasks/{id}` - Update task
- `DELETE /tasks/{id}` - Delete task

## Future Work

- Add login/signup functionality
- Push notifications for due tasks
- Store data in Firebase or cloud DB


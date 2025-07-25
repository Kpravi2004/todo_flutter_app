package com.example.todoapp.model;

public class Task {
    private Long id;
    private String title;
    private boolean completed;
    private String dueDate; // e.g. 2025-07-26
    private String startTime; // e.g. 09:00 AM
    private String endTime;   // e.g. 11:00 AM

    public Task() {}

    public Task(Long id, String title, boolean completed, String dueDate, String startTime, String endTime) {
        this.id = id;
        this.title = title;
        this.completed = completed;
        this.dueDate = dueDate;
        this.startTime = startTime;
        this.endTime = endTime;
    }

    // Getters and setters
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }

    public boolean isCompleted() { return completed; }
    public void setCompleted(boolean completed) { this.completed = completed; }

    public String getDueDate() { return dueDate; }
    public void setDueDate(String dueDate) { this.dueDate = dueDate; }

    public String getStartTime() { return startTime; }
    public void setStartTime(String startTime) { this.startTime = startTime; }

    public String getEndTime() { return endTime; }
    public void setEndTime(String endTime) { this.endTime = endTime; }
}

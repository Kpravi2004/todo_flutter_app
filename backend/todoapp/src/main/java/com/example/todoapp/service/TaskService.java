package com.example.todoapp.service;

import com.example.todoapp.model.Task;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.List;
import java.util.Optional;
import java.util.concurrent.atomic.AtomicLong;

@Service
public class TaskService {
    private final List<Task> tasks = new ArrayList<>();
    private final AtomicLong counter = new AtomicLong();

    public List<Task> getAllTasks() {
        return tasks;
    }

    public Task addTask(Task task) {
        Long id = counter.incrementAndGet();
        task.setId(id);
        tasks.add(task);
        return task;
    }

    public boolean deleteTask(Long id) {
        return tasks.removeIf(task -> task.getId().equals(id));
    }

    public Task updateTask(Long id, Task updatedTask) {
        Optional<Task> optionalTask = tasks.stream()
            .filter(t -> t.getId().equals(id))
            .findFirst();

        if (optionalTask.isPresent()) {
            Task task = optionalTask.get();
            task.setTitle(updatedTask.getTitle());
            task.setCompleted(updatedTask.isCompleted());
            task.setDueDate(updatedTask.getDueDate());
            task.setStartTime(updatedTask.getStartTime());
            task.setEndTime(updatedTask.getEndTime());
            return task;
        }
        return null;
    }
}

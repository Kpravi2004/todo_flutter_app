package com.example.todoapp.controller;

import com.example.todoapp.model.Task;
import com.example.todoapp.service.TaskService;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/tasks")
@CrossOrigin(origins = "*") // Allow requests from any frontend
public class TaskController {

    private final TaskService taskService;

    public TaskController(TaskService taskService) {
        this.taskService = taskService;
    }

    @GetMapping
    public List<Task> getTasks() {
        return taskService.getAllTasks();
    }

    @PostMapping
    public Task createTask(@RequestBody Task task) {
        return taskService.addTask(task);
    }

    @DeleteMapping("/{id}")
    public String deleteTask(@PathVariable Long id) {
        boolean removed = taskService.deleteTask(id);
        return removed ? "Deleted" : "Task not found";
    }

    @PutMapping("/{id}")
    public Task updateTask(@PathVariable Long id, @RequestBody Task task) {
        return taskService.updateTask(id, task);
    }
}

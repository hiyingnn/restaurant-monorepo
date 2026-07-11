package com.restaurant.food.controller;

import com.restaurant.food.model.MenuItem;
import com.restaurant.food.service.MenuItemService;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/menu-items")
public class MenuItemController {

    private final MenuItemService service;

    public MenuItemController(MenuItemService service) {
        this.service = service;
    }

    @GetMapping
    public List<MenuItem> findAll() {
        return service.findAll();
    }

    @GetMapping("/{id}")
    public MenuItem findById(@PathVariable Long id) {
        return service.findById(id);
    }

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    public MenuItem create(@RequestBody MenuItem entity) {
        return service.create(entity);
    }
}

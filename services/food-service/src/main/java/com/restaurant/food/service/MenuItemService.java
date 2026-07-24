package com.restaurant.food.service;

import com.restaurant.food.model.MenuItem;
import com.restaurant.food.repository.MenuItemRepository;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class MenuItemService {

    private final MenuItemRepository repository;

    public MenuItemService(MenuItemRepository repository) {
        this.repository = repository;
    }

    public List<MenuItem> findAll() {
        return repository.findAll();
    }

    public MenuItem findById(Long id) {
        return repository.findById(id)
                .orElseThrow(() -> new MenuItemNotFoundException(id));
    }

    public MenuItem create(MenuItem entity) {
        return repository.save(entity);
    }
}

// fix: guard against duplicate menuitem submissions (idempotency key check to be added)

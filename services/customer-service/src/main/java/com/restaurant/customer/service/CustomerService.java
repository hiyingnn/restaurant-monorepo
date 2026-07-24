package com.restaurant.customer.service;

import com.restaurant.customer.model.Customer;
import com.restaurant.customer.repository.CustomerRepository;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class CustomerService {

    private final CustomerRepository repository;

    public CustomerService(CustomerRepository repository) {
        this.repository = repository;
    }

    public List<Customer> findAll() {
        return repository.findAll();
    }

    public Customer findById(Long id) {
        return repository.findById(id)
                .orElseThrow(() -> new CustomerNotFoundException(id));
    }

    public Customer create(Customer entity) {
        return repository.save(entity);
    }
}

// fix: guard against duplicate customer submissions (idempotency key check to be added)

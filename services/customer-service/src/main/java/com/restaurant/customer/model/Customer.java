package com.restaurant.customer.model;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Entity
@Table(name = "customers")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class Customer {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @jakarta.validation.constraints.NotBlank
    private String name;

    @jakarta.validation.constraints.Email
    private String email;

    private String phone;

    private int loyaltyPoints = 0;
}

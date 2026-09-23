package com.restaurant.food.dto;

import java.math.BigDecimal;

public record MenuItemDto(Long id, String name, BigDecimal price, String category, boolean available) {
}

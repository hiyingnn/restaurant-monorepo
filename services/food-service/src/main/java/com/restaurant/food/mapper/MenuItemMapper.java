package com.restaurant.food.mapper;

import com.restaurant.food.dto.MenuItemDto;
import com.restaurant.food.model.MenuItem;
import org.mapstruct.Mapper;

@Mapper(componentModel = "spring")
public interface MenuItemMapper {
    MenuItemDto toDto(MenuItem menuItem);
}

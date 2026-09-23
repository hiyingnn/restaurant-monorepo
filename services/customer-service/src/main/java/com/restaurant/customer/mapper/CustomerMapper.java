package com.restaurant.customer.mapper;

import com.restaurant.customer.dto.CustomerDto;
import com.restaurant.customer.model.Customer;
import org.mapstruct.Mapper;

@Mapper(componentModel = "spring")
public interface CustomerMapper {
    CustomerDto toDto(Customer customer);
}

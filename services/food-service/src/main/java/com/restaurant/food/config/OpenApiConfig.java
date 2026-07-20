package com.restaurant.food.config;

import io.swagger.v3.oas.models.OpenAPI;
import io.swagger.v3.oas.models.info.Info;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class OpenApiConfig {

    @Bean
    public OpenAPI food_serviceOpenApi() {
        return new OpenAPI().info(new Info().title("food-service").version("0.1.0"));
    }
}

package com.qlsv.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import io.swagger.v3.oas.models.OpenAPI;
import io.swagger.v3.oas.models.info.Info;

@Configuration
public class OpenApiConfig {
    @Bean
    public OpenAPI qlsvOpenAPI() {
        return new OpenAPI().info(new Info()
            .title("QLSV API")
            .description("Hệ thống quản lý sinh viên — REST API")
            .version("0.1.0"));
    }
}

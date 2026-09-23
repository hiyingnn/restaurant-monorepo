# order-service

Standalone Spring Boot 4.0.0 microservice (Java 17), managing `Order` records.
Originally lived in its own Git repository before the migration described in the parent article
(*From Microservice Sprawl to a Unified Codebase*).

## Dependencies (as inherited independently, before the shared parent POM)

- spring-boot-starter-web
- spring-boot-starter-data-jpa
- spring-boot-starter-actuator
- h2
- lombok 1.18.30
- spring-boot-starter-validation
- springdoc-openapi 2.6.0

## Run locally

```bash
mvn spring-boot:run
```

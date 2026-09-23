# customer-service

Standalone Spring Boot 4.1.0 microservice (Java 17), managing `Customer` records.
Originally lived in its own Git repository before the migration described in the parent article
(*From Microservice Sprawl to a Unified Codebase*).

## Dependencies (as inherited independently, before the shared parent POM)

- spring-boot-starter-web
- spring-boot-starter-data-jpa
- spring-boot-starter-actuator
- h2
- lombok 1.18.32
- spring-boot-starter-validation
- mapstruct 1.6.3
- testcontainers 1.20.4 (test scope)

## Run locally

```bash
mvn spring-boot:run
```

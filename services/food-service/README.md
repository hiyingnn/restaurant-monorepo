# food-service

Standalone Spring Boot 4.1.1 microservice (Java 21), managing `MenuItem` records.
Originally lived in its own Git repository before the migration described in the parent article
(*From Microservice Sprawl to a Unified Codebase*).

## Dependencies (as inherited independently, before the shared parent POM)

- spring-boot-starter-web
- spring-boot-starter-data-jpa
- spring-boot-starter-actuator
- h2
- lombok 1.18.34
- mapstruct 1.6.3
- springdoc-openapi 2.7.0

## Run locally

```bash
mvn spring-boot:run
```

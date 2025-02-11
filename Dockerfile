# ======================================================================
# 빌드 스테이지: Maven으로 Spring Boot 패키징
# ======================================================================
FROM maven:3.9.9-eclipse-temurin-17 AS build
WORKDIR /app

# 프로젝트 전체를 복사 (src, pom.xml, .m2 등 모두 포함)
COPY . /app



# settings.xml 파일을 복사해 Maven이 사내 Nexus를 바라보게 함
#COPY settings.xml /root/.m2/settings.xml

# pom.xml, 소스 복사
#COPY pom.xml .
#RUN mvn dependency:go-offline -s /root/.m2/settings.xml

#COPY src ./src
#RUN mvn clean package -DskipTests -s /root/.m2/settings.xml





RUN mvn clean package -DskipTests

# ======================================================================
# 런타임 스테이지: 경량 JRE로 실행
# ======================================================================
FROM eclipse-temurin:17-jre
WORKDIR /app

# 빌드 스테이지에서 생성된 JAR만 복사
COPY --from=build /app/target/demo-0.0.1-SNAPSHOT.jar app.jar

EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]

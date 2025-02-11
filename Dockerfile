# ======================================================================
# 빌드 스테이지: Maven으로 Spring Boot 패키징
# ======================================================================
FROM maven:3.9.9-eclipse-temurin-17 AS build
WORKDIR /app

# 프로젝트 전체를 복사 (src, pom.xml, .m2 등 모두 포함)
#COPY . /app

# 1) 로컬에서 준비한 Maven 캐시를 복사
#    - 예: 로컬 프로젝트에 .m2/repository 폴더가 있다고 가정
COPY .m2 /root/.m2

# 2) pom.xml만 먼저 복사해 dependency:go-offline 용 캐싱도 가능
COPY pom.xml .
# (이미 .m2/repository에 의존성이 있다면, 여기서 dependency:go-offline을 해도
#  별도 다운로드는 거의 없을 것입니다.)
RUN mvn dependency:go-offline
# 3) 이후 전체 소스 복사
COPY src ./src


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

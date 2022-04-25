FROM openjdk:8 as build
RUN git clone https://github.com/retrowars/retrowars
WORKDIR /retrowars

RUN ./gradlew -PexcludeAndroid stage :server:dist
FROM openjdk:8
COPY --from=build /retrowars/server/build/libs/retrowars-server*.jar /retrowars-server.jar

EXPOSE 8080/tcp
ENV PORT=8080

CMD ["java", "-jar", "/retrowars-server.jar"]

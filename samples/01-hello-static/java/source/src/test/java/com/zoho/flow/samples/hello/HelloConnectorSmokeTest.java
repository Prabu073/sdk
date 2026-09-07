package com.zoho.flow.samples.hello;

public final class HelloConnectorSmokeTest {

    private HelloConnectorSmokeTest() {
    }

    public static void main(String[] args) {
        HelloConnector connector = new HelloConnector();

        HelloInput namedInput = new HelloInput();
        namedInput.name = "Ada";
        require("Hello, Ada!".equals(connector.sayHello(namedInput).message), "Named greeting did not match");

        HelloInput emptyInput = new HelloInput();
        require("Hello, World!".equals(connector.sayHello(emptyInput).message), "Default greeting did not match");

        require("Hello, World!".equals(connector.sayHello(null).message), "Null input greeting did not match");
        System.out.println("HelloConnectorSmokeTest passed");
    }

    private static void require(boolean condition, String message) {
        if (!condition) {
            throw new AssertionError(message);
        }
    }
}

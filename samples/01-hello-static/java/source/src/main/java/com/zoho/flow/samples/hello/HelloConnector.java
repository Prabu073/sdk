package com.zoho.flow.samples.hello;

import com.zoho.agent.flow.customclass.AbstractCustomClass;
import com.zoho.agent.flow.customclass.annotation.Action;
import com.zoho.agent.flow.customclass.annotation.Description;

@Description("A minimal connector that returns a greeting")
public final class HelloConnector extends AbstractCustomClass {

    public HelloConnector() {
    }

    @Action
    @Description("Create a greeting for the supplied name")
    public HelloOutput sayHello(HelloInput input) {
        String name = input == null ? null : input.name;
        if (name == null || name.trim().isEmpty()) {
            name = "World";
        }

        HelloOutput output = new HelloOutput();
        output.message = "Hello, " + name.trim() + "!";
        return output;
    }
}

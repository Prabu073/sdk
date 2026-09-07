package com.zoho.flow.samples.hello;

import com.zoho.agent.flow.customclass.CustomClassData;
import com.zoho.agent.flow.customclass.annotation.Description;
import com.zoho.agent.flow.customclass.annotation.Label;
import com.zoho.agent.flow.customclass.annotation.Optional;

public final class HelloInput extends CustomClassData {

    @Label("Name")
    @Description("Name to include in the greeting; defaults to World")
    @Optional
    public String name;

    public HelloInput() {
    }
}

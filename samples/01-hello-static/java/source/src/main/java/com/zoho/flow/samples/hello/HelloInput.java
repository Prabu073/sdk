package com.zoho.flow.samples.hello;

import com.zoho.agent.flow.extension.ExtensionData;
import com.zoho.agent.flow.extension.annotation.Description;
import com.zoho.agent.flow.extension.annotation.Label;
import com.zoho.agent.flow.extension.annotation.Optional;

public final class HelloInput extends ExtensionData {

    @Label("Name")
    @Description("Name to include in the greeting; defaults to World")
    @Optional
    public String name;

    public HelloInput() {
    }
}

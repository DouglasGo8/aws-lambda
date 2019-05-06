
package com.pagseguro.lambda.vertx.core.authorizer.api.verticle;

import java.util.UUID;

import org.apache.log4j.Logger;

import io.vertx.core.AbstractVerticle;
import io.vertx.core.eventbus.Message;
import io.vertx.core.json.JsonObject;

/**
 * @author Douglas D.b
 */
public class AuthorizerResource extends AbstractVerticle {

    

    private String authBusQueue = "auth.queue";

    @Override
    public void start() throws Exception {

        super.vertx.eventBus().consumer(this.authBusQueue, this::onMessage);

    }
    
    private void onMessage(Message<JsonObject> message) {
        
        logger.debug(message);

        message.reply(new JsonObject().put("authToken", UUID.randomUUID().toString()));
    }



    /**
     * 
     */
    private static final Logger logger = Logger.getLogger(AuthorizerResource.class);
}

package com.pagseguro.lambda.vertx.core.authorizer.service;

import java.util.Map;
import java.util.concurrent.CompletableFuture;
import java.util.concurrent.ExecutionException;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.TimeoutException;

import com.amazonaws.services.lambda.runtime.Context;
import com.amazonaws.services.lambda.runtime.RequestHandler;
import com.pagseguro.lambda.vertx.core.authorizer.api.verticle.AuthorizerResource;
import com.pagseguro.lambda.vertx.core.authorizer.domain.ApiGatewayResponse;

import org.apache.log4j.BasicConfigurator;
import org.apache.log4j.Logger;

import io.vertx.core.DeploymentOptions;
import io.vertx.core.Vertx;
import io.vertx.core.json.JsonObject;

/**
 * 
 */
public class Handler implements RequestHandler<Map<String, Object>, ApiGatewayResponse> {

    /**
     * 
     */
    private final static Vertx vertx;

    /**
    * 
    */
    private String authBusQueue = "auth.queue";
    
    /**
     * 
     */
    private static final Logger logger = Logger.getLogger(Handler.class);


    /**
     * 
     */
    static {

        vertx = Vertx.vertx();

        final DeploymentOptions deployVertx = new DeploymentOptions()
                .setInstances(Runtime.getRuntime().availableProcessors());

        vertx.deployVerticle(AuthorizerResource.class.getName(), deployVertx);
    }

    public Handler() {

        BasicConfigurator.configure();

    }

    @Override
    public ApiGatewayResponse handleRequest(Map<String, Object> input, Context context) {

        final JsonObject jsonRequest = new JsonObject(input);
        final CompletableFuture<JsonObject> future = new CompletableFuture<>();

        vertx.eventBus().send(this.authBusQueue, jsonRequest, rs -> {
            if (!rs.succeeded()) {
                logger.error(
                        "Request id = " + context.getAwsRequestId() + " failed. Cause = " + rs.cause().getMessage());
                throw new RuntimeException(rs.cause());
            }

            future.complete((JsonObject) rs.result().body());
        });

        try {

            Object response = future.get(15, TimeUnit.SECONDS);

            return ApiGatewayResponse.builder().setStatusCode(200).setObjectBody(response).build();

        } catch (InterruptedException | ExecutionException | TimeoutException e) {
            logger.error("Service timeout. Request id = " + context.getAwsRequestId() + " Error = " + e.getMessage());

            return ApiGatewayResponse.builder().setStatusCode(504).setRawBody("Service timeout").build();
        }

    }

}
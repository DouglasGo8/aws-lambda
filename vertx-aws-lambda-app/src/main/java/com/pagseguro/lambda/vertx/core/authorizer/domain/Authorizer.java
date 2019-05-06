


package com.pagseguro.lambda.vertx.core.authorizer.domain;

import java.util.Date;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.annotation.JsonProperty;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
@JsonIgnoreProperties
public class Authorizer {

    @JsonProperty("id")
    private long id;
    
    @JsonProperty("shorturl")
    private String shortUrl;
    
    @JsonProperty("created")
    private Date created;

}
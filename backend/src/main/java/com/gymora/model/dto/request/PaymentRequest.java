package com.gymora.model.dto.request;

import jakarta.validation.constraints.NotNull;
import lombok.Data;

import java.math.BigDecimal;

@Data
public class PaymentRequest {

    @NotNull(message = "Membership ID is required")
    private Long membershipId;

    @NotNull(message = "Customer ID is required")
    private Long customerId;

    @NotNull(message = "Amount is required")
    private BigDecimal amount;

    private String paymentMethod;
    private String transactionId;
}

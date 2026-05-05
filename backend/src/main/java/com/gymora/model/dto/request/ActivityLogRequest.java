package com.gymora.model.dto.request;

import jakarta.validation.constraints.NotNull;
import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDate;

@Data
public class ActivityLogRequest {

    @NotNull(message = "Customer ID is required")
    private Long customerId;

    @NotNull(message = "Log date is required")
    private LocalDate logDate;

    private BigDecimal weightKg;
    private BigDecimal bmi;
    private Integer caloriesConsumed;
    private Integer caloriesBurned;
    private Integer steps;
    private Integer waterMl;
    private String notes;
}

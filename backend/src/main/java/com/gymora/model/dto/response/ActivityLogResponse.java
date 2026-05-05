package com.gymora.model.dto.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ActivityLogResponse {

    private Long id;
    private Long customerId;
    private LocalDate logDate;
    private BigDecimal weightKg;
    private BigDecimal bmi;
    private Integer caloriesConsumed;
    private Integer caloriesBurned;
    private Integer steps;
    private Integer waterMl;
    private String notes;
    private LocalDateTime createdAt;
}

package com.gymora.model.dto.request;

import com.gymora.model.enums.PlanType;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

import java.time.LocalDate;

@Data
public class WorkoutPlanRequest {

    @NotNull(message = "Trainer ID is required")
    private Long trainerId;

    @NotNull(message = "Customer ID is required")
    private Long customerId;

    @NotBlank(message = "Title is required")
    private String title;

    private String description;
    private String exercises; // JSON string

    @NotNull(message = "Plan type is required")
    private PlanType planType;

    @NotNull(message = "Start date is required")
    private LocalDate startDate;

    private LocalDate endDate;
}

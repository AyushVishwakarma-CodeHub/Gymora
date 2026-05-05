package com.gymora.model.dto.request;

import com.gymora.model.enums.FitnessGoal;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDate;

@Data
public class CustomerRequest {

    @NotNull(message = "User ID is required")
    private Long userId;

    @NotNull(message = "Gym ID is required")
    private Long gymId;

    private Long trainerId;

    private LocalDate dateOfBirth;
    private String gender;
    private BigDecimal heightCm;
    private BigDecimal weightKg;
    private FitnessGoal goal;
}

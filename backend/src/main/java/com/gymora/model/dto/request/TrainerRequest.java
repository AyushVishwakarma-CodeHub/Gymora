package com.gymora.model.dto.request;

import jakarta.validation.constraints.NotNull;
import lombok.Data;

@Data
public class TrainerRequest {

    @NotNull(message = "User ID is required")
    private Long userId;

    @NotNull(message = "Gym ID is required")
    private Long gymId;

    private String specialization;
    private Integer experienceYears;
    private String bio;
}

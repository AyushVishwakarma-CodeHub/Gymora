package com.gymora.model.dto.response;

import com.gymora.model.enums.PlanType;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDate;
import java.time.LocalDateTime;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class WorkoutPlanResponse {

    private Long id;
    private Long trainerId;
    private String trainerName;
    private Long customerId;
    private String customerName;
    private String title;
    private String description;
    private Object exercises; // JSON object/list
    private PlanType planType;
    private LocalDate startDate;
    private LocalDate endDate;
    private Boolean isActive;
    private LocalDateTime createdAt;
}

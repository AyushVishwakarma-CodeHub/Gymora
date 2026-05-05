package com.gymora.model.dto.response;

import com.gymora.model.enums.FitnessGoal;
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
public class CustomerResponse {

    private Long id;
    private Long userId;
    private String fullName;
    private String email;
    private String avatarUrl;
    private Long gymId;
    private String gymName;
    private Long trainerId;
    private String trainerName;
    private LocalDate dateOfBirth;
    private String gender;
    private BigDecimal heightCm;
    private BigDecimal weightKg;
    private FitnessGoal goal;
    private MembershipResponse activeMembership;
    private LocalDateTime createdAt;
}

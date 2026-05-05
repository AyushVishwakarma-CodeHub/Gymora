package com.gymora.model.dto.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class TrainerResponse {

    private Long id;
    private Long userId;
    private String fullName;
    private String email;
    private String avatarUrl;
    private Long gymId;
    private String gymName;
    private String specialization;
    private Integer experienceYears;
    private String bio;
    private Boolean isActive;
    private Integer customerCount;
    private LocalDateTime createdAt;
}

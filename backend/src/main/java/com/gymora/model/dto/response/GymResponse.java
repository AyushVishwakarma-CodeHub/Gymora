package com.gymora.model.dto.response;

import com.gymora.model.enums.GymStatus;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class GymResponse {

    private Long id;
    private String name;
    private String address;
    private String city;
    private String phone;
    private String logoUrl;
    private String description;
    private GymStatus status;
    private Long adminId;
    private String adminName;
    private Integer trainerCount;
    private Integer customerCount;
    private LocalDateTime createdAt;
}

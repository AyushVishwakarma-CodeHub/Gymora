package com.gymora.model.dto.request;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

@Data
public class GymRequest {

    @NotBlank(message = "Gym name is required")
    private String name;

    @NotBlank(message = "Address is required")
    private String address;

    private String city;
    private String phone;
    private String logoUrl;
    private String description;

    @NotNull(message = "Admin ID is required")
    private Long adminId;
}

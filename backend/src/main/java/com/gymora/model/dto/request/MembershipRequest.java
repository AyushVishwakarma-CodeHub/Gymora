package com.gymora.model.dto.request;

import com.gymora.model.enums.DurationType;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDate;

@Data
public class MembershipRequest {

    @NotNull(message = "Customer ID is required")
    private Long customerId;

    @NotNull(message = "Gym ID is required")
    private Long gymId;

    @NotBlank(message = "Plan name is required")
    private String planName;

    @NotNull(message = "Price is required")
    private BigDecimal price;

    @NotNull(message = "Duration type is required")
    private DurationType durationType;

    @NotNull(message = "Start date is required")
    private LocalDate startDate;
}

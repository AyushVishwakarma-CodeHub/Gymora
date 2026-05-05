package com.gymora.model.dto.response;

import com.gymora.model.enums.DurationType;
import com.gymora.model.enums.MembershipStatus;
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
public class MembershipResponse {

    private Long id;
    private Long customerId;
    private String customerName;
    private Long gymId;
    private String planName;
    private BigDecimal price;
    private DurationType durationType;
    private LocalDate startDate;
    private LocalDate endDate;
    private MembershipStatus status;
    private Integer daysRemaining;
    private LocalDateTime createdAt;
}

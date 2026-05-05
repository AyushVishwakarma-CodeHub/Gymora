package com.gymora.model.dto.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class DashboardResponse {

    private Long totalGyms;
    private Long totalTrainers;
    private Long totalCustomers;
    private Long activeMembers;
    private BigDecimal totalRevenue;
    private BigDecimal monthlyRevenue;
    private Long pendingGyms;
    private Long expiringMemberships;
}

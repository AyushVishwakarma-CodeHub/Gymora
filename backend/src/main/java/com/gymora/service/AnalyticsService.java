package com.gymora.service;

import com.gymora.model.dto.response.DashboardResponse;
import com.gymora.model.enums.GymStatus;
import com.gymora.model.enums.MembershipStatus;
import com.gymora.repository.*;
import lombok.RequiredArgsConstructor;
import org.springframework.cache.annotation.Cacheable;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;

@Service
@RequiredArgsConstructor
public class AnalyticsService {

    private final GymRepository gymRepository;
    private final TrainerRepository trainerRepository;
    private final CustomerRepository customerRepository;
    private final MembershipRepository membershipRepository;
    private final PaymentRepository paymentRepository;

    @Cacheable(value = "dashboard", key = "'system-overview'")
    public DashboardResponse getSystemOverview() {
        return DashboardResponse.builder()
                .totalGyms((long) gymRepository.findAll().size())
                .totalTrainers(trainerRepository.count())
                .totalCustomers(customerRepository.count())
                .activeMembers(membershipRepository.countActiveMembers())
                .totalRevenue(paymentRepository.getTotalRevenue())
                .monthlyRevenue(paymentRepository.getRevenueAfterDate(
                        LocalDateTime.now().withDayOfMonth(1).withHour(0).withMinute(0)))
                .pendingGyms(gymRepository.countByStatus(GymStatus.PENDING))
                .expiringMemberships((long) membershipRepository.findExpiringMemberships(
                        LocalDate.now(), LocalDate.now().plusDays(7)).size())
                .build();
    }

    @Cacheable(value = "dashboard", key = "'gym-' + #gymId")
    public DashboardResponse getGymAnalytics(Long gymId) {
        return DashboardResponse.builder()
                .totalTrainers(trainerRepository.countByGymId(gymId))
                .totalCustomers(customerRepository.countByGymId(gymId))
                .activeMembers(membershipRepository.countByGymIdAndStatus(gymId, MembershipStatus.ACTIVE))
                .totalRevenue(paymentRepository.getGymTotalRevenue(gymId))
                .build();
    }
}

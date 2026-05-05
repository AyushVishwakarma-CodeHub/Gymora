package com.gymora.service;

import com.gymora.exception.ResourceNotFoundException;
import com.gymora.model.dto.request.MembershipRequest;
import com.gymora.model.dto.response.MembershipResponse;
import com.gymora.model.entity.Customer;
import com.gymora.model.entity.Gym;
import com.gymora.model.entity.Membership;
import com.gymora.model.enums.DurationType;
import com.gymora.model.enums.MembershipStatus;
import com.gymora.repository.CustomerRepository;
import com.gymora.repository.GymRepository;
import com.gymora.repository.MembershipRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.time.temporal.ChronoUnit;
import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class MembershipService {

    private final MembershipRepository membershipRepository;
    private final CustomerRepository customerRepository;
    private final GymRepository gymRepository;

    @Transactional
    public MembershipResponse createMembership(MembershipRequest request) {
        Customer customer = customerRepository.findById(request.getCustomerId())
                .orElseThrow(() -> new ResourceNotFoundException("Customer", "id", request.getCustomerId()));
        Gym gym = gymRepository.findById(request.getGymId())
                .orElseThrow(() -> new ResourceNotFoundException("Gym", "id", request.getGymId()));

        LocalDate endDate = calculateEndDate(request.getStartDate(), request.getDurationType());

        Membership membership = Membership.builder()
                .customer(customer)
                .gym(gym)
                .planName(request.getPlanName())
                .price(request.getPrice())
                .durationType(request.getDurationType())
                .startDate(request.getStartDate())
                .endDate(endDate)
                .status(MembershipStatus.ACTIVE)
                .build();

        membership = membershipRepository.save(membership);
        return mapToResponse(membership);
    }

    public List<MembershipResponse> getCustomerMemberships(Long customerId) {
        return membershipRepository.findByCustomerId(customerId).stream()
                .map(this::mapToResponse)
                .collect(Collectors.toList());
    }

    public List<MembershipResponse> getGymMemberships(Long gymId) {
        return membershipRepository.findByGymId(gymId).stream()
                .map(this::mapToResponse)
                .collect(Collectors.toList());
    }

    @Transactional
    public MembershipResponse updateMembership(Long id, MembershipRequest request) {
        Membership membership = membershipRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Membership", "id", id));

        if (request.getPlanName() != null) membership.setPlanName(request.getPlanName());
        if (request.getPrice() != null) membership.setPrice(request.getPrice());

        membership = membershipRepository.save(membership);
        return mapToResponse(membership);
    }

    @Transactional
    public void checkAndExpireMemberships() {
        LocalDate today = LocalDate.now();
        List<Membership> expiring = membershipRepository.findExpiringMemberships(
                today.minusDays(1), today);
        for (Membership m : expiring) {
            if (m.getEndDate().isBefore(today) || m.getEndDate().isEqual(today)) {
                m.setStatus(MembershipStatus.EXPIRED);
                membershipRepository.save(m);
            }
        }
    }

    private LocalDate calculateEndDate(LocalDate startDate, DurationType durationType) {
        return switch (durationType) {
            case MONTHLY -> startDate.plusMonths(1);
            case QUARTERLY -> startDate.plusMonths(3);
            case HALF_YEARLY -> startDate.plusMonths(6);
            case YEARLY -> startDate.plusYears(1);
        };
    }

    private MembershipResponse mapToResponse(Membership membership) {
        int daysRemaining = (int) ChronoUnit.DAYS.between(LocalDate.now(), membership.getEndDate());

        return MembershipResponse.builder()
                .id(membership.getId())
                .customerId(membership.getCustomer().getId())
                .customerName(membership.getCustomer().getUser().getFullName())
                .gymId(membership.getGym().getId())
                .planName(membership.getPlanName())
                .price(membership.getPrice())
                .durationType(membership.getDurationType())
                .startDate(membership.getStartDate())
                .endDate(membership.getEndDate())
                .status(membership.getStatus())
                .daysRemaining(Math.max(daysRemaining, 0))
                .createdAt(membership.getCreatedAt())
                .build();
    }
}

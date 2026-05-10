package com.gymora.service;

import com.gymora.exception.ResourceNotFoundException;
import com.gymora.model.dto.request.CustomerRequest;
import com.gymora.model.dto.response.CustomerResponse;
import com.gymora.model.dto.response.MembershipResponse;
import com.gymora.model.entity.*;
import com.gymora.model.enums.MembershipStatus;
import com.gymora.repository.*;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.time.temporal.ChronoUnit;
import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class CustomerService {

    private final CustomerRepository customerRepository;
    private final UserRepository userRepository;
    private final GymRepository gymRepository;
    private final TrainerRepository trainerRepository;
    private final MembershipRepository membershipRepository;

    @Transactional
    public CustomerResponse createCustomer(CustomerRequest request) {
        User user = userRepository.findById(request.getUserId())
                .orElseThrow(() -> new ResourceNotFoundException("User", "id", request.getUserId()));
        Gym gym = gymRepository.findById(request.getGymId())
                .orElseThrow(() -> new ResourceNotFoundException("Gym", "id", request.getGymId()));

        Customer customer = Customer.builder()
                .user(user)
                .gym(gym)
                .dateOfBirth(request.getDateOfBirth())
                .gender(request.getGender())
                .heightCm(request.getHeightCm())
                .weightKg(request.getWeightKg())
                .goal(request.getGoal())
                .build();

        if (request.getTrainerId() != null) {
            Trainer trainer = trainerRepository.findById(request.getTrainerId())
                    .orElseThrow(() -> new ResourceNotFoundException("Trainer", "id", request.getTrainerId()));
            customer.setTrainer(trainer);
        }

        customer = customerRepository.save(customer);
        return mapToResponse(customer);
    }

    public CustomerResponse getCustomerById(Long id) {
        Customer customer = customerRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Customer", "id", id));
        return mapToResponse(customer);
    }

    public CustomerResponse getCustomerByUserId(Long userId) {
        Customer customer = customerRepository.findByUserId(userId)
                .orElseThrow(() -> new ResourceNotFoundException("Customer", "userId", userId));
        return mapToResponse(customer);
    }

    public List<CustomerResponse> getCustomersByGym(Long gymId) {
        return customerRepository.findByGymId(gymId).stream()
                .map(this::mapToResponse)
                .collect(Collectors.toList());
    }

    public List<CustomerResponse> getCustomersByTrainer(Long trainerId) {
        return customerRepository.findByTrainerId(trainerId).stream()
                .map(this::mapToResponse)
                .collect(Collectors.toList());
    }

    @Transactional
    public CustomerResponse updateCustomer(Long id, CustomerRequest request) {
        Customer customer = customerRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Customer", "id", id));

        if (request.getDateOfBirth() != null) customer.setDateOfBirth(request.getDateOfBirth());
        if (request.getGender() != null) customer.setGender(request.getGender());
        if (request.getHeightCm() != null) customer.setHeightCm(request.getHeightCm());
        if (request.getWeightKg() != null) customer.setWeightKg(request.getWeightKg());
        if (request.getGoal() != null) customer.setGoal(request.getGoal());

        customer = customerRepository.save(customer);
        return mapToResponse(customer);
    }

    @Transactional
    public CustomerResponse assignTrainer(Long customerId, Long trainerId) {
        Customer customer = customerRepository.findById(customerId)
                .orElseThrow(() -> new ResourceNotFoundException("Customer", "id", customerId));
        Trainer trainer = trainerRepository.findById(trainerId)
                .orElseThrow(() -> new ResourceNotFoundException("Trainer", "id", trainerId));

        customer.setTrainer(trainer);
        customer = customerRepository.save(customer);
        return mapToResponse(customer);
    }

    private CustomerResponse mapToResponse(Customer customer) {
        MembershipResponse activeMembership = null;
        try {
            Membership membership = membershipRepository
                    .findByCustomerIdAndStatus(customer.getId(), MembershipStatus.ACTIVE)
                    .orElse(null);
            if (membership != null) {
                int daysRemaining = (int) ChronoUnit.DAYS.between(LocalDate.now(), membership.getEndDate());
                activeMembership = MembershipResponse.builder()
                        .id(membership.getId())
                        .planName(membership.getPlanName())
                        .price(membership.getPrice())
                        .durationType(membership.getDurationType())
                        .startDate(membership.getStartDate())
                        .endDate(membership.getEndDate())
                        .status(membership.getStatus())
                        .daysRemaining(Math.max(daysRemaining, 0))
                        .build();
            }
        } catch (Exception ignored) {}

        return CustomerResponse.builder()
                .id(customer.getId())
                .userId(customer.getUser().getId())
                .fullName(customer.getUser().getFullName())
                .email(customer.getUser().getEmail())
                .avatarUrl(customer.getUser().getAvatarUrl())
                .gymId(customer.getGym().getId())
                .gymName(customer.getGym().getName())
                .trainerId(customer.getTrainer() != null ? customer.getTrainer().getId() : null)
                .trainerName(customer.getTrainer() != null ? customer.getTrainer().getUser().getFullName() : null)
                .dateOfBirth(customer.getDateOfBirth())
                .gender(customer.getGender())
                .heightCm(customer.getHeightCm())
                .weightKg(customer.getWeightKg())
                .goal(customer.getGoal())
                .isApproved(Boolean.TRUE.equals(customer.getIsApproved()))
                .activeMembership(activeMembership)
                .createdAt(customer.getCreatedAt())
                .build();
    }
}

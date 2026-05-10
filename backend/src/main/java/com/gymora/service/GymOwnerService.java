package com.gymora.service;

import com.gymora.exception.BadRequestException;
import com.gymora.exception.ResourceNotFoundException;
import com.gymora.model.dto.request.RegisterRequest;
import com.gymora.model.dto.response.CustomerResponse;
import com.gymora.model.dto.response.TrainerResponse;
import com.gymora.model.entity.*;
import com.gymora.model.enums.GymStatus;
import com.gymora.model.enums.Role;
import com.gymora.repository.*;
import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class GymOwnerService {

    private final UserRepository userRepository;
    private final CustomerRepository customerRepository;
    private final TrainerRepository trainerRepository;
    private final GymRepository gymRepository;
    private final PasswordEncoder passwordEncoder;
    private final CustomerService customerService;
    private final TrainerService trainerService;

    @Transactional
    public CustomerResponse addMember(Long gymId, RegisterRequest request) {
        if (userRepository.existsByEmail(request.getEmail())) {
            throw new BadRequestException("Email is already registered");
        }

        Gym gym = gymRepository.findById(gymId)
                .orElseThrow(() -> new ResourceNotFoundException("Gym", "id", gymId));

        // 1. Create User
        User user = User.builder()
                .fullName(request.getFullName())
                .email(request.getEmail())
                .passwordHash(passwordEncoder.encode(request.getPassword() != null ? request.getPassword() : "123456"))
                .phone(request.getPhone())
                .role(Role.CUSTOMER)
                .isActive(true)
                .build();
        user = userRepository.save(user);

        // 2. Create Customer
        Customer customer = Customer.builder()
                .user(user)
                .gym(gym)
                .isApproved(true) // Auto-approve when added by owner
                .build();
        customer = customerRepository.save(customer);

        // Map to Response (using customerService for consistency)
        return customerService.getCustomerById(customer.getId());
    }

    @Transactional
    public void approveTrainer(Long trainerId) {
        Trainer trainer = trainerRepository.findById(trainerId)
                .orElseThrow(() -> new ResourceNotFoundException("Trainer", "id", trainerId));
        trainer.setIsApproved(true);
        trainerRepository.save(trainer);
    }

    @Transactional
    public TrainerResponse addTrainer(Long gymId, RegisterRequest request) {
        if (userRepository.existsByEmail(request.getEmail())) {
            throw new BadRequestException("Email is already registered");
        }

        Gym gym = gymRepository.findById(gymId)
                .orElseThrow(() -> new ResourceNotFoundException("Gym", "id", gymId));

        // 1. Create User
        User user = User.builder()
                .fullName(request.getFullName())
                .email(request.getEmail())
                .passwordHash(passwordEncoder.encode(request.getPassword() != null ? request.getPassword() : "123456"))
                .phone(request.getPhone())
                .role(Role.TRAINER)
                .isActive(true)
                .build();
        user = userRepository.save(user);

        // 2. Create Trainer
        Trainer trainer = Trainer.builder()
                .user(user)
                .gym(gym)
                .specialization("General Fitness")
                .experienceYears(0)
                .isApproved(true) // Auto-approve when added by owner
                .build();
        trainer = trainerRepository.save(trainer);

        // Map to Response
        return trainerService.getTrainerById(trainer.getId());
    }
}

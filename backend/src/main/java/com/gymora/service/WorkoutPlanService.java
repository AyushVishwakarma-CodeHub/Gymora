package com.gymora.service;

import com.gymora.exception.ResourceNotFoundException;
import com.gymora.model.dto.request.WorkoutPlanRequest;
import com.gymora.model.dto.response.WorkoutPlanResponse;
import com.gymora.model.entity.Customer;
import com.gymora.model.entity.Trainer;
import com.gymora.model.entity.WorkoutPlan;
import com.gymora.repository.CustomerRepository;
import com.gymora.repository.TrainerRepository;
import com.gymora.repository.WorkoutPlanRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class WorkoutPlanService {

    private final WorkoutPlanRepository workoutPlanRepository;
    private final TrainerRepository trainerRepository;
    private final CustomerRepository customerRepository;

    @Transactional
    public WorkoutPlanResponse createPlan(WorkoutPlanRequest request) {
        Trainer trainer = trainerRepository.findById(request.getTrainerId())
                .orElseThrow(() -> new ResourceNotFoundException("Trainer", "id", request.getTrainerId()));
        Customer customer = customerRepository.findById(request.getCustomerId())
                .orElseThrow(() -> new ResourceNotFoundException("Customer", "id", request.getCustomerId()));

        WorkoutPlan plan = WorkoutPlan.builder()
                .trainer(trainer)
                .customer(customer)
                .title(request.getTitle())
                .description(request.getDescription())
                .exercises(request.getExercises())
                .planType(request.getPlanType())
                .startDate(request.getStartDate())
                .endDate(request.getEndDate())
                .isActive(true)
                .build();

        plan = workoutPlanRepository.save(plan);
        return mapToResponse(plan);
    }

    public WorkoutPlanResponse getPlanById(Long id) {
        WorkoutPlan plan = workoutPlanRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("WorkoutPlan", "id", id));
        return mapToResponse(plan);
    }

    public List<WorkoutPlanResponse> getCustomerPlans(Long customerId) {
        return workoutPlanRepository.findByCustomerId(customerId).stream()
                .map(this::mapToResponse)
                .collect(Collectors.toList());
    }

    public List<WorkoutPlanResponse> getActiveCustomerPlans(Long customerId) {
        return workoutPlanRepository.findByCustomerIdAndIsActiveTrue(customerId).stream()
                .map(this::mapToResponse)
                .collect(Collectors.toList());
    }

    @Transactional
    public WorkoutPlanResponse updatePlan(Long id, WorkoutPlanRequest request) {
        WorkoutPlan plan = workoutPlanRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("WorkoutPlan", "id", id));

        if (request.getTitle() != null) plan.setTitle(request.getTitle());
        if (request.getDescription() != null) plan.setDescription(request.getDescription());
        if (request.getExercises() != null) plan.setExercises(request.getExercises());
        if (request.getPlanType() != null) plan.setPlanType(request.getPlanType());
        if (request.getStartDate() != null) plan.setStartDate(request.getStartDate());
        if (request.getEndDate() != null) plan.setEndDate(request.getEndDate());

        plan = workoutPlanRepository.save(plan);
        return mapToResponse(plan);
    }

    @Transactional
    public void deletePlan(Long id) {
        WorkoutPlan plan = workoutPlanRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("WorkoutPlan", "id", id));
        plan.setIsActive(false);
        workoutPlanRepository.save(plan);
    }

    private WorkoutPlanResponse mapToResponse(WorkoutPlan plan) {
        return WorkoutPlanResponse.builder()
                .id(plan.getId())
                .trainerId(plan.getTrainer().getId())
                .trainerName(plan.getTrainer().getUser().getFullName())
                .customerId(plan.getCustomer().getId())
                .customerName(plan.getCustomer().getUser().getFullName())
                .title(plan.getTitle())
                .description(plan.getDescription())
                .exercises(plan.getExercises())
                .planType(plan.getPlanType())
                .startDate(plan.getStartDate())
                .endDate(plan.getEndDate())
                .isActive(plan.getIsActive())
                .createdAt(plan.getCreatedAt())
                .build();
    }
}

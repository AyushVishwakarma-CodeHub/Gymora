package com.gymora.service;

import com.gymora.exception.ResourceNotFoundException;
import com.gymora.model.dto.request.DietPlanRequest;
import com.gymora.model.dto.response.DietPlanResponse;
import com.gymora.model.entity.Customer;
import com.gymora.model.entity.DietPlan;
import com.gymora.model.entity.Trainer;
import com.gymora.repository.CustomerRepository;
import com.gymora.repository.DietPlanRepository;
import com.gymora.repository.TrainerRepository;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class DietPlanService {

    private final DietPlanRepository dietPlanRepository;
    private final TrainerRepository trainerRepository;
    private final CustomerRepository customerRepository;
    private final com.fasterxml.jackson.databind.ObjectMapper objectMapper;

    @Transactional
    public DietPlanResponse createPlan(DietPlanRequest request) {
        Trainer trainer = trainerRepository.findById(request.getTrainerId())
                .orElseThrow(() -> new ResourceNotFoundException("Trainer", "id", request.getTrainerId()));
        Customer customer = customerRepository.findById(request.getCustomerId())
                .orElseThrow(() -> new ResourceNotFoundException("Customer", "id", request.getCustomerId()));

        DietPlan plan = DietPlan.builder()
                .trainer(trainer)
                .customer(customer)
                .title(request.getTitle())
                .description(request.getDescription())
                .meals(request.getMeals())
                .targetCalories(request.getTargetCalories())
                .startDate(request.getStartDate())
                .endDate(request.getEndDate())
                .isActive(true)
                .build();

        plan = dietPlanRepository.save(plan);
        return mapToResponse(plan);
    }

    public List<DietPlanResponse> getCustomerPlans(Long customerId) {
        return dietPlanRepository.findByCustomerId(customerId).stream()
                .map(this::mapToResponse)
                .collect(Collectors.toList());
    }

    public List<DietPlanResponse> getActiveCustomerPlans(Long customerId) {
        return dietPlanRepository.findByCustomerIdAndIsActiveTrue(customerId).stream()
                .map(this::mapToResponse)
                .collect(Collectors.toList());
    }

    @Transactional
    public DietPlanResponse updatePlan(Long id, DietPlanRequest request) {
        DietPlan plan = dietPlanRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("DietPlan", "id", id));

        if (request.getTitle() != null) plan.setTitle(request.getTitle());
        if (request.getDescription() != null) plan.setDescription(request.getDescription());
        if (request.getMeals() != null) plan.setMeals(request.getMeals());
        if (request.getTargetCalories() != null) plan.setTargetCalories(request.getTargetCalories());

        plan = dietPlanRepository.save(plan);
        return mapToResponse(plan);
    }

    private DietPlanResponse mapToResponse(DietPlan plan) {
        return DietPlanResponse.builder()
                .id(plan.getId())
                .trainerId(plan.getTrainer().getId())
                .trainerName(plan.getTrainer().getUser().getFullName())
                .customerId(plan.getCustomer().getId())
                .customerName(plan.getCustomer().getUser().getFullName())
                .title(plan.getTitle())
                .description(plan.getDescription())
                .meals(plan.getMeals()) // Keep as raw JSON string for Flutter jsonDecode
                .targetCalories(plan.getTargetCalories())
                .startDate(plan.getStartDate())
                .endDate(plan.getEndDate())
                .isActive(plan.getIsActive())
                .createdAt(plan.getCreatedAt())
                .build();
    }
}

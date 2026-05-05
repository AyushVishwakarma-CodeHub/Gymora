package com.gymora.service;

import com.gymora.exception.ResourceNotFoundException;
import com.gymora.model.dto.request.ActivityLogRequest;
import com.gymora.model.dto.response.ActivityLogResponse;
import com.gymora.model.entity.ActivityLog;
import com.gymora.model.entity.Customer;
import com.gymora.repository.ActivityLogRepository;
import com.gymora.repository.CustomerRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class ActivityLogService {

    private final ActivityLogRepository activityLogRepository;
    private final CustomerRepository customerRepository;

    @Transactional
    public ActivityLogResponse logActivity(ActivityLogRequest request) {
        Customer customer = customerRepository.findById(request.getCustomerId())
                .orElseThrow(() -> new ResourceNotFoundException("Customer", "id", request.getCustomerId()));

        // Check if log exists for this date, update if so
        ActivityLog log = activityLogRepository
                .findByCustomerIdAndLogDate(request.getCustomerId(), request.getLogDate())
                .orElse(ActivityLog.builder()
                        .customer(customer)
                        .logDate(request.getLogDate())
                        .build());

        if (request.getWeightKg() != null) log.setWeightKg(request.getWeightKg());
        if (request.getBmi() != null) log.setBmi(request.getBmi());
        if (request.getCaloriesConsumed() != null) log.setCaloriesConsumed(request.getCaloriesConsumed());
        if (request.getCaloriesBurned() != null) log.setCaloriesBurned(request.getCaloriesBurned());
        if (request.getSteps() != null) log.setSteps(request.getSteps());
        if (request.getWaterMl() != null) log.setWaterMl(request.getWaterMl());
        if (request.getNotes() != null) log.setNotes(request.getNotes());

        log = activityLogRepository.save(log);
        return mapToResponse(log);
    }

    public List<ActivityLogResponse> getCustomerLogs(Long customerId) {
        return activityLogRepository.findByCustomerIdOrderByLogDateDesc(customerId).stream()
                .map(this::mapToResponse)
                .collect(Collectors.toList());
    }

    public List<ActivityLogResponse> getCustomerLogsByDateRange(Long customerId, LocalDate start, LocalDate end) {
        return activityLogRepository
                .findByCustomerIdAndLogDateBetweenOrderByLogDateAsc(customerId, start, end)
                .stream()
                .map(this::mapToResponse)
                .collect(Collectors.toList());
    }

    public List<ActivityLogResponse> getRecentLogs(Long customerId) {
        return activityLogRepository.findRecentByCustomerId(customerId).stream()
                .map(this::mapToResponse)
                .collect(Collectors.toList());
    }

    private ActivityLogResponse mapToResponse(ActivityLog log) {
        return ActivityLogResponse.builder()
                .id(log.getId())
                .customerId(log.getCustomer().getId())
                .logDate(log.getLogDate())
                .weightKg(log.getWeightKg())
                .bmi(log.getBmi())
                .caloriesConsumed(log.getCaloriesConsumed())
                .caloriesBurned(log.getCaloriesBurned())
                .steps(log.getSteps())
                .waterMl(log.getWaterMl())
                .notes(log.getNotes())
                .createdAt(log.getCreatedAt())
                .build();
    }
}

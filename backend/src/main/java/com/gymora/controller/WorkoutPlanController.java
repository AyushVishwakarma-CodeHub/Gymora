package com.gymora.controller;

import com.gymora.model.dto.request.WorkoutPlanRequest;
import com.gymora.model.dto.response.ApiResponse;
import com.gymora.model.dto.response.WorkoutPlanResponse;
import com.gymora.service.WorkoutPlanService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/workout-plans")
@RequiredArgsConstructor
@Tag(name = "Workout Plans", description = "Workout plan management endpoints")
public class WorkoutPlanController {

    private final WorkoutPlanService workoutPlanService;

    @PostMapping
    @PreAuthorize("hasRole('TRAINER')")
    @Operation(summary = "Create workout plan")
    public ResponseEntity<ApiResponse<WorkoutPlanResponse>> createPlan(
            @Valid @RequestBody WorkoutPlanRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.success("Workout plan created",
                        workoutPlanService.createPlan(request)));
    }

    @GetMapping("/{id}")
    @Operation(summary = "Get workout plan by ID")
    public ResponseEntity<ApiResponse<WorkoutPlanResponse>> getPlanById(@PathVariable Long id) {
        return ResponseEntity.ok(ApiResponse.success(workoutPlanService.getPlanById(id)));
    }

    @GetMapping("/customer/{customerId}")
    @Operation(summary = "Get customer workout plans")
    public ResponseEntity<ApiResponse<List<WorkoutPlanResponse>>> getCustomerPlans(
            @PathVariable Long customerId) {
        return ResponseEntity.ok(ApiResponse.success(workoutPlanService.getCustomerPlans(customerId)));
    }

    @GetMapping("/customer/{customerId}/active")
    @Operation(summary = "Get active workout plans")
    public ResponseEntity<ApiResponse<List<WorkoutPlanResponse>>> getActiveCustomerPlans(
            @PathVariable Long customerId) {
        return ResponseEntity.ok(ApiResponse.success(
                workoutPlanService.getActiveCustomerPlans(customerId)));
    }

    @PutMapping("/{id}")
    @PreAuthorize("hasRole('TRAINER')")
    @Operation(summary = "Update workout plan")
    public ResponseEntity<ApiResponse<WorkoutPlanResponse>> updatePlan(
            @PathVariable Long id, @RequestBody WorkoutPlanRequest request) {
        return ResponseEntity.ok(ApiResponse.success("Plan updated",
                workoutPlanService.updatePlan(id, request)));
    }

    @DeleteMapping("/{id}")
    @PreAuthorize("hasRole('TRAINER')")
    @Operation(summary = "Delete workout plan (soft delete)")
    public ResponseEntity<ApiResponse<Void>> deletePlan(@PathVariable Long id) {
        workoutPlanService.deletePlan(id);
        return ResponseEntity.ok(ApiResponse.success("Plan deleted", null));
    }
}
